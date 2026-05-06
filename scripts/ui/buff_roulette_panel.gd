extends Control
# BuffRoulettePanel — pause-safe random buff reveal overlay.

const UiStyleRef := preload("res://scripts/ui/ui_style.gd")

const ROLL_DURATION: float = 1.35
const REVEAL_DURATION: float = 0.55
const TICK_INTERVAL: float = 0.075

@onready var _panel: Panel = $Panel
@onready var _title_label: Label = $Panel/TitleLabel
@onready var _reel_label: Label = $Panel/ReelLabel
@onready var _message_label: Label = $Panel/MessageLabel

var _names: Array = []
var _name_index: int = 0
var _roll_elapsed: float = 0.0
var _tick_elapsed: float = 0.0
var _reveal_elapsed: float = 0.0
var _rolling: bool = false
var _revealing: bool = false
var _paused_by_panel: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	BuffManager.buff_roll_requested.connect(_show_roll)
	GameState.game_started.connect(_force_hide)
	GameState.game_over.connect(_force_hide)
	GameState.max_level_cleared.connect(_force_hide)
	_apply_style()


func _process(delta: float) -> void:
	if _rolling:
		_process_roll(delta)
		return
	if _revealing:
		_reveal_elapsed += delta
		if _reveal_elapsed >= REVEAL_DURATION:
			_finish_roll()


func _show_roll() -> void:
	_names = BuffManager.get_available_buff_display_names()
	if _names.is_empty():
		BuffManager.apply_selected_buff("")
		return
	_name_index = 0
	_roll_elapsed = 0.0
	_tick_elapsed = 0.0
	_reveal_elapsed = 0.0
	_rolling = true
	_revealing = false
	_reel_label.text = String(_names[_name_index])
	_message_label.text = "뾰로로로롱..."
	visible = true
	_pause_gameplay()
	AudioEvents.ui_menu_open()


func _process_roll(delta: float) -> void:
	_roll_elapsed += delta
	_tick_elapsed += delta
	if _tick_elapsed >= TICK_INTERVAL:
		_tick_elapsed = 0.0
		_name_index = (_name_index + 1) % _names.size()
		_reel_label.text = String(_names[_name_index])
		AudioEvents.ui_switch()
	if _roll_elapsed < ROLL_DURATION:
		return
	var selected_buff_id := BuffManager.roll_random_buff_id()
	_rolling = false
	_revealing = true
	_reveal_elapsed = 0.0
	_reel_label.text = BuffManager.get_buff_display_name(selected_buff_id)
	_message_label.text = "선택 완료!"
	if BuffManager.apply_selected_buff(selected_buff_id):
		AudioEvents.ui_confirm()
	else:
		AudioEvents.ui_error()


func _finish_roll() -> void:
	visible = false
	_revealing = false
	_resume_gameplay()


func _force_hide() -> void:
	visible = false
	_rolling = false
	_revealing = false
	_resume_gameplay()


func _pause_gameplay() -> void:
	if get_tree().paused:
		return
	get_tree().paused = true
	_paused_by_panel = true


func _resume_gameplay() -> void:
	if not _paused_by_panel:
		return
	get_tree().paused = false
	_paused_by_panel = false


func _apply_style() -> void:
	UiStyleRef.apply_panel(_panel, UiStyleRef.PANEL_DARK, UiStyleRef.PANEL_BORDER)
	UiStyleRef.apply_menu_title(_title_label, 25, UiStyleRef.TEXT_MAIN, 5)
	UiStyleRef.apply_menu_title(_reel_label, 23, Color(0.18, 0.34, 0.72), 5)
	UiStyleRef.apply_label(_message_label, 16, UiStyleRef.TEXT_SUB, 4)
