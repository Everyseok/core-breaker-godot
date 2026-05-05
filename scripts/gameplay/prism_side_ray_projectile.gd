extends Area2D

const HIT_EFFECT_SCENE := preload("res://scenes/vfx/hit_effect_burst.tscn")
const DamageRulesRef := preload("res://scripts/domain/combat/damage_rules.gd")
const WeaponProfileRef := preload("res://scripts/visual/weapon_profile.gd")
const ProjectileVisualFactoryRef := preload("res://scripts/visual/projectile_visual_factory.gd")

const SPEED := 700.0
const LIFETIME := 1.25
const IMPACT_OFFSET := 11.0

var direction: Vector2 = Vector2.UP
var source_tier: int = 0
var hit_effect_layer: Node2D = null
var visual_style_id: String = ""
var _age: float = 0.0


func _ready() -> void:
	collision_layer = 4
	collision_mask = 2

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(5, 16)
	shape.shape = rect
	shape.position = Vector2(0, 8)
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
	var resolved_tier: int = maxi(source_tier, 0)
	var damage := DamageRulesRef.damage_for_tier(resolved_tier)
	if area.has_method("resolve_projectile_hit"):
		area.call("resolve_projectile_hit", damage, 0, resolved_tier)
	elif area.has_method("take_damage"):
		area.call("take_damage", damage, resolved_tier)
	else:
		return

	_spawn_hit_effect(_impact_position())
	queue_free()


func _impact_position() -> Vector2:
	var forward := direction.normalized()
	if forward.length_squared() <= 0.001:
		forward = Vector2.UP
	return global_position + (forward * IMPACT_OFFSET)


func _spawn_hit_effect(hit_position: Vector2) -> void:
	var layer: Node = get_parent()
	if hit_effect_layer != null and is_instance_valid(hit_effect_layer):
		layer = hit_effect_layer
	if layer == null or not is_instance_valid(layer):
		return
	var effect := HIT_EFFECT_SCENE.instantiate()
	effect.call("configure", maxi(source_tier, 0), direction, Vector2.ZERO, _resolved_visual_style())
	layer.add_child(effect)
	var effect_node := effect as Node2D
	if effect_node != null:
		effect_node.global_position = hit_position


func _resolved_visual_style() -> String:
	if visual_style_id != "":
		return visual_style_id
	return WeaponProfileRef.get_projectile_style(maxi(source_tier, 0), "prism_lance")
