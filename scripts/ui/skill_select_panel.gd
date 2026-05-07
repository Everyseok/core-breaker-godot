extends Control
# SkillSelectPanel — UI-only selector for automatic skills.
# It talks only to SkillManager. It must not deal damage, target bricks, or spawn gameplay VFX.

const UiStyleRef := preload("res://scripts/ui/ui_style.gd")
const SkillRulesRef := preload("res://scripts/domain/skills/skill_rules.gd")

const PANEL_SIZE: Vector2 = Vector2(344.0, 346.0)
const CARD_SIZE: Vector2 = Vector2(98.0, 166.0)

var _dim_overlay: ColorRect
var _panel: Panel
var _title_label: Label
var _subtitle_label: Label
var _cards_container: HBoxContainer
var _resolving_selection: bool = false
var _card_buttons: Dictionary = {}


func _ready() -> void:
	add_to_group("skill_select_panel")
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	_build_ui()
	_center_panel()

	if not resized.is_connected(_center_panel):
		resized.connect(_center_panel)
	if not get_viewport().size_changed.is_connected(_center_panel):
		get_viewport().size_changed.connect(_center_panel)

	var skill_manager = _get_skill_manager()
	if skill_manager != null:
		if skill_manager.has_signal("skill_selection_requested"):
			skill_manager.skill_selection_requested.connect(_on_skill_selection_requested)

	GameState.game_started.connect(_force_close)
	GameState.game_over.connect(_force_close)
	GameState.max_level_cleared.connect(_force_close)
	GameState.level_transitioned.connect(_on_level_transitioned)


func _on_level_transitioned(_new_level: int) -> void:
	_force_close()


func _on_skill_selection_requested(options: Array) -> void:
	_open_panel(options)


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	_dim_overlay = ColorRect.new()
	_dim_overlay.anchor_right = 1.0
	_dim_overlay.anchor_bottom = 1.0
	_dim_overlay.color = Color(0.01, 0.03, 0.08, 0.0)
	_dim_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_dim_overlay)

	_panel = Panel.new()
	_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_panel.size = PANEL_SIZE
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_panel)
	UiStyleRef.apply_panel(_panel, Color(0.06, 0.09, 0.18, 0.96), Color(0.70, 0.88, 1.0))

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
	_title_label.text = "자동 스킬 선택!"
	_panel.add_child(_title_label)
	UiStyleRef.apply_label(_title_label, 26, Color.WHITE, 5)

	_subtitle_label = Label.new()
	_subtitle_label.anchor_right = 1.0
	_subtitle_label.offset_top = 60.0
	_subtitle_label.offset_bottom = 92.0
	_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle_label.text = "해금된 스킬 중 하나를 골라줘!"
	_panel.add_child(_subtitle_label)
	UiStyleRef.apply_label(_subtitle_label, 17, UiStyleRef.TEXT_SUB, 4)

	_cards_container = HBoxContainer.new()
	_cards_container.anchor_left = 0.5
	_cards_container.anchor_top = 0.5
	_cards_container.anchor_right = 0.5
	_cards_container.anchor_bottom = 0.5
	_cards_container.offset_left = -156.0
	_cards_container.offset_top = -20.0
	_cards_container.offset_right = 156.0
	_cards_container.offset_bottom = 150.0
	_cards_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_cards_container.add_theme_constant_override("separation", 10)
	_panel.add_child(_cards_container)


func _open_panel(options: Array) -> void:
	if visible:
		return

	var filtered_options := _valid_skill_options(options)
	if filtered_options.is_empty():
		var skill_manager = _get_skill_manager()
		if skill_manager != null and skill_manager.has_method("set_skill_panel_open"):
			skill_manager.call("set_skill_panel_open", false)
		AudioEvents.ui_error()
		return

	_resolving_selection = false
	_center_panel()
	_rebuild_cards(filtered_options)

	_title_label.text = "자동 스킬 선택!"
	_subtitle_label.text = "해금된 스킬 중 하나를 골라줘!"

	visible = true
	get_tree().paused = true

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


func _valid_skill_options(options: Array) -> Array:
	var result: Array = []
	for option_variant in options:
		if not (option_variant is Dictionary):
			continue
		var option: Dictionary = option_variant
		var skill_id := String(option.get("id", SkillRulesRef.NONE))
		if not SkillRulesRef.is_valid_skill_id(skill_id):
			continue
		result.append(option)
	return result


