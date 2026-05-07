class_name SkillVisualFactory
extends RefCounted
# SkillVisualFactory — code-native companion equipment for automatic skills.
# Visual-only. No targeting, no damage, no audio, no projectile VFX.

const SkillRulesRef := preload("res://scripts/domain/skills/skill_rules.gd")


static func build_companion(parent: Node2D, skill_id: String) -> void:
	if parent == null:
		return

	_clear_parent(parent)

	if not SkillRulesRef.is_valid_skill_id(skill_id):
		return

	var definition := SkillRulesRef.definition_for_id(skill_id)
	var primary: Color = Color(definition.get("primary_color", Color(0.52, 0.74, 1.0, 1.0)))
	var secondary: Color = Color(definition.get("secondary_color", Color(0.80, 0.92, 1.0, 1.0)))
	var accent: Color = Color(definition.get("accent_color", primary))

	match skill_id:
		SkillRulesRef.STONE_THROW:
			_build_catapult(parent, primary, secondary, accent)
		SkillRulesRef.METEOR:
			_build_meteor_cannon(parent, primary, secondary, accent)
		SkillRulesRef.MACHINE_GUN:
			_build_toy_turrets(parent, primary, secondary, accent)
		_:
			return


static func _clear_parent(parent: Node) -> void:
	for child in parent.get_children():
		child.queue_free()


static func _build_catapult(parent: Node2D, primary: Color, secondary: Color, accent: Color) -> void:
	# Small wooden toy catapult. Width about 44px.
	# Coordinates are centered around the companion root.
	_add_rect(parent, Vector2(0.0, 18.0), Vector2(44.0, 6.0), accent.darkened(0.08))
	_add_rect(parent, Vector2(-16.0, 8.0), Vector2(6.0, 22.0), primary)
	_add_rect(parent, Vector2(16.0, 8.0), Vector2(6.0, 22.0), primary.darkened(0.05))
	_add_rect(parent, Vector2(0.0, 6.0), Vector2(36.0, 5.0), primary.lightened(0.08))

	# Throwing arm and cup.
	_add_line(parent, Vector2(-14.0, 4.0), Vector2(14.0, -12.0), 4.0, primary.lightened(0.08))
	_add_rect(parent, Vector2(18.0, -15.0), Vector2(14.0, 6.0), accent)
	_add_rect(parent, Vector2(20.0, -20.0), Vector2(10.0, 10.0), secondary)

	# Tiny wheels / toy grounding.
	_add_rect(parent, Vector2(-20.0, 24.0), Vector2(8.0, 8.0), primary.darkened(0.18))
	_add_rect(parent, Vector2(20.0, 24.0), Vector2(8.0, 8.0), primary.darkened(0.18))


static func _build_meteor_cannon(parent: Node2D, primary: Color, secondary: Color, accent: Color) -> void:
	# Small rounded fantasy cannon. Width about 48px.
	# Must feel different from the front siege cannon: lower, rounder, ember-like.
	_add_rect(parent, Vector2(0.0, 20.0), Vector2(46.0, 6.0), primary.darkened(0.58))
	_add_rect(parent, Vector2(-18.0, 26.0), Vector2(8.0, 8.0), accent.darkened(0.22))
	_add_rect(parent, Vector2(18.0, 26.0), Vector2(8.0, 8.0), accent.darkened(0.22))

	# Cannon body and barrel.
	_add_rect(parent, Vector2(0.0, 7.0), Vector2(30.0, 22.0), primary.darkened(0.04))
	_add_rect(parent, Vector2(0.0, -6.0), Vector2(24.0, 16.0), primary.lightened(0.02))
	_add_rect(parent, Vector2(0.0, -18.0), Vector2(26.0, 8.0), secondary)

	# Ember accents.
	_add_rect(parent, Vector2(-12.0, -3.0), Vector2(5.0, 10.0), accent)
	_add_rect(parent, Vector2(12.0, -3.0), Vector2(5.0, 10.0), accent)
	_add_rect(parent, Vector2(0.0, -25.0), Vector2(8.0, 6.0), Color(1.0, 0.94, 0.74, 0.95))


static func _build_toy_turrets(parent: Node2D, primary: Color, secondary: Color, accent: Color) -> void:
	# Three cute toy turrets/drones, not realistic soldiers.
	# Total width about 72px. No real gun detail, no violence.
	_build_single_toy_turret(parent, Vector2(-24.0, 8.0), primary.darkened(0.06), secondary, accent, -1.0)
	_build_single_toy_turret(parent, Vector2(0.0, 0.0), secondary.darkened(0.04), primary.lightened(0.18), accent, 0.0)
	_build_single_toy_turret(parent, Vector2(24.0, 8.0), primary, secondary, accent, 1.0)


static func _build_single_toy_turret(
	parent: Node2D,
	center: Vector2,
	body_color: Color,
	helmet_color: Color,
	accent: Color,
	side: float
) -> void:
	# Body.
	_add_rect(parent, center + Vector2(0.0, 8.0), Vector2(15.0, 16.0), body_color)
	_add_rect(parent, center + Vector2(0.0, -4.0), Vector2(17.0, 10.0), helmet_color)

	# Face/visor-like cute drone mark.
	_add_rect(parent, center + Vector2(0.0, 1.0), Vector2(9.0, 3.0), Color(0.90, 0.96, 1.0, 0.90))

	# Tiny toy muzzle block, intentionally non-realistic.
	var muzzle_x := 10.0 if side >= 0.0 else -10.0
	if absf(side) < 0.1:
		muzzle_x = 0.0
	_add_rect(parent, center + Vector2(muzzle_x, 12.0), Vector2(7.0, 4.0), accent.lightened(0.08))

	# Feet / hover pads.
	_add_rect(parent, center + Vector2(-5.0, 20.0), Vector2(5.0, 4.0), body_color.darkened(0.20))
	_add_rect(parent, center + Vector2(5.0, 20.0), Vector2(5.0, 4.0), body_color.darkened(0.20))


static func _add_rect(parent: Node, center: Vector2, size: Vector2, color: Color, z_index: int = 0) -> ColorRect:
	var shadow := ColorRect.new()
	shadow.size = size
	shadow.position = center - (size * 0.5) + Vector2(2.0, 2.0)
	var shadow_color := color.darkened(0.76)
	shadow.color = Color(shadow_color.r, shadow_color.g, shadow_color.b, 0.48)
	shadow.z_index = z_index - 1
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(shadow)

	var rect := ColorRect.new()
	rect.size = size
	rect.position = center - (size * 0.5)
	rect.color = color
	rect.z_index = z_index
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)
	return rect


static func _add_line(parent: Node, start: Vector2, end: Vector2, width: float, color: Color, z_index: int = 0) -> Line2D:
	var shadow := Line2D.new()
	shadow.width = width + 2.0
	shadow.default_color = Color(0.0, 0.02, 0.06, 0.40)
	shadow.antialiased = false
	shadow.begin_cap_mode = Line2D.LINE_CAP_ROUND
	shadow.end_cap_mode = Line2D.LINE_CAP_ROUND
	shadow.joint_mode = Line2D.LINE_JOINT_ROUND
	shadow.points = PackedVector2Array([start + Vector2(2.0, 2.0), end + Vector2(2.0, 2.0)])
	shadow.z_index = z_index - 1
	parent.add_child(shadow)

	var line := Line2D.new()
	line.width = width
	line.default_color = color
	line.antialiased = false
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.points = PackedVector2Array([start, end])
	line.z_index = z_index
	parent.add_child(line)
	return line
