extends Node2D
# Core — fixed center; game over when any brick enters the kill radius.
# KILL_RADIUS remains the exact gameplay death/launch point while the guardian
# visuals add aim-follow, recoil, and tier-aware weapon presentation around it.

signal core_breached()

const KILL_RADIUS := 40.0
const WeaponProfileRef := preload("res://scripts/visual/weapon_profile.gd")
const WeaponModuleFactoryRef := preload("res://scripts/visual/weapon_module_factory.gd")
const SkillVisualFactoryRef := preload("res://scripts/visual/skill_visual_factory.gd")

var _aura_rect: ColorRect
var _glow_rect: ColorRect
var _core_dot: ColorRect
var _body_root: Node2D
var _guardian_root: Node2D
var _module_root: Node2D
var _skill_companion_root: Node2D
var _flash_root: Node2D
var _shell_shadow: ColorRect
var _outer_shell: ColorRect
var _shell: ColorRect
var _shell_rim: ColorRect
var _shell_highlight: ColorRect
var _visor_rect: ColorRect
var _charge_rect: ColorRect
var _left_wing: ColorRect
var _right_wing: ColorRect
var _idle_tween: Tween
var _pulse_tween: Tween
var _flash_tween: Tween
var _target_aim_angle: float = 0.0
var _visual_aim_angle: float = 0.0
var _guardian_base_position: Vector2 = Vector2(0.0, -8.0)
var _glow_base_position: Vector2 = Vector2.ZERO
var _core_dot_base_position: Vector2 = Vector2.ZERO
var _visor_base_position: Vector2 = Vector2.ZERO
var _charge_base_position: Vector2 = Vector2.ZERO
var _left_wing_base_position: Vector2 = Vector2.ZERO
var _right_wing_base_position: Vector2 = Vector2.ZERO
var _recoil_offset: Vector2 = Vector2.ZERO
var _current_tier: int = 0
var _current_skill_visual_id: String = ""


func _ready() -> void:
	_build_kill_zone()
	_build_visual()
	_current_tier = GameState.current_projectile_tier
	_rebuild_guardian(_current_tier, GameState.active_weapon_choice_id)
	GameState.tier_changed.connect(_on_tier_changed)
	GameState.tier_threshold_reached.connect(_on_tier_threshold_reached)
	GameState.weapon_choice_selected.connect(_on_weapon_choice_selected)
	InputHandler.aim_changed.connect(_on_aim_changed)
	_connect_skill_visual_signals()
	_on_aim_changed(InputHandler.aim_direction)
	_sync_skill_companion()
	_start_idle_pulse()


func _process(delta: float) -> void:
	_update_visual_follow(delta)


func _build_kill_zone() -> void:
	var area := Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 2
	area.area_entered.connect(_on_brick_entered)

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = KILL_RADIUS
	shape.shape = circle
	area.add_child(shape)
	add_child(area)


