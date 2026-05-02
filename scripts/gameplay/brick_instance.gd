extends Area2D
# BrickInstance — wall segment. Visual is wider tangentially than radially
# so that rotated segments tile the ring with no visible gaps.

const BrickRulesRef := preload("res://scripts/domain/bricks/brick_rules.gd")

signal destroyed(brick_type: int)

const COLLISION_W := BrickRulesRef.SEGMENT_SIZE
const COLLISION_H := 14.0
const VISUAL_W := BrickRulesRef.SEGMENT_SIZE
const VISUAL_H := 14.0

var brick_type: int = BrickRulesRef.BrickType.NORMAL
var hp: int = 1
var max_hp: int = 1
var ring_owner = null
var segment_index: int = -1
var _visual: ColorRect


func setup(type: int, current_hp: int = -1, current_max_hp: int = -1) -> void:
	sync_state(type, current_hp, current_max_hp)


func sync_state(type: int, current_hp: int = -1, current_max_hp: int = -1) -> void:
	brick_type = type
	max_hp = current_max_hp if current_max_hp > 0 else BrickRulesRef.hp_for_type(type)
	hp = current_hp if current_hp > 0 else max_hp
	_update_visual()


func set_segment_context(owner: Node2D, index: int) -> void:
	ring_owner = owner
	segment_index = index


func _ready() -> void:
	collision_layer = 2
	collision_mask = 0

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(COLLISION_W, COLLISION_H)
	shape.shape = rect
	add_child(shape)

	_visual = ColorRect.new()
	_visual.size = Vector2(VISUAL_W, VISUAL_H)
	_visual.position = Vector2(-VISUAL_W * 0.5, -VISUAL_H * 0.5)
	add_child(_visual)
	_update_visual()


func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	hp -= amount
	if hp <= 0:
		destroyed.emit(brick_type)
		queue_free()
	else:
		_update_visual()


func resolve_projectile_hit(damage: int, spread_radius: int) -> void:
	if ring_owner != null and is_instance_valid(ring_owner) and ring_owner.has_method("apply_projectile_hit"):
		ring_owner.call("apply_projectile_hit", segment_index, damage, spread_radius)
		return
	take_damage(damage)


func resolve_electric_projectile_hit(damage: int) -> void:
	if ring_owner != null and is_instance_valid(ring_owner) and ring_owner.has_method("apply_electric_hit"):
		ring_owner.call("apply_electric_hit", segment_index, damage)
		return
	take_damage(damage)


func resolve_piercing_spear_hit(damage: int) -> void:
	if ring_owner != null and is_instance_valid(ring_owner) and ring_owner.has_method("apply_piercing_spear_hit"):
		ring_owner.call("apply_piercing_spear_hit", segment_index, damage)
		return
	take_damage(damage)


func trigger_terminal_explosion(damage: int, same_layer_radius: int = 2) -> void:
	if ring_owner != null and is_instance_valid(ring_owner) and ring_owner.has_method("apply_terminal_explosion"):
		ring_owner.call("apply_terminal_explosion", segment_index, damage, same_layer_radius)


func get_segment_hit_key() -> String:
	if ring_owner != null and is_instance_valid(ring_owner) and ring_owner.has_method("get_segment_hit_key"):
		var key_variant: Variant = ring_owner.call("get_segment_hit_key", segment_index)
		if key_variant is String:
			return key_variant
	return "local:%d" % segment_index


func get_bounce_normal() -> Vector2:
	var owner_2d: Node2D = ring_owner
	if owner_2d != null and is_instance_valid(owner_2d):
		var normal: Vector2 = (global_position - owner_2d.global_position).normalized()
		if normal.length_squared() > 0.001:
			return normal
	return Vector2.ZERO


func _update_visual() -> void:
	if _visual == null:
		return
	var base := BrickRulesRef.base_color_for_type(brick_type)
	if max_hp == 1:
		_visual.color = base
		return
	# Lerp toward near-white as HP drops (visible damage state)
	var t := float(hp) / float(max_hp)
	_visual.color = base.lerp(Color(0.88, 0.88, 0.88), 1.0 - t)
