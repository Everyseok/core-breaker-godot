extends Control
# HUD — single wide reference-style top band. The scene owns the node tree;
# this script only styles, lays out, and updates the active HUD nodes.

@onready var _hud_band_shadow: ColorRect = $HudBandShadow
@onready var _hud_band: Panel = $HudBand
@onready var _hud_top_trim: ColorRect = $HudTopTrim
@onready var _hud_bottom_trim: ColorRect = $HudBottomTrim

@onready var _level_gauge: ProgressBar = $LevelGauge
@onready var _gauge_fill_mask: Control = $LevelGauge/GaugeFillMask
@onready var _gauge_fill_rect: ColorRect = $LevelGauge/GaugeFillMask/GaugeFillRect
@onready var _gauge_stripe_root: Control = $LevelGauge/GaugeFillMask/GaugeStripeRoot
@onready var _gauge_shine: ColorRect = $LevelGauge/GaugeFillMask/GaugeShine
@onready var _level_label: Label = $LevelGauge/LevelLabel

@onready var _threshold_module: Control = $ThresholdWeaponModule
@onready var _threshold_accent_line: ColorRect = $ThresholdWeaponModule/ThresholdAccentLine
@onready var _threshold_icon_holder: Control = $ThresholdWeaponModule/ThresholdIconHolder
@onready var _threshold_value_label: Label = $ThresholdWeaponModule/ThresholdValueLabel
@onready var _threshold_name_label: Label = $ThresholdWeaponModule/ThresholdNameLabel

@onready var _main_number_shadow_label: Label = $MainNumberShadowLabel
@onready var _main_number_label: Label = $MainNumberLabel

@onready var _pause_btn: Button = $PauseButton
@onready var _pause_bar_left_shadow: ColorRect = $PauseButton/PauseBarLeftShadow
@onready var _pause_bar_right_shadow: ColorRect = $PauseButton/PauseBarRightShadow
@onready var _pause_bar_left: ColorRect = $PauseButton/PauseBarLeft
@onready var _pause_bar_right: ColorRect = $PauseButton/PauseBarRight

@onready var _divider: ColorRect = $Divider

@onready var _current_weapon_module: Control = $CurrentWeaponModule
@onready var _current_weapon_accent: ColorRect = $CurrentWeaponModule/CurrentWeaponAccent
@onready var _weapon_label: Label = $CurrentWeaponModule/WeaponLabel
@onready var _best_label: Label = $BestKLabel

@onready var _weapon_flash: ColorRect = $WeaponFlash
@onready var _weapon_impact_label: Label = $WeaponImpactLabel

const UiStyleRef := preload("res://scripts/ui/ui_style.gd")
const WeaponProfileRef := preload("res://scripts/visual/weapon_profile.gd")

const HUD_MARGIN_X: float = 4.0
const HUD_TOP: float = 4.0
const HUD_HEIGHT: float = 126.0
const HUD_SHADOW_OFFSET: Vector2 = Vector2(0.0, 4.0)
const INNER_MARGIN_X: float = 10.0
const TOP_GAUGE_Y: float = 8.0
const LEVEL_GAUGE_HEIGHT: float = 24.0
const MAIN_ROW_Y: float = 44.0
const THRESHOLD_HEIGHT: float = 34.0
const THRESHOLD_GAP: float = 12.0
const THRESHOLD_SHORT_WIDTH: float = 100.0
const THRESHOLD_LONG_WIDTH: float = 114.0
const MAIN_NUMBER_HEIGHT: float = 52.0
const MAIN_NUMBER_FONT_SIZE_SMALL: int = 46
const MAIN_NUMBER_FONT_SIZE_LARGE: int = 42
const MAIN_NUMBER_SHADOW_OFFSET: Vector2 = Vector2(4.0, 4.0)
const PAUSE_SIZE: Vector2 = Vector2(40.0, 36.0)
const DIVIDER_Y: float = 90.0
const CURRENT_WEAPON_ROW_Y: float = 100.0
const CURRENT_WEAPON_WIDTH: float = 184.0
const CURRENT_WEAPON_HEIGHT: float = 20.0
const BEST_LABEL_WIDTH: float = 112.0
const STRIPE_STEP: float = 18.0

