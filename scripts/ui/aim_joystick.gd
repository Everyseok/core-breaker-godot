extends Control
# AimJoystick — placeholder virtual stick used only for aiming.
# It updates InputHandler aim direction, preserves last valid direction after
# release, and can move between left / center / right bottom anchors.

enum PositionSlot { LEFT, CENTER, RIGHT }

const SLOT_KEYS: Array[String] = ["left", "center", "right"]
const JOYSTICK_SIZE: Vector2 = Vector2(120.0, 120.0)
const BASE_SIZE: Vector2 = Vector2(88.0, 88.0)
const KNOB_SIZE: Vector2 = Vector2(34.0, 34.0)
const BUTTON_SIZE: Vector2 = Vector2(34.0, 34.0)
const BUTTON_GAP: float = 10.0
const BOTTOM_MARGIN: float = 106.0
const DIVIDER_SIZE: Vector2 = Vector2(180.0, 2.0)
const DIVIDER_GAP: float = 16.0
const BUFF_BUTTON_SIZE: Vector2 = Vector2(88.0, 42.0)
const BUFF_BUTTON_GAP: float = 12.0
const INPUT_RADIUS: float = 34.0
const DEADZONE_RADIUS: float = 6.0

var _position_slot: int = PositionSlot.CENTER
var _mouse_drag_active: bool = false
var _active_touch_index: int = -1
var _knob_offset: Vector2 = Vector2.UP * INPUT_RADIUS

var _joystick_area: Control
var _base: ColorRect
var _knob: ColorRect
var _left_button: Button
var _right_button: Button
var _divider: ColorRect
var _buff_button: Button


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	_load_saved_position()
	if InputHandler.aim_direction.length_squared() > 0.001:
		_knob_offset = InputHandler.aim_direction.normalized() * INPUT_RADIUS
	_update_layout()
	if not resized.is_connected(_update_layout):
		resized.connect(_update_layout)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _mouse_drag_active:
		_update_aim_from_global_position(event.position)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_mouse_drag_active = false
	elif event is InputEventScreenDrag:
		if event.index == _active_touch_index:
			_update_aim_from_global_position(event.position)
	elif event is InputEventScreenTouch:
		if not event.pressed and event.index == _active_touch_index:
			_active_touch_index = -1


func _process(_delta: float) -> void:
	_update_buff_button_state()


func _build_ui() -> void:
	_joystick_area = Control.new()
	_joystick_area.name = "JoystickArea"
	_joystick_area.mouse_filter = Control.MOUSE_FILTER_STOP
	_joystick_area.gui_input.connect(_on_joystick_area_gui_input)
	add_child(_joystick_area)

	_base = ColorRect.new()
	_base.name = "Base"
	_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_base.color = Color(0.12, 0.12, 0.12, 0.45)
	_joystick_area.add_child(_base)

	_knob = ColorRect.new()
	_knob.name = "Knob"
	_knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_knob.color = Color(0.88, 0.88, 0.88, 0.8)
	_joystick_area.add_child(_knob)

	_left_button = _build_position_button("MoveLeftButton", "<")
	_left_button.pressed.connect(_on_move_left_pressed)
	add_child(_left_button)

	_right_button = _build_position_button("MoveRightButton", ">")
	_right_button.pressed.connect(_on_move_right_pressed)
	add_child(_right_button)

	_divider = ColorRect.new()
	_divider.name = "BuffDivider"
	_divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_divider.color = Color(1.0, 1.0, 1.0, 0.2)
	add_child(_divider)

	_buff_button = Button.new()
	_buff_button.name = "BuffButton"
	_buff_button.focus_mode = Control.FOCUS_NONE
	_buff_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_buff_button.pressed.connect(_on_buff_button_pressed)
	add_child(_buff_button)


func _build_position_button(node_name: String, label: String) -> Button:
	var button: Button = Button.new()
	button.name = node_name
	button.text = label
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.modulate = Color(1.0, 1.0, 1.0, 0.82)
	return button


func _on_joystick_area_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		_mouse_drag_active = event.pressed
		if event.pressed:
			_update_aim_from_local_position(event.position)
	elif event is InputEventMouseMotion:
		if _mouse_drag_active:
			_update_aim_from_local_position(event.position)
	elif event is InputEventScreenTouch:
		if event.pressed:
			_active_touch_index = event.index
			_update_aim_from_global_position(event.position)
		elif event.index == _active_touch_index:
			_active_touch_index = -1
	elif event is InputEventScreenDrag:
		if event.index == _active_touch_index:
			_update_aim_from_global_position(event.position)


func _update_aim_from_global_position(global_position: Vector2) -> void:
	var area_rect: Rect2 = _joystick_area.get_global_rect()
	var local_position: Vector2 = global_position - area_rect.position
	_update_aim_from_local_position(local_position)


