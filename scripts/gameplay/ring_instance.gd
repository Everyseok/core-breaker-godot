extends Node2D
# RingInstance — continuous segmented radial wall; shrinks toward core each frame.
# Bricks are rotated tangentially so the wide face tiles the circumference.
# As radius decreases, the wall compacts to fewer active segments so overlap does not accumulate.

const BRICK_SCENE := preload("res://scenes/gameplay/brick_instance.tscn")
const BrickRulesRef := preload("res://scripts/domain/bricks/brick_rules.gd")
const RingSpawnPlannerRef := preload("res://scripts/application/rings/ring_spawn_planner.gd")
const CombatProcResolverRef := preload("res://scripts/application/combat/combat_proc_resolver.gd")
const WeaponChoiceRulesRef := preload("res://scripts/domain/combat/weapon_choice_rules.gd")
const ANGULAR_SPEED := 0.45

signal brick_destroyed(brick_type: int)

var radius: float = 280.0
var shrink_speed: float = 30.0
var brick_count: int = 63
var brick_type: int = 0
var segment_size: float = BrickRulesRef.SEGMENT_SIZE
var wall_group_id: int = -1
var wall_layer_index: int = 0
var wall_layer_count: int = 1

var _bricks: Array = []
var _angles: Array = []
var _segments: Array = []
var _rotation_offset: float = 0.0


func setup(
	p_radius: float,
	p_speed: float,
	p_count: int,
	p_type: int,
	p_segment_size: float = BrickRulesRef.SEGMENT_SIZE,
	p_wall_group_id: int = -1,
	p_wall_layer_index: int = 0,
	p_wall_layer_count: int = 1
) -> void:
	radius = p_radius
	shrink_speed = p_speed
	brick_count = p_count
	brick_type = p_type
	segment_size = p_segment_size
	wall_group_id = p_wall_group_id
	wall_layer_index = p_wall_layer_index
	wall_layer_count = p_wall_layer_count


func _ready() -> void:
	DangerManager.register_ring(self)
	_segments = _build_initial_segments(brick_count, brick_type)
	_angles = _build_initial_angles(_segments.size())
	_rebuild_bricks()


func _exit_tree() -> void:
	DangerManager.unregister_ring(self)


func _process(delta: float) -> void:
	if not GameState.is_playing:
		return
	radius -= shrink_speed * delta
	_rotation_offset = fposmod(_rotation_offset + (ANGULAR_SPEED * delta), TAU)
	var target_count: int = RingSpawnPlannerRef.segment_count_for_radius(radius, segment_size)
	if target_count < _segments.size():
		_retile_segments(target_count)
	_update_brick_transforms()


func get_radius() -> float:
	return radius


func get_wall_group_id() -> int:
	return wall_group_id


func get_wall_layer_index() -> int:
	return wall_layer_index


func get_wall_layer_count() -> int:
	return wall_layer_count


func get_segment_hit_key(segment_index: int) -> String:
	return _target_key(segment_index)


func segment_index_for_angle(angle: float) -> int:
	if _segments.is_empty():
		return -1
	var normalized_angle: float = fposmod(angle - _rotation_offset, TAU)
	var raw_index: int = int(round((normalized_angle / TAU) * float(_segments.size())))
	return wrapi(raw_index, 0, _segments.size())


func _build_initial_angles(count: int) -> Array:
	var angles: Array = []
	for i in range(count):
		angles.append((TAU * float(i)) / float(count))
	return angles


func _build_initial_segments(count: int, segment_brick_type: int) -> Array:
	var segments: Array = []
	var max_hp: int = BrickRulesRef.hp_for_type(segment_brick_type)
	for _i in range(count):
		segments.append({
			"alive": true,
			"brick_type": segment_brick_type,
			"hp": max_hp,
			"max_hp": max_hp,
		})
	return segments