const HUD_SURFACE_COLOR := Color(0.98, 0.94, 0.78, 0.86)
const HUD_SHADOW_COLOR := Color(0.32, 0.22, 0.08, 0.24)
const HUD_TOP_TRIM_COLOR := Color(1.0, 1.0, 1.0, 0.72)
const HUD_BOTTOM_TRIM_COLOR := Color(1.0, 0.70, 0.26, 0.88)
const GAUGE_TRACK_COLOR := Color(0.62, 0.74, 0.92, 0.94)
const GAUGE_BORDER_COLOR := Color(0.24, 0.42, 0.78, 0.84)
const GAUGE_FILL_COLOR := Color(0.18, 0.58, 0.96, 0.58)
const GAUGE_SHINE_COLOR := Color(0.92, 0.98, 1.0, 0.36)
const HUD_TEXT_COLOR := Color(0.11, 0.16, 0.30)
const HUD_TEXT_OUTLINE_COLOR := Color(1.0, 0.96, 0.78, 0.96)
const NUMBER_MAIN_COLOR := Color(0.10, 0.18, 0.32)
const NUMBER_SHADOW_COLOR := Color(1.0, 0.92, 0.58, 0.72)
const NUMBER_OUTLINE_COLOR := Color(1.0, 0.98, 0.76, 0.98)
const THRESHOLD_BASE_ACCENT := Color(1.0, 0.62, 0.20, 0.92)
const DIVIDER_COLOR := Color(0.46, 0.64, 0.96, 0.72)
const PAUSE_BG_COLOR := Color(0.36, 0.68, 1.0, 0.98)
const PAUSE_BG_HOVER_COLOR := Color(0.46, 0.76, 1.0, 1.0)
const PAUSE_BG_PRESSED_COLOR := Color(0.24, 0.54, 0.92, 1.0)
const PAUSE_BORDER_COLOR := Color(0.98, 0.98, 1.0, 0.86)
const PAUSE_BORDER_HOVER_COLOR := Color(1.0, 0.90, 0.36, 0.92)
const PAUSE_BAR_COLOR := Color.WHITE
const PAUSE_BAR_SHADOW_COLOR := Color(0.34, 0.88, 1.0, 0.56)

const LEGACY_HUD_NODE_NAMES := [
	"ShellPanel",
	"ShellTopTrim",
	"ShellBottomTrim",
	"ThresholdShadow",
	"ThresholdPanel",
	"MainNumberGlow",
	"CurrentWeaponShadow",
	"CurrentWeaponPanel",
]

var _weapon_chip_tween: Tween
var _weapon_impact_tween: Tween
var _current_weapon_name: String = "화살"


func _ready() -> void:
	_cleanup_old_hud_nodes_if_needed()
	_connect_signals()
	_apply_reference_styles()
	_layout_reference_hud()
	_refresh_all()
	if not resized.is_connected(_on_resized):
		resized.connect(_on_resized)


func _connect_signals() -> void:
	GameState.k_changed.connect(_on_k_changed)
	GameState.unlock_progress_changed.connect(_on_unlock_progress_changed)
	GameState.progression_display_changed.connect(_on_progression_display_changed)
	GameState.game_started.connect(_on_game_started)
	GameState.tier_changed.connect(_on_tier_changed)
	GameState.tier_threshold_reached.connect(_on_tier_threshold_reached)
	GameState.weapon_choice_selected.connect(_on_weapon_choice_selected)
	if not SaveManager.best_record_changed.is_connected(_on_best_record_changed):
		SaveManager.best_record_changed.connect(_on_best_record_changed)
	_pause_btn.pressed.connect(_on_pause_pressed)


func _cleanup_old_hud_nodes_if_needed() -> void:
	for child in get_children():
		if child.name in LEGACY_HUD_NODE_NAMES:
			child.queue_free()


