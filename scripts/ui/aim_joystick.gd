extends Control
# AimJoystick — retro pseudo-3D arcade stick used only for aiming.
# Gameplay aim logic still lives in InputHandler; this script only owns the
# bottom control dock layout and the joystick's visual response.

enum PositionSlot { LEFT, CENTER, RIGHT }

const SLOT_KEYS: Array[String] = ["left", "center", "right"]
const JOYSTICK_SIZE: Vector2 = Vector2(132.0, 132.0)
const PLATE_SIZE: Vector2 = Vector2(104.0, 78.0)
const SOCKET_SIZE: Vector2 = Vector2(30.0, 18.0)
const KNOB_SIZE: Vector2 = Vector2(40.0, 40.0)
const KNOB_SHINE_SIZE: Vector2 = Vector2(14.0, 12.0)
const BUTTON_SIZE: Vector2 = Vector2(42.0, 36.0)
const BUTTON_GAP: float = 12.0
const CONTROL_BOTTOM_MARGIN: float = 6.0
const DIVIDER_SIZE: Vector2 = Vector2(196.0, 4.0)
const DIVIDER_GAP: float = 10.0
const BUFF_BUTTON_SIZE: Vector2 = Vector2(104.0, 48.0)
const BUFF_BUTTON_GAP: float = 8.0
const LOCK_BADGE_SIZE: Vector2 = Vector2(32.0, 32.0)
const LOCK_BODY_SIZE: Vector2 = Vector2(20.0, 16.0)
const INPUT_RADIUS: float = 46.0
const VISUAL_RADIUS: float = 24.0
const DEADZONE_RADIUS: float = 5.0
const RETURN_SPEED: float = 220.0
const SHAFT_WIDTH: float = 11.0
const SHAFT_SHADOW_WIDTH: float = 13.0
const KNOB_SHADOW_OFFSET: Vector2 = Vector2(4.0, 5.0)
const STICK_SOCKET_CENTER: Vector2 = Vector2(66.0, 62.0)
const KNOB_NEUTRAL_CENTER: Vector2 = Vector2(66.0, 46.0)

const UiStyleRef := preload("res://scripts/ui/ui_style.gd")

var _position_slot: int = PositionSlot.CENTER
var _mouse_drag_active: bool = false
var _active_touch_index: int = -1
var _visual_knob_offset: Vector2 = Vector2.ZERO

var _joystick_area: Control
var _base_shadow: Panel
var _base_plate: Panel
var _base_inner: Panel
var _base_highlight_top: ColorRect
var _base_highlight_left: ColorRect
var _base_lowlight_bottom: ColorRect
var _socket_shadow: Panel
var _socket: Panel
var _shaft_shadow: Line2D
var _shaft: Line2D
var _knob_shadow: Panel
var _knob: Panel
var _knob_shine: Panel
var _knob_spec: Panel
var _left_button: Button
var _right_button: Button
var _divider: ColorRect
var _buff_button: Button
var _buff_lock_badge: Control
var _buff_lock_shadow: Panel
var _buff_lock_shackle: Line2D
var _buff_lock_body: Panel
var _buff_lock_keyhole: ColorRect
var _buff_lock_spark: ColorRect
var _skill_button: Button
var _skill_lock_badge: Control
var _skill_lock_shadow: Panel
var _skill_lock_shackle: Line2D
var _skill_lock_body: Panel
var _skill_lock_keyhole: ColorRect
var _skill_lock_spark: ColorRect
var _buff_manager = null
var _skill_manager = null


func _ready() -> void:
	_buff_manager = get_node_or_null("/root/BuffManager")
	_skill_manager = get_node_or_null("/root/SkillManager")
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	_apply_visual_style()
	_load_saved_position()
	_update_layout()
	_sync_play_visibility()
	if not GameState.game_started.is_connected(_sync_play_visibility):
		GameState.game_started.connect(_sync_play_visibility)
	if not GameState.game_over.is_connected(_sync_play_visibility):
		GameState.game_over.connect(_sync_play_visibility)
	if not GameState.max_level_cleared.is_connected(_sync_play_visibility):
		GameState.max_level_cleared.connect(_sync_play_visibility)
	var skill_manager = _get_skill_manager()
	if skill_manager != null:
		if skill_manager.has_signal("skill_state_changed") and not skill_manager.skill_state_changed.is_connected(_update_skill_button_state):
			skill_manager.skill_state_changed.connect(_update_skill_button_state)
		if skill_manager.has_signal("skill_selected") and not skill_manager.skill_selected.is_connected(_on_skill_selected):
			skill_manager.skill_selected.connect(_on_skill_selected)
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


