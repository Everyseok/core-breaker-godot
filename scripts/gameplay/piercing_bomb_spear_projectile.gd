extends Area2D
# PiercingBombSpearProjectile — tier 4 siege-spear projectile; configurable
# pierce count and deterministic terminal explosion neighborhood.

const HIT_EFFECT_SCENE := preload("res://scenes/vfx/hit_effect_burst.tscn")
const DamageRulesRef := preload("res://scripts/domain/combat/damage_rules.gd")
const WeaponProfileRef := preload("res://scripts/visual/weapon_profile.gd")
const ProjectileVisualFactoryRef := preload("res://scripts/visual/projectile_visual_factory.gd")

const SPEED := 720.0
const LIFETIME := 1.6
const PIERCE_PUSHFORWARD := 10.0
const IMPACT_OFFSET := 15.0
const VISUAL_TIER := 4

var direction: Vector2 = Vector2.UP
var max_pierce_collisions: int = 2
var explosion_same_layer_radius: int = 2
var hit_effect_layer: Node2D = null
var visual_style_id: String = ""
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

	ProjectileVisualFactoryRef.build_visual(self, _resolved_visual_style())

	rotation = direction.angle() - PI / 2.0
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	position += direction * SPEED * delta
	_age += delta
	if _age >= LIFETIME:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	var damage := BuffManager.apply_damage_multiplier(DamageRulesRef.damage_for_tier(VISUAL_TIER))
	if not area.has_method("resolve_piercing_spear_hit"):
		if area.has_method("take_damage"):
			area.call("take_damage", damage, VISUAL_TIER)
			_spawn_hit_effect(_impact_position(), Vector2.ZERO)
			AudioEvents.weapon_hit(VISUAL_TIER, StringName(GameState.active_weapon_choice_id))
			queue_free()
		return

	var target_key: String = ""
	if area.has_method("get_segment_hit_key"):
		var key_variant: Variant = area.call("get_segment_hit_key")
		if key_variant is String:
			target_key = key_variant
	if target_key != "" and _hit_target_keys.has(target_key):
		return

	area.call("resolve_piercing_spear_hit", damage, VISUAL_TIER)
	if target_key != "":
		_hit_target_keys[target_key] = true
	_spawn_hit_effect(_impact_position(), Vector2.ZERO)
	AudioEvents.weapon_hit(VISUAL_TIER, StringName(GameState.active_weapon_choice_id))
	_pierce_collisions += 1

	if _pierce_collisions >= max_pierce_collisions:
		if area.has_method("trigger_terminal_explosion"):
			area.call("trigger_terminal_explosion", damage, explosion_same_layer_radius, VISUAL_TIER)
		queue_free()
		return

	global_position += direction.normalized() * PIERCE_PUSHFORWARD


func _impact_position() -> Vector2:
	var forward := direction.normalized()
	if forward.length_squared() <= 0.001:
		forward = Vector2.UP
	return global_position + (forward * IMPACT_OFFSET)


func _spawn_hit_effect(hit_position: Vector2, bounce_normal: Vector2) -> void:
	var layer: Node = get_parent()
	if hit_effect_layer != null and is_instance_valid(hit_effect_layer):
		layer = hit_effect_layer
	if layer == null or not is_instance_valid(layer):
		return
	var effect := HIT_EFFECT_SCENE.instantiate()
	effect.call("configure", VISUAL_TIER, direction, bounce_normal, _resolved_visual_style())
	layer.add_child(effect)
	var effect_node := effect as Node2D
	if effect_node != null:
		effect_node.global_position = hit_position


func _resolved_visual_style() -> String:
	if visual_style_id != "":
		return visual_style_id
	return WeaponProfileRef.get_projectile_style(VISUAL_TIER)