func _apply_reference_styles() -> void:
	_apply_hud_band_style()
	_style_level_gauge()
	_style_threshold_module()
	_style_number_labels(MAIN_NUMBER_FONT_SIZE_SMALL)
	_style_pause_button()
	_style_current_weapon_row()

	UiStyleRef.apply_display_label(_best_label, 12, HUD_TEXT_COLOR, 4)
	UiStyleRef.apply_display_label(_weapon_impact_label, 17, UiStyleRef.READY_YELLOW, 4)
	_best_label.add_theme_color_override("font_outline_color", HUD_TEXT_OUTLINE_COLOR)
	_best_label.text = _format_best_label()
	_weapon_flash.visible = false
	_weapon_impact_label.visible = false


func _apply_hud_band_style() -> void:
	_hud_band_shadow.color = HUD_SHADOW_COLOR
	_hud_top_trim.color = HUD_TOP_TRIM_COLOR
	_hud_bottom_trim.color = HUD_BOTTOM_TRIM_COLOR

	var band_box := StyleBoxFlat.new()
	band_box.bg_color = HUD_SURFACE_COLOR
	band_box.border_width_bottom = 1
	band_box.border_color = Color(0.95, 0.62, 0.24, 0.70)
	band_box.corner_radius_bottom_left = 18
	band_box.corner_radius_bottom_right = 18
	band_box.shadow_color = Color(0.0, 0.0, 0.0, 0.0)
	_hud_band.add_theme_stylebox_override("panel", band_box)


func _style_level_gauge() -> void:
	var background := StyleBoxFlat.new()
	background.bg_color = GAUGE_TRACK_COLOR
	background.border_color = GAUGE_BORDER_COLOR
	background.border_width_left = 1
	background.border_width_top = 1
	background.border_width_right = 1
	background.border_width_bottom = 1
	background.corner_radius_top_left = 12
	background.corner_radius_top_right = 12
	background.corner_radius_bottom_left = 12
	background.corner_radius_bottom_right = 12
	_level_gauge.add_theme_stylebox_override("background", background)

	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	fill.border_width_left = 0
	fill.border_width_top = 0
	fill.border_width_right = 0
	fill.border_width_bottom = 0
	_level_gauge.add_theme_stylebox_override("fill", fill)

	_gauge_fill_rect.color = GAUGE_FILL_COLOR
	_gauge_shine.color = GAUGE_SHINE_COLOR
	UiStyleRef.apply_display_label(_level_label, 15, HUD_TEXT_COLOR, 4)
	_level_label.add_theme_color_override("font_outline_color", HUD_TEXT_OUTLINE_COLOR)


func _style_threshold_module() -> void:
	UiStyleRef.apply_label(_threshold_value_label, 11, HUD_TEXT_COLOR, 4)
	UiStyleRef.apply_display_label(_threshold_name_label, 13, HUD_TEXT_COLOR, 4)
	_threshold_value_label.add_theme_color_override("font_outline_color", HUD_TEXT_OUTLINE_COLOR)
	_threshold_name_label.add_theme_color_override("font_outline_color", HUD_TEXT_OUTLINE_COLOR)
	_threshold_accent_line.color = THRESHOLD_BASE_ACCENT


func _style_number_labels(font_size: int) -> void:
	_main_number_shadow_label.add_theme_font_override("font", UiStyleRef.get_font())
	_main_number_shadow_label.add_theme_font_size_override("font_size", font_size)
	_main_number_shadow_label.add_theme_color_override("font_color", NUMBER_SHADOW_COLOR)
	_main_number_shadow_label.add_theme_constant_override("outline_size", 0)

	_main_number_label.add_theme_font_override("font", UiStyleRef.get_font())
	_main_number_label.add_theme_font_size_override("font_size", font_size)
	_main_number_label.add_theme_color_override("font_color", NUMBER_MAIN_COLOR)
	_main_number_label.add_theme_color_override("font_outline_color", NUMBER_OUTLINE_COLOR)
	_main_number_label.add_theme_constant_override("outline_size", 4)


