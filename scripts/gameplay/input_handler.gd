extends Node
# InputHandler — shared aim-state coordinator.
# Virtual joystick UI writes normalized aim direction here, and Weapon reads it.

signal aim_changed(direction: Vector2)

var aim_direction: Vector2 = Vector2.UP
var aim_origin: Vector2 = Vector2.ZERO
var _origin_ready: bool = false


func set_aim_origin(origin: Vector2) -> void:
	aim_origin = origin
	_origin_ready = true


func set_aim_direction(direction: Vector2) -> void:
	var normalized_direction: Vector2 = direction.normalized()
	if normalized_direction.length_squared() <= 0.001:
		return
	aim_direction = normalized_direction
	aim_changed.emit(aim_direction)


func set_aim_from_screen_position(screen_position: Vector2) -> void:
	var origin: Vector2 = aim_origin
	if not _origin_ready:
		origin = get_viewport().get_visible_rect().size * 0.5
	set_aim_direction(screen_position - origin)