func _build_visual() -> void:
	var aura_size := KILL_RADIUS * 2.8
	_aura_rect = ColorRect.new()
	_aura_rect.size = Vector2(aura_size, aura_size)
	_aura_rect.position = Vector2(-aura_size * 0.5, -aura_size * 0.5)
	_aura_rect.color = Color(1.0, 0.34, 0.12, 0.18)
	add_child(_aura_rect)

	_body_root = Node2D.new()
	_body_root.z_index = 1
	add_child(_body_root)

	_shell_shadow = ColorRect.new()
	_shell_shadow.size = Vector2(98.0, 94.0)
	_shell_shadow.position = Vector2(-49.0, -42.0)
	_shell_shadow.color = Color(0.00, 0.02, 0.08, 0.36)
	_body_root.add_child(_shell_shadow)

	_outer_shell = ColorRect.new()
	_outer_shell.size = Vector2(92.0, 88.0)
	_outer_shell.position = Vector2(-46.0, -46.0)
	_body_root.add_child(_outer_shell)

	_shell = ColorRect.new()
	_shell.size = Vector2(76.0, 72.0)
	_shell.position = Vector2(-38.0, -38.0)
	_body_root.add_child(_shell)

	_shell_rim = ColorRect.new()
	_shell_rim.size = Vector2(66.0, 10.0)
	_shell_rim.position = Vector2(-33.0, -34.0)
	_body_root.add_child(_shell_rim)

	_shell_highlight = ColorRect.new()
	_shell_highlight.size = Vector2(60.0, 5.0)
	_shell_highlight.position = Vector2(-30.0, -30.0)
	_body_root.add_child(_shell_highlight)

	_left_wing = ColorRect.new()
	_left_wing.size = Vector2(12.0, 28.0)
	_left_wing.position = Vector2(-36.0, -6.0)
	_body_root.add_child(_left_wing)
	_left_wing_base_position = _left_wing.position

	_right_wing = ColorRect.new()
	_right_wing.size = Vector2(12.0, 28.0)
	_right_wing.position = Vector2(24.0, -6.0)
	_body_root.add_child(_right_wing)
	_right_wing_base_position = _right_wing.position

	_visor_rect = ColorRect.new()
	_visor_rect.size = Vector2(30.0, 10.0)
	_visor_rect.position = Vector2(-15.0, -10.0)
	_body_root.add_child(_visor_rect)
	_visor_base_position = _visor_rect.position

	_charge_rect = ColorRect.new()
	_charge_rect.size = Vector2(18.0, 6.0)
	_charge_rect.position = Vector2(-9.0, 8.0)
	_body_root.add_child(_charge_rect)
	_charge_base_position = _charge_rect.position

	_glow_rect = ColorRect.new()
	_glow_rect.size = Vector2(34.0, 34.0)
	_glow_rect.position = Vector2(-17.0, -17.0)
	_body_root.add_child(_glow_rect)
	_glow_base_position = _glow_rect.position

	_core_dot = ColorRect.new()
	_core_dot.size = Vector2(10.0, 10.0)
	_core_dot.position = Vector2(-5.0, -5.0)
	_body_root.add_child(_core_dot)
	_core_dot_base_position = _core_dot.position

	_guardian_root = Node2D.new()
	_guardian_root.position = _guardian_base_position
	_guardian_root.z_index = 4
	add_child(_guardian_root)

	_module_root = Node2D.new()
	_module_root.name = "WeaponModuleRoot"
	_guardian_root.add_child(_module_root)

	_skill_companion_root = Node2D.new()
	_skill_companion_root.name = "SkillCompanionRoot"
	_skill_companion_root.position = Vector2(0.0, 26.0)
	_skill_companion_root.z_index = -2
	_guardian_root.add_child(_skill_companion_root)

	_flash_root = Node2D.new()
	_flash_root.name = "MuzzleFlashRoot"
	_flash_root.z_index = 2
	_guardian_root.add_child(_flash_root)


func get_launch_origin_global() -> Vector2:
	return global_position


func play_fire_feedback(tier: int, fire_direction: Vector2, choice_id: String = "") -> void:
	var direction := fire_direction.normalized() if fire_direction.length_squared() > 0.001 else Vector2.UP
	_recoil_offset = -direction * WeaponProfileRef.get_recoil_distance(tier, choice_id)
	_spawn_muzzle_flash(tier, choice_id)
	var pulse_color := WeaponProfileRef.get_secondary_color(tier, choice_id)
	_glow_rect.modulate = pulse_color
	_charge_rect.modulate = pulse_color


func _on_tier_changed(tier: int) -> void:
	_current_tier = tier
	_rebuild_guardian(tier, GameState.active_weapon_choice_id)


func _on_tier_threshold_reached(unlocked_tier: int, _threshold: int, _display_name: String) -> void:
	if unlocked_tier < 1 or unlocked_tier > 4:
		return
	_pulse_guardian(unlocked_tier)


func _on_weapon_choice_selected(choice_id: String, _display_name: String) -> void:
	_rebuild_guardian(GameState.current_projectile_tier, choice_id)
	_pulse_guardian(GameState.current_projectile_tier, choice_id)


func _connect_skill_visual_signals() -> void:
	var skill_manager = get_node_or_null("/root/SkillManager")
	if skill_manager == null:
		return

	var selected_callback := Callable(self, "_on_skill_selected")
	if skill_manager.has_signal("skill_selected") and not skill_manager.is_connected("skill_selected", selected_callback):
		skill_manager.connect("skill_selected", selected_callback)

	var state_callback := Callable(self, "_sync_skill_companion")
	if skill_manager.has_signal("skill_state_changed") and not skill_manager.is_connected("skill_state_changed", state_callback):
		skill_manager.connect("skill_state_changed", state_callback)


func _on_skill_selected(_skill_id: String, _display_name: String) -> void:
	_sync_skill_companion()