func _style_pause_button() -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = PAUSE_BG_COLOR
	normal.border_color = PAUSE_BORDER_COLOR
	normal.border_width_left = 1
	normal.border_width_top = 1
	normal.border_width_right = 1
	normal.border_width_bottom = 2
	normal.corner_radius_top_left = 17
	normal.corner_radius_top_right = 17
	normal.corner_radius_bottom_left = 17
	normal.corner_radius_bottom_right = 17
	normal.shadow_color = Color(0.0, 0.0, 0.0, 0.28)
	normal.shadow_size = 6

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = PAUSE_BG_HOVER_COLOR
	hover.border_color = PAUSE_BORDER_HOVER_COLOR

	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = PAUSE_BG_PRESSED_COLOR
	pressed.shadow_size = 3

	_pause_btn.add_theme_stylebox_override("normal", normal)
	_pause_btn.add_theme_stylebox_override("hover", hover)
	_pause_btn.add_theme_stylebox_override("pressed", pressed)
	_pause_btn.add_theme_stylebox_override("focus", hover)
	_pause_btn.text = ""
	_pause_btn.focus_mode = Control.FOCUS_NONE
	_pause_bar_left_shadow.color = PAUSE_BAR_SHADOW_COLOR
	_pause_bar_right_shadow.color = PAUSE_BAR_SHADOW_COLOR
	_pause_bar_left.color = PAUSE_BAR_COLOR
	_pause_bar_right.color = PAUSE_BAR_COLOR


func _style_current_weapon_row() -> void:
	_current_weapon_accent.color = THRESHOLD_BASE_ACCENT
	UiStyleRef.apply_display_label(_weapon_label, 15, HUD_TEXT_COLOR, 4)
	_weapon_label.add_theme_color_override("font_outline_color", HUD_TEXT_OUTLINE_COLOR)


