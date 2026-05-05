extends Node2D
# CombatProcEffect — reusable proc VFX for chain/prism/meteor/cannon moments.
# Visual-only; never changes HP, score, K, or progression.

const WeaponProfileRef := preload("res://scripts/visual/weapon_profile.gd")

var effect_id: String = ""
var target_world: Vector2 = Vector2.ZERO
var source_tier: int = -1
var _rng := RandomNumberGenerator.new()


func configure(next_effect_id: String, next_target_world: Vector2, next_source_tier: int = -1) -> void:
	effect_id = next_effect_id
	target_world = next_target_world
	source_tier = next_source_tier
	if is_node_ready():
		_rebuild()


func _ready() -> void:
	z_index = 58
	_rng.randomize()
	_rebuild()
	var cleanup := create_tween()
	cleanup.tween_interval(0.44)
	cleanup.finished.connect(queue_free)


func _rebuild() -> void:
	for child in get_children():
		child.queue_free()
	match effect_id:
		"chain_lightning":
			_build_chain_lightning()
		"prism_lance":
			_build_prism_lance()
		"meteor_cannon":
			_build_explosion_burst(1.18, true)
		"cannon_impact":
			_build_explosion_burst(0.94, false)


func _build_chain_lightning() -> void:
	var local_target := to_local(target_world)
	var profile := _profile_for_effect(effect_id)
	var arc_color := Color(0.72, 0.95, 1.0, 0.98)
	var core_color := Color(0.98, 1.0, 1.0, 0.98)
	var accent_color := Color(profile.get("accent_color", Color(0.40, 0.88, 1.0, 0.92)))
	var branch_color := Color(profile.get("primary_color", Color(1.0, 0.84, 0.20, 0.78)))

	_spawn_chain_arc(local_target, accent_color, 11.0, 0.30, 18.0)
	_spawn_chain_arc(local_target, arc_color, 6.6, 0.28, 14.0)
	_spawn_chain_arc(local_target + Vector2(3.0, -2.0), core_color, 3.8, 0.24, 10.0)
	_spawn_chain_arc(local_target + Vector2(-3.0, 2.0), branch_color, 3.2, 0.22, 10.0)
	_spawn_flash(Vector2(28.0, 28.0), core_color, 0.22, 1.92)
	_spawn_flash_at(local_target, Vector2(28.0, 28.0), Color(0.84, 0.98, 1.0, 0.94), 0.24, 1.92)
	_spawn_spark_cluster(Vector2.ZERO, 9, [branch_color, accent_color, arc_color, core_color], 0.26, 22.0)
	_spawn_spark_cluster(local_target, 8, [branch_color, accent_color, arc_color, core_color], 0.26, 22.0)


func _build_prism_lance() -> void:
	var local_target := to_local(target_world)
	var reach := maxf(local_target.length(), 42.0)
	var forward := local_target.normalized()
	if forward.length_squared() <= 0.001:
		forward = Vector2.UP
	var tangent := Vector2(-forward.y, forward.x)
	var profile := _profile_for_effect(effect_id)
	var cyan := Color(profile.get("secondary_color", Color(0.70, 0.96, 1.0, 0.96)))
	var violet := Color(profile.get("accent_color", Color(0.78, 0.42, 1.0, 0.84)))
	var core := Color(0.98, 0.98, 1.0, 0.94)

	_spawn_flash(Vector2(26.0, 26.0), cyan, 0.18, 1.88)
	_spawn_flash(Vector2(16.0, 16.0), violet, 0.24, 2.20)
	_spawn_energy_ray(forward * reach, core, 5.0, 0.22)
	_spawn_energy_ray((forward * reach * 0.88) + (tangent * 18.0), cyan, 3.6, 0.24)
	_spawn_energy_ray((forward * reach * 0.88) - (tangent * 18.0), violet, 3.6, 0.24)
	_spawn_glint_row(forward, tangent, reach * 0.80, 5, 0.22)


