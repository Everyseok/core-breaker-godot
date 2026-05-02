extends Control
# ConfirmExitDialog — user-initiated exit confirm (C-20).
# Centered overlay, not a bottom sheet (C-08/C-09). Works while paused.

@onready var _stay_btn: Button = $Panel/StayButton
@onready var _leave_btn: Button = $Panel/LeaveButton


func _ready() -> void:
	visible = false
	add_to_group("exit_dialog")
	_stay_btn.pressed.connect(_on_stay)
	_leave_btn.pressed.connect(_on_leave)


func show_dialog() -> void:
	visible = true


func _on_stay() -> void:
	visible = false


func _on_leave() -> void:
	visible = false
	PlatformBridge.request_close()