func _rebuild_bricks() -> void:
	for brick in _bricks:
		if is_instance_valid(brick):
			if brick.get_parent() == self:
				remove_child(brick)
			brick.queue_free()

	_bricks.clear()
	# _angles is managed by _ready/_build_initial_angles and _retile_segments.
	# Do NOT recompute here; preserving _angles across rebuilds prevents
	# the angle-jump visual jitter that occurred when segment count changed.
	# Safety fallback: if somehow _angles is mismatched, reinitialize uniformly.
	var segment_count: int = _segments.size()
	if _angles.size() != segment_count:
		_angles.clear()
		for i in range(segment_count):
			_angles.append((TAU * float(i)) / float(segment_count))

	for i in range(segment_count):
		var segment: Dictionary = _segments[i]
		if not bool(segment["alive"]):
			_bricks.append(null)
			continue

		var brick = BRICK_SCENE.instantiate()
		brick.setup(
			int(segment["brick_type"]),
			int(segment["hp"]),
			int(segment["max_hp"])
		)
		brick.set_segment_context(self, i)
		brick.destroyed.connect(_on_brick_destroyed.bind(i))
		add_child(brick)
		_bricks.append(brick)

	_update_brick_transforms()


func _update_brick_transforms() -> void:
	for i in range(_bricks.size()):
		var brick = _bricks[i]
		if not is_instance_valid(brick):
			continue
		var angle: float = fposmod(float(_angles[i]) + _rotation_offset, TAU)
		brick.position = Vector2(cos(angle), sin(angle)) * radius
		brick.rotation = angle + PI / 2.0


func _snapshot_segments() -> Array:
	var snapshot: Array = []
	for i in range(_segments.size()):
		var segment: Dictionary = _segments[i]
		if not bool(segment["alive"]):
			snapshot.append(segment.duplicate(true))
			continue

		var brick = _bricks[i]
		if is_instance_valid(brick):
			snapshot.append({
				"alive": true,
				"brick_type": int(brick.brick_type),
				"hp": int(brick.hp),
				"max_hp": int(brick.max_hp),
			})
		else:
			snapshot.append(segment.duplicate(true))
	return snapshot


func _retile_segments(target_count: int) -> void:
	if target_count >= _segments.size():
		return

	var source_segments: Array = _snapshot_segments()
	var source_count: int = source_segments.size()
	var buckets: Array = []
	buckets.resize(target_count)
	for i in range(target_count):
		buckets[i] = []

	for old_index in range(source_count):
		var bucket_index: int = mini(
			int(floor(float(old_index) * float(target_count) / float(source_count))),
			target_count - 1
		)
		buckets[bucket_index].append(source_segments[old_index])

	# Compute new base angles from old _angles BEFORE rebuilding bricks.
	# Each new bucket j inherits the average base angle of its source old segments,
	# preserving visual phase continuity and eliminating the compaction jump/jitter.
	# Using ceili() to determine exact bucket boundaries consistent with floor() assignment above.
	var next_angles: Array = []
	for j in range(target_count):
		var old_first: int = clampi(
			ceili(float(j) * float(source_count) / float(target_count)),
			0, source_count - 1
		)
		var old_last: int = mini(
			ceili(float(j + 1) * float(source_count) / float(target_count)) - 1,
			source_count - 1
		)
		var angle_sum: float = 0.0
		var angle_count: int = 0
		for old_i in range(old_first, old_last + 1):
			if old_i < _angles.size():
				angle_sum += _angles[old_i]
				angle_count += 1
		if angle_count > 0:
			next_angles.append(angle_sum / float(angle_count))
		else:
			next_angles.append(float(j) * TAU / float(target_count))

	var next_segments: Array = []
	for bucket in buckets:
		next_segments.append(_merge_bucket(bucket))

	_segments = next_segments
	_angles = next_angles
	brick_count = _segments.size()
	_rebuild_bricks()
	_cleanup_if_empty()


