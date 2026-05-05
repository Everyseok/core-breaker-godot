extends Node2D
# Single fixed gameplay background image with a subtle level-based tint shift.
# Pure presentation: no collision, no score, no gameplay mutation.

const VIEWPORT_W := 390.0
const VIEWPORT_H := 844.0

const EARLY_LEVEL_TINT := Color(0.96, 0.98, 1.0, 1.0)
const LATE_LEVEL_TINT := Color(0.74, 0.80, 0.90, 1.0)
const MAX_TINT_LEVEL := 30.0
const TRANSITION_DURATION := 0.35

var _background_sprite: Sprite2D
var _current_level: int = 1
var _tint_tween: Tween
var _background_texture: Texture2D


func _ready() -> void:
	z_index = -100
	_build_background()
	GameState.game_started.connect(_on_game_started)
	GameState.level_transitioned.connect(_on_level_transitioned)
	_refresh_for_level(GameState.current_level if GameState.current_level > 0 else 1, false)


func _build_background() -> void:
	_background_texture = _load_background_texture()
	if _background_texture == null:
		return
	_background_sprite = Sprite2D.new()
	_background_sprite.name = "BackgroundSprite"
	_background_sprite.texture = _background_texture
	_background_sprite.centered = false
	_background_sprite.position = Vector2.ZERO
	_background_sprite.z_index = -100
	_background_sprite.scale = Vector2(
		VIEWPORT_W / maxf(float(_background_texture.get_width()), 1.0),
		VIEWPORT_H / maxf(float(_background_texture.get_height()), 1.0)
	)
	add_child(_background_sprite)


func _on_game_started() -> void:
	_current_level = 1
	_refresh_for_level(1, false)


func _on_level_transitioned(new_level: int) -> void:
	_current_level = new_level
	_refresh_for_level(new_level, true)


func _refresh_for_level(level: int, animate: bool) -> void:
	if _background_sprite == null:
		return
	var t: float = clampf(float(level - 1) / MAX_TINT_LEVEL, 0.0, 1.0)
	var target_tint: Color = EARLY_LEVEL_TINT.lerp(LATE_LEVEL_TINT, t)
	if _tint_tween != null:
		_tint_tween.kill()
		_tint_tween = null
	if not animate:
		_background_sprite.modulate = target_tint
		return
	_tint_tween = create_tween()
	_tint_tween.tween_property(_background_sprite, "modulate", target_tint, TRANSITION_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _load_background_texture() -> Texture2D:
	var image := Image.load_from_file(ProjectSettings.globalize_path("res://basicbackground.png"))
	if image == null or image.is_empty():
		push_warning("basicbackground.png could not be loaded")
		return null
	return ImageTexture.create_from_image(image)
