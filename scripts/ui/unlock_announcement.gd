extends Control
# Short punchy weapon-change announcement shown under the top HUD.

const WeaponProfileRef := preload("res://scripts/visual/weapon_profile.gd")
const UiStyleRef := preload("res://scripts/ui/ui_style.gd")

@onready var _panel: Panel = $Panel
@onready var _label: Label = $Panel/Label

var _base_position: Vector2
var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_base_position = position
	pivot_offset = size * 0.5
	visible = false
	GameState.tier_threshold_reached.connect(_on_tier_threshold_reached)
	GameState.weapon_choice_selected.connect(_on_weapon_choice_selected)


func _on_tier_threshold_reached(unlocked_tier: int, _threshold: int, display_name: String) -> void:
	if unlocked_tier < 1 or unlocked_tier > 4:
		return
	show_weapon_change_banner("%s 장착!" % display_name, unlocked_tier)


func _on_weapon_choice_selected(choice_id: String, display_name: String) -> void:
	show_weapon_change_banner("%s 장착!" % display_name, GameState.current_projectile_tier, choice_id)


func show_weapon_change_banner(text: String, tier: int, choice_id: String = "") -> void:
	_show_banner(text, tier, choice_id)


func _show_banner(text: String, tier: int, choice_id: String = "") -> void:
	if _tween != null:
		_tween.kill()
		_tween = null

	var fill := WeaponProfileRef.get_primary_color(tier, choice_id).darkened(0.72)
	fill.a = 0.94
	var border := WeaponProfileRef.get_secondary_color(tier, choice_id)
	UiStyleRef.apply_panel(_panel, fill, border)
	UiStyleRef.apply_label(_label, 22, Color.WHITE)
	_label.text = text

	visible = true
	position = _base_position + Vector2(0.0, 18.0)
	scale = Vector2(0.84, 0.84)
	modulate = Color(1.0, 1.0, 1.0, 0.0)

	_tween = create_tween()
	_tween.parallel().tween_property(self, "position", _base_position, 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(self, "scale", Vector2(1.06, 1.06), 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(self, "modulate:a", 1.0, 0.08).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector2.ONE, 0.08).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_interval(0.62)
	_tween.tween_property(self, "position", _base_position + Vector2(0.0, -10.0), 0.16).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.parallel().tween_property(self, "modulate:a", 0.0, 0.16).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.finished.connect(_hide_banner)


func _hide_banner() -> void:
	visible = false
	position = _base_position
	scale = Vector2.ONE
