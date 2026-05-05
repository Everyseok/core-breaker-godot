extends Node2D
# Short-lived decorative impact burst per weapon tier.
# This script never changes score, damage, HP, or spawn rules.

const WeaponProfileRef := preload("res://scripts/visual/weapon_profile.gd")

var tier: int = 0
var direction: Vector2 = Vector2.UP
var surface_normal: Vector2 = Vector2.ZERO
var visual_style_id: String = ""
var _rng := RandomNumberGenerator.new()


func configure(hit_tier: int, travel_direction: Vector2, hit_normal: Vector2 = Vector2.ZERO, next_visual_style_id: String = "") -> void:
	tier = hit_tier
	direction = travel_direction.normalized() if travel_direction.length_squared() > 0.001 else Vector2.UP
	surface_normal = hit_normal.normalized() if hit_normal.length_squared() > 0.001 else -direction
	visual_style_id = next_visual_style_id


func _ready() -> void:
	z_index = 60
	_rng.randomize()
	_build_effect()
	var cleanup := create_tween()
	cleanup.tween_interval(0.42)
	cleanup.finished.connect(queue_free)


func _build_effect() -> void:
	match _resolved_hit_style():
		"thunder":
			_build_thunder_impact()
		"spark_lance":
			_build_lance_impact()
		"volt_storm":
			_build_storm_impact()
		"siege_cannon":
			_build_cannon_impact()
		"chain_lightning":
			_build_chain_impact()
		"prism_lance":
			_build_prism_impact()
		"meteor_cannon":
			_build_meteor_impact()
		_:
			_build_arrow_impact()


func _build_arrow_impact() -> void:
	var primary := _primary_color()
	var secondary := _secondary_color()
	var outward := _safe_outward()
	var tangent := Vector2(-outward.y, outward.x)

	_spawn_flash(Vector2(24.0, 18.0), secondary, 0.16, 1.70)
	_spawn_streak(direction * 14.0, Vector2(20.0, 5.0), secondary, 0.18, direction.angle())
	_spawn_streak(tangent * 6.0, Vector2(8.0, 6.0), primary, 0.20, tangent.angle())
	_spawn_streak(-tangent * 6.0, Vector2(8.0, 6.0), primary.lightened(0.12), 0.20, (-tangent).angle())


func _build_thunder_impact() -> void:
	var outward := _safe_outward()
	var tangent := Vector2(-outward.y, outward.x)
	var hot := Color(0.98, 1.0, 0.98, 0.98)
	var cyan := Color(0.74, 0.96, 1.0, 0.98)
	var blue := Color(0.34, 0.82, 1.0, 0.92)
	var gold := Color(1.0, 0.84, 0.18, 0.84)

	_spawn_flash(Vector2(34.0, 34.0), hot, 0.20, 1.94)
	_spawn_local_arc(Vector2(-18.0, 4.0), Vector2(18.0, -5.0), cyan, 6.6, 0.24, 12.0)
	_spawn_local_arc(Vector2(-14.0, -9.0), Vector2(15.0, 10.0), blue, 4.8, 0.22, 10.0)
	_spawn_streak(outward * 10.0, Vector2(18.0, 4.0), gold, 0.20, outward.angle())
	_spawn_spark_burst(Vector2.ZERO, 9, [gold, cyan, hot, blue], 0.24, 20.0)
	_spawn_spark_burst(tangent * 3.0, 6, [blue, cyan, hot], 0.22, 16.0)


func _build_lance_impact() -> void:
	var outward := _safe_outward()
	var tangent := Vector2(-outward.y, outward.x)
	var primary := _primary_color()
	var secondary := _secondary_color()
	var accent := _accent_color()
	var core := Color(0.96, 0.99, 1.0, 0.94)

	_spawn_flash(Vector2(26.0, 18.0), secondary, 0.18, 1.90)
	_spawn_streak(outward * 12.0, Vector2(28.0, 4.0), core, 0.20, outward.angle())
	_spawn_streak((tangent * 8.0) + (outward * 6.0), Vector2(20.0, 3.0), primary.lightened(0.10), 0.22, (outward + tangent * 0.24).angle())
	_spawn_streak((-tangent * 8.0) + (outward * 6.0), Vector2(20.0, 3.0), accent.lightened(0.28), 0.22, (outward - tangent * 0.24).angle())
	_spawn_prism_glints(outward, tangent, 5, 0.22)