func _layout_reference_hud() -> void:
	var viewport_width: float = size.x if size.x > 0.0 else 390.0
	var band_x: float = HUD_MARGIN_X
	var band_width: float = maxf(viewport_width - (HUD_MARGIN_X * 2.0), 340.0)
	var gauge_x: float = band_x + INNER_MARGIN_X
	var gauge_y: float = HUD_TOP + TOP_GAUGE_Y
	var gauge_width: float = band_width - (INNER_MARGIN_X * 2.0)
	var threshold_width: float = _get_threshold_module_width()
	var threshold_x: float = band_x + INNER_MARGIN_X
	var threshold_y: float = HUD_TOP + MAIN_ROW_Y + 3.0
	var pause_x: float = band_x + band_width - INNER_MARGIN_X - PAUSE_SIZE.x
	var number_x: float = threshold_x + threshold_width + THRESHOLD_GAP
	var number_width: float = maxf((pause_x - 8.0) - number_x, 96.0)
	var current_weapon_x: float = band_x + INNER_MARGIN_X
	var best_x: float = band_x + band_width - INNER_MARGIN_X - BEST_LABEL_WIDTH

	_set_rect(_hud_band_shadow, Vector2(band_x, HUD_TOP) + HUD_SHADOW_OFFSET, Vector2(band_width, HUD_HEIGHT))
	_set_rect(_hud_band, Vector2(band_x, HUD_TOP), Vector2(band_width, HUD_HEIGHT))
	_set_rect(_hud_top_trim, Vector2(band_x + 10.0, HUD_TOP + 4.0), Vector2(band_width - 20.0, 2.0))
	_set_rect(_hud_bottom_trim, Vector2(band_x + 10.0, HUD_TOP + HUD_HEIGHT - 4.0), Vector2(band_width - 20.0, 2.0))

	_set_rect(_level_gauge, Vector2(gauge_x, gauge_y), Vector2(gauge_width, LEVEL_GAUGE_HEIGHT))
	_set_rect(_gauge_fill_mask, Vector2(4.0, 4.0), Vector2(maxf(_level_gauge.size.x - 8.0, 0.0), maxf(_level_gauge.size.y - 8.0, 0.0)))
	_set_rect(_gauge_fill_rect, Vector2.ZERO, _gauge_fill_mask.size)
	_set_rect(_gauge_stripe_root, Vector2.ZERO, _gauge_fill_mask.size)
	_set_rect(_gauge_shine, Vector2(0.0, 0.0), Vector2(_gauge_fill_mask.size.x, 5.0))
	_set_rect(_level_label, Vector2.ZERO, _level_gauge.size)

	_set_rect(_threshold_module, Vector2(threshold_x, threshold_y), Vector2(threshold_width, THRESHOLD_HEIGHT))
	_set_rect(_threshold_icon_holder, Vector2(0.0, 5.0), Vector2(22.0, 22.0))
	_set_rect(_threshold_value_label, Vector2(28.0, 2.0), Vector2(42.0, 12.0))
	_set_rect(_threshold_name_label, Vector2(28.0, 14.0), Vector2(threshold_width - 28.0, 16.0))
	_set_rect(_threshold_accent_line, Vector2(0.0, 29.0), Vector2(maxf(threshold_width - 18.0, 0.0), 2.0))

	_set_rect(_main_number_label, Vector2(number_x, HUD_TOP + MAIN_ROW_Y - 4.0), Vector2(number_width, MAIN_NUMBER_HEIGHT))
	_set_rect(_main_number_shadow_label, _main_number_label.position + MAIN_NUMBER_SHADOW_OFFSET, _main_number_label.size)

	_set_rect(_pause_btn, Vector2(pause_x, HUD_TOP + MAIN_ROW_Y + 1.0), PAUSE_SIZE)
	_layout_pause_icon()

	_set_rect(_divider, Vector2(band_x + INNER_MARGIN_X, HUD_TOP + DIVIDER_Y), Vector2(band_width - (INNER_MARGIN_X * 2.0), 1.0))
	_divider.color = DIVIDER_COLOR

	_set_rect(_current_weapon_module, Vector2(current_weapon_x, HUD_TOP + CURRENT_WEAPON_ROW_Y), Vector2(CURRENT_WEAPON_WIDTH, CURRENT_WEAPON_HEIGHT))
	_set_rect(_current_weapon_accent, Vector2(0.0, 4.0), Vector2(3.0, 13.0))
	_set_rect(_weapon_label, Vector2(10.0, 0.0), Vector2(CURRENT_WEAPON_WIDTH - 10.0, 18.0))

	_set_rect(_best_label, Vector2(best_x, HUD_TOP + CURRENT_WEAPON_ROW_Y + 1.0), Vector2(BEST_LABEL_WIDTH, 16.0))
	_set_rect(_weapon_flash, _current_weapon_module.position + Vector2(-2.0, -1.0), _current_weapon_module.size + Vector2(8.0, 4.0))
	_set_rect(_weapon_impact_label, Vector2(current_weapon_x + CURRENT_WEAPON_WIDTH - 54.0, HUD_TOP + CURRENT_WEAPON_ROW_Y - 12.0), Vector2(64.0, 20.0))

	_level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_threshold_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_threshold_value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_threshold_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_threshold_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_main_number_shadow_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_main_number_shadow_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_main_number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_main_number_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_weapon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_weapon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_best_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_weapon_impact_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_weapon_impact_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	_rebuild_gauge_stripes()
	_update_level_progress(GameState.current_level, GameState.current_level_k)


func _layout_pause_icon() -> void:
	_set_rect(_pause_bar_left_shadow, Vector2(13.0, 9.0), Vector2(6.0, 18.0))
	_set_rect(_pause_bar_right_shadow, Vector2(24.0, 9.0), Vector2(6.0, 18.0))
	_set_rect(_pause_bar_left, Vector2(11.0, 7.0), Vector2(6.0, 18.0))
	_set_rect(_pause_bar_right, Vector2(22.0, 7.0), Vector2(6.0, 18.0))


func _refresh_all() -> void:
	_on_k_changed(GameState.current_level_k)
	var progression_state: Dictionary = GameState.get_progression_display_state()
	_on_progression_display_changed(
		int(progression_state.get("current_level", GameState.current_level)),
		int(progression_state.get("current_k", GameState.k)),
		int(progression_state.get("total_progress", GameState.total_progress)),
		String(progression_state.get("current_weapon_name", "화살")),
		String(progression_state.get("next_unlock_name", "")),
		int(progression_state.get("next_unlock_threshold", -1)),
		String(progression_state.get("ready_unlock_name", "")),
		bool(progression_state.get("max_spec_tier_reached", false))
	)


func _on_resized() -> void:
	_layout_reference_hud()


