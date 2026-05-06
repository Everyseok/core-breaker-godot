extends Area2D
# BrickInstance — wall segment. Visual is wider tangentially than radially
# so that rotated segments tile the ring with no visible gaps.

const BrickRulesRef := preload("res://scripts/domain/bricks/brick_rules.gd")

signal destroyed(brick_type: int)

const COLLISION_W := BrickRulesRef.SEGMENT_SIZE
const COLLISION_H := 14.0
const VISUAL_W := BrickRulesRef.SEGMENT_SIZE
const VISUAL_H := 14.0
const DEFAULT_COLLISION_LAYER := 2

var brick_type: int = BrickRulesRef.BrickType.NORMAL
var hp: int = 1
var max_hp: int = 1
var ring_owner = null
var segment_index: int = -1
var _shadow_rect: ColorRect
var _frame_rect: ColorRect
var _base_rect: ColorRect
var _highlight_rect: ColorRect
var _underside_rect: ColorRect
var _detail_rect: ColorRect
var _detail_secondary_rect: ColorRect
var _damage_rect: ColorRect


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


func set_airborne_collision_disabled(disabled: bool) -> void:
	collision_layer = 0 if disabled else DEFAULT_COLLISION_LAYER
	monitorable = not disabled


func set_jump_visual_state(jump_state: String, is_jumper: bool) -> void:
	match jump_state:
		"warning":
			modulate = Color(1.0, 0.92, 0.68, 1.0)
		"airborne":
			modulate = Color(0.92, 0.98, 1.0, 0.78)
		"recovery":
			modulate = Color(0.84, 1.0, 0.90, 1.0)
		_:
			modulate = Color(1.0, 1.0, 1.0, 1.0) if is_jumper else Color.WHITE


func is_airborne_for_core_breach() -> bool:
	if ring_owner != null and is_instance_valid(ring_owner) and ring_owner.has_method("is_segment_airborne"):
		return bool(ring_owner.call("is_segment_airborne", segment_index))
	return false


func _ready() -> void:
	collision_layer = DEFAULT_COLLISION_LAYER
	collision_mask = 0

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(COLLISION_W, COLLISION_H)
	shape.shape = rect
	add_child(shape)

	var half_size := Vector2(VISUAL_W * 0.5, VISUAL_H * 0.5)

	_shadow_rect = ColorRect.new()
	_shadow_rect.size = Vector2(VISUAL_W - 2.0, VISUAL_H - 1.0)
	_shadow_rect.position = Vector2(-((VISUAL_W - 2.0) * 0.5) + 2.0, -((VISUAL_H - 1.0) * 0.5) + 2.5)
	add_child(_shadow_rect)

	_frame_rect = ColorRect.new()
	_frame_rect.size = Vector2(VISUAL_W, VISUAL_H)
	_frame_rect.position = -half_size
	add_child(_frame_rect)

	_base_rect = ColorRect.new()
	_base_rect.size = Vector2(VISUAL_W - 6.0, VISUAL_H - 6.0)
	_base_rect.position = Vector2(-((VISUAL_W - 6.0) * 0.5), -((VISUAL_H - 6.0) * 0.5) - 1.0)
	add_child(_base_rect)

	_highlight_rect = ColorRect.new()
	_highlight_rect.size = Vector2(VISUAL_W - 8.0, 3.0)
	_highlight_rect.position = Vector2(-(VISUAL_W - 8.0) * 0.5, -half_size.y + 2.0)
	add_child(_highlight_rect)

	_underside_rect = ColorRect.new()
	_underside_rect.size = Vector2(VISUAL_W - 8.0, 3.0)
	_underside_rect.position = Vector2(-(VISUAL_W - 8.0) * 0.5, half_size.y - 5.0)
	add_child(_underside_rect)

	_detail_rect = ColorRect.new()
	add_child(_detail_rect)

	_detail_secondary_rect = ColorRect.new()
	add_child(_detail_secondary_rect)

	_damage_rect = ColorRect.new()
	_damage_rect.size = Vector2(VISUAL_W, VISUAL_H)
	_damage_rect.position = -half_size
	_damage_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	add_child(_damage_rect)

	_update_visual()


func take_damage(amount: int, source_tier: int = -1) -> void:
	if amount <= 0:
		return
	var will_destroy := hp - amount <= 0
	_request_damage_number(amount, will_destroy, source_tier)
	if will_destroy:
		AudioEvents.brick_break()
	if will_destroy and (ring_owner == null or not is_instance_valid(ring_owner)):
		_request_brick_break_effect()
	hp -= amount
	if hp <= 0:
		destroyed.emit(brick_type)
		queue_free()
	else:
		_update_visual()


func resolve_projectile_hit(damage: int, spread_radius: int, source_tier: int = -1) -> void:
	if ring_owner != null and is_instance_valid(ring_owner) and ring_owner.has_method("apply_projectile_hit"):
		ring_owner.call("apply_projectile_hit", segment_index, damage, spread_radius, source_tier)
		return
	take_damage(damage, source_tier)


