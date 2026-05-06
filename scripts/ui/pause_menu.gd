extends Control
# PauseMenu — in-game pause overlay.

const UiStyleRef := preload("res://scripts/ui/ui_style.gd")

@onready var _dim_overlay: ColorRect = $DimOverlay
@onready var _plate_shadow: ColorRect = $PausePlateShadow
@onready var _plate: Panel = $PausePlate
@onready var _trim_top: ColorRect = $PausePlate/PauseTrimTop
@onready var _trim_bottom: ColorRect = $PausePlate/PauseTrimBottom
@onready var _title_shadow: Label = $PausePlate/PauseTitleShadow
@onready var _title: Label = $PausePlate/PauseTitle
@onready var _resume_btn: Button = $PausePlate/ResumeButton
@onready var _ranking_btn: Button = $PausePlate/RankingButton
@onready var _sound_btn: Button = $PausePlate/SoundToggleButton
@onready var _restart_btn: Button = $PausePlate/RestartButton
@onready var _ranking_status_label: Label = $PausePlate/RankingStatusLabel

var _ranking_feedback_token: int = 0


func _ready() -> void:
	visible = false
	add_to_group("pause_menu")
	_resume_btn.pressed.connect(_resume)
	_ranking_btn.pressed.connect(_open_ranking)
	_sound_btn.pressed.connect(_toggle_sound)
	_restart_btn.pressed.connect(_restart)
	if not PlatformBridge.leaderboard_open_failed.is_connected(_on_leaderboard_open_failed):
		PlatformBridge.leaderboard_open_failed.connect(_on_leaderboard_open_failed)
	_apply_style()
	_clear_ranking_feedback()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if not GameState.is_playing:
		return
	if _is_weapon_choice_panel_visible():
		return
	if visible:
		_resume()
	else:
		show_menu()
	get_viewport().set_input_as_handled()


func show_menu() -> void:
	_update_sound_label()
	_clear_ranking_feedback()
	visible = true
	get_tree().paused = true
	AudioEvents.ui_pause()


func _resume() -> void:
	_clear_ranking_feedback()
	get_tree().paused = false
	visible = false
	AudioEvents.ui_resume()


func _toggle_sound() -> void:
	AudioManager.set_sound_enabled(not AudioManager.get_sound_enabled())
	_update_sound_label()
	AudioEvents.ui_switch()


func _open_ranking() -> void:
	AudioEvents.ui_tap()
	_clear_ranking_feedback()
	PlatformBridge.open_leaderboard()


func _restart() -> void:
	_clear_ranking_feedback()
	get_tree().paused = false
	visible = false
	AudioEvents.ui_confirm()
	var roots: Array = get_tree().get_nodes_in_group("game_root")
	if roots.is_empty():
		get_tree().reload_current_scene()
		return
	roots[0].start_game()


func _update_sound_label() -> void:
	_sound_btn.text = "소리 켜짐" if AudioManager.get_sound_enabled() else "소리 꺼짐"


func _apply_style() -> void:
	_dim_overlay.color = Color(0.12, 0.18, 0.28, 0.42)
	_plate_shadow.color = Color(0.32, 0.22, 0.08, 0.18)
	_trim_top.color = Color(1.0, 1.0, 1.0, 0.42)
	_trim_bottom.color = Color(1.0, 0.62, 0.22, 0.62)
	UiStyleRef.apply_menu_plate(_plate)
	UiStyleRef.apply_menu_title(_title_shadow, 28, UiStyleRef.MENU_TITLE_SHADOW, 0)
	UiStyleRef.apply_menu_title(_title, 28, Color(1.0, 0.95, 0.44), 6)
	UiStyleRef.apply_arcade_button(_resume_btn, UiStyleRef.MENU_PRIMARY_FILL, UiStyleRef.MENU_PRIMARY_BORDER, Color.WHITE, 22)
	UiStyleRef.apply_arcade_button(_ranking_btn, UiStyleRef.MENU_SECONDARY_FILL, UiStyleRef.MENU_SECONDARY_BORDER, Color.WHITE, 21)
	UiStyleRef.apply_arcade_button(_sound_btn, UiStyleRef.MENU_SUCCESS_FILL, UiStyleRef.MENU_SUCCESS_BORDER, Color.WHITE, 21)
	UiStyleRef.apply_arcade_button(_restart_btn, UiStyleRef.MENU_DANGER_FILL, UiStyleRef.MENU_DANGER_BORDER, Color.WHITE, 21)
	UiStyleRef.apply_label(_ranking_status_label, 14, UiStyleRef.TEXT_SUB, 4)
	_title_shadow.position = _title.position + Vector2(4.0, 5.0)
	_title_shadow.modulate = Color(1.0, 1.0, 1.0, 0.96)
	_ranking_status_label.add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.08, 0.96))
	_ranking_status_label.modulate = Color(1.0, 1.0, 1.0, 0.94)


func _is_weapon_choice_panel_visible() -> bool:
	var panels := get_tree().get_nodes_in_group("weapon_choice_panel")
	for panel_variant in panels:
		var panel := panel_variant as Control
		if panel != null and panel.visible:
			return true
	return false


func _on_leaderboard_open_failed(message: String) -> void:
	if not visible:
		return
	AudioEvents.ui_error()
	_show_ranking_feedback(message)


func _show_ranking_feedback(message: String) -> void:
	_ranking_feedback_token += 1
	var token := _ranking_feedback_token
	_ranking_status_label.text = message
	_ranking_status_label.visible = message != ""
	if message == "":
		return
	var timer := get_tree().create_timer(2.6, true)
	timer.timeout.connect(func() -> void:
		if token != _ranking_feedback_token:
			return
		_clear_ranking_feedback()
	)


func _clear_ranking_feedback() -> void:
	_ranking_feedback_token += 1
	_ranking_status_label.text = ""
	_ranking_status_label.visible = false