func _rebuild_cards(options: Array) -> void:
	for child in _cards_container.get_children():
		_cards_container.remove_child(child)
		child.queue_free()

	_card_buttons.clear()

	for option_variant in options:
		var skill: Dictionary = option_variant
		var card := _build_skill_card(skill)
		_cards_container.add_child(card)
		_card_buttons[String(skill.get("id", ""))] = card


func _build_skill_card(skill: Dictionary) -> Button:
	var skill_id := String(skill.get("id", SkillRulesRef.NONE))

	var button := Button.new()
	button.focus_mode = Control.FOCUS_NONE
	button.text = ""
	button.custom_minimum_size = CARD_SIZE
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.clip_contents = true
	button.pressed.connect(_on_skill_pressed.bind(skill_id))
	_apply_card_style(button, skill, false)

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
	tag.offset_top = 10.0
	tag.offset_right = 44.0
	tag.offset_bottom = 32.0
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.text = "자동 · %s" % String(skill.get("tag", ""))
	button.add_child(tag)
	UiStyleRef.apply_label(tag, 11, Color(1.0, 0.98, 0.78), 3)

	var icon_holder := Control.new()
	icon_holder.name = "IconHolder"
	icon_holder.anchor_left = 0.5
	icon_holder.anchor_right = 0.5
	icon_holder.offset_left = -28.0
	icon_holder.offset_top = 38.0
	icon_holder.offset_right = 28.0
	icon_holder.offset_bottom = 88.0
	icon_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(icon_holder)
	_build_skill_icon(icon_holder, skill)

	var name_label := Label.new()
	name_label.anchor_left = 0.5
	name_label.anchor_right = 0.5
	name_label.offset_left = -44.0
	name_label.offset_top = 96.0
	name_label.offset_right = 44.0
	name_label.offset_bottom = 122.0
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.text = String(skill.get("display_name", ""))
	button.add_child(name_label)
	UiStyleRef.apply_label(name_label, 18, Color.WHITE, 4)

	var desc_label := Label.new()
	desc_label.anchor_left = 0.5
	desc_label.anchor_right = 0.5
	desc_label.offset_left = -40.0
	desc_label.offset_top = 124.0
	desc_label.offset_right = 40.0
	desc_label.offset_bottom = 160.0
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	desc_label.text = String(skill.get("description", ""))
	button.add_child(desc_label)
	UiStyleRef.apply_label(desc_label, 12, UiStyleRef.TEXT_MAIN, 3)

	return button


func _apply_card_style(button: Button, skill: Dictionary, selected: bool) -> void:
	var primary: Color = Color(skill.get("primary_color", Color(0.54, 0.74, 1.0, 1.0)))
	var secondary: Color = Color(skill.get("secondary_color", Color(0.80, 0.92, 1.0, 1.0)))
	var fill := primary.darkened(0.72)
	fill.a = 0.98
	var border := secondary.lightened(0.20) if selected else secondary
	UiStyleRef.apply_button(button, fill, border, Color.WHITE, 1)
	button.add_theme_constant_override("outline_size", 0)


