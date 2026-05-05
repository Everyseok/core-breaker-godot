class_name WeaponModuleFactory
extends RefCounted


static func build_module(parent: Node, style_id: String, primary: Color, secondary: Color, accent: Color) -> void:
	_add_common_mount(parent, primary, secondary)
	match style_id:
		"thunder":
			_build_fork(parent, primary, secondary, accent)
		"spark_lance":
			_build_triple_lance(parent, primary, secondary, accent)
		"volt_storm":
			_build_storm_crown(parent, primary, secondary, accent)
		"siege_cannon":
			_build_cannon(parent, primary, secondary, accent)
		"chain_lightning":
			_build_chain_coil(parent, primary, secondary, accent)
		"prism_lance":
			_build_prism_splitter(parent, primary, secondary, accent)
		"meteor_cannon":
			_build_meteor_artillery(parent, primary, secondary, accent)
		_:
			_build_bow(parent, primary, secondary, accent)


static func build_muzzle_flash(parent: Node, style_id: String, flash_scale: float, primary: Color, secondary: Color, accent: Color) -> void:
	match style_id:
		"thunder":
			_add_flash_rect(parent, Vector2.ZERO, Vector2(12.0, 18.0) * flash_scale, secondary)
			_add_flash_line(parent, Vector2(-12.0, 8.0), Vector2(0.0, -8.0), 3.2, accent.lightened(0.18))
			_add_flash_line(parent, Vector2(0.0, 9.0), Vector2(12.0, -5.0), 2.6, Color(0.78, 0.96, 1.0, 0.94))
		"spark_lance":
			_add_flash_rect(parent, Vector2.ZERO, Vector2(8.0, 24.0) * flash_scale, secondary)
			_add_flash_rect(parent, Vector2.ZERO, Vector2(4.0, 30.0) * flash_scale, Color(0.96, 0.98, 1.0, 0.94))
			_add_flash_line(parent, Vector2(-8.0, 5.0), Vector2(0.0, -14.0), 2.4, accent.lightened(0.30))
			_add_flash_line(parent, Vector2(8.0, 5.0), Vector2(0.0, -14.0), 2.4, primary.lightened(0.18))
		"volt_storm":
			_add_flash_rect(parent, Vector2.ZERO, Vector2(14.0, 18.0) * flash_scale, secondary)
			_add_flash_line(parent, Vector2(-14.0, 6.0), Vector2(0.0, -12.0), 3.0, secondary)
			_add_flash_line(parent, Vector2(14.0, 6.0), Vector2(0.0, -12.0), 3.0, primary)
			_add_flash_line(parent, Vector2(0.0, 10.0), Vector2(0.0, -16.0), 2.6, Color(0.98, 0.98, 1.0, 0.92))
		"siege_cannon":
			_add_flash_rect(parent, Vector2.ZERO, Vector2(16.0, 18.0) * flash_scale, secondary)
			_add_flash_rect(parent, Vector2.ZERO, Vector2(10.0, 30.0) * flash_scale, Color(1.0, 0.94, 0.86, 0.96))
			_add_flash_line(parent, Vector2(-12.0, 8.0), Vector2(0.0, -15.0), 3.6, accent.lightened(0.20))
			_add_flash_line(parent, Vector2(12.0, 8.0), Vector2(0.0, -15.0), 3.6, primary.lightened(0.12))
		"chain_lightning":
			_add_flash_rect(parent, Vector2.ZERO, Vector2(14.0, 20.0) * flash_scale, secondary)
			_add_flash_line(parent, Vector2(-14.0, 9.0), Vector2(-2.0, -6.0), 3.0, primary)
			_add_flash_line(parent, Vector2(-2.0, -4.0), Vector2(12.0, 6.0), 2.2, accent)
			_add_flash_line(parent, Vector2(2.0, 8.0), Vector2(14.0, -6.0), 2.6, Color(0.82, 0.98, 1.0, 0.94))
		"prism_lance":
			_add_flash_rect(parent, Vector2.ZERO, Vector2(10.0, 22.0) * flash_scale, secondary)
			_add_flash_rect(parent, Vector2.ZERO, Vector2(5.0, 28.0) * flash_scale, Color(0.96, 0.98, 1.0, 0.94))
			_add_flash_line(parent, Vector2(-9.0, 4.0), Vector2(-3.0, -14.0), 2.4, primary.lightened(0.14))
			_add_flash_line(parent, Vector2(9.0, 4.0), Vector2(3.0, -14.0), 2.4, accent.lightened(0.18))
		"meteor_cannon":
			_add_flash_rect(parent, Vector2.ZERO, Vector2(18.0, 22.0) * flash_scale, secondary)
			_add_flash_rect(parent, Vector2.ZERO, Vector2(12.0, 34.0) * flash_scale, Color(1.0, 0.96, 0.86, 0.98))
			_add_flash_line(parent, Vector2(-14.0, 10.0), Vector2(0.0, -17.0), 4.0, primary.lightened(0.12))
			_add_flash_line(parent, Vector2(14.0, 10.0), Vector2(0.0, -17.0), 4.0, accent)
		_:
			_add_flash_rect(parent, Vector2.ZERO, Vector2(8.0, 14.0) * flash_scale, secondary)
			_add_flash_line(parent, Vector2(-6.0, 4.0), Vector2(0.0, -10.0), 2.0, accent.lightened(0.18))
			_add_flash_line(parent, Vector2(6.0, 4.0), Vector2(0.0, -10.0), 2.0, primary.lightened(0.12))


