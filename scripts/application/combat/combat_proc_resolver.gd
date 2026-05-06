class_name CombatProcResolver
extends RefCounted

const WeaponChoiceRulesRef := preload("res://scripts/domain/combat/weapon_choice_rules.gd")
const CHAIN_FALLBACK_DISTANCE := 18.0


static func resolve_chain_lightning(
	origin_segment_index: int,
	blocked_indices: Array,
	segments: Array,
	origin_angle: float
) -> Dictionary:
	var target_index: int = find_chain_target_index(origin_segment_index, blocked_indices, segments)
	return {
		"effect_id": "chain_lightning",
		"target_index": target_index,
		"has_damage_target": target_index >= 0,
		"fallback_offset": chain_fallback_offset_for_angle(origin_angle),
	}


static func resolve_meteor_cannon(origin_segment_index: int, segment_count: int) -> Dictionary:
	return {
		"effect_id": "meteor_cannon",
		"target_indices": collect_target_indices(
			origin_segment_index,
			WeaponChoiceRulesRef.METEOR_RADIUS,
			segment_count
		),
	}


static func find_chain_target_index(origin_segment_index: int, blocked_indices: Array, segments: Array) -> int:
	if segments.is_empty():
		return -1
	var blocked: Dictionary = {}
	for blocked_variant in blocked_indices:
		blocked[int(blocked_variant)] = true
	for offset in [1, -1, 2, -2]:
		if abs(offset) > WeaponChoiceRulesRef.CHAIN_RANGE:
			continue
		var target_index: int = wrapi(origin_segment_index + offset, 0, segments.size())
		if blocked.has(target_index):
			continue
		var segment: Dictionary = segments[target_index]
		if not bool(segment["alive"]):
			continue
		return target_index
	return -1


static func collect_target_indices(center_index: int, spread_radius: int, segment_count: int) -> Array:
	var target_indices: Array = []
	if segment_count <= 0:
		return target_indices
	var unique_targets: Dictionary = {}
	for offset in range(-spread_radius, spread_radius + 1):
		var wrapped_index: int = wrapi(center_index + offset, 0, segment_count)
		unique_targets[wrapped_index] = true
	for index_variant in unique_targets.keys():
		target_indices.append(int(index_variant))
	return target_indices


static func chain_fallback_offset_for_angle(angle: float) -> Vector2:
	var tangent := Vector2(-sin(angle), cos(angle)).normalized()
	if tangent.length_squared() <= 0.001:
		tangent = Vector2.RIGHT
	return tangent * CHAIN_FALLBACK_DISTANCE
