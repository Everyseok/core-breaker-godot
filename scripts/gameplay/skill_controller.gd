extends Node2D
# SkillController — automatic runtime skill firing only.
# This node must not own UI, permanent visuals, or audio assets.
# Phase 5B adds code-native flight and impact VFX, but this node still owns no audio/assets.

const SkillRulesRef := preload("res://scripts/domain/skills/skill_rules.gd")
const SkillProjectileVisualFactoryRef := preload("res://scripts/visual/skill_projectile_visual_factory.gd")

var _core: Node2D
var _projectile_layer: Node2D
var _vfx_layer: Node2D
var _elapsed_since_fire: float = 0.0


func set_core(core: Node2D) -> void:
	_core = core


func set_projectile_layer(layer: Node2D) -> void:
	_projectile_layer = layer


func set_vfx_layer(layer: Node2D) -> void:
	_vfx_layer = layer


func _process(delta: float) -> void:
	if not _can_tick_skill():
		_elapsed_since_fire = 0.0
		return

	var skill_manager = _get_skill_manager()
	if skill_manager == null:
		return

	if not skill_manager.has_method("get_selected_skill_id"):
		return

	var skill_id := String(skill_manager.call("get_selected_skill_id"))
	if not SkillRulesRef.is_valid_skill_id(skill_id):
		return

	var interval := SkillRulesRef.interval_for_id(skill_id)
	_elapsed_since_fire += delta
	if _elapsed_since_fire < interval:
		return

	var targets := _select_targets(skill_id)
	if targets.is_empty():
		return

	_elapsed_since_fire = 0.0
	_fire_skill(skill_id, targets)


func _can_tick_skill() -> bool:
	if not GameState.is_playing:
		return false
	if GameState.revive_prompt_pending:
		return false
	if get_tree().paused:
		return false
	if GameState.has_method("is_weapon_choice_panel_open") and GameState.is_weapon_choice_panel_open():
		return false

	var skill_manager = _get_skill_manager()
	if skill_manager != null and skill_manager.has_method("is_skill_panel_open"):
		if bool(skill_manager.call("is_skill_panel_open")):
			return false

	var buff_manager = get_node_or_null("/root/BuffManager")
	if buff_manager != null and buff_manager.has_method("is_roll_in_progress"):
		if bool(buff_manager.call("is_roll_in_progress")):
			return false

	return true


func _get_skill_manager():
	return get_node_or_null("/root/SkillManager")


func _get_skill_origin() -> Vector2:
	if _core != null and is_instance_valid(_core):
		if _core.has_method("get_launch_origin_global"):
			var origin_variant: Variant = _core.call("get_launch_origin_global")
			if origin_variant is Vector2:
				return origin_variant
		return _core.global_position
	return global_position


func _get_skill_vfx_layer() -> Node2D:
	if _projectile_layer != null and is_instance_valid(_projectile_layer):
		return _projectile_layer
	if _vfx_layer != null and is_instance_valid(_vfx_layer):
		return _vfx_layer
	return null


func _target_world_position(target: Dictionary, fallback: Vector2) -> Vector2:
	var world_variant: Variant = target.get("world_position", fallback)
	if world_variant is Vector2:
		return world_variant

	var ring = target.get("ring")
	var segment_index := int(target.get("segment_index", -1))
	if ring != null and is_instance_valid(ring):
		if ring.has_method("get_segment_world_position_safe"):
			var safe_position: Variant = ring.call("get_segment_world_position_safe", segment_index)
			if safe_position is Vector2:
				return safe_position

	return fallback


func _select_targets(skill_id: String) -> Array:
	var all_targets := _collect_all_skill_targets()
	if all_targets.is_empty():
		return []

	all_targets.sort_custom(_sort_targets_by_danger)

	if skill_id == SkillRulesRef.MACHINE_GUN:
		var max_targets := mini(SkillRulesRef.max_targets_for_id(skill_id), all_targets.size())
		var selected: Array = []
		for i in range(max_targets):
			selected.append(all_targets[i])
		return selected

	return [all_targets[0]]


