extends Control

const UiStyleRef := preload("res://scripts/ui/ui_style.gd")
const WeaponChoiceRulesRef := preload("res://scripts/domain/combat/weapon_choice_rules.gd")
const WeaponProfileRef := preload("res://scripts/visual/weapon_profile.gd")

var _dim_overlay: ColorRect
var _panel: Panel
var _title_label: Label
var _subtitle_label: Label
var _cards_container: HBoxContainer
var _resolving_selection: bool = false
var _card_buttons: Dictionary = {}


func _ready() -> void:
	add_to_group("weapon_choice_panel")
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	_build_ui()
	GameState.weapon_choice_requested.connect(_on_weapon_choice_requested)
	GameState.game_started.connect(_force_close)
	GameState.game_over.connect(_force_close)
	GameState.max_level_cleared.connect(_force_close)
	GameState.level_transitioned.connect(_on_level_transitioned)


func _on_weapon_choice_requested(options: Array) -> void:
	if options.is_empty():
		options = WeaponChoiceRulesRef.get_choices()
	_open_panel(options)


func _on_level_transitioned(_new_level: int) -> void:
	_force_close()


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	_dim_overlay = ColorRect.new()
	_dim_overlay.anchor_right = 1.0
	_dim_overlay.anchor_bottom = 1.0
	_dim_overlay.color = Color(0.01, 0.03, 0.08, 0.0)
	_dim_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_dim_overlay)

	_panel = Panel.new()
	_panel.anchor_left = 0.5
	_panel.anchor_top = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_bottom = 0.5
	_panel.offset_left = -172.0
	_panel.offset_top = -196.0
	_panel.offset_right = 172.0
	_panel.offset_bottom = 178.0
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_panel)
	UiStyleRef.apply_panel(_panel, Color(0.06, 0.09, 0.18, 0.96), Color(0.54, 0.74, 1.0))

	var title_glow := ColorRect.new()
	title_glow.position = Vector2(76.0, 16.0)
	title_glow.size = Vector2(192.0, 10.0)
	title_glow.color = Color(0.50, 0.76, 1.0, 0.22)
	title_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(title_glow)

	_title_label = Label.new()
	_title_label.anchor_right = 1.0
	_title_label.offset_top = 22.0
	_title_label.offset_bottom = 58.0
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.text = "무기 진화 선택!"
	_panel.add_child(_title_label)
	UiStyleRef.apply_label(_title_label, 26, Color.WHITE, 5)

	_subtitle_label = Label.new()
	_subtitle_label.anchor_right = 1.0
	_subtitle_label.offset_top = 60.0
	_subtitle_label.offset_bottom = 92.0
	_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle_label.text = "하나만 골라줘!"
	_panel.add_child(_subtitle_label)
	UiStyleRef.apply_label(_subtitle_label, 18, UiStyleRef.TEXT_SUB, 4)

	_cards_container = HBoxContainer.new()
	_cards_container.anchor_left = 0.5
	_cards_container.anchor_top = 0.5
	_cards_container.anchor_right = 0.5
	_cards_container.anchor_bottom = 0.5
	_cards_container.offset_left = -156.0
	_cards_container.offset_top = -22.0
	_cards_container.offset_right = 156.0
	_cards_container.offset_bottom = 154.0
	_cards_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_cards_container.add_theme_constant_override("separation", 10)
	_panel.add_child(_cards_container)

	for choice_variant in WeaponChoiceRulesRef.get_choices():
		if choice_variant is Dictionary:
			var card := _build_choice_card(choice_variant)
			_cards_container.add_child(card)
			_card_buttons[String(choice_variant.get("id", ""))] = card


