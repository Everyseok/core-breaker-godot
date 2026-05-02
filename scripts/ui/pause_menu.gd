extends Control
# PauseMenu — in-game pause overlay.
# process_mode = ALWAYS so this node operates while get_tree().paused = true.
# No bottom-sheet coercion (C-08, C-09). Accessible from all gameplay screens (C-10).

@onready var _sound_btn: Button = $SoundToggleButton
@onready var _resume_btn: Button = $ResumeButton
@onready var _restart_btn: Button = $RestartButton


func _ready() -> void:
	visible = false
	add_to_group("pause_menu")
	_resume_btn.pressed.connect(_resume)
	_sound_btn.pressed.connect(_toggle_sound)
	_restart_btn.pressed.connect(_restart)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if not GameState.is_playing:
		return
	if visible:
		_resume()
	else:
		show_menu()
	get_viewport().set_input_as_handled()


func show_menu() -> void:
	_update_sound_label()
	visible = true
	get_tree().paused = true


func _resume() -> void:
	get_tree().paused = false
	visible = false


func _toggle_sound() -> void:
	AudioManager.set_sound_enabled(not AudioManager.get_sound_enabled())
	_update_sound_label()


func _restart() -> void:
	get_tree().paused = false
	visible = false
	var roots: Array = get_tree().get_nodes_in_group("game_root")
	if roots.is_empty():
		get_tree().reload_current_scene()
		return
	roots[0].start_game()


func _update_sound_label() -> void:
	_sound_btn.text = "Sound: ON" if AudioManager.get_sound_enabled() else "Sound: OFF"