func _merge_bucket(bucket: Array) -> Dictionary:
	var default_max_hp: int = BrickRulesRef.hp_for_type(brick_type)
	var merged: Dictionary = {
		"alive": false,
		"brick_type": brick_type,
		"hp": 0,
		"max_hp": default_max_hp,
	}

	var chosen_type: int = brick_type
	var chosen_hp: int = 0
	var chosen_max_hp: int = default_max_hp

	for segment_variant in bucket:
		var segment: Dictionary = segment_variant
		if not bool(segment["alive"]):
			continue
		if chosen_hp == 0:
			chosen_type = int(segment["brick_type"])
		chosen_max_hp = maxi(chosen_max_hp, int(segment["max_hp"]))
		chosen_hp = maxi(chosen_hp, int(segment["hp"]))

	if chosen_hp > 0:
		merged["alive"] = true
		merged["brick_type"] = chosen_type
		merged["hp"] = clampi(chosen_hp, 1, chosen_max_hp)
		merged["max_hp"] = chosen_max_hp

	return merged


func _on_brick_destroyed(destroyed_brick_type: int, segment_index: int) -> void:
	if segment_index < 0 or segment_index >= _segments.size():
		return
	var segment: Dictionary = _segments[segment_index]
	if not bool(segment["alive"]):
		return
	_request_brick_break_effect(_segment_world_position(segment_index), destroyed_brick_type)
	segment["alive"] = false
	segment["hp"] = 0
	_segments[segment_index] = segment
	_bricks[segment_index] = null
	brick_destroyed.emit(destroyed_brick_type)
	_cleanup_if_empty()


func apply_projectile_hit(segment_index: int, damage: int, spread_radius: int, source_tier: int = -1) -> void:
	if damage <= 0 or _segments.is_empty():
		return
	var target_indices: Array = _collect_target_indices(segment_index, spread_radius)
	for target_variant in target_indices:
		_damage_segment(int(target_variant), damage, source_tier)
	_apply_active_weapon_choice_for_hit(segment_index, damage, source_tier, target_indices)
	_cleanup_if_empty()


func apply_electric_hit(segment_index: int, damage: int, source_tier: int = -1) -> void:
	if damage <= 0 or _segments.is_empty():
		return

	var sibling_ring = _find_adjacent_layer_ring()
	var sibling_center_index: int = -1
	if sibling_ring != null and is_instance_valid(sibling_ring):
		sibling_center_index = sibling_ring.segment_index_for_angle(_angle_for_segment(segment_index))

	var used_targets: Dictionary = {}
	var hit_plan: Array = [
		{
			"preferred_ring": self,
			"preferred_center": segment_index,
			"fallback_ring": sibling_ring,
			"fallback_center": sibling_center_index,
			"offset": 0,
		},
		{
			"preferred_ring": self,
			"preferred_center": segment_index,
			"fallback_ring": sibling_ring,
			"fallback_center": sibling_center_index,
			"offset": -1,
		},
		{
			"preferred_ring": self,
			"preferred_center": segment_index,
			"fallback_ring": sibling_ring,
			"fallback_center": sibling_center_index,
			"offset": 1,
		},
		{
			"preferred_ring": sibling_ring,
			"preferred_center": sibling_center_index,
			"fallback_ring": self,
			"fallback_center": segment_index,
			"offset": 0,
		},
		{
			"preferred_ring": sibling_ring,
			"preferred_center": sibling_center_index,
			"fallback_ring": self,
			"fallback_center": segment_index,
			"offset": -1,
		},
		{
			"preferred_ring": sibling_ring,
			"preferred_center": sibling_center_index,
			"fallback_ring": self,
			"fallback_center": segment_index,
			"offset": 1,
		},
	]

	for plan_variant in hit_plan:
		var plan: Dictionary = plan_variant
		var target_info: Dictionary = _select_electric_target(
			plan.get("preferred_ring"),
			int(plan.get("preferred_center", -1)),
			int(plan.get("offset", 0)),
			plan.get("fallback_ring"),
			int(plan.get("fallback_center", -1)),
			used_targets
		)
		if target_info.is_empty():
			continue
		var target_ring = target_info.get("ring")
		var target_index: int = int(target_info.get("index", -1))
		if target_ring != null and is_instance_valid(target_ring) and target_index >= 0:
			target_ring._damage_segment(target_index, damage, source_tier)
			used_targets[target_ring._target_key(target_index)] = true

	_apply_active_weapon_choice_for_hit(segment_index, damage, source_tier, _collect_target_indices(segment_index, 1))
	_cleanup_if_empty()
	if sibling_ring != null and is_instance_valid(sibling_ring):
		sibling_ring._cleanup_if_empty()


