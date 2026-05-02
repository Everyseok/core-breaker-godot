extends Node2D
# Weapon — fires from the center core area toward InputHandler.aim_direction.
# Auto-fires; tier-aware; supports Overclock.
# The visible core is the launch point, so this script keeps visuals minimal.

const ARROW_SCENE  := preload("res://scenes/gameplay/arrow_projectile.tscn")
const STONE_SCENE  := preload("res://scenes/gameplay/stone_projectile.tscn")
const ELECTRIC_BOLT_SCENE := preload("res://scenes/gameplay/electric_split_projectile.tscn")
const PIERCING_BOMB_SPEAR_SCENE := preload("res://scenes/gameplay/piercing_bomb_spear_projectile.tscn")

const BASE_FIRE_INTERVAL  := 0.35
const OVERCLOCK_MULTIPLIER := 1.0 / 3.0
const OVERCLOCK_DURATION  := 3.0
const OVERCLOCK_COOLDOWN := 15.0
const SIEGE_VOLLEY_ANGLES := [-36, -24, -12, 0, 12, 24, 36]

var _projectile_layer: Node2D
var _fire_timer: Timer
var _is_overclocked: bool = false
var _overclock_timer: float = 0.0
var _overclock_cooldown_timer: float = 0.0
var _current_tier: int = 0
var _aim_line: Line2D
var _launch_origin_provider: Node2D = null


func _ready() -> void:
	add_to_group("weapon")
	InputHandler.set_aim_origin(_get_launch_origin())

	_build_visuals()

	_fire_timer = Timer.new()
	_fire_timer.wait_time = BASE_FIRE_INTERVAL
	_fire_timer.autostart = true
	_fire_timer.timeout.connect(_fire)
	add_child(_fire_timer)

	_current_tier = GameState.current_projectile_tier
	GameState.tier_changed.connect(_on_tier_changed)
	GameState.game_started.connect(_on_game_started)


func _build_visuals() -> void:
	# Aim indicator: semi-transparent line extending toward aim direction
	_aim_line = Line2D.new()
	_aim_line.width = 2.0
	_aim_line.default_color = Color(1.0, 1.0, 1.0, 0.35)
	# Keep the center launch point visually clear so the cyan core point remains
	# the exact visible origin of outgoing projectiles.
	_aim_line.z_index = -1
	_aim_line.add_point(Vector2.ZERO)
	_aim_line.add_point(Vector2.UP * 120.0)
	add_child(_aim_line)


func set_launch_origin_provider(provider: Node2D) -> void:
	_launch_origin_provider = provider
	if _launch_origin_provider != null and is_instance_valid(_launch_origin_provider):
		global_position = _launch_origin_provider.global_position
	InputHandler.set_aim_origin(_get_launch_origin())


func set_projectile_layer(layer: Node2D) -> void:
	_projectile_layer = layer


func activate_overclock() -> void:
	if not can_activate_overclock():
		return
	_is_overclocked = true
	_overclock_timer = OVERCLOCK_DURATION
	_fire_timer.wait_time = BASE_FIRE_INTERVAL * OVERCLOCK_MULTIPLIER


func _process(delta: float) -> void:
	# Update aim line to match current aim direction
	if _launch_origin_provider != null and is_instance_valid(_launch_origin_provider):
		global_position = _launch_origin_provider.global_position
	_aim_line.set_point_position(1, InputHandler.aim_direction * 130.0)
	InputHandler.set_aim_origin(_get_launch_origin())

	if not _is_overclocked:
		if _overclock_cooldown_timer > 0.0:
			_overclock_cooldown_timer = maxf(_overclock_cooldown_timer - delta, 0.0)
		return
	_overclock_timer -= delta
	if _overclock_timer <= 0.0:
		_is_overclocked = false
		_overclock_timer = 0.0
		_overclock_cooldown_timer = OVERCLOCK_COOLDOWN
		_fire_timer.wait_time = BASE_FIRE_INTERVAL


func _fire() -> void:
	if not GameState.is_playing or _projectile_layer == null:
		return
	match _current_tier:
		0: _fire_arrow()
		1: _fire_stone()
		2: _fire_split_arrows()
		3: _fire_electric_split_arrows()
		4: _fire_piercing_bomb_spear()
		_: _fire_arrow()


func _fire_arrow() -> void:
	var p = ARROW_SCENE.instantiate()
	p.direction = InputHandler.aim_direction
	_projectile_layer.add_child(p)
	p.global_position = _get_launch_origin()


func _fire_stone() -> void:
	var p = STONE_SCENE.instantiate()
	p.direction = InputHandler.aim_direction
	_projectile_layer.add_child(p)
	p.global_position = _get_launch_origin()


func _fire_split_arrows() -> void:
	for deg in [-15, 0, 15]:
		var p = ARROW_SCENE.instantiate()
		p.direction = Vector2.from_angle(InputHandler.aim_direction.angle() + deg_to_rad(deg))
		_projectile_layer.add_child(p)
		p.global_position = _get_launch_origin()


func _fire_electric_split_arrows() -> void:
	for deg in [-15, 0, 15]:
		var p = ELECTRIC_BOLT_SCENE.instantiate()
		p.direction = Vector2.from_angle(InputHandler.aim_direction.angle() + deg_to_rad(deg))
		_projectile_layer.add_child(p)
		p.global_position = _get_launch_origin()


func _fire_piercing_bomb_spear() -> void:
	for deg in SIEGE_VOLLEY_ANGLES:
		var p = PIERCING_BOMB_SPEAR_SCENE.instantiate()
		p.direction = Vector2.from_angle(InputHandler.aim_direction.angle() + deg_to_rad(deg))
		if deg == 0:
			p.max_pierce_collisions = 2
			p.explosion_same_layer_radius = 2
		else:
			p.max_pierce_collisions = 1
			p.explosion_same_layer_radius = 1
		_projectile_layer.add_child(p)
		p.global_position = _get_launch_origin()


func _on_tier_changed(tier: int) -> void:
	_current_tier = tier
	_is_overclocked = false
	_overclock_timer = 0.0
	_fire_timer.wait_time = BASE_FIRE_INTERVAL


func _on_game_started() -> void:
	_is_overclocked = false
	_overclock_timer = 0.0
	_overclock_cooldown_timer = 0.0
	_fire_timer.wait_time = BASE_FIRE_INTERVAL


func _get_launch_origin() -> Vector2:
	if _launch_origin_provider != null and is_instance_valid(_launch_origin_provider):
		if _launch_origin_provider.has_method("get_launch_origin_global"):
			var launch_variant: Variant = _launch_origin_provider.call("get_launch_origin_global")
			if launch_variant is Vector2:
				return launch_variant
		return _launch_origin_provider.global_position
	return global_position


func is_overclock_unlocked() -> bool:
	return GameState.is_overclock_unlocked()


func can_activate_overclock() -> bool:
	return (
		GameState.is_playing
		and is_overclock_unlocked()
		and not _is_overclocked
		and _overclock_cooldown_timer <= 0.0
	)


func is_overclock_active() -> bool:
	return _is_overclocked


func is_overclock_on_cooldown() -> bool:
	return not _is_overclocked and _overclock_cooldown_timer > 0.0


func get_overclock_remaining_time() -> float:
	if _is_overclocked:
		return maxf(_overclock_timer, 0.0)
	return maxf(_overclock_cooldown_timer, 0.0)


func get_overclock_unlock_threshold() -> int:
	return GameState.get_overclock_unlock_threshold()
