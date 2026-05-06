extends Node2D
# GameRoot — gameplay scene root; wires gameplay nodes and their presentation layers.

const DAMAGE_NUMBER_SCENE := preload("res://scenes/vfx/damage_number.tscn")
const BRICK_BREAK_EFFECT_SCENE := preload("res://scenes/vfx/brick_break_effect.tscn")
const COMBAT_PROC_EFFECT_SCENE := preload("res://scenes/vfx/combat_proc_effect.tscn")
const AdLayoutRef := preload("res://scripts/ui/ad_layout.gd")

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
	_apply_ad_safe_playfield_layout()
	if not get_viewport().size_changed.is_connected(_apply_ad_safe_playfield_layout):
		get_viewport().size_changed.connect(_apply_ad_safe_playfield_layout)
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
	_sync_background_transform()
	add_child(_background)
	move_child(_background, 0)


func _apply_ad_safe_playfield_layout() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(390.0, 844.0)

	var playfield_top := (
		AdLayoutRef.RESERVED_TOP_HEIGHT
		+ AdLayoutRef.HUD_RESERVED_HEIGHT
		+ AdLayoutRef.PLAYFIELD_TOP_GAP
	)
	var playfield_bottom := viewport_size.y - AdLayoutRef.BOTTOM_CONTROL_RESERVED_HEIGHT
	if playfield_bottom <= playfield_top + 80.0:
		playfield_bottom = viewport_size.y - 150.0

	var radius_by_width := maxf((viewport_size.x - (AdLayoutRef.PLAYFIELD_HORIZONTAL_MARGIN * 2.0)) * 0.5, 1.0)
	var radius_by_height := maxf((playfield_bottom - playfield_top) * 0.5, 1.0)
	var scale_factor := clampf(
		minf(radius_by_width, radius_by_height) / AdLayoutRef.PLAYFIELD_BASE_OUTER_RADIUS,
		AdLayoutRef.PLAYFIELD_MIN_SCALE,
		AdLayoutRef.PLAYFIELD_MAX_SCALE
	)

	position = Vector2(viewport_size.x * 0.5, (playfield_top + playfield_bottom) * 0.5)
	scale = Vector2.ONE * scale_factor
	_sync_background_transform()


func _sync_background_transform() -> void:
	if _background == null:
		return
	var safe_scale := Vector2(maxf(scale.x, 0.001), maxf(scale.y, 0.001))
	_background.position = Vector2(-position.x / safe_scale.x, -position.y / safe_scale.y)
	_background.scale = Vector2(1.0 / safe_scale.x, 1.0 / safe_scale.y)


func start_game() -> void:
	# Public entry point called by MainMenu (initial start) and restart paths.
	# Clears any active bricks/projectiles so it is safe to call on both initial
	# launch and after a previous run has ended.
	AudioEvents.game_start()
	AudioEvents.bgm_set_state(&"run", float(GameState.current_level_k))
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
	AudioEvents.game_over()
	AudioEvents.bgm_stop()
	# GM-01 / GC-01: submit the user's persisted best after run completion.
	PlatformBridge.submit_leaderboard_score(SaveManager.get_best_record_value())


func _on_max_level_cleared() -> void:
	_ring_spawner.stop()
	DangerManager.reset()
	AudioEvents.game_max_clear()
	AudioEvents.bgm_stop()
	# GM-01 / GC-01: submit the user's persisted best after max-level-clear.
	PlatformBridge.submit_leaderboard_score(SaveManager.get_best_record_value())


func _on_level_transitioned(_new_level: int) -> void:
	AudioEvents.level_transition()
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
