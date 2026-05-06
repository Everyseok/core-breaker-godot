extends Control
# MainMenu — title screen overlay shown on app launch.

const UiStyleRef := preload("res://scripts/ui/ui_style.gd")
const BACKGROUND_CANDIDATES := [
	"res://assets/backgrounds/mainbackground.png",
	"res://mainbackground.png",
]

@onready var _background_fallback: ColorRect = $BackgroundFallback
@onready var _background_texture: TextureRect = $BackgroundTexture
@onready var _top_overlay: ColorRect = $TopOverlay
@onready var _bottom_overlay: ColorRect = $BottomOverlay
@onready var _left_vignette: ColorRect = $LeftVignette
@onready var _right_vignette: ColorRect = $RightVignette
@onready var _title_shadow: Label = $TitleShadow
@onready var _title_label: Label = $TitleLabel
@onready var _best_label: Label = $BestLabel
@onready var _menu_trim: ColorRect = $MenuTrim
@onready var _start_btn: Button = $StartButton
@onready var _ranking_btn: Button = $RankingButton
@onready var _ranking_status_label: Label = $RankingStatusLabel

var _loaded_background_path: String = ""
var _ranking_feedback_token: int = 0


func _ready() -> void:
	visible = true
	_start_btn.pressed.connect(_on_start_pressed)
	_ranking_btn.pressed.connect(_on_ranking_pressed)
	GameState.game_started.connect(_on_game_started)
	visibility_changed.connect(_on_visibility_changed)
	if not SaveManager.best_record_changed.is_connected(_on_best_record_changed):
		SaveManager.best_record_changed.connect(_on_best_record_changed)
	if not PlatformBridge.leaderboard_open_failed.is_connected(_on_leaderboard_open_failed):
		PlatformBridge.leaderboard_open_failed.connect(_on_leaderboard_open_failed)
	_apply_style()
	_load_background_texture()
	_update_best_label()
	_clear_ranking_feedback()
	AudioEvents.bgm_set_state(&"title", 0.0)


func _apply_style() -> void:
	_background_fallback.color = Color(0.86, 0.94, 1.0)
	_top_overlay.color = Color(1.0, 0.88, 0.50, 0.10)
	_bottom_overlay.color = Color(0.50, 0.78, 1.0, 0.16)
	_left_vignette.color = Color(1.0, 0.82, 0.42, 0.08)
	_right_vignette.color = Color(0.48, 0.80, 1.0, 0.08)
	_menu_trim.color = Color(1.0, 0.74, 0.30, 0.28)

	UiStyleRef.apply_menu_title(_title_shadow, 30, UiStyleRef.MENU_TITLE_SHADOW, 0)
	UiStyleRef.apply_menu_title(_title_label, 30, Color(1.0, 0.95, 0.44), 6)
	UiStyleRef.apply_display_label(_best_label, 18, UiStyleRef.READY_YELLOW, 4)
	UiStyleRef.apply_arcade_button(_start_btn, UiStyleRef.MENU_PRIMARY_FILL, UiStyleRef.MENU_PRIMARY_BORDER, Color.WHITE, 24)
	UiStyleRef.apply_arcade_button(_ranking_btn, UiStyleRef.MENU_SECONDARY_FILL, UiStyleRef.MENU_SECONDARY_BORDER, Color.WHITE, 21)
	UiStyleRef.apply_label(_ranking_status_label, 14, UiStyleRef.TEXT_SUB, 4)

	_title_shadow.position = _title_label.position + Vector2(4.0, 5.0)
	_title_shadow.modulate = Color(1.0, 1.0, 1.0, 0.96)
	_best_label.add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.08, 0.94))
	_ranking_status_label.add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.08, 0.96))
	_ranking_status_label.modulate = Color(1.0, 1.0, 1.0, 0.94)
	_background_texture.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _load_background_texture() -> void:
	_background_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_background_texture.texture = null
	_loaded_background_path = ""
	for path in BACKGROUND_CANDIDATES:
		if not ResourceLoader.exists(path):
			continue
		var texture := load(path) as Texture2D
		if texture == null:
			continue
		_background_texture.texture = texture
		_loaded_background_path = path
		break
	_background_texture.visible = _background_texture.texture != null
	_background_fallback.visible = not _background_texture.visible
	_refresh_title_visibility()


func get_loaded_background_path() -> String:
	return _loaded_background_path


func _update_best_label() -> void:
	_best_label.text = "최고 기록 %d개" % SaveManager.get_best_record_value()


func _refresh_title_visibility() -> void:
	var uses_baked_title := _background_texture.visible and _loaded_background_path.get_file().to_lower() == "mainbackground.png"
	_title_shadow.visible = not uses_baked_title
	_title_label.visible = not uses_baked_title
	_menu_trim.visible = not uses_baked_title


func _on_visibility_changed() -> void:
	if visible:
		_update_best_label()
		_clear_ranking_feedback()
		AudioEvents.bgm_set_state(&"title", 0.0)


func _on_best_record_changed(_best_value: int) -> void:
	_update_best_label()


func _on_start_pressed() -> void:
	var roots: Array = get_tree().get_nodes_in_group("game_root")
	if roots.is_empty():
		push_error("[MainMenu] 'game_root' group not found")
		return
	visible = false
	roots[0].start_game()


func _on_ranking_pressed() -> void:
	AudioEvents.ui_tap()
	_clear_ranking_feedback()
	PlatformBridge.open_leaderboard()


func _on_game_started() -> void:
	visible = false


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
	var timer := get_tree().create_timer(2.6)
	timer.timeout.connect(func() -> void:
		if token != _ranking_feedback_token:
			return
		_clear_ranking_feedback()
	)


func _clear_ranking_feedback() -> void:
	_ranking_feedback_token += 1
	_ranking_status_label.text = ""
	_ranking_status_label.visible = false
