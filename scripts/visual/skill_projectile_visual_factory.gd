class_name SkillProjectileVisualFactory
extends RefCounted
# SkillProjectileVisualFactory — visual-only flight and impact effects for automatic skills.
# No damage, no targeting, no audio, no assets.

const SkillRulesRef := preload("res://scripts/domain/skills/skill_rules.gd")


static func spawn_area_skill_vfx(
	layer: Node2D,
	skill_id: String,
	origin: Vector2,
	target: Vector2,
	flight_time: float,
	impact_callback: Callable
) -> void:
	if layer == null or not is_instance_valid(layer):
		_call_impact(impact_callback)
		return

	match skill_id:
		SkillRulesRef.STONE_THROW:
			_spawn_catapult_stone(layer, origin, target, flight_time, impact_callback)
		SkillRulesRef.METEOR:
			_spawn_cannon_meteor_shell(layer, origin, target, flight_time, impact_callback)
		_:
			_call_impact(impact_callback)


static func spawn_machine_gun_tracer(
	layer: Node2D,
	origin: Vector2,
	target: Vector2,
	tracer_index: int = 0
) -> void:
	if layer == null or not is_instance_valid(layer):
		return

	var start := _launch_origin_behind_core(origin, target, 18.0)
	var root := Node2D.new()
	root.z_index = 70
	layer.add_child(root)
	root.global_position = start

	var local_target := root.to_local(target)
	var direction := local_target.normalized()
	if direction.length_squared() <= 0.001:
		direction = Vector2.UP
	var tangent := Vector2(-direction.y, direction.x)
	var jitter := tangent * float((tracer_index % 3) - 1) * 3.0
	local_target += jitter

	_add_line(root, Vector2.ZERO, local_target, 5.0, Color(0.34, 0.58, 1.0, 0.28), -1)
	_add_line(root, Vector2.ZERO, local_target, 2.0, Color(0.86, 0.96, 1.0, 0.88), 0)

	_spawn_tiny_hit_spark(layer, target, Color(0.70, 0.88, 1.0, 0.92), Color(0.96, 0.98, 1.0, 0.92))

	var tween := layer.create_tween()
	tween.parallel().tween_property(root, "modulate:a", 0.0, 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(root, "scale", Vector2(0.72, 0.72), 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.finished.connect(root.queue_free)


static func _spawn_catapult_stone(
	layer: Node2D,
	origin: Vector2,
	target: Vector2,
	flight_time: float,
	impact_callback: Callable
) -> void:
	# LLM semantic: catapult + stone + toy mechanism + blunt brick impact.
	# Visual: gray stone lobs from behind core in a clear parabolic arc.
	var start := _launch_origin_behind_core(origin, target, 30.0)
	var root := Node2D.new()
	root.z_index = 62
	layer.add_child(root)
	root.global_position = start

	_spawn_launch_puff(layer, start, Color(0.42, 0.28, 0.16, 0.36), Color(0.76, 0.64, 0.50, 0.28))

	var projectile := Node2D.new()
	root.add_child(projectile)

	var shadow := ColorRect.new()
	shadow.size = Vector2(14.0, 5.0)
	shadow.position = Vector2(-7.0, 8.0)
	shadow.color = Color(0.0, 0.02, 0.06, 0.28)
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	projectile.add_child(shadow)

	_add_rect(projectile, Vector2.ZERO, Vector2(13.0, 13.0), Color(0.54, 0.54, 0.56, 1.0), 1)
	_add_rect(projectile, Vector2(-3.0, -3.0), Vector2(5.0, 5.0), Color(0.72, 0.72, 0.74, 0.94), 2)

	var safe_time := maxf(flight_time, 0.08)
	var arc_height := clampf(start.distance_to(target) * 0.20, 22.0, 64.0)

	var move_tween := layer.create_tween()
	move_tween.tween_property(root, "global_position", target, safe_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	move_tween.finished.connect(func() -> void:
		_call_impact(impact_callback)
		_spawn_stone_impact(layer, target)
		root.queue_free()
	)

	var arc_tween := layer.create_tween()
	arc_tween.tween_property(projectile, "position:y", -arc_height, safe_time * 0.50).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	arc_tween.tween_property(projectile, "position:y", 0.0, safe_time * 0.50).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	var spin_tween := layer.create_tween()
	spin_tween.tween_property(projectile, "rotation", TAU * 0.75, safe_time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


static func _spawn_cannon_meteor_shell(
	layer: Node2D,
	origin: Vector2,
	target: Vector2,
	flight_time: float,
	impact_callback: Callable
) -> void:
	# LLM semantic: meteor cannon + ember shell + arcade fireball.
	# Important: this is cannon-fired from the core-back cannon, NOT a vertical sky drop.
	var start := _launch_origin_behind_core(origin, target, 28.0)
	var root := Node2D.new()
	root.z_index = 64
	layer.add_child(root)
	root.global_position = start

	_spawn_meteor_muzzle_flash(layer, start, target)

	var projectile := Node2D.new()
	root.add_child(projectile)

	var direction := (target - start).normalized()
	if direction.length_squared() <= 0.001:
		direction = Vector2.UP
	var tangent := Vector2(-direction.y, direction.x)

	_add_rect(projectile, Vector2.ZERO, Vector2(16.0, 14.0), Color(1.0, 0.36, 0.10, 1.0), 2)
	_add_rect(projectile, Vector2(-2.0, -2.0), Vector2(8.0, 7.0), Color(1.0, 0.92, 0.52, 0.96), 3)

	# Attached ember tail behind the shell; not a sky-fall trail.
	_add_rect(projectile, -direction * 12.0, Vector2(20.0, 7.0), Color(1.0, 0.66, 0.16, 0.42), 0)
	_add_rect(projectile, -direction * 22.0 + tangent * 2.0, Vector2(16.0, 5.0), Color(1.0, 0.22, 0.08, 0.30), -1)

	var safe_time := maxf(flight_time, 0.08)
	var arc_height := clampf(start.distance_to(target) * 0.10, 12.0, 34.0)

	var move_tween := layer.create_tween()
	move_tween.tween_property(root, "global_position", target, safe_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	move_tween.finished.connect(func() -> void:
		_call_impact(impact_callback)
		_spawn_meteor_impact(layer, target)
		root.queue_free()
	)

	var arc_tween := layer.create_tween()
	arc_tween.tween_property(projectile, "position:y", -arc_height, safe_time * 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	arc_tween.tween_property(projectile, "position:y", 0.0, safe_time * 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	var scale_tween := layer.create_tween()
	scale_tween.tween_property(projectile, "scale", Vector2(1.12, 1.12), safe_time * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(projectile, "scale", Vector2.ONE, safe_time * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


static func _launch_origin_behind_core(origin: Vector2, target: Vector2, offset: float) -> Vector2:
	var direction := (target - origin).normalized()
	if direction.length_squared() <= 0.001:
		direction = Vector2.UP
	return origin - (direction * offset)


static func _spawn_launch_puff(layer: Node2D, position_value: Vector2, dust: Color, highlight: Color) -> void:
	var root := Node2D.new()
	root.z_index = 58
	layer.add_child(root)
	root.global_position = position_value

	_add_rect(root, Vector2(-8.0, 0.0), Vector2(12.0, 6.0), dust, 0)
	_add_rect(root, Vector2(6.0, -3.0), Vector2(9.0, 5.0), highlight, 1)
	_add_rect(root, Vector2(2.0, 5.0), Vector2(7.0, 4.0), dust.lightened(0.18), 1)

	var tween := layer.create_tween()
	tween.parallel().tween_property(root, "scale", Vector2(1.45, 1.20), 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(root, "modulate:a", 0.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.finished.connect(root.queue_free)


static func _spawn_meteor_muzzle_flash(layer: Node2D, start: Vector2, target: Vector2) -> void:
	var root := Node2D.new()
	root.z_index = 59
	layer.add_child(root)
	root.global_position = start

	var direction := (target - start).normalized()
	if direction.length_squared() <= 0.001:
		direction = Vector2.UP

	_add_line(root, Vector2.ZERO, direction * 26.0, 8.0, Color(1.0, 0.36, 0.10, 0.50), -1)
	_add_line(root, Vector2.ZERO, direction * 20.0, 4.0, Color(1.0, 0.92, 0.58, 0.86), 0)
	_add_rect(root, direction * 8.0, Vector2(14.0, 10.0), Color(1.0, 0.62, 0.18, 0.60), 1)

	var tween := layer.create_tween()
	tween.parallel().tween_property(root, "scale", Vector2(1.25, 1.25), 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(root, "modulate:a", 0.0, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.finished.connect(root.queue_free)


static func _spawn_stone_impact(layer: Node2D, position_value: Vector2) -> void:
	var root := Node2D.new()
	root.z_index = 66
	layer.add_child(root)
	root.global_position = position_value

	_add_rect(root, Vector2.ZERO, Vector2(24.0, 10.0), Color(0.56, 0.56, 0.58, 0.62), 0)
	_spawn_radial_chunks(root, 5, Color(0.64, 0.64, 0.66, 0.90), Color(0.34, 0.34, 0.36, 0.72), 0.22, 22.0)

	var tween := layer.create_tween()
	tween.parallel().tween_property(root, "scale", Vector2(1.36, 1.10), 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(root, "modulate:a", 0.0, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.finished.connect(root.queue_free)


static func _spawn_meteor_impact(layer: Node2D, position_value: Vector2) -> void:
	var root := Node2D.new()
	root.z_index = 68
	layer.add_child(root)
	root.global_position = position_value

	_spawn_flash(root, Vector2(34.0, 28.0), Color(1.0, 0.96, 0.82, 0.92), 0)
	_spawn_ring(root, 20.0, Color(1.0, 0.58, 0.16, 0.78), 4.0, 0)
	_spawn_radial_chunks(root, 8, Color(1.0, 0.44, 0.10, 0.92), Color(1.0, 0.86, 0.34, 0.88), 0.30, 34.0)

	var tween := layer.create_tween()
	tween.parallel().tween_property(root, "scale", Vector2(1.62, 1.42), 0.30).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(root, "modulate:a", 0.0, 0.34).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.finished.connect(root.queue_free)


static func _spawn_tiny_hit_spark(layer: Node2D, position_value: Vector2, primary: Color, secondary: Color) -> void:
	var root := Node2D.new()
	root.z_index = 65
	layer.add_child(root)
	root.global_position = position_value

	_add_rect(root, Vector2.ZERO, Vector2(10.0, 4.0), primary, 0)
	_add_rect(root, Vector2(2.0, -3.0), Vector2(5.0, 5.0), secondary, 1)

	var tween := layer.create_tween()
	tween.parallel().tween_property(root, "scale", Vector2(1.40, 1.40), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(root, "modulate:a", 0.0, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.finished.connect(root.queue_free)


static func _spawn_flash(parent: Node, size: Vector2, color: Color, z_index: int) -> void:
	var flash := ColorRect.new()
	flash.size = size
	flash.position = -size * 0.5
	flash.color = color
	flash.z_index = z_index
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(flash)


static func _spawn_ring(parent: Node, radius: float, color: Color, width: float, z_index: int) -> void:
	var ring := Line2D.new()
	ring.width = width
	ring.default_color = color
	ring.antialiased = false
	ring.closed = true
	ring.z_index = z_index
	var points := PackedVector2Array()
	for i in range(16):
		var angle := TAU * (float(i) / 16.0)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	ring.points = points
	parent.add_child(ring)


static func _spawn_radial_chunks(parent: Node, count: int, primary: Color, secondary: Color, duration: float, reach: float) -> void:
	for i in range(count):
		var angle := TAU * (float(i) / float(maxi(count, 1)))
		var direction := Vector2(cos(angle), sin(angle))
		var chunk := ColorRect.new()
		var size := Vector2(6.0 + float(i % 3), 4.0 + float((i + 1) % 3))
		chunk.size = size
		chunk.position = -size * 0.5
		chunk.color = primary if i % 2 == 0 else secondary
		chunk.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(chunk)

		var tween := parent.create_tween()
		tween.parallel().tween_property(chunk, "position", (direction * reach) - (size * 0.5), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(chunk, "scale", Vector2(0.20, 0.20), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(chunk, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


static func _add_rect(parent: Node, center: Vector2, size: Vector2, color: Color, z_index: int = 0) -> ColorRect:
	var rect := ColorRect.new()
	rect.size = size
	rect.position = center - (size * 0.5)
	rect.color = color
	rect.z_index = z_index
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)
	return rect


static func _add_line(parent: Node, start: Vector2, end: Vector2, width: float, color: Color, z_index: int = 0) -> Line2D:
	var line := Line2D.new()
	line.width = width
	line.default_color = color
	line.antialiased = false
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.points = PackedVector2Array([start, end])
	line.z_index = z_index
	parent.add_child(line)
	return line


static func _call_impact(impact_callback: Callable) -> void:
	if impact_callback.is_valid():
		impact_callback.call()