func apply_piercing_spear_hit(segment_index: int, damage: int, source_tier: int = -1) -> void:
	if damage <= 0 or _segments.is_empty():
		return
	_damage_segment(segment_index, damage, source_tier)
	_apply_active_weapon_choice_for_hit(segment_index, damage, source_tier, [segment_index])
	_cleanup_if_empty()


func apply_terminal_explosion(segment_index: int, damage: int, same_layer_radius: int = 2, source_tier: int = -1) -> void:
	if damage <= 0 or _segments.is_empty():
		return

	var angle: float = _angle_for_segment(segment_index)
	var unique_targets: Dictionary = {}
	var same_layer_targets: Array = _collect_target_indices(segment_index, same_layer_radius)
	for target_variant in same_layer_targets:
		var target_index: int = int(target_variant)
		unique_targets[_target_key(target_index)] = {
			"ring": self,
			"index": target_index,
		}

	var outer_ring = _find_outer_layer_ring()
	if outer_ring != null and is_instance_valid(outer_ring):
		var outer_index: int = outer_ring.segment_index_for_angle(angle)
		if outer_index >= 0:
			unique_targets[outer_ring.get_segment_hit_key(outer_index)] = {
				"ring": outer_ring,
				"index": outer_index,
			}

	var inner_ring = _find_inner_layer_ring()
	if inner_ring != null and is_instance_valid(inner_ring):
		var inner_index: int = inner_ring.segment_index_for_angle(angle)
		if inner_index >= 0:
			unique_targets[inner_ring.get_segment_hit_key(inner_index)] = {
				"ring": inner_ring,
				"index": inner_index,
			}

	for target_variant in unique_targets.values():
		var target_info: Dictionary = target_variant
		var target_ring = target_info.get("ring")
		var target_index: int = int(target_info.get("index", -1))
		if target_ring != null and is_instance_valid(target_ring) and target_index >= 0:
			target_ring._damage_segment(target_index, damage, source_tier)

	_cleanup_if_empty()
	if outer_ring != null and is_instance_valid(outer_ring):
		outer_ring._cleanup_if_empty()
	if inner_ring != null and is_instance_valid(inner_ring):
		inner_ring._cleanup_if_empty()


func _collect_target_indices(center_index: int, spread_radius: int) -> Array:
	return CombatProcResolverRef.collect_target_indices(center_index, spread_radius, _segments.size())


func _damage_segment(segment_index: int, damage: int, source_tier: int = -1) -> void:
	if segment_index < 0 or segment_index >= _segments.size():
		return
	var segment: Dictionary = _segments[segment_index]
	if not bool(segment["alive"]):
		return

	var world_position := _segment_world_position(segment_index)
	var next_hp: int = int(segment["hp"]) - damage
	_request_damage_number(world_position, damage, next_hp <= 0, source_tier)
	if next_hp <= 0:
		AudioEvents.brick_break()
		_request_brick_break_effect(world_position, int(segment["brick_type"]))
		_remove_brick(segment_index)
		segment["alive"] = false
		segment["hp"] = 0
		_segments[segment_index] = segment
		brick_destroyed.emit(int(segment["brick_type"]))
		return

	segment["hp"] = next_hp
	_segments[segment_index] = segment
	var brick = _bricks[segment_index]
	if is_instance_valid(brick):
		brick.sync_state(
			int(segment["brick_type"]),
			int(segment["hp"]),
			int(segment["max_hp"])
		)


func _apply_active_weapon_choice_for_hit(
	origin_segment_index: int,
	damage: int,
	source_tier: int,
	blocked_indices: Array
) -> void:
	match GameState.active_weapon_choice_id:
		WeaponChoiceRulesRef.CHAIN_LIGHTNING:
			if GameState.roll_chain_lightning_trigger():
				_apply_chain_lightning_modifier(origin_segment_index, damage, source_tier, blocked_indices)
		WeaponChoiceRulesRef.METEOR_CANNON:
			if GameState.consume_meteor_trigger():
				_apply_meteor_cannon_modifier(origin_segment_index, damage, source_tier)
		_:
			return