func _build_skill_icon(holder: Control, skill: Dictionary) -> void:
	var skill_id := String(skill.get("id", SkillRulesRef.NONE))
	var primary: Color = Color(skill.get("primary_color", Color.WHITE))
	var secondary: Color = Color(skill.get("secondary_color", Color.WHITE))
	var accent: Color = Color(skill.get("accent_color", primary))

	match skill_id:
		SkillRulesRef.STONE_THROW:
			_add_icon_rect(holder, Vector2(8.0, 30.0), Vector2(42.0, 6.0), accent)
			_add_icon_rect(holder, Vector2(14.0, 16.0), Vector2(8.0, 18.0), primary)
			_add_icon_rect(holder, Vector2(34.0, 16.0), Vector2(8.0, 18.0), primary)
			_add_icon_rect(holder, Vector2(24.0, 8.0), Vector2(12.0, 12.0), secondary)
			_add_icon_rect(holder, Vector2(24.0, 22.0), Vector2(14.0, 4.0), primary.lightened(0.10))
		SkillRulesRef.METEOR:
			_add_icon_rect(holder, Vector2(28.0, 6.0), Vector2(14.0, 14.0), primary)
			_add_icon_rect(holder, Vector2(18.0, 18.0), Vector2(26.0, 8.0), secondary)
			_add_icon_rect(holder, Vector2(10.0, 30.0), Vector2(40.0, 5.0), accent)
			_add_icon_rect(holder, Vector2(18.0, 36.0), Vector2(24.0, 4.0), primary.lightened(0.20))
		SkillRulesRef.MACHINE_GUN:
			_add_icon_rect(holder, Vector2(6.0, 26.0), Vector2(12.0, 12.0), primary)
			_add_icon_rect(holder, Vector2(22.0, 18.0), Vector2(12.0, 12.0), secondary)
			_add_icon_rect(holder, Vector2(38.0, 26.0), Vector2(12.0, 12.0), primary)
			_add_icon_rect(holder, Vector2(15.0, 36.0), Vector2(6.0, 3.0), accent)
			_add_icon_rect(holder, Vector2(31.0, 32.0), Vector2(6.0, 3.0), accent)
			_add_icon_rect(holder, Vector2(47.0, 36.0), Vector2(6.0, 3.0), accent)
		_:
			_add_icon_rect(holder, Vector2(20.0, 14.0), Vector2(18.0, 18.0), primary)
			_add_icon_rect(holder, Vector2(14.0, 34.0), Vector2(30.0, 6.0), secondary)


func _add_icon_rect(holder: Control, position_value: Vector2, size_value: Vector2, color: Color) -> void:
	var rect := ColorRect.new()
	rect.position = position_value
	rect.size = size_value
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(rect)


func _on_skill_pressed(skill_id: String) -> void:
	if _resolving_selection:
		return
	if not SkillRulesRef.is_valid_skill_id(skill_id):
		AudioEvents.ui_error()
		return

	var skill_manager = _get_skill_manager()
	if skill_manager == null or not skill_manager.has_method("select_skill"):
		AudioEvents.ui_error()
		return

	_resolving_selection = true

	var skill_definition := SkillRulesRef.definition_for_id(skill_id)
	var button := _card_buttons.get(skill_id) as Button
	if button != null:
		_apply_card_style(button, skill_definition, true)
		var flash := button.get_node_or_null("SelectionFlash") as ColorRect
		if flash != null:
			flash.color = Color(1.0, 1.0, 1.0, 0.0)
		var tween := create_tween()
		tween.parallel().tween_property(button, "scale", Vector2(1.06, 1.06), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		if flash != null:
			tween.parallel().tween_property(flash, "color:a", 0.46, 0.08).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.tween_property(flash, "color:a", 0.0, 0.14).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	if bool(skill_manager.call("select_skill", skill_id)):
		AudioEvents.ui_confirm()
		_title_label.text = "%s 선택!" % SkillRulesRef.display_name_for_id(skill_id)
		_subtitle_label.text = "자동으로 계속 발동돼!"
		call_deferred("_force_close")
	else:
		_resolving_selection = false
		AudioEvents.ui_error()


func _force_close() -> void:
	_resolving_selection = false

	var skill_manager = _get_skill_manager()
	if skill_manager != null and skill_manager.has_method("set_skill_panel_open"):
		skill_manager.call("set_skill_panel_open", false)

	if visible and get_tree().paused:
		get_tree().paused = false

	visible = false
	_title_label.text = "자동 스킬 선택!"
	_subtitle_label.text = "해금된 스킬 중 하나를 골라줘!"


func _center_panel() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(390.0, 844.0)

	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 0.0
	anchor_bottom = 0.0
	offset_left = 0.0
	offset_top = 0.0
	offset_right = viewport_size.x
	offset_bottom = viewport_size.y

	_dim_overlay.anchor_left = 0.0
	_dim_overlay.anchor_top = 0.0
	_dim_overlay.anchor_right = 0.0
	_dim_overlay.anchor_bottom = 0.0
	_dim_overlay.offset_left = 0.0
	_dim_overlay.offset_top = 0.0
	_dim_overlay.offset_right = viewport_size.x
	_dim_overlay.offset_bottom = viewport_size.y

	_panel.size = PANEL_SIZE
	_panel.position = ((viewport_size - PANEL_SIZE) * 0.5).floor()


func _get_skill_manager():
	return get_node_or_null("/root/SkillManager")
