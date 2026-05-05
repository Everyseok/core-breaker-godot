class_name ProjectileVisualFactory
extends RefCounted

const WeaponProfileRef := preload("res://scripts/visual/weapon_profile.gd")


static func build_visual(host: Node2D, style_id: String) -> void:
	match style_id:
		"thunder":
			_build_thunder(host)
		"spark_lance":
			_build_spark_lance(host)
		"volt_storm":
			_build_volt_storm(host)
		"siege_cannon":
			_build_siege_cannon(host)
		"chain_lightning":
			_build_chain_lightning(host)
		"prism_lance":
			_build_prism_lance(host)
		"meteor_cannon":
			_build_meteor_cannon(host)
		_:
			_build_arrow(host)


static func _build_arrow(host: Node2D) -> void:
	var profile := WeaponProfileRef.get_profile_by_visual_id("arrow")
	_add_rect(host, Vector2(3.0, 14.0), Vector2(-1.5, 0.0), Color(profile.get("primary_color", Color.WHITE)))
	_add_rect(host, Vector2(5.0, 5.0), Vector2(-2.5, 11.0), Color(profile.get("secondary_color", Color.WHITE)))
	_add_rect(host, Vector2(5.0, 3.0), Vector2(-2.5, 0.0), Color(profile.get("accent_color", Color.WHITE)))


static func _build_thunder(host: Node2D) -> void:
	var profile := WeaponProfileRef.get_profile_by_visual_id("thunder")
	_add_rect(host, Vector2(3.0, 14.0), Vector2(-1.5, 0.0), Color(profile.get("primary_color", Color.WHITE)))
	_add_rect(host, Vector2(7.0, 4.0), Vector2(-3.5, 11.0), Color(profile.get("secondary_color", Color.WHITE)))
	_add_rect(host, Vector2(2.0, 10.0), Vector2(2.0, 2.0), Color(profile.get("accent_color", Color.WHITE)))
	_add_rect(host, Vector2(2.0, 8.0), Vector2(-4.0, 3.0), Color(0.78, 0.96, 1.0, 0.74))


static func _build_spark_lance(host: Node2D) -> void:
	var profile := WeaponProfileRef.get_profile_by_visual_id("spark_lance")
	_add_rect(host, Vector2(3.0, 16.0), Vector2(-1.5, 0.0), Color(profile.get("primary_color", Color.WHITE)))
	_add_rect(host, Vector2(5.0, 5.0), Vector2(-2.5, 12.0), Color(profile.get("secondary_color", Color.WHITE)))
	_add_rect(host, Vector2(2.0, 13.0), Vector2(2.0, 1.0), Color(profile.get("accent_color", Color.WHITE)))
	_add_rect(host, Vector2(8.0, 3.0), Vector2(-4.0, 2.0), Color(0.92, 0.98, 1.0, 0.38))


static func _build_volt_storm(host: Node2D) -> void:
	var profile := WeaponProfileRef.get_profile_by_visual_id("volt_storm")
	_add_rect(host, Vector2(4.0, 16.0), Vector2(-2.0, 0.0), Color(profile.get("primary_color", Color.WHITE)))
	_add_rect(host, Vector2(7.0, 5.0), Vector2(-3.5, 12.0), Color(profile.get("secondary_color", Color.WHITE)))
	_add_rect(host, Vector2(2.0, 12.0), Vector2(-5.0, 2.0), Color(profile.get("accent_color", Color.WHITE)))
	_add_rect(host, Vector2(2.0, 12.0), Vector2(3.0, 2.0), Color(0.42, 0.96, 0.90, 0.58))
	_add_rect(host, Vector2(2.0, 12.0), Vector2(-1.0, 2.0), Color(0.96, 0.88, 1.0, 0.86))


static func _build_siege_cannon(host: Node2D) -> void:
	var profile := WeaponProfileRef.get_profile_by_visual_id("siege_cannon")
	_add_rect(host, Vector2(6.0, 22.0), Vector2(-3.0, 0.0), Color(profile.get("primary_color", Color.WHITE)))
	_add_rect(host, Vector2(4.0, 16.0), Vector2(-2.0, 3.0), Color(profile.get("accent_color", Color.WHITE).lightened(0.22)))
	_add_rect(host, Vector2(8.0, 6.0), Vector2(-4.0, 16.0), Color(profile.get("secondary_color", Color.WHITE)))
	_add_rect(host, Vector2(2.0, 12.0), Vector2(4.0, 4.0), Color(1.0, 0.96, 0.86, 0.52))


static func _build_chain_lightning(host: Node2D) -> void:
	var profile := WeaponProfileRef.get_profile_by_visual_id("chain_lightning")
	_add_rect(host, Vector2(6.0, 22.0), Vector2(-3.0, 0.0), Color(profile.get("primary_color", Color.WHITE)))
	_add_rect(host, Vector2(4.0, 16.0), Vector2(-2.0, 3.0), Color(profile.get("secondary_color", Color.WHITE)))
	_add_rect(host, Vector2(9.0, 5.0), Vector2(-4.5, 16.0), Color(0.98, 0.98, 0.82, 0.94))
	_add_rect(host, Vector2(2.0, 10.0), Vector2(-5.0, 4.0), Color(profile.get("accent_color", Color.WHITE)))
	_add_rect(host, Vector2(2.0, 10.0), Vector2(3.0, 4.0), Color(0.82, 0.98, 1.0, 0.82))


static func _build_prism_lance(host: Node2D) -> void:
	var profile := WeaponProfileRef.get_profile_by_visual_id("prism_lance")
	_add_rect(host, Vector2(4.0, 18.0), Vector2(-2.0, 0.0), Color(profile.get("primary_color", Color.WHITE)))
	_add_rect(host, Vector2(2.0, 14.0), Vector2(-1.0, 2.0), Color(profile.get("secondary_color", Color.WHITE)))
	_add_rect(host, Vector2(8.0, 4.0), Vector2(-4.0, 13.0), Color(profile.get("accent_color", Color.WHITE)))
	_add_rect(host, Vector2(2.0, 10.0), Vector2(-5.0, 3.0), Color(profile.get("secondary_color", Color.WHITE).lightened(0.08)))
	_add_rect(host, Vector2(2.0, 10.0), Vector2(3.0, 3.0), Color(profile.get("accent_color", Color.WHITE).lightened(0.10)))


static func _build_meteor_cannon(host: Node2D) -> void:
	var profile := WeaponProfileRef.get_profile_by_visual_id("meteor_cannon")
	_add_rect(host, Vector2(7.0, 24.0), Vector2(-3.5, 0.0), Color(profile.get("primary_color", Color.WHITE)))
	_add_rect(host, Vector2(5.0, 18.0), Vector2(-2.5, 3.0), Color(profile.get("accent_color", Color.WHITE)))
	_add_rect(host, Vector2(10.0, 7.0), Vector2(-5.0, 17.0), Color(profile.get("secondary_color", Color.WHITE)))
	_add_rect(host, Vector2(3.0, 10.0), Vector2(-6.0, 6.0), Color(1.0, 0.82, 0.32, 0.78))
	_add_rect(host, Vector2(3.0, 10.0), Vector2(3.0, 6.0), Color(1.0, 0.94, 0.84, 0.66))


static func _add_rect(host: Node2D, size: Vector2, position_value: Vector2, color: Color) -> void:
	var rect := ColorRect.new()
	rect.size = size
	rect.position = position_value
	rect.color = color
	host.add_child(rect)