func _on_tier_changed(tier: int) -> void:
	_refresh_threshold_module()
	_refresh_current_weapon_module(tier, GameState.active_weapon_choice_id)


func _on_weapon_choice_selected(choice_id: String, display_name: String) -> void:
	_refresh_current_weapon_module(GameState.current_projectile_tier, choice_id)
	_play_weapon_change_impact(GameState.current_projectile_tier, "%s 장착!" % display_name, choice_id)


func _on_tier_threshold_reached(unlocked_tier: int, _threshold: int, display_name: String) -> void:
	if unlocked_tier < 1:
		return
	_current_weapon_name = display_name
	_refresh_threshold_module()
	_refresh_current_weapon_module(unlocked_tier, GameState.active_weapon_choice_id)
	_play_weapon_change_impact(unlocked_tier, "%s 장착!" % display_name)


func _on_k_changed(new_k: int) -> void:
	_on_unlock_progress_changed(new_k, GameState.stone_unlock_threshold, GameState.stone_unlocked)


func _on_game_started() -> void:
	_on_k_changed(GameState.current_level_k)
	_best_label.text = _format_best_label()


func _on_best_record_changed(_best_value: int) -> void:
	_best_label.text = _format_best_label()


func _on_unlock_progress_changed(current_k: int, _threshold: int, _unlocked: bool) -> void:
	_update_level_progress(GameState.current_level, current_k)
	_sync_main_number_text(current_k)
	_best_label.text = _format_best_label()


func _on_progression_display_changed(
	current_level: int,
	current_k: int,
	_total_progress: int,
	_current_weapon_name_from_progression: String,
	_next_unlock_name: String,
	_next_unlock_threshold: int,
	_ready_unlock_name: String,
	_max_spec_tier_reached: bool
) -> void:
	_update_level_progress(current_level, current_k)
	_sync_main_number_text(current_k)
	_refresh_threshold_module()
	_refresh_current_weapon_module(GameState.current_projectile_tier, GameState.active_weapon_choice_id)
	_best_label.text = _format_best_label()


func _on_pause_pressed() -> void:
	if not GameState.is_playing:
		return
	var menus := get_tree().get_nodes_in_group("pause_menu")
	if not menus.is_empty():
		menus[0].show_menu()


func _update_level_progress(current_level: int, current_k: int) -> void:
	var gauge_max: int = GameState.get_score_gauge_max()
	var normalized_progress: float = clampf(float(current_k) / maxf(float(gauge_max), 1.0), 0.0, 1.0)
	_level_label.text = "%d/%d" % [current_k, gauge_max]
	_level_gauge.max_value = 1.0
	_level_gauge.value = normalized_progress
	var full_fill_width := maxf(_level_gauge.size.x - 8.0, 0.0)
	_gauge_fill_mask.size.x = maxf(full_fill_width * normalized_progress, 0.0)


func _sync_main_number_text(current_k: int) -> void:
	var font_size := MAIN_NUMBER_FONT_SIZE_SMALL
	if current_k >= 1000:
		font_size = MAIN_NUMBER_FONT_SIZE_LARGE
	_style_number_labels(font_size)
	var number_text := str(current_k)
	_main_number_shadow_label.text = number_text
	_main_number_label.text = number_text


func _refresh_threshold_module() -> void:
	var tier := GameState.current_projectile_tier
	var threshold := GameState.get_tier_threshold(tier)
	var display_name := GameState.get_tier_display_name(tier)
	var primary := WeaponProfileRef.get_primary_color(tier)
	var secondary := WeaponProfileRef.get_secondary_color(tier)
	var accent := WeaponProfileRef.get_accent_color(tier)

	_threshold_value_label.text = "%d+" % maxi(threshold, 0)
	_threshold_name_label.text = display_name
	_threshold_value_label.add_theme_color_override("font_color", HUD_TEXT_COLOR)
	_threshold_value_label.add_theme_color_override("font_outline_color", HUD_TEXT_OUTLINE_COLOR)
	_threshold_name_label.add_theme_color_override("font_color", HUD_TEXT_COLOR)
	_threshold_name_label.add_theme_color_override("font_outline_color", HUD_TEXT_OUTLINE_COLOR)
	_threshold_accent_line.color = accent.lightened(0.10)
	_rebuild_threshold_icon(WeaponProfileRef.get_icon_style(tier), primary, secondary, accent)
	_layout_reference_hud()