func _build_storm_impact() -> void:
	var outward := _safe_outward()
	var tangent := Vector2(-outward.y, outward.x)
	var primary := _primary_color()
	var secondary := _secondary_color()
	var core := Color(0.98, 0.96, 1.0, 0.94)

	_spawn_flash(Vector2(34.0, 30.0), secondary, 0.22, 2.02)
	_spawn_ring(18.0, primary, 4.6, 0.26, 1.78)
	_spawn_local_arc(Vector2(-20.0, 2.0), Vector2(18.0, -5.0), secondary, 5.8, 0.24, 10.0)
	_spawn_local_arc(Vector2(-14.0, -11.0), Vector2(15.0, 11.0), primary.lightened(0.10), 4.6, 0.24, 10.0)
	_spawn_streak(outward * 10.0, Vector2(22.0, 4.0), core, 0.20, outward.angle())
	_spawn_spark_burst(Vector2.ZERO, 10, [primary, secondary, core], 0.24, 20.0)
	_spawn_streak(tangent * 10.0, Vector2(14.0, 3.0), secondary, 0.20, tangent.angle())
	_spawn_streak(-tangent * 10.0, Vector2(14.0, 3.0), primary, 0.20, (-tangent).angle())


func _build_cannon_impact() -> void:
	var outward := _safe_outward()
	var primary := _primary_color()
	var secondary := _secondary_color()
	var hot := Color(1.0, 0.96, 0.88, 0.98)
	var ember := Color(1.0, 0.84, 0.46, 0.90)

	_spawn_flash(Vector2(34.0, 34.0), hot, 0.18, 1.70)
	_spawn_flash(Vector2(46.0, 46.0), primary.lightened(0.10), 0.24, 2.18)
	_spawn_ring(18.0, ember, 4.8, 0.28, 1.92)
	_spawn_streak(outward * 12.0, Vector2(22.0, 5.0), secondary, 0.24, outward.angle())
	_spawn_fragment_cloud(6, [primary, secondary, ember], 0.30, 24.0)
	_spawn_smoke_puffs(3, Color(0.20, 0.14, 0.14, 0.30), 0.30)


func _build_chain_impact() -> void:
	var primary := _primary_color()
	var secondary := _secondary_color()
	var accent := _accent_color()
	_build_thunder_impact()
	_spawn_ring(15.0, accent, 4.4, 0.20, 1.52)
	_spawn_local_arc(Vector2(-20.0, 4.0), Vector2(20.0, -7.0), secondary, 5.4, 0.24, 12.0)
	_spawn_spark_burst(Vector2.ZERO, 7, [primary, accent, secondary], 0.24, 20.0)


func _build_prism_impact() -> void:
	_build_lance_impact()
	var outward := _safe_outward()
	var tangent := Vector2(-outward.y, outward.x)
	_spawn_ring(12.0, _accent_color(), 2.6, 0.18, 1.40)
	_spawn_prism_glints(outward, tangent, 7, 0.24)


func _build_meteor_impact() -> void:
	_build_cannon_impact()
	_spawn_flash(Vector2(52.0, 52.0), Color(1.0, 0.94, 0.82, 0.54), 0.20, 2.30)
	_spawn_ring(22.0, _secondary_color(), 5.4, 0.30, 2.04)
	_spawn_fragment_cloud(8, [_primary_color(), _secondary_color(), _accent_color()], 0.32, 28.0)