func _sync_skill_companion() -> void:
	if _skill_companion_root == null:
		return

	var skill_manager = get_node_or_null("/root/SkillManager")
	if skill_manager == null or not skill_manager.has_method("get_selected_skill_id"):
		_clear_skill_companion()
		return

	var skill_id := String(skill_manager.call("get_selected_skill_id"))
	_rebuild_skill_companion(skill_id)


func _rebuild_skill_companion(skill_id: String) -> void:
	if _skill_companion_root == null:
		return

	if skill_id == _current_skill_visual_id:
		return

	_current_skill_visual_id = skill_id
	SkillVisualFactoryRef.build_companion(_skill_companion_root, skill_id)


func _clear_skill_companion() -> void:
	if _skill_companion_root == null:
		return

	for child in _skill_companion_root.get_children():
		child.queue_free()

	_current_skill_visual_id = ""


func _on_aim_changed(direction: Vector2) -> void:
	if direction.length_squared() <= 0.001:
		return
	_target_aim_angle = direction.angle() + (PI * 0.5)


func _on_brick_entered(area: Area2D) -> void:
	if area != null and area.has_method("is_airborne_for_core_breach"):
		if bool(area.call("is_airborne_for_core_breach")):
			return
	core_breached.emit()


func _rebuild_guardian(tier: int, choice_id: String = "") -> void:
	if _module_root == null or _flash_root == null:
		return
	for child in _module_root.get_children():
		child.queue_free()
	for child in _flash_root.get_children():
		child.queue_free()

	_apply_body_palette(tier, choice_id)
	_flash_root.position = Vector2(0.0, -WeaponProfileRef.get_muzzle_reach(tier, choice_id))

	var primary := WeaponProfileRef.get_primary_color(tier, choice_id)
	var secondary := WeaponProfileRef.get_secondary_color(tier, choice_id)
	var accent := WeaponProfileRef.get_accent_color(tier, choice_id)
	var visual_id := WeaponProfileRef.resolve_visual_id(tier, choice_id)
	WeaponModuleFactoryRef.build_module(_module_root, visual_id, primary, secondary, accent)


func _apply_body_palette(tier: int, choice_id: String = "") -> void:
	var primary := WeaponProfileRef.get_primary_color(tier, choice_id)
	var secondary := WeaponProfileRef.get_secondary_color(tier, choice_id)
	var accent := WeaponProfileRef.get_accent_color(tier, choice_id)
	_outer_shell.color = Color(0.14, 0.14, 0.20, 0.98).lerp(primary.darkened(0.78), 0.32)
	_shell.color = Color(0.09, 0.12, 0.18, 0.98).lerp(primary.darkened(0.86), 0.20)
	_shell_rim.color = secondary.darkened(0.10)
	_shell_highlight.color = secondary.lightened(0.10)
	_left_wing.color = accent.darkened(0.28)
	_right_wing.color = accent.darkened(0.18)
	_visor_rect.color = secondary
	_charge_rect.color = primary.lightened(0.10)
	_glow_rect.color = Color(primary.lerp(secondary, 0.56).r, primary.lerp(secondary, 0.56).g, primary.lerp(secondary, 0.56).b, 0.82)
	_core_dot.color = secondary.lightened(0.18)
	_aura_rect.color = Color(primary.r, primary.g, primary.b, 0.18)