func _build_explosion_burst(scale_multiplier: float, include_smoke: bool) -> void:
	var profile := _profile_for_effect(effect_id)
	var hot := Color(1.0, 0.96, 0.90, 0.98)
	var orange := Color(profile.get("primary_color", Color(1.0, 0.54, 0.18, 0.94)))
	var ember := Color(profile.get("secondary_color", Color(1.0, 0.82, 0.42, 0.86)))
	var accent := Color(profile.get("accent_color", Color(1.0, 0.96, 0.84, 0.88)))
	var smoke := Color(0.18, 0.14, 0.18, 0.42)

	_spawn_flash(Vector2(34.0, 34.0) * scale_multiplier, hot, 0.16, 1.65)
	_spawn_flash(Vector2(48.0, 48.0) * scale_multiplier, orange, 0.24, 2.08)
	_spawn_ring(22.0 * scale_multiplier, ember, 5.0, 0.28, 1.82)
	_spawn_fragment_burst(7 if include_smoke else 5, [orange, ember, hot, accent], scale_multiplier, 0.30)
	if include_smoke:
		_spawn_smoke_puffs(4, smoke, scale_multiplier, 0.36)


func _spawn_chain_arc(local_target: Vector2, color: Color, width: float, duration: float, jitter: float) -> void:
	var glow := Line2D.new()
	glow.width = width * 1.72
	glow.default_color = Color(color.r, color.g, color.b, 0.30)
	glow.antialiased = false
	glow.begin_cap_mode = Line2D.LINE_CAP_ROUND
	glow.end_cap_mode = Line2D.LINE_CAP_ROUND
	glow.joint_mode = Line2D.LINE_JOINT_ROUND
	glow.points = _build_jagged_arc_points(local_target, jitter * 1.08)
	add_child(glow)

	var line := Line2D.new()
	line.width = width
	line.default_color = color
	line.antialiased = false
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.points = _build_jagged_arc_points(local_target, jitter)
	add_child(line)

	var tween := create_tween()
	tween.parallel().tween_property(glow, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(glow, "scale", Vector2(0.96, 0.96), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(line, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(line, "scale", Vector2(0.96, 0.96), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _spawn_energy_ray(local_target: Vector2, color: Color, width: float, duration: float) -> void:
	var line := Line2D.new()
	line.width = width
	line.default_color = color
	line.antialiased = false
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.points = PackedVector2Array([Vector2.ZERO, local_target])
	add_child(line)

	var tween := create_tween()
	tween.parallel().tween_property(line, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(line, "scale", Vector2(0.36, 0.36), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _spawn_glint_row(forward: Vector2, tangent: Vector2, reach: float, count: int, duration: float) -> void:
	for i in range(count):
		var t := float(i + 1) / float(count + 1)
		var glint := ColorRect.new()
		glint.size = Vector2(5.0, 5.0)
		glint.position = (forward * reach * t) + (tangent * _rng.randf_range(-5.0, 5.0)) - Vector2(2.5, 2.5)
		glint.color = Color(0.90, 0.96, 1.0, 0.84) if i % 2 == 0 else Color(0.72, 0.48, 1.0, 0.74)
		glint.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(glint)

		var tween := create_tween()
		tween.parallel().tween_property(glint, "scale", Vector2(0.20, 0.20), duration + (t * 0.05)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(glint, "modulate:a", 0.0, duration + (t * 0.05)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _spawn_fragment_burst(count: int, palette: Array, scale_multiplier: float, duration: float) -> void:
	for _i in range(count):
		var fragment := Node2D.new()
		fragment.position = Vector2(_rng.randf_range(-4.0, 4.0), _rng.randf_range(-4.0, 4.0))
		fragment.rotation = deg_to_rad(_rng.randf_range(-40.0, 40.0))
		add_child(fragment)

		var rect := ColorRect.new()
		rect.size = Vector2(_rng.randf_range(8.0, 14.0) * scale_multiplier, _rng.randf_range(4.0, 8.0) * scale_multiplier)
		rect.position = -rect.size * 0.5
		rect.color = palette[_rng.randi_range(0, palette.size() - 1)]
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fragment.add_child(rect)

		var drift := Vector2(_rng.randf_range(-28.0, 28.0), _rng.randf_range(-26.0, 18.0)) * scale_multiplier
		var tween := create_tween()
		tween.parallel().tween_property(fragment, "position", fragment.position + drift, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(fragment, "rotation", fragment.rotation + deg_to_rad(_rng.randf_range(-80.0, 80.0)), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(fragment, "scale", Vector2(0.25, 0.25), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(rect, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _spawn_smoke_puffs(count: int, color: Color, scale_multiplier: float, duration: float) -> void:
	for _i in range(count):
		var puff := ColorRect.new()
		puff.size = Vector2(_rng.randf_range(12.0, 18.0) * scale_multiplier, _rng.randf_range(8.0, 12.0) * scale_multiplier)
		puff.position = Vector2(_rng.randf_range(-10.0, 10.0), _rng.randf_range(-6.0, 10.0)) - (puff.size * 0.5)
		puff.color = color
		puff.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(puff)

		var drift := Vector2(_rng.randf_range(-16.0, 16.0), _rng.randf_range(-24.0, -10.0)) * scale_multiplier
		var tween := create_tween()
		tween.parallel().tween_property(puff, "position", puff.position + drift, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(puff, "scale", Vector2(1.55, 1.40), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(puff, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _spawn_spark_cluster(local_origin: Vector2, count: int, palette: Array, duration: float, reach: float) -> void:
	for _i in range(count):
		var spark := ColorRect.new()
		spark.size = Vector2(_rng.randf_range(4.0, 8.0), _rng.randf_range(3.0, 6.0))
		spark.position = local_origin - (spark.size * 0.5)
		spark.color = palette[_rng.randi_range(0, palette.size() - 1)]
		spark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(spark)

		var drift := Vector2(_rng.randf_range(-reach, reach), _rng.randf_range(-reach, reach))
		var tween := create_tween()
		tween.parallel().tween_property(spark, "position", spark.position + drift, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(spark, "scale", Vector2(0.12, 0.12), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(spark, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _spawn_ring(initial_radius: float, color: Color, width: float, duration: float, scale_multiplier: float) -> void:
	var ring := Line2D.new()
	ring.width = width
	ring.antialiased = false
	ring.default_color = color
	ring.closed = true
	var points := PackedVector2Array()
	for i in range(18):
		var angle := TAU * (float(i) / 18.0)
		points.append(Vector2(cos(angle), sin(angle)) * initial_radius)
	ring.points = points
	add_child(ring)

	var tween := create_tween()
	tween.parallel().tween_property(ring, "scale", Vector2(scale_multiplier, scale_multiplier), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(ring, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _spawn_flash(size: Vector2, color: Color, duration: float, grow_scale: float) -> void:
	_spawn_flash_at(Vector2.ZERO, size, color, duration, grow_scale)


func _spawn_flash_at(local_position: Vector2, size: Vector2, color: Color, duration: float, grow_scale: float) -> void:
	var flash := ColorRect.new()
	flash.size = size
	flash.position = local_position - (size * 0.5)
	flash.color = color
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)

	var tween := create_tween()
	tween.parallel().tween_property(flash, "scale", Vector2(grow_scale, grow_scale), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(flash, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _build_jagged_arc_points(local_target: Vector2, jitter: float) -> PackedVector2Array:
	var points := PackedVector2Array([Vector2.ZERO])
	var distance := maxf(local_target.length(), 1.0)
	var direction := local_target / distance
	var tangent := Vector2(-direction.y, direction.x)
	var step_count := clampi(int(round(distance / 42.0)), 4, 8)
	for step in range(1, step_count):
		var t := float(step) / float(step_count)
		var base := local_target * t
		var offset := tangent * (_rng.randf_range(-jitter, jitter) * (1.0 - absf(0.5 - t)))
		points.append(base + offset)
	points.append(local_target)
	return points


func _profile_for_effect(effect_name: String) -> Dictionary:
	if effect_name == "cannon_impact":
		return WeaponProfileRef.resolve_profile(maxi(source_tier, 0))
	var profile := WeaponProfileRef.get_profile_by_visual_id(effect_name)
	if not profile.is_empty():
		return profile
	return WeaponProfileRef.resolve_profile(maxi(source_tier, 0))