func _process(delta: float) -> void:
	_sync_play_visibility()
	if not visible:
		return
	_update_buff_button_state()
	_update_skill_button_state()
	if _is_dragging_stick():
		return
	if _visual_knob_offset.is_zero_approx():
		return
	_visual_knob_offset = _visual_knob_offset.move_toward(Vector2.ZERO, RETURN_SPEED * delta)
	if _visual_knob_offset.length_squared() < 0.1:
		_visual_knob_offset = Vector2.ZERO
	_update_arcade_visuals()


func _build_ui() -> void:
	_joystick_area = Control.new()
	_joystick_area.name = "JoystickArea"
	_joystick_area.mouse_filter = Control.MOUSE_FILTER_STOP
	_joystick_area.gui_input.connect(_on_joystick_area_gui_input)
	add_child(_joystick_area)

	_base_shadow = _build_panel("BaseShadow")
	_joystick_area.add_child(_base_shadow)

	_base_plate = _build_panel("BasePlate")
	_joystick_area.add_child(_base_plate)

	_base_inner = _build_panel("BaseInner")
	_joystick_area.add_child(_base_inner)

	_base_highlight_top = ColorRect.new()
	_base_highlight_top.name = "BaseHighlightTop"
	_base_highlight_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_joystick_area.add_child(_base_highlight_top)

	_base_highlight_left = ColorRect.new()
	_base_highlight_left.name = "BaseHighlightLeft"
	_base_highlight_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_joystick_area.add_child(_base_highlight_left)

	_base_lowlight_bottom = ColorRect.new()
	_base_lowlight_bottom.name = "BaseLowlightBottom"
	_base_lowlight_bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_joystick_area.add_child(_base_lowlight_bottom)

	_socket_shadow = _build_panel("SocketShadow")
	_joystick_area.add_child(_socket_shadow)

	_socket = _build_panel("Socket")
	_joystick_area.add_child(_socket)

	_shaft_shadow = Line2D.new()
	_shaft_shadow.name = "ShaftShadow"
	_shaft_shadow.z_index = 1
	_shaft_shadow.width = SHAFT_SHADOW_WIDTH
	_shaft_shadow.default_color = Color(0.00, 0.02, 0.08, 0.46)
	_shaft_shadow.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_shaft_shadow.end_cap_mode = Line2D.LINE_CAP_ROUND
	_shaft_shadow.joint_mode = Line2D.LINE_JOINT_ROUND
	_shaft_shadow.add_point(Vector2.ZERO)
	_shaft_shadow.add_point(Vector2.ZERO)
	_joystick_area.add_child(_shaft_shadow)

	_shaft = Line2D.new()
	_shaft.name = "Shaft"
	_shaft.z_index = 2
	_shaft.width = SHAFT_WIDTH
	_shaft.default_color = Color(0.74, 0.78, 0.88, 0.96)
	_shaft.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_shaft.end_cap_mode = Line2D.LINE_CAP_ROUND
	_shaft.joint_mode = Line2D.LINE_JOINT_ROUND
	_shaft.add_point(Vector2.ZERO)
	_shaft.add_point(Vector2.ZERO)
	_joystick_area.add_child(_shaft)

	_knob_shadow = _build_panel("KnobShadow")
	_knob_shadow.z_index = 2
	_joystick_area.add_child(_knob_shadow)

	_knob = _build_panel("Knob")
	_knob.z_index = 3
	_joystick_area.add_child(_knob)

	_knob_shine = _build_panel("KnobShine")
	_knob_shine.z_index = 4
	_joystick_area.add_child(_knob_shine)

	_knob_spec = _build_panel("KnobSpec")
	_knob_spec.z_index = 4
	_joystick_area.add_child(_knob_spec)

	_left_button = _build_position_button("MoveLeftButton", "◀")
	_left_button.pressed.connect(_on_move_left_pressed)
	add_child(_left_button)

	_right_button = _build_position_button("MoveRightButton", "▶")
	_right_button.pressed.connect(_on_move_right_pressed)
	add_child(_right_button)

	_divider = ColorRect.new()
	_divider.name = "BuffDivider"
	_divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_divider)

	_buff_button = Button.new()
	_buff_button.name = "BuffButton"
	_buff_button.focus_mode = Control.FOCUS_NONE
	_buff_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_buff_button.pressed.connect(_on_buff_button_pressed)
	add_child(_buff_button)

	_buff_lock_badge = Control.new()
	_buff_lock_badge.name = "BuffLockBadge"
	_buff_lock_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_buff_lock_badge.visible = false
	_buff_lock_badge.z_index = 5
	add_child(_buff_lock_badge)

	_buff_lock_shadow = _build_panel("LockShadow")
	_buff_lock_badge.add_child(_buff_lock_shadow)

	_buff_lock_shackle = Line2D.new()
	_buff_lock_shackle.name = "LockShackle"
	_buff_lock_shackle.width = 4.0
	_buff_lock_shackle.default_color = Color(1.0, 0.96, 0.68, 1.0)
	_buff_lock_shackle.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_buff_lock_shackle.end_cap_mode = Line2D.LINE_CAP_ROUND
	_buff_lock_shackle.joint_mode = Line2D.LINE_JOINT_ROUND
	_buff_lock_shackle.add_point(Vector2(9.0, 17.0))
	_buff_lock_shackle.add_point(Vector2(9.0, 9.0))
	_buff_lock_shackle.add_point(Vector2(16.0, 5.0))
	_buff_lock_shackle.add_point(Vector2(23.0, 9.0))
	_buff_lock_shackle.add_point(Vector2(23.0, 17.0))
	_buff_lock_badge.add_child(_buff_lock_shackle)

	_buff_lock_body = _build_panel("LockBody")
	_buff_lock_badge.add_child(_buff_lock_body)

	_buff_lock_keyhole = ColorRect.new()
	_buff_lock_keyhole.name = "LockKeyhole"
	_buff_lock_keyhole.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_buff_lock_badge.add_child(_buff_lock_keyhole)

	_buff_lock_spark = ColorRect.new()
	_buff_lock_spark.name = "LockSpark"
	_buff_lock_spark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_buff_lock_badge.add_child(_buff_lock_spark)

	_skill_button = Button.new()
	_skill_button.name = "SkillButton"
	_skill_button.focus_mode = Control.FOCUS_NONE
	_skill_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_skill_button.pressed.connect(_on_skill_button_pressed)
	add_child(_skill_button)

	_skill_lock_badge = Control.new()
	_skill_lock_badge.name = "SkillLockBadge"
	_skill_lock_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_skill_lock_badge.visible = false
	_skill_lock_badge.z_index = 5
	add_child(_skill_lock_badge)

	_skill_lock_shadow = _build_panel("SkillLockShadow")
	_skill_lock_badge.add_child(_skill_lock_shadow)

	_skill_lock_shackle = Line2D.new()
	_skill_lock_shackle.name = "SkillLockShackle"
	_skill_lock_shackle.width = 4.0
	_skill_lock_shackle.default_color = Color(1.0, 0.96, 0.68, 1.0)
	_skill_lock_shackle.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_skill_lock_shackle.end_cap_mode = Line2D.LINE_CAP_ROUND
	_skill_lock_shackle.joint_mode = Line2D.LINE_JOINT_ROUND
	_skill_lock_shackle.add_point(Vector2(9.0, 17.0))
	_skill_lock_shackle.add_point(Vector2(9.0, 9.0))
	_skill_lock_shackle.add_point(Vector2(16.0, 5.0))
	_skill_lock_shackle.add_point(Vector2(23.0, 9.0))
	_skill_lock_shackle.add_point(Vector2(23.0, 17.0))
	_skill_lock_badge.add_child(_skill_lock_shackle)

	_skill_lock_body = _build_panel("SkillLockBody")
	_skill_lock_badge.add_child(_skill_lock_body)

	_skill_lock_keyhole = ColorRect.new()
	_skill_lock_keyhole.name = "SkillLockKeyhole"
	_skill_lock_keyhole.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_skill_lock_badge.add_child(_skill_lock_keyhole)

	_skill_lock_spark = ColorRect.new()
	_skill_lock_spark.name = "SkillLockSpark"
	_skill_lock_spark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_skill_lock_badge.add_child(_skill_lock_spark)