func resolve_electric_projectile_hit(damage: int, source_tier: int = -1) -> void:
	if ring_owner != null and is_instance_valid(ring_owner) and ring_owner.has_method("apply_electric_hit"):
		ring_owner.call("apply_electric_hit", segment_index, damage, source_tier)
		return
	take_damage(damage, source_tier)


func resolve_piercing_spear_hit(damage: int, source_tier: int = -1) -> void:
	if ring_owner != null and is_instance_valid(ring_owner) and ring_owner.has_method("apply_piercing_spear_hit"):
		ring_owner.call("apply_piercing_spear_hit", segment_index, damage, source_tier)
		return
	take_damage(damage, source_tier)


func trigger_terminal_explosion(damage: int, same_layer_radius: int = 2, source_tier: int = -1) -> void:
	if ring_owner != null and is_instance_valid(ring_owner) and ring_owner.has_method("apply_terminal_explosion"):
		ring_owner.call("apply_terminal_explosion", segment_index, damage, same_layer_radius, source_tier)


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
	if _frame_rect == null:
		return
	var frame_color := BrickRulesRef.frame_color_for_type(brick_type)
	var base_color := BrickRulesRef.base_color_for_type(brick_type)
	var highlight_color := BrickRulesRef.highlight_color_for_type(brick_type)
	var detail_color := BrickRulesRef.detail_color_for_type(brick_type)
	var shadow_color := BrickRulesRef.shadow_color_for_type(brick_type)
	var underside_color := BrickRulesRef.underside_color_for_type(brick_type)

	var damage_t := 1.0 - clampf(float(hp) / float(maxi(max_hp, 1)), 0.0, 1.0)
	_shadow_rect.color = shadow_color.lerp(Color(0.18, 0.20, 0.28), damage_t * 0.26)
	_frame_rect.color = frame_color.lerp(Color(0.46, 0.48, 0.56), damage_t * 0.32)
	_base_rect.color = base_color.lerp(Color(0.40, 0.42, 0.48), damage_t * 0.46)
	_highlight_rect.color = highlight_color.lerp(Color(0.52, 0.54, 0.62), damage_t * 0.44)
	_underside_rect.color = underside_color.lerp(Color(0.18, 0.20, 0.28), damage_t * 0.42)

	match brick_type:
		BrickRulesRef.BrickType.STRONG:
			_detail_rect.size = Vector2(VISUAL_W - 12.0, 5.0)
			_detail_rect.position = Vector2(-(VISUAL_W - 12.0) * 0.5, -5.5)
			_detail_rect.color = detail_color.lerp(Color(0.58, 0.60, 0.66), damage_t * 0.30)
			_detail_secondary_rect.size = Vector2(8.0, 7.0)
			_detail_secondary_rect.position = Vector2(-4.0, 0.0)
			_detail_secondary_rect.color = frame_color.lerp(Color(0.64, 0.66, 0.72), damage_t * 0.26)
		BrickRulesRef.BrickType.ARMORED:
			_detail_rect.size = Vector2(7.0, VISUAL_H - 3.0)
			_detail_rect.position = Vector2(-10.5, -(VISUAL_H - 3.0) * 0.5 - 0.5)
			_detail_rect.color = detail_color.lerp(Color(0.50, 0.48, 0.56), damage_t * 0.30)
			_detail_secondary_rect.size = Vector2(7.0, VISUAL_H - 3.0)
			_detail_secondary_rect.position = Vector2(3.5, -(VISUAL_H - 3.0) * 0.5 - 0.5)
			_detail_secondary_rect.color = detail_color.lerp(Color(0.50, 0.48, 0.56), damage_t * 0.30)
		_:
			_detail_rect.size = Vector2(7.0, 5.0)
			_detail_rect.position = Vector2(-9.0, -3.0)
			_detail_rect.color = detail_color.lerp(Color(0.72, 0.66, 0.58), damage_t * 0.28)
			_detail_secondary_rect.size = Vector2(7.0, 5.0)
			_detail_secondary_rect.position = Vector2(2.0, -2.0)
			_detail_secondary_rect.color = highlight_color.lerp(Color(0.78, 0.72, 0.62), damage_t * 0.20)

	_damage_rect.color = Color(0.02, 0.03, 0.07, damage_t * 0.42)


func _request_damage_number(amount: int, destroyed: bool, source_tier: int) -> void:
	var roots := get_tree().get_nodes_in_group("game_root")
	if roots.is_empty():
		return
	var root := roots[0]
	if root != null and is_instance_valid(root) and root.has_method("spawn_damage_number"):
		root.call_deferred("spawn_damage_number", global_position, amount, destroyed, source_tier)


func _request_brick_break_effect() -> void:
	var roots := get_tree().get_nodes_in_group("game_root")
	if roots.is_empty():
		return
	var root := roots[0]
	if root != null and is_instance_valid(root) and root.has_method("spawn_brick_break_effect"):
		root.call_deferred("spawn_brick_break_effect", global_position, brick_type)
