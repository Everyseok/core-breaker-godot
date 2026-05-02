extends Node
# DangerManager — tracks active rings and delegates danger math to domain rules.

const DangerRulesRef := preload("res://scripts/domain/danger/danger_rules.gd")
const JsonConfigLoaderRef := preload("res://scripts/infrastructure/config/json_config_loader.gd")

signal danger_level_changed(level: int)

const GAME_CONFIG_PATH := "res://data/game_config.json"
const DEFAULT_REFERENCE_RADIUS := 280.0

var current_level: int = 0
var reference_radius: float = DEFAULT_REFERENCE_RADIUS

var _tracked_rings: Array = []


func _ready() -> void:
	_load_reference_radius()


func register_ring(ring: Node2D) -> void:
	if ring not in _tracked_rings:
		_tracked_rings.append(ring)


func unregister_ring(ring: Node2D) -> void:
	_tracked_rings.erase(ring)


func reset() -> void:
	_tracked_rings.clear()
	_set_level(0)


func _process(_delta: float) -> void:
	if _tracked_rings.is_empty():
		_set_level(0)
		return
	var min_r := INF
	var has_valid_ring := false
	for ring in _tracked_rings:
		if is_instance_valid(ring) and ring.has_method("get_radius"):
			min_r = minf(min_r, ring.get_radius())
			has_valid_ring = true
	if not has_valid_ring:
		_set_level(0)
		return
	_set_level(DangerRulesRef.level_for_ratio(min_r / maxf(reference_radius, 1.0)))


func _set_level(level: int) -> void:
	if level != current_level:
		current_level = level
		danger_level_changed.emit(current_level)


func _load_reference_radius() -> void:
	var config: Dictionary = JsonConfigLoaderRef.load_dictionary(GAME_CONFIG_PATH)
	var configured_radius: Variant = config.get("play_field_radius", DEFAULT_REFERENCE_RADIUS)
	reference_radius = DEFAULT_REFERENCE_RADIUS
	if configured_radius is float or configured_radius is int:
		reference_radius = maxf(float(configured_radius), 1.0)
