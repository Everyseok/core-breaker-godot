class_name RingSpawnPlanner
extends RefCounted

const BrickRulesRef := preload("res://scripts/domain/bricks/brick_rules.gd")
const JsonConfigLoaderRef := preload("res://scripts/infrastructure/config/json_config_loader.gd")
const WeaponChoiceRulesRef := preload("res://scripts/domain/combat/weapon_choice_rules.gd")

const GAME_CONFIG_PATH := "res://data/game_config.json"
const DEFAULT_SPAWN_RADIUS := 280.0
const DEFAULT_SHRINK_SPEED := 30.0
const DEFAULT_LAYER_SPACING := 18.0


func build_spawn_spec(k_value: int) -> Dictionary:
	var radius: float = _spawn_radius()
	var layers: Array = _layers_for_k(k_value, radius)
	return {
		"radius": radius,
		"shrink_speed": _shrink_speed_for_k(k_value),
		"segment_count": segment_count_for_radius(radius),
		"segment_size": BrickRulesRef.SEGMENT_SIZE,
		"brick_type": brick_type_for_k(k_value),
		"layers": layers,
	}


static func segment_count_for_radius(
	radius: float,
	segment_size: float = BrickRulesRef.SEGMENT_SIZE
) -> int:
	# Tile the circumference so adjacent segments are touching without accumulating overlap.
	return maxi(ceili(TAU * radius / segment_size), 6)


func brick_type_for_k(k_value: int) -> int:
	if k_value >= 40:
		return BrickRulesRef.BrickType.ARMORED
	if k_value >= 15:
		return BrickRulesRef.BrickType.STRONG
	return BrickRulesRef.BrickType.NORMAL


func _shrink_speed_for_k(k_value: int) -> float:
	# Rings shrink slightly faster with progression to maintain difficulty.
	return DEFAULT_SHRINK_SPEED + minf(k_value * 0.10, 20.0)


func _spawn_radius() -> float:
	var config: Dictionary = JsonConfigLoaderRef.load_dictionary(GAME_CONFIG_PATH)
	var configured_radius: Variant = config.get("play_field_radius", DEFAULT_SPAWN_RADIUS)
	if configured_radius is float or configured_radius is int:
		return maxf(float(configured_radius), 1.0)
	return DEFAULT_SPAWN_RADIUS


func _layers_for_k(k_value: int, outer_radius: float) -> Array:
	var layer_types: Array = _layer_types_for_k(k_value)
	var spacing: float = _layer_spacing()
	var layers: Array = []
	for layer_index in range(layer_types.size()):
		var layer_radius: float = maxf(outer_radius - (spacing * float(layer_index)), 1.0)
		layers.append(_build_layer_spec(layer_radius, int(layer_types[layer_index])))
	return layers


func _layer_types_for_k(k_value: int) -> Array:
	if k_value >= 250:
		var base_layers := [
			BrickRulesRef.BrickType.STRONG,
			BrickRulesRef.BrickType.STRONG,
			BrickRulesRef.BrickType.NORMAL,
			BrickRulesRef.BrickType.STRONG,
			BrickRulesRef.BrickType.ARMORED,
		]
		if k_value >= WeaponChoiceRulesRef.CHOICE_TRIGGER_K and base_layers.size() == 5:
			return _expand_five_layer_wall(base_layers)
		return base_layers
	if k_value >= 75 and k_value < 250:
		return [
			BrickRulesRef.BrickType.STRONG,
			BrickRulesRef.BrickType.ARMORED,
		]
	return [
		brick_type_for_k(k_value),
	]


func _build_layer_spec(layer_radius: float, layer_brick_type: int) -> Dictionary:
	return {
		"radius": layer_radius,
		"segment_count": segment_count_for_radius(layer_radius),
		"brick_type": layer_brick_type,
	}


func _layer_spacing() -> float:
	var config: Dictionary = JsonConfigLoaderRef.load_dictionary(GAME_CONFIG_PATH)
	var configured_spacing: Variant = config.get("wall_layer_spacing", DEFAULT_LAYER_SPACING)
	if configured_spacing is float or configured_spacing is int:
		return maxf(float(configured_spacing), 1.0)
	return DEFAULT_LAYER_SPACING


func _expand_five_layer_wall(base_layers: Array) -> Array:
	if base_layers.size() != 5:
		return base_layers.duplicate(true)
	return [
		BrickRulesRef.BrickType.STRONG,
		BrickRulesRef.BrickType.STRONG,
		BrickRulesRef.BrickType.STRONG,
		BrickRulesRef.BrickType.NORMAL,
		BrickRulesRef.BrickType.STRONG,
		BrickRulesRef.BrickType.STRONG,
		BrickRulesRef.BrickType.STRONG,
		BrickRulesRef.BrickType.ARMORED,
	]
