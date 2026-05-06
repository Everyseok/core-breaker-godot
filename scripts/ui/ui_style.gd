class_name UiStyle
extends RefCounted

const UI_FONT_PATH := "res://assets/fonts/game_ui_kr.ttf"

const PANEL_DARK := Color(0.98, 0.92, 0.76, 0.95)
const PANEL_SOFT := Color(0.95, 0.98, 1.0, 0.94)
const PANEL_BORDER := Color(1.0, 0.66, 0.26, 1.0)
const TEXT_MAIN := Color(0.18, 0.20, 0.32)
const TEXT_SUB := Color(0.34, 0.42, 0.62)
const TEXT_MUTE := Color(0.38, 0.44, 0.58)
const READY_YELLOW := Color(1.0, 0.78, 0.20)
const SUCCESS_GREEN := Color(0.26, 0.76, 0.46)
const DANGER_RED := Color(0.94, 0.36, 0.32)
const MENU_SURFACE := Color(1.0, 0.94, 0.78, 0.82)
const MENU_SURFACE_SOFT := Color(0.90, 0.98, 1.0, 0.70)
const MENU_TRIM := Color(1.0, 0.66, 0.28, 0.72)
const MENU_TITLE_SHADOW := Color(1.0, 0.72, 0.28, 0.72)
const MENU_PRIMARY_FILL := Color(0.28, 0.68, 1.0, 0.98)
const MENU_PRIMARY_BORDER := Color(1.0, 0.92, 0.42, 0.96)
const MENU_SECONDARY_FILL := Color(0.38, 0.82, 0.92, 0.96)
const MENU_SECONDARY_BORDER := Color(0.96, 1.0, 1.0, 0.86)
const MENU_SUCCESS_FILL := Color(0.30, 0.78, 0.50, 0.96)
const MENU_SUCCESS_BORDER := Color(0.88, 1.0, 0.72, 0.88)
const MENU_DANGER_FILL := Color(0.96, 0.42, 0.38, 0.96)
const MENU_DANGER_BORDER := Color(1.0, 0.86, 0.58, 0.90)

static var _ui_font: Font
static var _fallback_font: SystemFont


static func get_font() -> Font:
	if _ui_font != null:
		return _ui_font
	if ResourceLoader.exists(UI_FONT_PATH):
		var loaded_font := load(UI_FONT_PATH)
		if loaded_font is Font:
			_ui_font = loaded_font
			return _ui_font
	return _get_fallback_font()


static func get_display_font() -> Font:
	return get_font()


static func has_custom_ui_font() -> bool:
	return ResourceLoader.exists(UI_FONT_PATH)


static func _get_fallback_font() -> Font:
	if _fallback_font != null:
		return _fallback_font
	_fallback_font = SystemFont.new()
	_fallback_font.font_names = [
		"NanumSquareRoundOTF",
		"NanumSquareRound",
		"NeoDunggeunmo Pro",
		"NeoDunggeunmo",
		"DungGeunMo",
		"Galmuri11",
		"Galmuri14",
		"CookieRun Regular",
		"CookieRun Black",
		"Apple SD Gothic Neo",
		"SF Pro KR",
		"Noto Sans CJK KR",
		"Noto Sans KR",
		"Malgun Gothic",
		"NanumGothic",
		"Arial Unicode MS",
		"sans-serif",
	]
	return _fallback_font


static func apply_label(label: Label, font_size: int, font_color: Color = TEXT_MAIN, outline_size: int = 4) -> void:
	label.add_theme_font_override("font", get_font())
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_color_override("font_outline_color", _outline_for(font_color))
	label.add_theme_constant_override("outline_size", outline_size)


static func apply_display_label(label: Label, font_size: int, font_color: Color = TEXT_MAIN, outline_size: int = 5) -> void:
	label.add_theme_font_override("font", get_display_font())
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_color_override("font_outline_color", _outline_for(font_color))
	label.add_theme_constant_override("outline_size", outline_size)


static func apply_button(
	button: Button,
	fill_color: Color,
	border_color: Color,
	font_color: Color = TEXT_MAIN,
	font_size: int = 22
) -> void:
	button.add_theme_font_override("font", get_font())
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", font_color.lightened(0.06))
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", font_color.darkened(0.35))
	button.add_theme_color_override("font_outline_color", _outline_for(font_color))
	button.add_theme_constant_override("outline_size", 5)
	button.add_theme_stylebox_override("normal", _make_box(fill_color, border_color))
	button.add_theme_stylebox_override("hover", _make_box(fill_color.lightened(0.10), border_color.lightened(0.08)))
	button.add_theme_stylebox_override("pressed", _make_box(fill_color.darkened(0.08), border_color.lightened(0.12)))
	button.add_theme_stylebox_override("disabled", _make_box(fill_color.darkened(0.26), border_color.darkened(0.22)))
	button.add_theme_stylebox_override("focus", _make_box(fill_color.lightened(0.04), READY_YELLOW))