static func _add_common_mount(parent: Node, primary: Color, secondary: Color) -> void:
	_add_rect(parent, 0.0, -12.0, 24.0, 8.0, primary.darkened(0.64))
	_add_rect(parent, 0.0, -20.0, 14.0, 10.0, primary.darkened(0.42))
	_add_rect(parent, -9.0, -9.0, 6.0, 10.0, secondary.darkened(0.48))
	_add_rect(parent, 9.0, -9.0, 6.0, 10.0, secondary.darkened(0.48))


static func _build_bow(parent: Node, primary: Color, secondary: Color, accent: Color) -> void:
	_add_rect(parent, -14.0, -28.0, 5.0, 20.0, primary)
	_add_rect(parent, 14.0, -28.0, 5.0, 20.0, primary)
	_add_rect(parent, -10.0, -38.0, 5.0, 10.0, accent)
	_add_rect(parent, 10.0, -38.0, 5.0, 10.0, accent)
	_add_rect(parent, 0.0, -20.0, 4.0, 26.0, primary.darkened(0.28))
	_add_rect(parent, 0.0, -40.0, 8.0, 8.0, secondary)


static func _build_fork(parent: Node, primary: Color, secondary: Color, accent: Color) -> void:
	_add_rect(parent, 0.0, -24.0, 10.0, 20.0, primary.darkened(0.20))
	_add_rect(parent, -12.0, -32.0, 6.0, 16.0, primary)
	_add_rect(parent, 12.0, -32.0, 6.0, 16.0, primary)
	_add_rect(parent, -12.0, -44.0, 8.0, 8.0, secondary)
	_add_rect(parent, 12.0, -44.0, 8.0, 8.0, secondary)
	_add_rect(parent, 0.0, -41.0, 5.0, 10.0, accent.lightened(0.08))


static func _build_triple_lance(parent: Node, primary: Color, secondary: Color, accent: Color) -> void:
	for offset in [-12.0, 0.0, 12.0]:
		_add_rect(parent, offset, -30.0, 4.0, 24.0, primary)
		_add_rect(parent, offset, -44.0, 7.0, 10.0, secondary)
	_add_rect(parent, 0.0, -18.0, 16.0, 6.0, accent)


static func _build_storm_crown(parent: Node, primary: Color, secondary: Color, accent: Color) -> void:
	_add_rect(parent, 0.0, -24.0, 14.0, 18.0, primary.darkened(0.16))
	for offset in [-16.0, -6.0, 6.0, 16.0]:
		_add_rect(parent, offset, -36.0, 6.0, 10.0, secondary if absf(offset) > 10.0 else primary)
	_add_rect(parent, 0.0, -42.0, 10.0, 12.0, accent.lightened(0.24))
	_add_rect(parent, 0.0, -48.0, 6.0, 6.0, Color(0.96, 0.98, 1.0, 0.94))


