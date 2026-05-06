extends Node2D
# DamageNumber — cute layered floating damage text.
# Visual-only feedback; does not affect combat math.

const UiStyleRef := preload("res://scripts/ui/ui_style.gd")
const WeaponProfileRef := preload("res://scripts/visual/weapon_profile.gd")

var _amount: int = 1
var _tier: int = 0
var _destroyed: bool = false

var _shadow_label: Label
var _accent_label: Label
var _main_label: Label
var _spark_a: ColorRect
var _spark_b: ColorRect
var _rng := RandomNumberGenerator.new()


func configure(amount: int, tier: int, destroyed: bool = false) -> void:
	_amount = maxi(amount, 1)
	_tier = maxi(tier, 0)
	_destroyed = destroyed
	if is_node_ready():
		_apply_content()


func _ready() -> void:
	z_index = 30
	_rng.randomize()
	_build_visual()
	_apply_content()
	call_deferred("_play_intro")


func _build_visual() -> void:
	_spark_a = ColorRect.new()
	_spark_a.size = Vector2(10.0, 10.0)
	_spark_a.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_spark_a)

	_spark_b = ColorRect.new()
	_spark_b.size = Vector2(6.0, 6.0)
	_spark_b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_spark_b)

	_shadow_label = Label.new()
	_shadow_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_shadow_label)

	_accent_label = Label.new()
	_accent_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_accent_label)

	_main_label = Label.new()
	_main_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_main_label)


func _apply_content() -> void:
	var text := _format_damage(_amount)
	var width := maxf(44.0, 22.0 + (float(text.length()) * 22.0))
	var font_size := 30 if _destroyed else 26
	var primary := WeaponProfileRef.get_primary_color(_tier)
	var secondary := WeaponProfileRef.get_secondary_color(_tier)

	UiStyleRef.apply_label(_shadow_label, font_size + 2, Color(0.02, 0.03, 0.08, 0.94), 0)
	UiStyleRef.apply_label(_accent_label, font_size + 1, primary.lightened(0.10), 4)
	UiStyleRef.apply_label(_main_label, font_size, Color.WHITE, 4)

	for label in [_shadow_label, _accent_label, _main_label]:
		label.text = text
		label.size = Vector2(width, 42.0)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	_shadow_label.position = Vector2((-width * 0.5) + 4.0, -18.0 + 5.0)
	_accent_label.position = Vector2((-width * 0.5) - 2.0, -18.0 - 2.0)
	_main_label.position = Vector2(-width * 0.5, -18.0)

	_spark_a.position = Vector2(-10.0, -14.0)
	_spark_a.color = secondary
	_spark_b.position = Vector2(12.0, -4.0)
	_spark_b.color = primary.lightened(0.22)
	_spark_a.scale = Vector2.ONE * (1.28 if _destroyed else 1.0)
	_spark_b.scale = Vector2.ONE * (1.12 if _destroyed else 1.0)


func _play_intro() -> void:
	var x_jitter := _rng.randf_range(-14.0, 14.0)
	var start_position := position
	var end_position := start_position + Vector2(x_jitter, -42.0 if _destroyed else -34.0)

	position = start_position + Vector2(x_jitter * 0.2, 8.0)
	scale = Vector2(0.56, 0.56)
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	rotation = deg_to_rad(_rng.randf_range(-5.0, 5.0))

	var tween := create_tween()
	tween.parallel().tween_property(self, "position", end_position, 0.46).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "scale", Vector2(1.16, 1.16), 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(0.12)
	tween.tween_property(self, "modulate:a", 0.0, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "rotation", 0.0, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.finished.connect(queue_free)


func _format_damage(amount: int) -> String:
	if amount < 1000:
		return str(amount)

	if amount % 1000 == 0:
		return "%dK" % int(amount / 1000)

	var thousands := float(amount) / 1000.0
	var text := "%.1fK" % thousands
	return text.replace(".0K", "K")
