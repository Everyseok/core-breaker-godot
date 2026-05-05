extends Node2D
# Weapon — fires from the center core area toward InputHandler.aim_direction.
# Auto-fires; tier-aware; supports Overclock.
# Presentation stays lightweight here; the guardian/core owns the center identity.

const WeaponProfileRef := preload("res://scripts/visual/weapon_profile.gd")
const WeaponChoiceRulesRef := preload("res://scripts/domain/combat/weapon_choice_rules.gd")

const ARROW_SCENE  := preload("res://scenes/gameplay/arrow_projectile.tscn")
const THUNDER_SCENE := preload("res://scenes/gameplay/thunder_bolt_projectile.tscn")
const SPARK_LANCE_SCENE := preload("res://scenes/gameplay/spark_lance_projectile.tscn")
const ELECTRIC_BOLT_SCENE := preload("res://scenes/gameplay/electric_split_projectile.tscn")
const PIERCING_BOMB_SPEAR_SCENE := preload("res://scenes/gameplay/piercing_bomb_spear_projectile.tscn")
const PRISM_SIDE_RAY_SCENE := preload("res://scenes/gameplay/prism_side_ray_projectile.tscn")

const BASE_FIRE_INTERVAL  := 0.35
const OVERCLOCK_MULTIPLIER := 1.0 / 3.0
const OVERCLOCK_DURATION  := 3.0
const OVERCLOCK_COOLDOWN := 15.0
const SIEGE_VOLLEY_ANGLES := [-36, -24, -12, 0, 12, 24, 36]

var _projectile_layer: Node2D
var _hit_effect_layer: Node2D
var _fire_timer: Timer
var _is_overclocked: bool = false
var _overclock_timer: float = 0.0
var _overclock_cooldown_timer: float = 0.0
var _current_tier: int = 0
var _aim_glow_line: Line2D
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
	GameState.weapon_choice_selected.connect(_on_weapon_choice_selected)
	GameState.game_started.connect(_on_game_started)


func _build_visuals() -> void:
	_aim_glow_line = Line2D.new()
	_aim_glow_line.width = 6.0
	_aim_glow_line.default_color = WeaponProfileRef.get_primary_color(_current_tier, GameState.active_weapon_choice_id).darkened(0.05)
	_aim_glow_line.default_color.a = 0.20
	_aim_glow_line.z_index = -2
	_aim_glow_line.add_point(Vector2.ZERO)
	_aim_glow_line.add_point(Vector2.UP * 120.0)
	add_child(_aim_glow_line)

	# Aim indicator: semi-transparent line extending toward aim direction
	_aim_line = Line2D.new()
	_aim_line.width = 3.0
	_aim_line.default_color = WeaponProfileRef.get_aim_line_color(_current_tier, GameState.active_weapon_choice_id)
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


func set_hit_effect_layer(layer: Node2D) -> void:
	_hit_effect_layer = layer


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
	_aim_glow_line.set_point_position(1, InputHandler.aim_direction * 130.0)
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
		1: _fire_thunder()
		2: _fire_spark_lances()
		3: _fire_volt_storm()
		4: _fire_siege_cannon()
		_: _fire_arrow()
	_play_fire_feedback()
	if GameState.consume_prism_volley_trigger():
		_fire_prism_side_rays()


func _fire_arrow() -> void:
	var p = ARROW_SCENE.instantiate()
	p.direction = InputHandler.aim_direction
	_attach_projectile(p)


func _fire_thunder() -> void:
	for deg in [-8, 8]:
		var p = THUNDER_SCENE.instantiate()
		p.direction = Vector2.from_angle(InputHandler.aim_direction.angle() + deg_to_rad(deg))
		_attach_projectile(p)


func _fire_spark_lances() -> void:
	for deg in [-15, 0, 15]:
		var p = SPARK_LANCE_SCENE.instantiate()
		p.direction = Vector2.from_angle(InputHandler.aim_direction.angle() + deg_to_rad(deg))
		_attach_projectile(p)