func _collect_all_skill_targets() -> Array:
	var result: Array = []

	if not DangerManager.has_method("get_tracked_rings_snapshot"):
		return result

	for ring_variant in DangerManager.get_tracked_rings_snapshot():
		var ring = ring_variant
		if ring == null or not is_instance_valid(ring):
			continue
		if not ring.has_method("get_skill_target_snapshot"):
			continue

		var ring_targets: Array = ring.call("get_skill_target_snapshot")
		for target_variant in ring_targets:
			if target_variant is Dictionary:
				result.append(target_variant)

	return result


func _sort_targets_by_danger(a: Dictionary, b: Dictionary) -> bool:
	# Smaller radius means the wall is closer to the core, therefore more dangerous.
	return float(a.get("radius", INF)) < float(b.get("radius", INF))


func _fire_skill(skill_id: String, targets: Array) -> void:
	match skill_id:
		SkillRulesRef.STONE_THROW, SkillRulesRef.METEOR:
			_fire_area_skill(skill_id, targets[0])
		SkillRulesRef.MACHINE_GUN:
			_fire_machine_gun(skill_id, targets)
		_:
			return


func _fire_area_skill(skill_id: String, target: Dictionary) -> void:
	var ring = target.get("ring")
	if ring == null or not is_instance_valid(ring):
		return
	if not ring.has_method("apply_skill_hit"):
		return

	var segment_index := int(target.get("segment_index", -1))
	if segment_index < 0:
		return

	var damage := SkillRulesRef.damage_for_id(skill_id)
	var spread_radius := SkillRulesRef.spread_radius_for_id(skill_id)
	var origin := _get_skill_origin()
	var target_position := _target_world_position(target, origin)
	var flight_time := SkillRulesRef.flight_time_for_id(skill_id)
	var layer := _get_skill_vfx_layer()

	AudioEvents.passive_launch(StringName(skill_id))

	var impact_callback := func() -> void:
		AudioEvents.passive_impact(StringName(skill_id))
		if ring != null and is_instance_valid(ring) and ring.has_method("apply_skill_hit"):
			ring.call("apply_skill_hit", segment_index, damage, spread_radius, skill_id)

	SkillProjectileVisualFactoryRef.spawn_area_skill_vfx(
		layer,
		skill_id,
		origin,
		target_position,
		flight_time,
		impact_callback
	)


func _fire_machine_gun(skill_id: String, targets: Array) -> void:
	var grouped_by_ring: Dictionary = {}
	var origin := _get_skill_origin()
	var layer := _get_skill_vfx_layer()
	var tracer_index := 0
	AudioEvents.passive_launch(StringName(skill_id))

	for target_variant in targets:
		if not (target_variant is Dictionary):
			continue

		var target: Dictionary = target_variant
		var ring = target.get("ring")
		if ring == null or not is_instance_valid(ring):
			continue

		var segment_index := int(target.get("segment_index", -1))
		if segment_index < 0:
			continue

		var target_position := _target_world_position(target, origin)
		SkillProjectileVisualFactoryRef.spawn_machine_gun_tracer(layer, origin, target_position, tracer_index)
		tracer_index += 1

		var ring_key := str(ring.get_instance_id())
		if not grouped_by_ring.has(ring_key):
			grouped_by_ring[ring_key] = {
				"ring": ring,
				"indices": [],
			}

		grouped_by_ring[ring_key]["indices"].append(segment_index)

	for group_variant in grouped_by_ring.values():
		var group: Dictionary = group_variant
		var ring = group.get("ring")
		if ring == null or not is_instance_valid(ring):
			continue
		if not ring.has_method("apply_skill_multi_hit"):
			continue

		var indices: Array = group.get("indices", [])
		if indices.is_empty():
			continue

		ring.call("apply_skill_multi_hit", indices, SkillRulesRef.damage_for_id(skill_id), skill_id)

	if tracer_index > 0:
		AudioEvents.passive_impact(StringName(skill_id))


func get_debug_selected_skill_id() -> String:
	var skill_manager = _get_skill_manager()
	if skill_manager == null or not skill_manager.has_method("get_selected_skill_id"):
		return SkillRulesRef.NONE
	return String(skill_manager.call("get_selected_skill_id"))


func get_debug_elapsed_since_fire() -> float:
	return _elapsed_since_fire