func _spawn_flash(size: Vector2, color: Color, duration: float, grow_scale: float) -> void:
	var flash := ColorRect.new()
	flash.size = size
	flash.position = -size * 0.5
	flash.color = color
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)

	var tween := create_tween()
	tween.parallel().tween_property(flash, "scale", Vector2(grow_scale, grow_scale), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(flash, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _spawn_streak(local_position: Vector2, size: Vector2, color: Color, duration: float, angle: float) -> void:
	var shard := Node2D.new()
	shard.position = local_position
	shard.rotation = angle
	add_child(shard)

	var rect := ColorRect.new()
	rect.size = size
	rect.position = -size * 0.5
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shard.add_child(rect)

	var tween := create_tween()
	tween.parallel().tween_property(shard, "scale", Vector2(0.18, 0.18), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(rect, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _spawn_local_arc(start: Vector2, end: Vector2, color: Color, width: float, duration: float, jitter: float) -> void:
	var glow := Line2D.new()
	glow.width = width * 1.65
	glow.default_color = Color(color.r, color.g, color.b, 0.28)
	glow.antialiased = false
	glow.begin_cap_mode = Line2D.LINE_CAP_ROUND
	glow.end_cap_mode = Line2D.LINE_CAP_ROUND
	glow.joint_mode = Line2D.LINE_JOINT_ROUND
	glow.points = _build_arc_points(start, end, jitter * 1.06)
	add_child(glow)

	var line := Line2D.new()
	line.width = width
	line.default_color = color
	line.antialiased = false
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.points = _build_arc_points(start, end, jitter)
	add_child(line)

	var tween := create_tween()
	tween.parallel().tween_property(glow, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(glow, "scale", Vector2(0.92, 0.92), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(line, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(line, "scale", Vector2(0.88, 0.88), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _spawn_ring(initial_radius: float, color: Color, width: float, duration: float, scale_multiplier: float) -> void:
	var ring := Line2D.new()
	ring.width = width
	ring.antialiased = false
	ring.default_color = color
	ring.closed = true
	var points := PackedVector2Array()
	for i in range(16):
		var angle := TAU * (float(i) / 16.0)
		points.append(Vector2(cos(angle), sin(angle)) * initial_radius)
	ring.points = points
	add_child(ring)

	var tween := create_tween()
	tween.parallel().tween_property(ring, "scale", Vector2(scale_multiplier, scale_multiplier), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(ring, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _spawn_spark_burst(local_origin: Vector2, count: int, palette: Array, duration: float, reach: float) -> void:
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


func _spawn_fragment_cloud(count: int, palette: Array, duration: float, reach: float) -> void:
	for _i in range(count):
		var piece := Node2D.new()
		piece.position = Vector2(_rng.randf_range(-6.0, 6.0), _rng.randf_range(-6.0, 6.0))
		piece.rotation = deg_to_rad(_rng.randf_range(-35.0, 35.0))
		add_child(piece)

		var rect := ColorRect.new()
		rect.size = Vector2(_rng.randf_range(7.0, 13.0), _rng.randf_range(4.0, 7.0))
		rect.position = -rect.size * 0.5
		rect.color = palette[_rng.randi_range(0, palette.size() - 1)]
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		piece.add_child(rect)

		var drift := Vector2(_rng.randf_range(-reach, reach), _rng.randf_range(-reach, reach * 0.7))
		var tween := create_tween()
		tween.parallel().tween_property(piece, "position", piece.position + drift, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(piece, "rotation", piece.rotation + deg_to_rad(_rng.randf_range(-80.0, 80.0)), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(piece, "scale", Vector2(0.22, 0.22), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(rect, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _spawn_smoke_puffs(count: int, color: Color, duration: float) -> void:
	for _i in range(count):
		var puff := ColorRect.new()
		puff.size = Vector2(_rng.randf_range(10.0, 16.0), _rng.randf_range(7.0, 10.0))
		puff.position = Vector2(_rng.randf_range(-8.0, 8.0), _rng.randf_range(-4.0, 8.0)) - (puff.size * 0.5)
		puff.color = color
		puff.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(puff)

		var drift := Vector2(_rng.randf_range(-14.0, 14.0), _rng.randf_range(-18.0, -8.0))
		var tween := create_tween()
		tween.parallel().tween_property(puff, "position", puff.position + drift, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(puff, "scale", Vector2(1.38, 1.32), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(puff, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _spawn_prism_glints(forward: Vector2, tangent: Vector2, count: int, duration: float) -> void:
	for i in range(count):
		var t := float(i + 1) / float(count + 1)
		var glint := ColorRect.new()
		glint.size = Vector2(5.0, 5.0)
		glint.position = (forward * 26.0 * t) + (tangent * _rng.randf_range(-4.0, 4.0)) - Vector2(2.5, 2.5)
		glint.color = Color(0.92, 0.98, 1.0, 0.86) if i % 2 == 0 else Color(0.66, 0.48, 1.0, 0.74)
		glint.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(glint)

		var tween := create_tween()
		tween.parallel().tween_property(glint, "scale", Vector2(0.14, 0.14), duration + (t * 0.06)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(glint, "modulate:a", 0.0, duration + (t * 0.06)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _build_arc_points(start: Vector2, end: Vector2, jitter: float) -> PackedVector2Array:
	var direction_vector := end - start
	var distance := maxf(direction_vector.length(), 1.0)
	var direction_unit := direction_vector / distance
	var tangent := Vector2(-direction_unit.y, direction_unit.x)
	var points := PackedVector2Array([start])
	var step_count := clampi(int(round(distance / 14.0)), 4, 7)
	for step in range(1, step_count):
		var t := float(step) / float(step_count)
		var base := start.lerp(end, t)
		var offset := tangent * _rng.randf_range(-jitter, jitter)
		points.append(base + offset)
	points.append(end)
	return points


func _safe_outward() -> Vector2:
	return surface_normal if surface_normal.length_squared() > 0.001 else -direction


func _resolved_profile() -> Dictionary:
	if visual_style_id != "":
		var profile := WeaponProfileRef.get_profile_by_visual_id(visual_style_id)
		if not profile.is_empty():
			return profile
	return WeaponProfileRef.resolve_profile(tier)


func _resolved_hit_style() -> String:
	return String(_resolved_profile().get("hit_vfx_style", "arrow"))


func _primary_color() -> Color:
	return Color(_resolved_profile().get("primary_color", Color.WHITE))


func _secondary_color() -> Color:
	return Color(_resolved_profile().get("secondary_color", Color.WHITE))


func _accent_color() -> Color:
	return Color(_resolved_profile().get("accent_color", Color.WHITE))