func _update_visual_follow(delta: float) -> void:
	if _body_root == null or _guardian_root == null:
		return
	var aim := InputHandler.aim_direction
	if aim.length_squared() <= 0.001:
		aim = Vector2.UP
	_target_aim_angle = aim.angle() + (PI * 0.5)
	_recoil_offset = _recoil_offset.lerp(Vector2.ZERO, minf(delta * 12.0, 1.0))

	var body_target := Vector2(aim.x * 4.2, aim.y * 2.8)
	_body_root.position = _body_root.position.lerp(body_target, minf(delta * 8.0, 1.0))
	_body_root.rotation = lerpf(_body_root.rotation, deg_to_rad(aim.x * 7.5), minf(delta * 8.0, 1.0))

	_guardian_root.position = _guardian_root.position.lerp(
		_guardian_base_position + Vector2(aim.x * 8.0, aim.y * 5.5) + _recoil_offset,
		minf(delta * 10.0, 1.0)
	)
	_visual_aim_angle = lerp_angle(_visual_aim_angle, _target_aim_angle, minf(delta * 11.0, 1.0))
	_guardian_root.rotation = _visual_aim_angle

	_left_wing.position = _left_wing.position.lerp(
		_left_wing_base_position + Vector2(-aim.x * 1.8, aim.y * 1.3),
		minf(delta * 8.0, 1.0)
	)
	_right_wing.position = _right_wing.position.lerp(
		_right_wing_base_position + Vector2(-aim.x * 1.8, aim.y * 1.3),
		minf(delta * 8.0, 1.0)
	)
	_left_wing.rotation = lerpf(_left_wing.rotation, deg_to_rad(-8.0 - (aim.x * 10.0)), minf(delta * 8.0, 1.0))
	_right_wing.rotation = lerpf(_right_wing.rotation, deg_to_rad(8.0 - (aim.x * 10.0)), minf(delta * 8.0, 1.0))

	_visor_rect.position = _visor_rect.position.lerp(
		_visor_base_position + Vector2(aim.x * 3.0, aim.y * 1.4),
		minf(delta * 9.0, 1.0)
	)
	_charge_rect.position = _charge_rect.position.lerp(
		_charge_base_position + Vector2(aim.x * 2.2, aim.y * 1.0),
		minf(delta * 9.0, 1.0)
	)
	_glow_rect.position = _glow_rect.position.lerp(
		_glow_base_position + Vector2(aim.x * 2.0, aim.y * 2.0),
		minf(delta * 9.0, 1.0)
	)
	_core_dot.position = _core_dot.position.lerp(
		_core_dot_base_position + Vector2(aim.x * 1.2, aim.y * 1.2),
		minf(delta * 9.0, 1.0)
	)
	_aura_rect.scale = _aura_rect.scale.lerp(Vector2.ONE * (1.0 + (absf(aim.x) * 0.05)), minf(delta * 5.0, 1.0))


func _spawn_muzzle_flash(tier: int, choice_id: String = "") -> void:
	if _flash_root == null:
		return
	for child in _flash_root.get_children():
		child.queue_free()
	if _flash_tween != null:
		_flash_tween.kill()

	var primary := WeaponProfileRef.get_primary_color(tier, choice_id)
	var secondary := WeaponProfileRef.get_secondary_color(tier, choice_id)
	var accent := WeaponProfileRef.get_accent_color(tier, choice_id)
	var flash_scale := WeaponProfileRef.get_muzzle_flash_scale(tier, choice_id)
	var visual_id := WeaponProfileRef.resolve_visual_id(tier, choice_id)

	WeaponModuleFactoryRef.build_muzzle_flash(_flash_root, visual_id, flash_scale, primary, secondary, accent)

	_flash_root.scale = Vector2.ONE
	_flash_root.modulate = Color.WHITE
	_flash_tween = create_tween()
	_flash_tween.parallel().tween_property(_flash_root, "scale", Vector2(1.26, 1.26), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_flash_tween.parallel().tween_property(_flash_root, "modulate:a", 0.0, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_flash_tween.finished.connect(_clear_flash_root)


func _clear_flash_root() -> void:
	if _flash_root == null:
		return
	for child in _flash_root.get_children():
		child.queue_free()
	_flash_root.modulate = Color.WHITE
	_flash_root.scale = Vector2.ONE


func _start_idle_pulse() -> void:
	if _idle_tween != null:
		_idle_tween.kill()
	_idle_tween = create_tween().set_loops()
	_idle_tween.tween_property(_aura_rect, "color:a", 0.30, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_idle_tween.parallel().tween_property(_glow_rect, "scale", Vector2(1.16, 1.16), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_idle_tween.tween_property(_aura_rect, "color:a", 0.18, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_idle_tween.parallel().tween_property(_glow_rect, "scale", Vector2.ONE, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _pulse_guardian(tier: int, choice_id: String = "") -> void:
	if _guardian_root == null:
		return
	if _pulse_tween != null:
		_pulse_tween.kill()

	var pulse_color := WeaponProfileRef.get_secondary_color(tier, choice_id)
	_guardian_root.scale = Vector2.ONE
	_guardian_root.modulate = Color.WHITE
	_pulse_tween = create_tween()
	_pulse_tween.parallel().tween_property(_guardian_root, "scale", Vector2(1.14, 1.14), 0.10).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_pulse_tween.parallel().tween_property(_guardian_root, "modulate", pulse_color, 0.10).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_pulse_tween.tween_property(_guardian_root, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_pulse_tween.parallel().tween_property(_guardian_root, "modulate", Color.WHITE, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
