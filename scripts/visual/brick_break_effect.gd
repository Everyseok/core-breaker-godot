extends Node2D
# BrickBreakEffect — brick-type-specific destruction feedback.
# Visual-only; does not change HP, score, K, or spawn rules.

const BrickRulesRef := preload("res://scripts/domain/bricks/brick_rules.gd")

var brick_type: int = BrickRulesRef.BrickType.NORMAL
var _rng := RandomNumberGenerator.new()


func configure(next_brick_type: int) -> void:
	brick_type = next_brick_type
	if is_node_ready():
		_rebuild_effect()


func _ready() -> void:
	z_index = 45
	_rng.randomize()
	_rebuild_effect()
	var cleanup := create_tween()
	cleanup.tween_interval(0.38)
	cleanup.finished.connect(queue_free)


func _rebuild_effect() -> void:
	for child in get_children():
		child.queue_free()
	_build_effect()


func _build_effect() -> void:
	match brick_type:
		BrickRulesRef.BrickType.STRONG:
			_spawn_flash(Vector2(24.0, 16.0), Color(0.84, 0.94, 1.0, 0.80), 0.18, 1.60)
			_spawn_chip_cloud(5, Color(0.60, 0.82, 1.0), Vector2(14.0, 10.0), 0.24)
			_spawn_chip_cloud(3, Color(0.16, 0.30, 0.56), Vector2(10.0, 8.0), 0.28)
			_spawn_line(PackedVector2Array([Vector2(-12.0, 0.0), Vector2(-4.0, -4.0), Vector2(4.0, 4.0), Vector2(12.0, 0.0)]), Color(0.86, 0.96, 1.0, 0.90), 3.0, 0.20)
		BrickRulesRef.BrickType.ARMORED:
			_spawn_flash(Vector2(28.0, 20.0), Color(0.92, 0.72, 1.0, 0.84), 0.22, 1.72)
			_spawn_chip_cloud(6, Color(0.76, 0.58, 1.0), Vector2(15.0, 12.0), 0.30)
			_spawn_chip_cloud(4, Color(0.20, 0.10, 0.30), Vector2(12.0, 10.0), 0.34)
			_spawn_line(PackedVector2Array([Vector2(-11.0, -1.0), Vector2(-5.0, -7.0), Vector2(1.0, 5.0), Vector2(10.0, -3.0)]), Color(0.98, 0.86, 1.0, 0.86), 4.0, 0.24)
		_:
			_spawn_flash(Vector2(22.0, 16.0), Color(1.0, 0.88, 0.60, 0.80), 0.16, 1.48)
			_spawn_chip_cloud(4, Color(0.96, 0.74, 0.34), Vector2(12.0, 9.0), 0.22)
			_spawn_chip_cloud(3, Color(0.54, 0.28, 0.10), Vector2(8.0, 6.0), 0.24)


func _spawn_chip_cloud(count: int, color: Color, max_size: Vector2, duration: float) -> void:
	for _i in range(count):
		var piece := Node2D.new()
		piece.position = Vector2(_rng.randf_range(-5.0, 5.0), _rng.randf_range(-4.0, 4.0))
		piece.rotation = deg_to_rad(_rng.randf_range(-25.0, 25.0))
		add_child(piece)

		var rect := ColorRect.new()
		rect.size = Vector2(
			_rng.randf_range(max_size.x * 0.35, max_size.x),
			_rng.randf_range(max_size.y * 0.30, max_size.y)
		)
		rect.position = -rect.size * 0.5
		rect.color = color
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		piece.add_child(rect)

		var drift := Vector2(_rng.randf_range(-22.0, 22.0), _rng.randf_range(-18.0, 8.0))
		var tween := create_tween()
		tween.parallel().tween_property(piece, "position", piece.position + drift, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(piece, "rotation", piece.rotation + deg_to_rad(_rng.randf_range(-50.0, 50.0)), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(piece, "scale", Vector2(0.30, 0.30), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(rect, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


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


func _spawn_line(points: PackedVector2Array, color: Color, width: float, duration: float) -> void:
	var line := Line2D.new()
	line.width = width
	line.points = points
	line.default_color = color
	line.antialiased = false
	line.begin_cap_mode = Line2D.LINE_CAP_BOX
	line.end_cap_mode = Line2D.LINE_CAP_BOX
	add_child(line)

	var tween := create_tween()
	tween.parallel().tween_property(line, "scale", Vector2(0.54, 0.54), duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(line, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
