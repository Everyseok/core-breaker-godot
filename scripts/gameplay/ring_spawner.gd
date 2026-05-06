extends Node2D
# RingSpawner — presentation-layer spawner that asks an application planner for specs.

const RingSpawnPlannerRef := preload("res://scripts/application/rings/ring_spawn_planner.gd")
const BrickRulesRef := preload("res://scripts/domain/bricks/brick_rules.gd")

signal brick_destroyed(brick_type: int)

const RING_SCENE := preload("res://scenes/gameplay/ring_instance.tscn")
const BASE_INTERVAL := 5.0

var _ring_layer: Node2D
var _timer: Timer
var _planner = RingSpawnPlannerRef.new()
var _wall_group_sequence: int = 0


func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = BASE_INTERVAL
	_timer.autostart = false
	_timer.timeout.connect(_spawn_ring)
	add_child(_timer)


func set_ring_layer(layer: Node2D) -> void:
	_ring_layer = layer


func start() -> void:
	_spawn_ring()
	_timer.start()


func stop() -> void:
	_timer.stop()


func _spawn_ring() -> void:
	if not GameState.is_playing or _ring_layer == null:
		return
	var spawn_spec := _planner.build_spawn_spec(GameState.current_level_k)
	var wall_group_id: int = _wall_group_sequence
	_wall_group_sequence += 1
	var rotation_mode: String = String(spawn_spec.get(
		"rotation_mode",
		RingSpawnPlannerRef.ROTATION_CLOCKWISE
	))
	var layer_specs: Array = spawn_spec.get("layers", [])
	if layer_specs.is_empty():
		layer_specs = [{
			"radius": float(spawn_spec.get("radius", RingSpawnPlannerRef.DEFAULT_SPAWN_RADIUS)),
			"segment_count": int(spawn_spec.get(
				"segment_count",
				RingSpawnPlannerRef.segment_count_for_radius(
					RingSpawnPlannerRef.DEFAULT_SPAWN_RADIUS,
					BrickRulesRef.SEGMENT_SIZE
				)
			)),
			"brick_type": int(spawn_spec.get("brick_type", BrickRulesRef.BrickType.NORMAL)),
		}]

	for layer_index in range(layer_specs.size()):
		var layer_spec_variant: Variant = layer_specs[layer_index]
		if not (layer_spec_variant is Dictionary):
			continue
		var layer_spec: Dictionary = layer_spec_variant
		var ring = RING_SCENE.instantiate()
		ring.setup(
			float(layer_spec.get("radius", RingSpawnPlannerRef.DEFAULT_SPAWN_RADIUS)),
			float(spawn_spec.get("shrink_speed", RingSpawnPlannerRef.DEFAULT_SHRINK_SPEED)),
			int(layer_spec.get(
				"segment_count",
				RingSpawnPlannerRef.segment_count_for_radius(
					float(layer_spec.get("radius", RingSpawnPlannerRef.DEFAULT_SPAWN_RADIUS)),
					BrickRulesRef.SEGMENT_SIZE
				)
			)),
			int(layer_spec.get("brick_type", BrickRulesRef.BrickType.NORMAL)),
			float(spawn_spec.get("segment_size", BrickRulesRef.SEGMENT_SIZE)),
			wall_group_id,
			layer_index,
			layer_specs.size(),
			rotation_mode
		)
		ring.brick_destroyed.connect(_on_ring_brick_destroyed)
		_ring_layer.add_child(ring)


func _on_ring_brick_destroyed(brick_type: int) -> void:
	brick_destroyed.emit(brick_type)