func _build_choice_card(choice: Dictionary) -> Button:
	var choice_id := String(choice.get("id", ""))
	var button := Button.new()
	button.focus_mode = Control.FOCUS_NONE
	button.text = ""
	button.custom_minimum_size = Vector2(98.0, 176.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.clip_contents = true
	button.pressed.connect(_on_choice_pressed.bind(choice_id))
	_apply_card_style(button, choice, false)

	var flash := ColorRect.new()
	flash.name = "SelectionFlash"
	flash.anchor_right = 1.0
	flash.anchor_bottom = 1.0
	flash.color = Color(1.0, 1.0, 1.0, 0.0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(flash)

	var tag := Label.new()
	tag.name = "TagLabel"
	tag.anchor_left = 0.5
	tag.anchor_right = 0.5
	tag.offset_left = -44.0
	tag.offset_top = 12.0
	tag.offset_right = 44.0
	tag.offset_bottom = 34.0
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.text = "추천 느낌 · %s" % String(choice.get("tag", ""))
	button.add_child(tag)
	UiStyleRef.apply_label(tag, 11, Color(1.0, 0.98, 0.78), 3)

	var icon_holder := Control.new()
	icon_holder.name = "IconHolder"
	icon_holder.anchor_left = 0.5
	icon_holder.anchor_right = 0.5
	icon_holder.offset_left = -28.0
	icon_holder.offset_top = 42.0
	icon_holder.offset_right = 28.0
	icon_holder.offset_bottom = 94.0
	icon_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(icon_holder)
	_build_card_icon(icon_holder, choice)

	var name_label := Label.new()
	name_label.anchor_left = 0.5
	name_label.anchor_right = 0.5
	name_label.offset_left = -44.0
	name_label.offset_top = 102.0
	name_label.offset_right = 44.0
	name_label.offset_bottom = 126.0
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.text = String(_profile_for_choice(choice_id).get("display_name", ""))
	button.add_child(name_label)
	UiStyleRef.apply_label(name_label, 18, Color.WHITE, 4)

	var desc_label := Label.new()
	desc_label.anchor_left = 0.5
	desc_label.anchor_right = 0.5
	desc_label.offset_left = -40.0
	desc_label.offset_top = 128.0
	desc_label.offset_right = 40.0
	desc_label.offset_bottom = 166.0
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	desc_label.text = String(choice.get("description", ""))
	button.add_child(desc_label)
	UiStyleRef.apply_label(desc_label, 13, UiStyleRef.TEXT_MAIN, 3)

	return button


func _apply_card_style(button: Button, choice: Dictionary, selected: bool) -> void:
	var profile := _profile_for_choice(String(choice.get("id", "")))
	var primary: Color = Color(profile.get("primary_color", Color.WHITE))
	var secondary: Color = Color(profile.get("secondary_color", Color.WHITE))
	var fill := primary.darkened(0.72)
	fill.a = 0.98
	var border := secondary if not selected else secondary.lightened(0.20)
	UiStyleRef.apply_button(button, fill, border, Color.WHITE, 1)
	button.add_theme_constant_override("outline_size", 0)


func _build_card_icon(holder: Control, choice: Dictionary) -> void:
	var profile := _profile_for_choice(String(choice.get("id", "")))
	var primary: Color = Color(profile.get("primary_color", Color.WHITE))
	var secondary: Color = Color(profile.get("secondary_color", Color.WHITE))
	var accent: Color = Color(profile.get("accent_color", primary))
	match String(profile.get("icon_style", "arrow")):
		"chain":
			_add_icon_rect(holder, Vector2(6.0, 10.0), Vector2(10.0, 10.0), secondary)
			_add_icon_rect(holder, Vector2(23.0, 2.0), Vector2(10.0, 10.0), primary)
			_add_icon_rect(holder, Vector2(39.0, 16.0), Vector2(10.0, 10.0), secondary)
			_add_icon_rect(holder, Vector2(14.0, 7.0), Vector2(12.0, 4.0), primary)
			_add_icon_rect(holder, Vector2(30.0, 13.0), Vector2(12.0, 4.0), primary)
		"meteor":
			_add_icon_rect(holder, Vector2(24.0, 8.0), Vector2(16.0, 12.0), primary)
			_add_icon_rect(holder, Vector2(16.0, 18.0), Vector2(28.0, 6.0), secondary)
			_add_icon_rect(holder, Vector2(8.0, 28.0), Vector2(40.0, 4.0), Color(1.0, 0.96, 0.82))
			_add_icon_rect(holder, Vector2(18.0, 32.0), Vector2(20.0, 4.0), primary)
		"storm":
			_add_icon_rect(holder, Vector2(20.0, 6.0), Vector2(16.0, 16.0), primary)
			_add_icon_rect(holder, Vector2(8.0, 20.0), Vector2(8.0, 18.0), secondary)
			_add_icon_rect(holder, Vector2(22.0, 18.0), Vector2(10.0, 24.0), accent)
			_add_icon_rect(holder, Vector2(40.0, 20.0), Vector2(8.0, 18.0), secondary)
		"arrow":
			_add_icon_rect(holder, Vector2(24.0, 6.0), Vector2(8.0, 30.0), primary)
			_add_icon_rect(holder, Vector2(20.0, 30.0), Vector2(16.0, 8.0), secondary)
			_add_icon_rect(holder, Vector2(20.0, 4.0), Vector2(16.0, 8.0), accent)
		_:
			_add_icon_rect(holder, Vector2(24.0, 4.0), Vector2(12.0, 12.0), secondary)
			_add_icon_rect(holder, Vector2(18.0, 16.0), Vector2(24.0, 16.0), primary)
			_add_icon_rect(holder, Vector2(6.0, 18.0), Vector2(8.0, 24.0), secondary)
			_add_icon_rect(holder, Vector2(42.0, 18.0), Vector2(8.0, 24.0), accent)


func _add_icon_rect(holder: Control, position_value: Vector2, size_value: Vector2, color: Color) -> void:
	var rect := ColorRect.new()
	rect.position = position_value
	rect.size = size_value
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(rect)


func _open_panel(options: Array) -> void:
	if visible:
		return
	_resolving_selection = false
	_title_label.text = "무기 진화 선택!"
	_subtitle_label.text = "하나만 골라줘!"
	_refresh_cards(options)
	visible = true
	get_tree().paused = true
	_play_audio_hook(WeaponChoiceRulesRef.AUDIO_HOOK_OPEN)

	_dim_overlay.color.a = 0.0
	_panel.scale = Vector2(0.92, 0.92)
	_panel.modulate.a = 0.0
	for card in _card_buttons.values():
		var button := card as Button
		if button == null:
			continue
		button.scale = Vector2(0.92, 0.92)
		button.modulate.a = 0.0

	var tween := create_tween()
	tween.parallel().tween_property(_dim_overlay, "color:a", 0.76, 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(_panel, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(_panel, "modulate:a", 1.0, 0.10).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	for index in range(_cards_container.get_child_count()):
		var button := _cards_container.get_child(index) as Button
		if button == null:
			continue
		tween.tween_interval(0.03)
		tween.parallel().tween_property(button, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(button, "modulate:a", 1.0, 0.10).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _refresh_cards(options: Array) -> void:
	for choice_variant in options:
		if not (choice_variant is Dictionary):
			continue
		var choice: Dictionary = choice_variant
		var choice_id := String(choice.get("id", ""))
		var button := _card_buttons.get(choice_id) as Button
		if button == null:
			continue
		_apply_card_style(button, choice, false)


func _on_choice_pressed(choice_id: String) -> void:
	if _resolving_selection:
		return
	if not WeaponChoiceRulesRef.is_selectable_choice(choice_id):
		return
	_resolving_selection = true
	_play_audio_hook(WeaponChoiceRulesRef.AUDIO_HOOK_SELECT)

	var choice := WeaponChoiceRulesRef.definition_for_id(choice_id)
	var button := _card_buttons.get(choice_id) as Button
	if button != null:
		_apply_card_style(button, choice, true)
		var flash := button.get_node_or_null("SelectionFlash") as ColorRect
		if flash != null:
			flash.color = Color(1.0, 1.0, 1.0, 0.0)
		var tween := create_tween()
		tween.parallel().tween_property(button, "scale", Vector2(1.06, 1.06), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		if flash != null:
			tween.parallel().tween_property(flash, "color:a", 0.46, 0.08).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.tween_property(flash, "color:a", 0.0, 0.14).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	_title_label.text = WeaponChoiceRulesRef.confirm_text_for_id(choice_id)
	_subtitle_label.text = "이번 단계 끝까지 함께 간다!"
	GameState.select_weapon_choice(choice_id)
	call_deferred("_force_close")


func _force_close() -> void:
	_resolving_selection = false
	if visible and get_tree().paused:
		get_tree().paused = false
	visible = false
	_title_label.text = "무기 진화 선택!"
	_subtitle_label.text = "하나만 골라줘!"


func _play_audio_hook(hook_name: String) -> void:
	AudioEvents.play_hook(hook_name)


func _profile_for_choice(choice_id: String) -> Dictionary:
	return WeaponProfileRef.get_profile_by_visual_id(choice_id)