func _apply_chain_lightning_modifier(
	origin_segment_index: int,
	damage: int,
	source_tier: int,
	blocked_indices: Array
) -> void:
	var origin_world := _segment_world_position(origin_segment_index)
	var chain_result: Dictionary = CombatProcResolverRef.resolve_chain_lightning(
		origin_segment_index,
		blocked_indices,
		_segments,
		_angle_for_segment(origin_segment_index)
	)
	if bool(chain_result.get("has_damage_target", false)):
		var target_index: int = int(chain_result.get("target_index", -1))
		var target_world := _segment_world_position(target_index)
		_request_weapon_choice_effect(String(chain_result.get("effect_id", "chain_lightning")), origin_world, target_world, source_tier)
		_play_choice_proc_audio(WeaponChoiceRulesRef.CHAIN_LIGHTNING)
		_damage_segment(target_index, damage, source_tier)
		return

	var fallback_offset: Vector2 = chain_result.get("fallback_offset", Vector2.RIGHT * 18.0)
	var fallback_world: Vector2 = origin_world + fallback_offset
	_request_weapon_choice_effect(String(chain_result.get("effect_id", "chain_lightning")), origin_world, fallback_world, source_tier)
	_play_choice_proc_audio(WeaponChoiceRulesRef.CHAIN_LIGHTNING)


func _apply_meteor_cannon_modifier(origin_segment_index: int, damage: int, source_tier: int) -> void:
	var origin_world := _segment_world_position(origin_segment_index)
	var meteor_result: Dictionary = CombatProcResolverRef.resolve_meteor_cannon(origin_segment_index, _segments.size())
	_request_weapon_choice_effect(String(meteor_result.get("effect_id", "meteor_cannon")), origin_world, origin_world, source_tier)
	_play_choice_proc_audio(WeaponChoiceRulesRef.METEOR_CANNON)
	for target_variant in meteor_result.get("target_indices", []):
		_damage_segment(int(target_variant), damage, source_tier)


func _find_adjacent_layer_ring():
	var inner_ring = _find_inner_layer_ring()
	if inner_ring != null and is_instance_valid(inner_ring):
		return inner_ring
	return _find_outer_layer_ring()


func _find_inner_layer_ring():
	return _find_layer_ring(wall_layer_index + 1)


func _find_outer_layer_ring():
	return _find_layer_ring(wall_layer_index - 1)


func _find_layer_ring(target_layer_index: int):
	if wall_group_id < 0 or wall_layer_count <= 1 or get_parent() == null:
		return null
	if target_layer_index < 0 or target_layer_index >= wall_layer_count:
		return null
	for sibling in get_parent().get_children():
		if sibling == self or not is_instance_valid(sibling):
			continue
		if not sibling.has_method("get_wall_group_id") or not sibling.has_method("get_wall_layer_index"):
			continue
		if int(sibling.call("get_wall_group_id")) != wall_group_id:
			continue
		if int(sibling.call("get_wall_layer_index")) == target_layer_index:
			return sibling
	return null


func _angle_for_segment(segment_index: int) -> float:
	if segment_index < 0 or segment_index >= _angles.size():
		return 0.0
	return fposmod(float(_angles[segment_index]) + _rotation_offset, TAU)


func _select_electric_target(
	preferred_ring,
	preferred_center: int,
	preferred_offset: int,
	fallback_ring,
	fallback_center: int,
	used_targets: Dictionary
) -> Dictionary:
	var target_info: Dictionary = _try_select_target(preferred_ring, preferred_center, preferred_offset, used_targets, false)
	if not target_info.is_empty():
		return target_info
	target_info = _try_select_target(fallback_ring, fallback_center, preferred_offset, used_targets, false)
	if not target_info.is_empty():
		return target_info
	target_info = _try_select_target(preferred_ring, preferred_center, preferred_offset, used_targets, true)
	if not target_info.is_empty():
		return target_info
	return _try_select_target(fallback_ring, fallback_center, preferred_offset, used_targets, true)


