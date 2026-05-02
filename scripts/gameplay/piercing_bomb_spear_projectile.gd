extends Area2D
# PiercingBombSpearProjectile — tier 4 siege-spear projectile; configurable
# pierce count and deterministic terminal explosion neighborhood.

const SPEED := 720.0
const LIFETIME := 1.6
const PIERCE_PUSHFORWARD := 10.0

var direction: Vector2 = Vector2.UP
var max_pierce_collisions: int = 2
var explosion_same_layer_radius: int = 2
var _age: float = 0.0
var _pierce_collisions: int = 0
var _hit_target_keys: Dictionary = {}


func _ready() -> void:
	collision_layer = 4
	collision_mask = 2

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(8, 22)
	shape.shape = rect
	shape.position = Vector2(0, 11)
	add_child(shape)

	var visual := ColorRect.new()
	visual.size = Vector2(6, 24)
	visual.position = Vector2(-3, 0)
	visual.color = Color(1.0, 0.55, 0.18)
	add_child(visual)

	rotation = direction.angle() - PI / 2.0
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	position += direction * SPEED * delta
	_age += delta
	if _age >= LIFETIME:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if not area.has_method("resolve_piercing_spear_hit"):
		if area.has_method("take_damage"):
			area.call("take_damage", 1)
			queue_free()
		return

	var target_key: String = ""
	if area.has_method("get_segment_hit_key"):
		var key_variant: Variant = area.call("get_segment_hit_key")
		if key_variant is String:
			target_key = key_variant
	if target_key != "" and _hit_target_keys.has(target_key):
		return

	area.call("resolve_piercing_spear_hit", 1)
	if target_key != "":
		_hit_target_keys[target_key] = true
	_pierce_collisions += 1

	if _pierce_collisions >= max_pierce_collisions:
		if area.has_method("trigger_terminal_explosion"):
			area.call("trigger_terminal_explosion", 1, explosion_same_layer_radius)
		queue_free()
		return

	global_position += direction.normalized() * PIERCE_PUSHFORWARD