static func apply_panel(panel: Panel, fill_color: Color, border_color: Color) -> void:
	panel.add_theme_stylebox_override("panel", _make_box(fill_color, border_color))


static func apply_menu_plate(panel: Panel) -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = MENU_SURFACE
	box.border_color = MENU_TRIM
	box.border_width_left = 1
	box.border_width_top = 1
	box.border_width_right = 1
	box.border_width_bottom = 3
	box.corner_radius_top_left = 18
	box.corner_radius_top_right = 18
	box.corner_radius_bottom_left = 18
	box.corner_radius_bottom_right = 18
	box.shadow_color = Color(0.0, 0.0, 0.0, 0.22)
	box.shadow_size = 9
	box.content_margin_left = 14.0
	box.content_margin_top = 10.0
	box.content_margin_right = 14.0
	box.content_margin_bottom = 10.0
	panel.add_theme_stylebox_override("panel", box)


static func apply_menu_title(label: Label, font_size: int, font_color: Color = TEXT_MAIN, outline_size: int = 6) -> void:
	label.add_theme_font_override("font", get_display_font())
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_color_override("font_outline_color", _outline_for(font_color))
	label.add_theme_constant_override("outline_size", outline_size)


static func apply_arcade_button(
	button: Button,
	fill_color: Color,
	border_color: Color,
	font_color: Color = TEXT_MAIN,
	font_size: int = 24
) -> void:
	button.add_theme_font_override("font", get_display_font())
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", font_color.lightened(0.04))
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", font_color.darkened(0.35))
	button.add_theme_color_override("font_outline_color", _outline_for(font_color))
	button.add_theme_constant_override("outline_size", 5)
	button.add_theme_stylebox_override("normal", _make_box_variant(fill_color, border_color, 16, 8))
	button.add_theme_stylebox_override("hover", _make_box_variant(fill_color.lightened(0.08), border_color.lightened(0.05), 16, 9))
	button.add_theme_stylebox_override("pressed", _make_box_variant(fill_color.darkened(0.08), border_color.lightened(0.08), 16, 5))
	button.add_theme_stylebox_override("disabled", _make_box_variant(fill_color.darkened(0.26), border_color.darkened(0.22), 16, 4))
	button.add_theme_stylebox_override("focus", _make_box_variant(fill_color.lightened(0.04), READY_YELLOW, 16, 8))


static func apply_progress_bar(progress_bar: ProgressBar, fill_color: Color) -> void:
	progress_bar.add_theme_stylebox_override("background", _make_box(Color(0.05, 0.06, 0.12, 0.92), Color(0.18, 0.23, 0.38)))
	progress_bar.add_theme_stylebox_override("fill", _make_box(fill_color, fill_color.lightened(0.10)))


static func _make_box(fill_color: Color, border_color: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill_color
	box.border_color = border_color
	box.border_width_left = 4
	box.border_width_top = 4
	box.border_width_right = 4
	box.border_width_bottom = 5
	box.corner_radius_top_left = 10
	box.corner_radius_top_right = 10
	box.corner_radius_bottom_left = 10
	box.corner_radius_bottom_right = 10
	box.shadow_color = Color(0.00, 0.00, 0.00, 0.40)
	box.shadow_size = 11
	box.content_margin_left = 10.0
	box.content_margin_top = 7.0
	box.content_margin_right = 10.0
	box.content_margin_bottom = 7.0
	return box


static func _outline_for(font_color: Color) -> Color:
	var luminance := (font_color.r * 0.299) + (font_color.g * 0.587) + (font_color.b * 0.114)
	if luminance < 0.55:
		return Color(1.0, 0.96, 0.78, 0.88)
	return Color(0.03, 0.05, 0.10, 0.96)


static func _make_box_variant(fill_color: Color, border_color: Color, radius: int, shadow_size: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill_color
	box.border_color = border_color
	box.border_width_left = 3
	box.border_width_top = 3
	box.border_width_right = 3
	box.border_width_bottom = 4
	box.corner_radius_top_left = radius
	box.corner_radius_top_right = radius
	box.corner_radius_bottom_left = radius
	box.corner_radius_bottom_right = radius
	box.shadow_color = Color(0.00, 0.00, 0.00, 0.34)
	box.shadow_size = shadow_size
	box.content_margin_left = 10.0
	box.content_margin_top = 7.0
	box.content_margin_right = 10.0
	box.content_margin_bottom = 7.0
	return box