func _try_select_target(
	target_ring,
	center_index: int,
	preferred_offset: int,
	used_targets: Dictionary,
	allow_repeat: bool
) -> Dictionary:
	if target_ring == null or not is_instance_valid(target_ring) or center_index < 0:
		return {}
	var target_index: int = target_ring._find_best_target_index(center_index, preferred_offset, used_targets, allow_repeat)
	if target_index < 0:
		return {}
	return {
		"ring": target_ring,
		"index": target_index,
	}


func _find_best_target_index(
	center_index: int,
	preferred_offset: int,
	used_targets: Dictionary,
	allow_repeat: bool
) -> int:
	if _segments.is_empty():
		return -1

	var seen_indices: Dictionary = {}
	for offset_variant in _ordered_offsets_for_reallocation(preferred_offset):
		var offset: int = int(offset_variant)
		var target_index: int = wrapi(center_index + offset, 0, _segments.size())
		if seen_indices.has(target_index):
			continue
		seen_indices[target_index] = true

		var segment: Dictionary = _segments[target_index]
		if not bool(segment["alive"]):
			continue

		var target_key: String = _target_key(target_index)
		if not allow_repeat and used_targets.has(target_key):
			continue
		return target_index

	return -1


func _ordered_offsets_for_reallocation(preferred_offset: int) -> Array:
	var ordered_offsets: Array = []
	var segment_count: int = _segments.size()
	if segment_count <= 0:
		return ordered_offsets

	if preferred_offset == 0:
		ordered_offsets.append(0)
		for distance in range(1, segment_count):
			ordered_offsets.append(-distance)
			ordered_offsets.append(distance)
		return ordered_offsets

	var direction: int = 1 if preferred_offset > 0 else -1
	var start_distance: int = maxi(abs(preferred_offset), 1)
	for distance in range(start_distance, segment_count):
		ordered_offsets.append(direction * distance)
	ordered_offsets.append(0)
	for distance in range(1, segment_count):
		ordered_offsets.append(-direction * distance)
	return ordered_offsets


func _target_key(segment_index: int) -> String:
	return "%s:%d" % [str(get_instance_id()), segment_index]


func _segment_world_position(segment_index: int) -> Vector2:
	var brick = _bricks[segment_index]
	if is_instance_valid(brick):
		return brick.global_position
	var angle := _angle_for_segment(segment_index)
	return to_global(Vector2(cos(angle), sin(angle)) * radius)


func _request_damage_number(world_position: Vector2, amount: int, destroyed: bool, source_tier: int) -> void:
	var roots := get_tree().get_nodes_in_group("game_root")
	if roots.is_empty():
		return
	var root := roots[0]
	if root != null and is_instance_valid(root) and root.has_method("spawn_damage_number"):
		root.call_deferred("spawn_damage_number", world_position, amount, destroyed, source_tier)


func _request_brick_break_effect(world_position: Vector2, destroyed_brick_type: int) -> void:
	var roots := get_tree().get_nodes_in_group("game_root")
	if roots.is_empty():
		return
	var root := roots[0]
	if root != null and is_instance_valid(root) and root.has_method("spawn_brick_break_effect"):
		root.call_deferred("spawn_brick_break_effect", world_position, destroyed_brick_type)


func _request_weapon_choice_effect(
	effect_id: String,
	world_position: Vector2,
	world_target: Vector2,
	source_tier: int
) -> void:
	var roots := get_tree().get_nodes_in_group("game_root")
	if roots.is_empty():
		return
	var root := roots[0]
	if root != null and is_instance_valid(root) and root.has_method("spawn_weapon_choice_effect"):
		root.call_deferred("spawn_weapon_choice_effect", effect_id, world_position, world_target, source_tier)


func _play_choice_proc_audio(choice_id: String) -> void:
	AudioEvents.weapon_proc(StringName(choice_id))


func _remove_brick(segment_index: int) -> void:
	var brick = _bricks[segment_index]
	if is_instance_valid(brick):
		if brick.get_parent() == self:
			remove_child(brick)
		brick.queue_free()
	_bricks[segment_index] = null


func _cleanup_if_empty() -> void:
	for segment_variant in _segments:
		var segment: Dictionary = segment_variant
		if bool(segment["alive"]):
			return
	queue_free()