func _fire_volt_storm() -> void:
	for deg in [-15, 0, 15]:
		var p = ELECTRIC_BOLT_SCENE.instantiate()
		p.direction = Vector2.from_angle(InputHandler.aim_direction.angle() + deg_to_rad(deg))
		_attach_projectile(p)


func _fire_siege_cannon() -> void:
	for deg in SIEGE_VOLLEY_ANGLES:
		var p = PIERCING_BOMB_SPEAR_SCENE.instantiate()
		p.direction = Vector2.from_angle(InputHandler.aim_direction.angle() + deg_to_rad(deg))
		if deg == 0:
			p.max_pierce_collisions = 2
			p.explosion_same_layer_radius = 2
		else:
			p.max_pierce_collisions = 1
			p.explosion_same_layer_radius = 1
		_attach_projectile(p)


func _fire_prism_side_rays() -> void:
	for deg in WeaponChoiceRulesRef.PRISM_SIDE_ANGLES:
		var ray = PRISM_SIDE_RAY_SCENE.instantiate()
		ray.direction = Vector2.from_angle(InputHandler.aim_direction.angle() + deg_to_rad(deg))
		ray.source_tier = _current_tier
		_attach_projectile(ray)
	_request_combat_effect("prism_lance", _get_launch_origin(), _get_launch_origin() + (InputHandler.aim_direction * 80.0), _current_tier)
	if AudioManager != null:
		var hook_name := WeaponChoiceRulesRef.proc_audio_hook_for_id(WeaponChoiceRulesRef.PRISM_LANCE)
		if AudioManager.has_method("play_weapon_proc"):
			AudioManager.play_weapon_proc(hook_name)
		elif AudioManager.has_method("play_hook"):
			AudioManager.play_hook(hook_name)


func _on_tier_changed(tier: int) -> void:
	_current_tier = tier
	_is_overclocked = false
	_overclock_timer = 0.0
	_fire_timer.wait_time = BASE_FIRE_INTERVAL
	_refresh_aim_visual()


func _on_weapon_choice_selected(_choice_id: String, _display_name: String) -> void:
	_refresh_aim_visual()


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


func _attach_projectile(projectile: Node2D) -> void:
	_apply_projectile_visual_identity(projectile)
	projectile.set("hit_effect_layer", _hit_effect_layer)
	_projectile_layer.add_child(projectile)
	projectile.global_position = _get_launch_origin()


func _request_combat_effect(effect_id: String, world_position: Vector2, world_target: Vector2, tier: int) -> void:
	var roots := get_tree().get_nodes_in_group("game_root")
	if roots.is_empty():
		return
	var root := roots[0]
	if root != null and is_instance_valid(root):
		if root.has_method("spawn_combat_effect"):
			root.call_deferred("spawn_combat_effect", effect_id, world_position, world_target, tier)
			return


func _play_fire_feedback() -> void:
	if _launch_origin_provider == null or not is_instance_valid(_launch_origin_provider):
		return
	if _launch_origin_provider.has_method("play_fire_feedback"):
		_launch_origin_provider.call_deferred("play_fire_feedback", _current_tier, InputHandler.aim_direction, GameState.active_weapon_choice_id)


func _refresh_aim_visual() -> void:
	if _aim_line != null:
		_aim_line.default_color = WeaponProfileRef.get_aim_line_color(_current_tier, GameState.active_weapon_choice_id)
	if _aim_glow_line != null:
		var glow_color := WeaponProfileRef.get_primary_color(_current_tier, GameState.active_weapon_choice_id)
		glow_color.a = 0.20
		_aim_glow_line.default_color = glow_color


func _apply_projectile_visual_identity(projectile: Node) -> void:
	var visual_style_id := WeaponProfileRef.get_projectile_style(_current_tier, GameState.active_weapon_choice_id)
	for property_info_variant in projectile.get_property_list():
		var property_info: Dictionary = property_info_variant
		if String(property_info.get("name", "")) == "visual_style_id":
			projectile.set("visual_style_id", visual_style_id)
			return


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