func _update_aim_from_local_position(local_position: Vector2) -> void:
	var center: Vector2 = JOYSTICK_SIZE * 0.5
	var raw_offset: Vector2 = local_position - center
	var clamped_offset: Vector2 = raw_offset.limit_length(INPUT_RADIUS)
	if clamped_offset.length() < DEADZONE_RADIUS:
		return
	_knob_offset = clamped_offset
	InputHandler.set_aim_direction(clamped_offset)
	_update_knob_position()


func _load_saved_position() -> void:
	var saved_key: String = SaveManager.get_aim_joystick_position()
	var saved_index: int = SLOT_KEYS.find(saved_key)
	if saved_index == -1:
		saved_index = PositionSlot.CENTER
	_set_position_slot(saved_index, false)


func _set_position_slot(slot: int, persist: bool = true) -> void:
	_position_slot = clampi(slot, PositionSlot.LEFT, PositionSlot.RIGHT)
	_update_layout()
	if persist:
		_persist_position_slot()


func _persist_position_slot() -> void:
	SaveManager.set_aim_joystick_position(SLOT_KEYS[_position_slot])
	SaveManager.save()


func _on_move_left_pressed() -> void:
	if _position_slot <= PositionSlot.LEFT:
		return
	_set_position_slot(_position_slot - 1)


func _on_move_right_pressed() -> void:
	if _position_slot >= PositionSlot.RIGHT:
		return
	_set_position_slot(_position_slot + 1)


func _update_layout() -> void:
	var slot_center_x: float = size.x * _slot_ratio(_position_slot)
	var slot_center_y: float = size.y - BOTTOM_MARGIN - (JOYSTICK_SIZE.y * 0.5)

	_joystick_area.position = Vector2(slot_center_x, slot_center_y) - (JOYSTICK_SIZE * 0.5)
	_joystick_area.size = JOYSTICK_SIZE

	_base.position = (JOYSTICK_SIZE - BASE_SIZE) * 0.5
	_base.size = BASE_SIZE

	_left_button.position = Vector2(
		_joystick_area.position.x - BUTTON_GAP - BUTTON_SIZE.x,
		slot_center_y - (BUTTON_SIZE.y * 0.5)
	)
	_left_button.size = BUTTON_SIZE

	_right_button.position = Vector2(
		_joystick_area.position.x + JOYSTICK_SIZE.x + BUTTON_GAP,
		slot_center_y - (BUTTON_SIZE.y * 0.5)
	)
	_right_button.size = BUTTON_SIZE

	_divider.position = Vector2(
		slot_center_x - (DIVIDER_SIZE.x * 0.5),
		_joystick_area.position.y - DIVIDER_GAP - DIVIDER_SIZE.y
	)
	_divider.size = DIVIDER_SIZE

	_buff_button.position = Vector2(
		slot_center_x - (BUFF_BUTTON_SIZE.x * 0.5),
		_divider.position.y - BUFF_BUTTON_GAP - BUFF_BUTTON_SIZE.y
	)
	_buff_button.size = BUFF_BUTTON_SIZE

	_update_knob_position()
	_update_button_state()
	_update_buff_button_state()


func _update_knob_position() -> void:
	_knob.size = KNOB_SIZE
	_knob.position = (JOYSTICK_SIZE * 0.5) + _knob_offset - (KNOB_SIZE * 0.5)


func _update_button_state() -> void:
	_left_button.disabled = _position_slot == PositionSlot.LEFT
	_right_button.disabled = _position_slot == PositionSlot.RIGHT


func _slot_ratio(slot: int) -> float:
	match slot:
		PositionSlot.LEFT:
			return 0.28
		PositionSlot.RIGHT:
			return 0.72
		_:
			return 0.5


func _on_buff_button_pressed() -> void:
	var weapon = _get_weapon()
	if weapon == null or not is_instance_valid(weapon):
		return
	weapon.activate_overclock()
	_update_buff_button_state()


func _update_buff_button_state() -> void:
	if _buff_button == null:
		return
	var weapon = _get_weapon()
	if weapon == null or not is_instance_valid(weapon):
		_buff_button.disabled = true
		_buff_button.text = "--"
		return

	if not weapon.is_overclock_unlocked():
		_buff_button.disabled = true
		_buff_button.text = "LOCK\n%d" % weapon.get_overclock_unlock_threshold()
		return

	if weapon.is_overclock_active():
		_buff_button.disabled = true
		_buff_button.text = "BOOST\nON"
		return

	if weapon.is_overclock_on_cooldown():
		_buff_button.disabled = true
		_buff_button.text = "CD\n%d" % maxi(ceili(weapon.get_overclock_remaining_time()), 0)
		return

	_buff_button.disabled = false
	_buff_button.text = "BOOST"


func _get_weapon():
	var weapons := get_tree().get_nodes_in_group("weapon")
	if weapons.is_empty():
		return null
	return weapons[0]