static func _build_cannon(parent: Node, primary: Color, secondary: Color, accent: Color) -> void:
	_add_rect(parent, 0.0, -14.0, 22.0, 8.0, primary.darkened(0.56))
	_add_rect(parent, 0.0, -28.0, 18.0, 20.0, primary)
	_add_rect(parent, 0.0, -40.0, 14.0, 12.0, primary.lightened(0.06))
	_add_rect(parent, 0.0, -49.0, 16.0, 7.0, secondary)
	_add_rect(parent, -15.0, -24.0, 6.0, 12.0, accent.darkened(0.20))
	_add_rect(parent, 15.0, -24.0, 6.0, 12.0, accent.darkened(0.20))


static func _build_chain_coil(parent: Node, primary: Color, secondary: Color, accent: Color) -> void:
	_add_rect(parent, 0.0, -20.0, 18.0, 10.0, primary.darkened(0.42))
	_add_rect(parent, 0.0, -34.0, 14.0, 14.0, primary)
	_add_rect(parent, -14.0, -34.0, 6.0, 18.0, accent)
	_add_rect(parent, 14.0, -34.0, 6.0, 18.0, accent)
	_add_rect(parent, -8.0, -48.0, 6.0, 8.0, secondary)
	_add_rect(parent, 8.0, -48.0, 6.0, 8.0, secondary)
	_add_rect(parent, 0.0, -45.0, 6.0, 10.0, Color(0.98, 0.98, 0.84, 0.94))


static func _build_prism_splitter(parent: Node, primary: Color, secondary: Color, accent: Color) -> void:
	_add_rect(parent, 0.0, -18.0, 20.0, 8.0, accent.darkened(0.24))
	_add_rect(parent, 0.0, -30.0, 10.0, 18.0, primary)
	_add_rect(parent, -12.0, -42.0, 8.0, 12.0, secondary)
	_add_rect(parent, 0.0, -48.0, 10.0, 10.0, Color(0.94, 0.98, 1.0, 0.94))
	_add_rect(parent, 12.0, -42.0, 8.0, 12.0, accent.lightened(0.12))


static func _build_meteor_artillery(parent: Node, primary: Color, secondary: Color, accent: Color) -> void:
	_add_rect(parent, 0.0, -14.0, 24.0, 8.0, primary.darkened(0.58))
	_add_rect(parent, 0.0, -30.0, 20.0, 22.0, primary)
	_add_rect(parent, 0.0, -44.0, 16.0, 14.0, primary.lightened(0.04))
	_add_rect(parent, 0.0, -54.0, 18.0, 8.0, secondary)
	_add_rect(parent, -16.0, -26.0, 6.0, 14.0, accent)
	_add_rect(parent, 16.0, -26.0, 6.0, 14.0, accent)
	_add_rect(parent, 0.0, -60.0, 8.0, 6.0, Color(1.0, 0.98, 0.88, 0.94))


static func _add_rect(parent: Node, x: float, y: float, w: float, h: float, color: Color) -> void:
	var shadow := ColorRect.new()
	shadow.size = Vector2(w, h)
	shadow.position = Vector2(x - (w * 0.5) + 2.0, y - (h * 0.5) + 2.0)
	var shadow_color := color.darkened(0.76)
	shadow.color = Color(shadow_color.r, shadow_color.g, shadow_color.b, 0.54)
	shadow.z_index = -1
	parent.add_child(shadow)

	var rect := ColorRect.new()
	rect.size = Vector2(w, h)
	rect.position = Vector2(x - (w * 0.5), y - (h * 0.5))
	rect.color = color
	parent.add_child(rect)


static func _add_flash_rect(parent: Node, local_position: Vector2, size: Vector2, color: Color) -> void:
	var rect := ColorRect.new()
	rect.size = size
	rect.position = local_position - (size * 0.5)
	rect.color = color
	parent.add_child(rect)


static func _add_flash_line(parent: Node, start: Vector2, end: Vector2, width: float, color: Color) -> void:
	var line := Line2D.new()
	line.width = width
	line.default_color = color
	line.antialiased = false
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.points = PackedVector2Array([start, end])
	parent.add_child(line)
