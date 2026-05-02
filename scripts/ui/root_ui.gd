extends CanvasLayer
# RootUI — applies safe-area padding for all child controls in one place.

@onready var _safe_area_container: Control = $SafeAreaContainer


func _ready() -> void:
	_apply_safe_area()
	get_viewport().size_changed.connect(_apply_safe_area)


func _apply_safe_area() -> void:
	var safe_area: Rect2i = DisplayServer.get_display_safe_area()
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size

	if safe_area.size == Vector2i.ZERO:
		_safe_area_container.offset_left = 0.0
		_safe_area_container.offset_top = 0.0
		_safe_area_container.offset_right = 0.0
		_safe_area_container.offset_bottom = 0.0
		return

	var left := float(safe_area.position.x)
	var top := float(safe_area.position.y)
	var right := maxf(0.0, viewport_size.x - float(safe_area.position.x + safe_area.size.x))
	var bottom := maxf(0.0, viewport_size.y - float(safe_area.position.y + safe_area.size.y))

	_safe_area_container.offset_left = left
	_safe_area_container.offset_top = top
	_safe_area_container.offset_right = -right
	_safe_area_container.offset_bottom = -bottom
