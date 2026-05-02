extends Control
# OverclockSlot — presentation/controller for the shared Overclock buff state.

@onready var _bg: ColorRect = $BG
@onready var _label: Label = $Label
@onready var _cooldown_label: Label = $CooldownLabel


func _ready() -> void:
	_update_visuals()


func _process(_delta: float) -> void:
	_update_visuals()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_activate()
	elif event is InputEventScreenTouch and event.pressed:
		_try_activate()


func _try_activate() -> void:
	var weapon = _get_weapon()
	if weapon == null or not is_instance_valid(weapon):
		return
	weapon.activate_overclock()


func _update_visuals() -> void:
	var weapon = _get_weapon()
	if weapon == null or not is_instance_valid(weapon):
		_bg.color = Color(0.12, 0.12, 0.12)
		_label.text = "--"
		_label.visible = true
		_cooldown_label.visible = false
		return

	if not weapon.is_overclock_unlocked():
		_bg.color = Color(0.16, 0.16, 0.16)
		_label.text = "LOCK"
		_label.visible = true
		_cooldown_label.visible = false
		return

	if weapon.is_overclock_active():
		_bg.color = Color(0.8, 0.65, 0.05)
		_label.text = "OC!"
		_label.visible = true
		_cooldown_label.visible = false
		return

	if weapon.is_overclock_on_cooldown():
		_bg.color = Color(0.22, 0.22, 0.22)
		_label.visible = false
		_cooldown_label.visible = true
		_cooldown_label.text = "%d" % maxi(ceili(weapon.get_overclock_remaining_time()), 0)
		return

	_bg.color = Color(0.15, 0.55, 0.15)
	_label.text = "OC"
	_label.visible = true
	_cooldown_label.visible = false


func _get_weapon():
	var weapons := get_tree().get_nodes_in_group("weapon")
	if weapons.is_empty():
		return null
	return weapons[0]