func _refresh_current_weapon_module(tier: int, choice_id: String = "") -> void:
	_current_weapon_name = WeaponProfileRef.get_display_name(tier, choice_id)
	_weapon_label.text = _format_next_goal_label()
	var accent := WeaponProfileRef.get_accent_color(tier, choice_id)
	var secondary := WeaponProfileRef.get_secondary_color(tier, choice_id)
	_current_weapon_accent.color = accent
	_weapon_label.add_theme_color_override("font_color", HUD_TEXT_COLOR)
	_weapon_label.add_theme_color_override("font_outline_color", HUD_TEXT_OUTLINE_COLOR)


func _rebuild_threshold_icon(style_id: String, primary: Color, secondary: Color, accent: Color) -> void:
	for child in _threshold_icon_holder.get_children():
		child.queue_free()

	match style_id:
		"arrow":
			_add_icon_rect(Vector2(2.0, 9.0), Vector2(12.0, 4.0), secondary)
			_add_icon_rect(Vector2(11.0, 6.0), Vector2(8.0, 3.0), primary, -0.45)
			_add_icon_rect(Vector2(11.0, 13.0), Vector2(8.0, 3.0), primary, 0.45)
		"thunder", "chain":
			_add_icon_rect(Vector2(4.0, 2.0), Vector2(7.0, 3.0), primary, -0.30)
			_add_icon_rect(Vector2(8.0, 7.0), Vector2(7.0, 3.0), secondary, 0.48)
			_add_icon_rect(Vector2(5.0, 12.0), Vector2(8.0, 3.0), accent, -0.44)
		"prism":
			_add_icon_rect(Vector2(7.0, 5.0), Vector2(8.0, 8.0), secondary, 0.78)
			_add_icon_rect(Vector2(4.0, 13.0), Vector2(14.0, 2.0), accent)
		"storm":
			_add_icon_rect(Vector2(7.0, 4.0), Vector2(8.0, 8.0), primary, 0.78)
			_add_icon_rect(Vector2(3.0, 9.0), Vector2(16.0, 2.0), secondary)
			_add_icon_rect(Vector2(9.0, 2.0), Vector2(2.0, 16.0), accent)
		"meteor":
			_add_icon_rect(Vector2(9.0, 3.0), Vector2(8.0, 8.0), secondary, 0.78)
			_add_icon_rect(Vector2(3.0, 11.0), Vector2(10.0, 3.0), primary, -0.36)
			_add_icon_rect(Vector2(1.0, 15.0), Vector2(8.0, 2.0), accent, -0.22)
		_:
			_add_icon_rect(Vector2(2.0, 9.0), Vector2(12.0, 4.0), secondary)
			_add_icon_rect(Vector2(11.0, 6.0), Vector2(8.0, 3.0), primary, -0.45)


func _add_icon_rect(local_position: Vector2, rect_size: Vector2, color: Color, rotation_radians: float = 0.0) -> void:
	var rect := ColorRect.new()
	rect.position = local_position
	rect.size = rect_size
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.rotation = rotation_radians
	_threshold_icon_holder.add_child(rect)


func _rebuild_gauge_stripes() -> void:
	for child in _gauge_stripe_root.get_children():
		child.queue_free()
	var stripe_count := int(ceil((_gauge_stripe_root.size.x + 42.0) / STRIPE_STEP))
	for i in range(stripe_count):
		var stripe := ColorRect.new()
		stripe.size = Vector2(18.0, _gauge_stripe_root.size.y + 20.0)
		stripe.position = Vector2((float(i) * STRIPE_STEP) - 12.0, -9.0)
		stripe.color = Color(0.84, 0.96, 1.0, 0.18)
		stripe.rotation = -0.60
		stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_gauge_stripe_root.add_child(stripe)


