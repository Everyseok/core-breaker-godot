extends Control
# ConfirmExitDialog — user-initiated exit confirm (C-20).
# Centered overlay, not a bottom sheet (C-08/C-09). Works while paused.

const UiStyleRef := preload("res://scripts/ui/ui_style.gd")

@onready var _message_label: Label = $Panel/MessageLabel
@onready var _stay_btn: Button = $Panel/StayButton
@onready var _leave_btn: Button = $Panel/LeaveButton


func _ready() -> void:
	visible = false
	add_to_group("exit_dialog")
	_stay_btn.pressed.connect(_on_stay)
	_leave_btn.pressed.connect(_on_leave)
	UiStyleRef.apply_panel($Panel, UiStyleRef.PANEL_SOFT, UiStyleRef.PANEL_BORDER)
	UiStyleRef.apply_label(_message_label, 20, Color.WHITE, 4)
	UiStyleRef.apply_button(_stay_btn, Color(0.16, 0.52, 0.88), Color(0.58, 0.86, 1.0), Color.WHITE, 18)
	UiStyleRef.apply_button(_leave_btn, Color(0.58, 0.18, 0.22), Color(1.0, 0.66, 0.68), Color.WHITE, 18)


func show_dialog() -> void:
	visible = true
	AudioEvents.ui_menu_open()


func _on_stay() -> void:
	visible = false
	AudioEvents.ui_menu_close()


func _on_leave() -> void:
	visible = false
	AudioEvents.ui_confirm()
	PlatformBridge.request_close()
