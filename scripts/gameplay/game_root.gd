extends Node2D
# GameRoot — gameplay scene root; wires child nodes and owns start/stop lifecycle

@onready var _core = $Core
@onready var _weapon = $Weapon
@onready var _ring_spawner = $RingSpawner
@onready var _brick_layer: Node2D = $BrickLayer
@onready var _projectile_layer: Node2D = $ProjectileLayer


func _ready() -> void:
	add_to_group("game_root")
	GameState.game_over.connect(_on_game_over)
	GameState.max_level_cleared.connect(_on_max_level_cleared)
	GameState.level_transitioned.connect(_on_level_transitioned)
	DangerManager.danger_level_changed.connect(_on_danger_level)
	_core.core_breached.connect(_on_core_breached)
	_ring_spawner.brick_destroyed.connect(_on_brick_destroyed)
	_weapon.set_launch_origin_provider(_core)
	_weapon.set_projectile_layer(_projectile_layer)
	_ring_spawner.set_ring_layer(_brick_layer)
	# Auto-start removed: MainMenu.start_game() begins a run when the player taps Start.


func start_game() -> void:
	# Public entry point called by MainMenu (initial start) and restart paths.
	# Clears any active bricks/projectiles so it is safe to call on both initial
	# launch and after a previous run has ended.
	_ring_spawner.stop()
	for child in _brick_layer.get_children():
		_brick_layer.remove_child(child)
		child.queue_free()
	for child in _projectile_layer.get_children():
		_projectile_layer.remove_child(child)
		child.queue_free()
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
	# GM-01 / GC-01: submit score at max-level-clear; total_progress == 100000
	PlatformBridge.submit_leaderboard_score(GameState.total_progress)


func _on_level_transitioned(_new_level: int) -> void:
	_reset_active_level_state()


func _on_danger_level(level: int) -> void:
	AudioManager.set_bgm_intensity(level)


func _reset_active_level_state() -> void:
	_ring_spawner.stop()
	for child in _brick_layer.get_children():
		_brick_layer.remove_child(child)
		child.queue_free()
	for child in _projectile_layer.get_children():
		_projectile_layer.remove_child(child)
		child.queue_free()
	DangerManager.reset()
	if GameState.is_playing:
		_ring_spawner.start()
