extends Node2D
# GameRoot — gameplay scene root; wires gameplay nodes and their presentation layers.

const DAMAGE_NUMBER_SCENE := preload("res://scenes/vfx/damage_number.tscn")
const BRICK_BREAK_EFFECT_SCENE := preload("res://scenes/vfx/brick_break_effect.tscn")
const COMBAT_PROC_EFFECT_SCENE := preload("res://scenes/vfx/combat_proc_effect.tscn")

@onready var _core = $Core
@onready var _weapon = $Weapon
@onready var _ring_spawner = $RingSpawner
@onready var _brick_layer: Node2D = $BrickLayer
@onready var _projectile_layer: Node2D = $ProjectileLayer
@onready var _vfx_layer: Node2D = $VfxLayer
@onready var _damage_number_layer: Node2D = $DamageNumberLayer

var _background: Node2D


func _ready() -> void:
	add_to_group("game_root")
	_build_background()
	GameState.game_over.connect(_on_game_over)
	GameState.max_level_cleared.connect(_on_max_level_cleared)
	GameState.level_transitioned.connect(_on_level_transitioned)
	DangerManager.danger_level_changed.connect(_on_danger_level)
	_core.core_breached.connect(_on_core_breached)
	_ring_spawner.brick_destroyed.connect(_on_brick_destroyed)
	_weapon.set_launch_origin_provider(_core)
	_weapon.set_projectile_layer(_projectile_layer)
	_weapon.set_hit_effect_layer(_vfx_layer)
	_ring_spawner.set_ring_layer(_brick_layer)
	# Auto-start removed: MainMenu.start_game() begins a run when the player taps Start.


func _build_background() -> void:
	var bg_script = load("res://scripts/visual/game_background.gd")
	if bg_script == null:
		return
	_background = bg_script.new()
	_background.position = -position
	add_child(_background)
	move_child(_background, 0)


func start_game() -> void:
	# Public entry point called by MainMenu (initial start) and restart paths.
	# Clears any active bricks/projectiles so it is safe to call on both initial
	# launch and after a previous run has ended.
	_ring_spawner.stop()
	_clear_runtime_layers()
	DangerManager.reset()
	GameState.start_run()
	_ring_spawner.start()


func _on_brick_destroyed(_brick_type: int) -> void:
	GameState.add_k(1)


func _on_core_breached() -> void:
	GameState.trigger_game_over()


func _on_game_over() -> void:
	_ring_spawner.stop()
	DangerManager.reset()
	# GM-01 / GC-01: submit score at run completion only; duplicate guard is in PlatformBridge
	PlatformBridge.submit_leaderboard_score(GameState.total_progress)


func _on_max_level_cleared() -> void:
	_ring_spawner.stop()
	DangerManager.reset()
	# GM-01 / GC-01: submit score at max-level-clear; total_progress == 300000
	PlatformBridge.submit_leaderboard_score(GameState.total_progress)


func _on_level_transitioned(_new_level: int) -> void:
	_reset_active_level_state()


func _on_danger_level(level: int) -> void:
	AudioManager.set_bgm_intensity(level)


func _reset_active_level_state() -> void:
	_ring_spawner.stop()
	_clear_runtime_layers()
	DangerManager.reset()
	if GameState.is_playing:
		_ring_spawner.start()


func _clear_runtime_layers() -> void:
	_clear_layer(_brick_layer)
	_clear_layer(_projectile_layer)
	_clear_layer(_vfx_layer)
	_clear_layer(_damage_number_layer)


func _clear_layer(layer: Node) -> void:
	for child in layer.get_children():
		layer.remove_child(child)
		child.queue_free()


func spawn_damage_number(world_position: Vector2, amount: int, destroyed: bool = false, tier: int = -1) -> void:
	if _damage_number_layer == null or not is_instance_valid(_damage_number_layer):
		return
	var popup := DAMAGE_NUMBER_SCENE.instantiate()
	if popup == null:
		return
	popup.call("configure", amount, tier if tier >= 0 else GameState.current_projectile_tier, destroyed)
	_damage_number_layer.add_child(popup)
	var popup_node := popup as Node2D
	if popup_node != null:
		popup_node.global_position = world_position


func spawn_brick_break_effect(world_position: Vector2, brick_type: int) -> void:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var effect := BRICK_BREAK_EFFECT_SCENE.instantiate()
	if effect == null:
		return
	effect.call("configure", brick_type)
	_vfx_layer.add_child(effect)
	var effect_node := effect as Node2D
	if effect_node != null:
		effect_node.global_position = world_position


func spawn_combat_effect(
	effect_id: String,
	world_position: Vector2,
	world_target: Vector2,
	source_tier: int = -1
) -> void:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var effect := COMBAT_PROC_EFFECT_SCENE.instantiate()
	if effect == null:
		return
	_vfx_layer.add_child(effect)
	var effect_node := effect as Node2D
	if effect_node != null:
		effect_node.global_position = world_position
	effect.call("configure", effect_id, world_target, source_tier)