func _build_panel(node_name: String) -> Panel:
	var panel := Panel.new()
	panel.name = node_name
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return panel


func _build_position_button(node_name: String, label: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = label
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return button


func _apply_visual_style() -> void:
	_apply_panel_box(_base_shadow, Color(0.00, 0.02, 0.06, 0.40), Color(0.00, 0.02, 0.06, 0.16), 18, 3, 4, 3, 8)
	_apply_panel_box(_base_plate, Color(0.16, 0.20, 0.28, 0.98), Color(0.42, 0.48, 0.60, 1.0), 18, 3, 3, 3, 6)
	_apply_panel_box(_base_inner, Color(0.20, 0.24, 0.34, 1.0), Color(0.12, 0.16, 0.24, 1.0), 14, 2, 2, 2, 4)
	_base_highlight_top.color = Color(0.82, 0.90, 1.0, 0.16)
	_base_highlight_left.color = Color(0.78, 0.86, 1.0, 0.12)
	_base_lowlight_bottom.color = Color(0.00, 0.02, 0.08, 0.24)
	_apply_panel_box(_socket_shadow, Color(0.00, 0.02, 0.06, 0.32), Color(0.00, 0.02, 0.06, 0.08), 14, 2, 2, 2, 4)
	_apply_panel_box(_socket, Color(0.08, 0.10, 0.16, 0.96), Color(0.36, 0.40, 0.52, 0.72), 12, 2, 2, 2, 3)
	_apply_panel_box(_knob_shadow, Color(0.00, 0.02, 0.06, 0.38), Color(0.00, 0.02, 0.06, 0.08), 20, 2, 2, 2, 4)
	_apply_panel_box(_knob, Color(0.92, 0.18, 0.20, 1.0), Color(0.56, 0.06, 0.10, 1.0), 20, 3, 3, 3, 5)
	_apply_panel_box(_knob_shine, Color(1.0, 0.82, 0.84, 0.82), Color(1.0, 0.82, 0.84, 0.0), 8, 0, 0, 0, 0)
	_apply_panel_box(_knob_spec, Color(1.0, 0.98, 0.98, 0.88), Color(1.0, 0.98, 0.98, 0.0), 4, 0, 0, 0, 0)
	_divider.color = Color(0.58, 0.72, 0.92, 0.26)
	_apply_arcade_button_style(_left_button)
	_apply_arcade_button_style(_right_button)
	UiStyleRef.apply_button(_buff_button, Color(0.18, 0.42, 0.30), Color(0.62, 0.94, 0.76), Color.WHITE, 16)
	UiStyleRef.apply_button(_skill_button, Color(0.18, 0.30, 0.46), Color(0.62, 0.82, 1.0), Color.WHITE, 16)
	_apply_lock_badge_style()


func _apply_arcade_button_style(button: Button) -> void:
	UiStyleRef.apply_button(
		button,
		Color(0.18, 0.20, 0.28),
		Color(0.62, 0.70, 0.92),
		Color(0.98, 0.99, 1.0),
		18
	)


func _apply_panel_box(
	panel: Panel,
	fill_color: Color,
	border_color: Color,
	radius: int,
	border_left: int,
	border_top: int,
	border_right: int,
	border_bottom: int
) -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = fill_color
	box.border_color = border_color
	box.border_width_left = border_left
	box.border_width_top = border_top
	box.border_width_right = border_right
	box.border_width_bottom = border_bottom
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	box.content_margin_left = 0.0
	box.content_margin_top = 0.0
	box.content_margin_right = 0.0
	box.content_margin_bottom = 0.0
	panel.add_theme_stylebox_override("panel", box)


func _apply_lock_badge_style() -> void:
	_apply_panel_box(_buff_lock_shadow, Color(0.00, 0.02, 0.06, 0.32), Color(0.00, 0.02, 0.06, 0.0), 7, 0, 0, 0, 0)
	_apply_panel_box(_buff_lock_body, Color(1.0, 0.72, 0.22, 1.0), Color(1.0, 0.94, 0.48, 1.0), 6, 2, 2, 2, 3)
	_buff_lock_keyhole.color = Color(0.22, 0.16, 0.12, 0.90)
	_buff_lock_spark.color = Color(1.0, 0.98, 0.72, 0.92)
	_apply_panel_box(_skill_lock_shadow, Color(0.00, 0.02, 0.06, 0.32), Color(0.00, 0.02, 0.06, 0.0), 7, 0, 0, 0, 0)
	_apply_panel_box(_skill_lock_body, Color(1.0, 0.72, 0.22, 1.0), Color(1.0, 0.94, 0.48, 1.0), 6, 2, 2, 2, 3)
	_skill_lock_keyhole.color = Color(0.22, 0.16, 0.12, 0.90)
	_skill_lock_spark.color = Color(1.0, 0.98, 0.72, 0.92)


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
			_update_aim_from_local_position(event.position)
		elif event.index == _active_touch_index:
			_active_touch_index = -1
	elif event is InputEventScreenDrag:
		if event.index == _active_touch_index:
			_update_aim_from_local_position(event.position)


func _update_aim_from_global_position(global_position: Vector2) -> void:
	var local_position: Vector2 = _joystick_area.get_global_transform_with_canvas().affine_inverse() * global_position
	_update_aim_from_local_position(local_position)


func _update_aim_from_local_position(local_position: Vector2) -> void:
	var center: Vector2 = KNOB_NEUTRAL_CENTER
	var raw_offset: Vector2 = local_position - center
	var clamped_offset: Vector2 = raw_offset.limit_length(INPUT_RADIUS)
	if clamped_offset.length() < DEADZONE_RADIUS:
		return
	_visual_knob_offset = clamped_offset * (VISUAL_RADIUS / INPUT_RADIUS)
	InputHandler.set_aim_direction(clamped_offset)
	_update_arcade_visuals()


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
	AudioEvents.ui_switch()


func _on_move_right_pressed() -> void:
	if _position_slot >= PositionSlot.RIGHT:
		return
	_set_position_slot(_position_slot + 1)
	AudioEvents.ui_switch()


func _update_layout() -> void:
	var slot_center_x: float = size.x * _slot_ratio(_position_slot)
	var slot_center_y: float = size.y - CONTROL_BOTTOM_MARGIN - (JOYSTICK_SIZE.y * 0.5)

	_joystick_area.position = Vector2(slot_center_x, slot_center_y) - (JOYSTICK_SIZE * 0.5)
	_joystick_area.size = JOYSTICK_SIZE

	var plate_position := Vector2((JOYSTICK_SIZE.x - PLATE_SIZE.x) * 0.5, JOYSTICK_SIZE.y - PLATE_SIZE.y - 12.0)
	_base_shadow.position = plate_position + Vector2(4.0, 6.0)
	_base_shadow.size = PLATE_SIZE
	_base_plate.position = plate_position
	_base_plate.size = PLATE_SIZE
	_base_inner.position = plate_position + Vector2(6.0, 6.0)
	_base_inner.size = PLATE_SIZE - Vector2(12.0, 14.0)
	_base_highlight_top.position = plate_position + Vector2(8.0, 7.0)
	_base_highlight_top.size = Vector2(PLATE_SIZE.x - 16.0, 9.0)
	_base_highlight_left.position = plate_position + Vector2(7.0, 10.0)
	_base_highlight_left.size = Vector2(9.0, PLATE_SIZE.y - 20.0)
	_base_lowlight_bottom.position = plate_position + Vector2(10.0, PLATE_SIZE.y - 14.0)
	_base_lowlight_bottom.size = Vector2(PLATE_SIZE.x - 20.0, 10.0)

	_socket_shadow.position = STICK_SOCKET_CENTER - (SOCKET_SIZE * 0.5) + Vector2(2.0, 3.0)
	_socket_shadow.size = SOCKET_SIZE
	_socket.position = STICK_SOCKET_CENTER - (SOCKET_SIZE * 0.5)
	_socket.size = SOCKET_SIZE

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

	var bottom_button_y := _divider.position.y - BUFF_BUTTON_GAP - BUFF_BUTTON_SIZE.y
	var bottom_button_group_width := (BUFF_BUTTON_SIZE.x * 2.0) + BUFF_BUTTON_GAP
	_buff_button.position = Vector2(
		slot_center_x - (bottom_button_group_width * 0.5),
		bottom_button_y
	)
	_buff_button.size = BUFF_BUTTON_SIZE

	_skill_button.position = Vector2(
		_buff_button.position.x + BUFF_BUTTON_SIZE.x + BUFF_BUTTON_GAP,
		bottom_button_y
	)
	_skill_button.size = BUFF_BUTTON_SIZE

	_update_buff_lock_badge_layout()
	_update_skill_lock_badge_layout()

	_update_arcade_visuals()
	_update_button_state()
	_update_buff_button_state()
	_update_skill_button_state()


func _update_buff_lock_badge_layout() -> void:
	_buff_lock_badge.position = _buff_button.position + Vector2(BUFF_BUTTON_SIZE.x - 20.0, -11.0)
	_buff_lock_badge.size = LOCK_BADGE_SIZE
	_buff_lock_shadow.position = Vector2(6.0, 11.0)
	_buff_lock_shadow.size = LOCK_BODY_SIZE
	_buff_lock_body.position = Vector2(5.0, 10.0)
	_buff_lock_body.size = LOCK_BODY_SIZE
	_buff_lock_keyhole.position = Vector2(14.0, 17.0)
	_buff_lock_keyhole.size = Vector2(4.0, 7.0)
	_buff_lock_spark.position = Vector2(23.0, 7.0)
	_buff_lock_spark.size = Vector2(4.0, 4.0)


func _update_skill_lock_badge_layout() -> void:
	_skill_lock_badge.position = _skill_button.position + Vector2(BUFF_BUTTON_SIZE.x - 20.0, -11.0)
	_skill_lock_badge.size = LOCK_BADGE_SIZE
	_skill_lock_shadow.position = Vector2(6.0, 11.0)
	_skill_lock_shadow.size = LOCK_BODY_SIZE
	_skill_lock_body.position = Vector2(5.0, 10.0)
	_skill_lock_body.size = LOCK_BODY_SIZE
	_skill_lock_keyhole.position = Vector2(14.0, 17.0)
	_skill_lock_keyhole.size = Vector2(4.0, 7.0)
	_skill_lock_spark.position = Vector2(23.0, 7.0)
	_skill_lock_spark.size = Vector2(4.0, 4.0)


func _update_arcade_visuals() -> void:
	var knob_center: Vector2 = KNOB_NEUTRAL_CENTER + _visual_knob_offset
	var direction: Vector2 = Vector2.ZERO
	if _visual_knob_offset.length_squared() > 0.001:
		direction = _visual_knob_offset.normalized()
	var shaft_start: Vector2 = STICK_SOCKET_CENTER + Vector2(0.0, 2.0)
	var shaft_end: Vector2 = knob_center - (direction * 6.0 if not direction.is_zero_approx() else Vector2(0.0, 6.0))

	_shaft_shadow.set_point_position(0, shaft_start + KNOB_SHADOW_OFFSET)
	_shaft_shadow.set_point_position(1, shaft_end + KNOB_SHADOW_OFFSET)
	_shaft.set_point_position(0, shaft_start)
	_shaft.set_point_position(1, shaft_end)

	_knob_shadow.position = knob_center - (KNOB_SIZE * 0.5) + KNOB_SHADOW_OFFSET
	_knob_shadow.size = KNOB_SIZE
	_knob.position = knob_center - (KNOB_SIZE * 0.5)
	_knob.size = KNOB_SIZE
	_knob_shine.position = _knob.position + Vector2(8.0, 7.0)
	_knob_shine.size = KNOB_SHINE_SIZE
	_knob_spec.position = _knob.position + Vector2(15.0, 10.0)
	_knob_spec.size = Vector2(6.0, 6.0)


func _is_dragging_stick() -> bool:
	return _mouse_drag_active or _active_touch_index >= 0


func _sync_play_visibility() -> void:
	visible = GameState.is_playing


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
	var buff_manager = _get_buff_manager()
	if buff_manager != null and bool(buff_manager.call("start_buff_roll")):
		AudioEvents.ui_confirm()
	else:
		AudioEvents.ui_error()
	_update_buff_button_state()


func _on_skill_button_pressed() -> void:
	var skill_manager = _get_skill_manager()
	if skill_manager != null and skill_manager.has_method("request_skill_selection") and bool(skill_manager.call("request_skill_selection")):
		AudioEvents.ui_confirm()
	else:
		AudioEvents.ui_error()
	_update_skill_button_state()


func _on_skill_selected(_skill_id: String, _display_name: String) -> void:
	_update_skill_button_state()


func _update_buff_button_state() -> void:
	if _buff_button == null:
		return
	var buff_manager = _get_buff_manager()
	if buff_manager == null:
		_buff_button.disabled = true
		_buff_button.text = "--"
		_set_buff_lock_visible(false)
		return
	if not GameState.is_playing:
		_buff_button.disabled = true
		_buff_button.text = "--"
		_set_buff_lock_visible(false)
		return

	if bool(buff_manager.call("is_roll_in_progress")):
		_buff_button.disabled = true
		_buff_button.text = "선택중"
		_set_buff_lock_visible(false)
		return

	if bool(buff_manager.call("is_buff_active")):
		_buff_button.disabled = true
		_buff_button.text = "%s\n%d초" % [
			String(buff_manager.call("get_active_buff_display_name")),
			int(buff_manager.call("get_active_time_remaining_ceil"))
		]
		_set_buff_lock_visible(false)
		return

	if bool(buff_manager.call("is_in_cooldown")):
		_buff_button.disabled = true
		_buff_button.text = "대기\n%d" % int(buff_manager.call("get_cooldown_time_remaining_ceil"))
		_set_buff_lock_visible(false)
		return

	if not bool(buff_manager.call("is_buff_unlocked", GameState.current_level_k)):
		_buff_button.disabled = true
		_buff_button.text = "버프\n%d개" % int(buff_manager.call("get_unlock_k"))
		_set_buff_lock_visible(true)
		return

	_buff_button.disabled = not bool(buff_manager.call("can_open_buff", GameState.current_level_k))
	_buff_button.text = "버프"
	_set_buff_lock_visible(false)


func _update_skill_button_state() -> void:
	if _skill_button == null:
		return

	var skill_manager = _get_skill_manager()
	if skill_manager == null:
		_skill_button.disabled = true
		_skill_button.text = "--"
		_set_skill_lock_visible(false)
		return

	if not GameState.is_playing:
		_skill_button.disabled = true
		_skill_button.text = "--"
		_set_skill_lock_visible(false)
		return

	var buff_manager = _get_buff_manager()
	if buff_manager != null and buff_manager.has_method("is_roll_in_progress"):
		if bool(buff_manager.call("is_roll_in_progress")):
			_skill_button.disabled = true
			_skill_button.text = "선택중"
			_set_skill_lock_visible(false)
			return

	if GameState.current_level_k < 1000:
		_skill_button.disabled = true
		_skill_button.text = "패시브\n1000개"
		_set_skill_lock_visible(true)
		return

	if skill_manager.has_method("is_skill_panel_open") and bool(skill_manager.call("is_skill_panel_open")):
		_skill_button.disabled = true
		_skill_button.text = "선택중"
		_set_skill_lock_visible(false)
		return

	var display_name := ""
	if skill_manager.has_method("get_selected_skill_display_name"):
		display_name = String(skill_manager.call("get_selected_skill_display_name"))

	_skill_button.disabled = false
	if display_name == "":
		_skill_button.text = "패시브\n선택"
	else:
		_skill_button.text = "패시브\n%s" % display_name
	_set_skill_lock_visible(false)


func _get_buff_manager():
	if _buff_manager == null or not is_instance_valid(_buff_manager):
		_buff_manager = get_node_or_null("/root/BuffManager")
	return _buff_manager


func _get_skill_manager():
	if _skill_manager == null or not is_instance_valid(_skill_manager):
		_skill_manager = get_node_or_null("/root/SkillManager")
	return _skill_manager


func _set_buff_lock_visible(is_visible: bool) -> void:
	if _buff_lock_badge != null:
		_buff_lock_badge.visible = is_visible


func _set_skill_lock_visible(is_visible: bool) -> void:
	if _skill_lock_badge != null:
		_skill_lock_badge.visible = is_visible