func _play_weapon_change_impact(tier: int, _impact_text: String, choice_id: String = "") -> void:
	if _weapon_chip_tween != null:
		_weapon_chip_tween.kill()
		_weapon_chip_tween = null
	if _weapon_impact_tween != null:
		_weapon_impact_tween.kill()
		_weapon_impact_tween = null

	var flash_color := WeaponProfileRef.get_secondary_color(tier, choice_id)
	flash_color.a = 0.0
	_weapon_flash.color = flash_color
	_weapon_flash.visible = true
	_weapon_flash.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_weapon_flash.scale = Vector2(0.96, 0.96)
	_weapon_flash.pivot_offset = _weapon_flash.size * 0.5

	_current_weapon_module.scale = Vector2(0.96, 0.96)
	_current_weapon_module.pivot_offset = _current_weapon_module.size * 0.5

	_weapon_impact_label.text = "쾅!"
	_weapon_impact_label.visible = true
	_weapon_impact_label.scale = Vector2(0.74, 0.74)
	_weapon_impact_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_weapon_impact_label.add_theme_color_override("font_color", WeaponProfileRef.get_secondary_color(tier, choice_id))

	_weapon_chip_tween = create_tween()
	_weapon_chip_tween.parallel().tween_property(_current_weapon_module, "scale", Vector2(1.08, 1.08), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_weapon_chip_tween.parallel().tween_property(_weapon_flash, "modulate:a", 0.96, 0.07).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_weapon_chip_tween.parallel().tween_property(_weapon_flash, "scale", Vector2(1.04, 1.12), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_weapon_chip_tween.tween_property(_current_weapon_module, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_weapon_chip_tween.parallel().tween_property(_weapon_flash, "modulate:a", 0.0, 0.14).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_weapon_chip_tween.parallel().tween_property(_weapon_flash, "scale", Vector2(1.10, 1.16), 0.14).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_weapon_chip_tween.finished.connect(_on_weapon_impact_finished)

	_weapon_impact_tween = create_tween()
	_weapon_impact_tween.parallel().tween_property(_weapon_impact_label, "modulate:a", 1.0, 0.06).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_weapon_impact_tween.parallel().tween_property(_weapon_impact_label, "scale", Vector2.ONE, 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_weapon_impact_tween.tween_interval(0.08)
	_weapon_impact_tween.parallel().tween_property(_weapon_impact_label, "position:y", _weapon_impact_label.position.y - 10.0, 0.16).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_weapon_impact_tween.parallel().tween_property(_weapon_impact_label, "modulate:a", 0.0, 0.14).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_weapon_impact_tween.finished.connect(_hide_impact_label)

	if AudioManager != null:
		if AudioManager.has_method("play_weapon_change"):
			AudioManager.play_weapon_change()
		elif AudioManager.has_method("play_hook"):
			AudioManager.play_hook("weapon_change")


func _on_weapon_impact_finished() -> void:
	_weapon_flash.visible = false
	_weapon_flash.scale = Vector2.ONE
	_current_weapon_module.scale = Vector2.ONE


func _hide_impact_label() -> void:
	_weapon_impact_label.visible = false


func _get_threshold_module_width() -> float:
	var display_name := GameState.get_tier_display_name(GameState.current_projectile_tier)
	if display_name.length() >= 6:
		return THRESHOLD_LONG_WIDTH
	return THRESHOLD_SHORT_WIDTH


func _format_best_label() -> String:
	return "최고 %d개" % SaveManager.get_best_record_value()


func _format_next_goal_label() -> String:
	var progression_state: Dictionary = GameState.get_progression_display_state()
	var next_name := String(progression_state.get("next_unlock_name", ""))
	var next_threshold := int(progression_state.get("next_unlock_threshold", -1))
	if bool(progression_state.get("max_spec_tier_reached", false)) or next_threshold < 0:
		return "다음: 기록 갱신"
	if next_name == "":
		return "다음: 준비 중"
	return "다음: %s" % next_name


func _set_rect(control: Control, rect_position: Vector2, rect_size: Vector2) -> void:
	control.anchor_left = 0.0
	control.anchor_top = 0.0
	control.anchor_right = 0.0
	control.anchor_bottom = 0.0
	control.position = rect_position
	control.size = rect_size
