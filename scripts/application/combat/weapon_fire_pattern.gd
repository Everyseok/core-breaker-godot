class_name WeaponFirePattern
extends RefCounted

const PROJECTILE_ARROW := "arrow"
const PROJECTILE_THUNDER := "thunder"
const PROJECTILE_SPARK_LANCE := "spark_lance"
const PROJECTILE_ELECTRIC_BOLT := "electric_bolt"
const PROJECTILE_PIERCING_BOMB_SPEAR := "piercing_bomb_spear"

const SIEGE_VOLLEY_ANGLES := [-36, -24, -12, 0, 12, 24, 36]


static func specs_for_tier(tier: int) -> Array:
	match tier:
		0:
			return [_spec(PROJECTILE_ARROW, 0.0)]
		1:
			return [
				_spec(PROJECTILE_THUNDER, -8.0),
				_spec(PROJECTILE_THUNDER, 8.0),
			]
		2:
			return [
				_spec(PROJECTILE_SPARK_LANCE, -15.0),
				_spec(PROJECTILE_SPARK_LANCE, 0.0),
				_spec(PROJECTILE_SPARK_LANCE, 15.0),
			]
		3:
			return [
				_spec(PROJECTILE_ELECTRIC_BOLT, -15.0),
				_spec(PROJECTILE_ELECTRIC_BOLT, 0.0),
				_spec(PROJECTILE_ELECTRIC_BOLT, 15.0),
			]
		4:
			var specs: Array = []
			for deg in SIEGE_VOLLEY_ANGLES:
				specs.append(_spec(
					PROJECTILE_PIERCING_BOMB_SPEAR,
					float(deg),
					2 if deg == 0 else 1,
					2 if deg == 0 else 1
				))
			return specs
		_:
			return [_spec(PROJECTILE_ARROW, 0.0)]


static func _spec(
	projectile_key: String,
	angle_offset_degrees: float,
	max_pierce_collisions: int = 0,
	explosion_same_layer_radius: int = 0
) -> Dictionary:
	return {
		"projectile_key": projectile_key,
		"angle_offset_degrees": angle_offset_degrees,
		"max_pierce_collisions": max_pierce_collisions,
		"explosion_same_layer_radius": explosion_same_layer_radius,
	}
