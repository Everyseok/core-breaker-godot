extends Area2D
# ElectricSplitProjectile — Tier 4 evolved storm weapon.
# Keeps the stable 1-bounce, ring-aware 6-hit electric behavior.

const HIT_EFFECT_SCENE := preload("res://scenes/vfx/hit_effect_burst.tscn")
const DamageRulesRef := preload("res://scripts/domain/combat/damage_rules.gd")
const WeaponProfileRef := preload("res://scripts/visual/weapon_profile.gd")
const ProjectileVisualFactoryRef := preload("res://scripts/visual/projectile_visual_factory.gd")

const SPEED := 600.0
const LIFETIME := 1.5
const BOUNCES := 1
const POST_HIT_PUSHBACK := 10.0
const HIT_COOLDOWN := 0.04
const IMPACT_OFFSET := 11.0
const VISUAL_TIER := 3

var direction: Vector2 = Vector2.UP
var hit_effect_layer: Node2D = null
var visual_style_id: String = ""
var _age: float = 0.0
var _bounces_remaining: int = BOUNCES
var _hit_cooldown: float = 0.0


func _ready() -> void:
	collision_layer = 4
	collision_mask = 2

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(6, 14)
	shape.shape = rect
	shape.position = Vector2(0, 7)
	add_child(shape)

	ProjectileVisualFactoryRef.build_visual(self, _resolved_visual_style())

	rotation = direction.angle() - PI / 2.0
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	position += direction * SPEED * delta
	_age += delta
	_hit_cooldown = maxf(_hit_cooldown - delta, 0.0)
	if _age >= LIFETIME:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if _hit_cooldown > 0.0:
		return

	var bounce_normal: Vector2 = Vector2.ZERO
	if area.has_method("get_bounce_normal"):
		var normal_variant: Variant = area.call("get_bounce_normal")
		if normal_variant is Vector2:
			bounce_normal = normal_variant

	var damage := DamageRulesRef.damage_for_tier(VISUAL_TIER)
	if area.has_method("resolve_electric_projectile_hit"):
		area.call("resolve_electric_projectile_hit", damage, VISUAL_TIER)
	elif area.has_method("resolve_projectile_hit"):
		area.call("resolve_projectile_hit", damage, 1, VISUAL_TIER)
	elif area.has_method("take_damage"):
		area.call("take_damage", damage, VISUAL_TIER)
	else:
		return

	_spawn_hit_effect(_impact_position(), bounce_normal)

	if _bounces_remaining <= 0:
		queue_free()
		return

	if bounce_normal.length_squared() <= 0.001:
		bounce_normal = -direction

	direction = _reflect(direction, bounce_normal).normalized()
	rotation = direction.angle() - PI / 2.0
	global_position += bounce_normal * POST_HIT_PUSHBACK
	_bounces_remaining -= 1
	_hit_cooldown = HIT_COOLDOWN


func _reflect(vector: Vector2, normal: Vector2) -> Vector2:
	var safe_normal: Vector2 = normal.normalized()
	return vector - (2.0 * vector.dot(safe_normal) * safe_normal)


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
