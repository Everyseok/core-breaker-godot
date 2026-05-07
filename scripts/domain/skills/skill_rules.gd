extends RefCounted

const NONE := ""
const STONE_THROW := "stone_throw"
const METEOR := "meteor"
const MACHINE_GUN := "machine_gun"

const FIRST_UNLOCK_K := 1000

const _DEFINITIONS := [
	{
		"id": STONE_THROW,
		"display_name": "돌",
		"unlock_k": 1000,
		"interval": 1.5,
		"damage": 3000,
		"spread_radius": 1,
		"max_targets": 3,
		"flight_time": 0.5,
		"description": "주변 3칸을 묵직하게 깨요",
		"tag": "안정",
		"primary_color": Color(0.56, 0.38, 0.20, 1.0),
		"secondary_color": Color(0.72, 0.72, 0.72, 1.0),
		"accent_color": Color(0.34, 0.22, 0.12, 1.0),
	},
	{
		"id": METEOR,
		"display_name": "메테오",
		"unlock_k": 1500,
		"interval": 1.5,
		"damage": 9000,
		"spread_radius": 2,
		"max_targets": 5,
		"flight_time": 0.5,
		"description": "주변 5칸을 크게 터뜨려요",
		"tag": "폭발",
		"primary_color": Color(1.0, 0.34, 0.12, 1.0),
		"secondary_color": Color(1.0, 0.74, 0.28, 1.0),
		"accent_color": Color(0.66, 0.10, 0.06, 1.0),
	},
	{
		"id": MACHINE_GUN,
		"display_name": "기관총",
		"unlock_k": 2000,
		"interval": 0.3,
		"damage": 3000,
		"spread_radius": 0,
		"max_targets": 10,
		"flight_time": 0.08,
		"description": "위험한 벽돌 10개를 빠르게 쏴요",
		"tag": "연사",
		"primary_color": Color(0.18, 0.34, 0.72, 1.0),
		"secondary_color": Color(0.64, 0.82, 1.0, 1.0),
		"accent_color": Color(0.92, 0.96, 1.0, 1.0),
	},
]


static func get_first_unlock_k() -> int:
	return FIRST_UNLOCK_K


static func get_definitions() -> Array:
	var result: Array = []
	for definition in _DEFINITIONS:
		result.append(Dictionary(definition).duplicate(true))
	return result


static func definition_for_id(skill_id: String) -> Dictionary:
	for definition in _DEFINITIONS:
		if String(definition.get("id", NONE)) == skill_id:
			return Dictionary(definition).duplicate(true)
	return {}


static func is_valid_skill_id(skill_id: String) -> bool:
	return not definition_for_id(skill_id).is_empty()


static func unlocked_ids_for_k(current_level_k: int) -> Array:
	var result: Array = []
	for definition in _DEFINITIONS:
		if current_level_k >= int(definition.get("unlock_k", 999999)):
			result.append(String(definition.get("id", NONE)))
	return result


static func unlocked_definitions_for_k(current_level_k: int) -> Array:
	var result: Array = []
	for definition in _DEFINITIONS:
		if current_level_k >= int(definition.get("unlock_k", 999999)):
			result.append(Dictionary(definition).duplicate(true))
	return result


static func default_skill_for_k(current_level_k: int) -> String:
	if current_level_k >= FIRST_UNLOCK_K:
		return STONE_THROW
	return NONE


static func display_name_for_id(skill_id: String) -> String:
	var definition := definition_for_id(skill_id)
	return String(definition.get("display_name", ""))


static func unlock_k_for_id(skill_id: String) -> int:
	var definition := definition_for_id(skill_id)
	return int(definition.get("unlock_k", -1))


static func interval_for_id(skill_id: String) -> float:
	var definition := definition_for_id(skill_id)
	return float(definition.get("interval", 1.0))


static func damage_for_id(skill_id: String) -> int:
	var definition := definition_for_id(skill_id)
	return int(definition.get("damage", 1))


static func spread_radius_for_id(skill_id: String) -> int:
	var definition := definition_for_id(skill_id)
	return int(definition.get("spread_radius", 0))


static func max_targets_for_id(skill_id: String) -> int:
	var definition := definition_for_id(skill_id)
	return int(definition.get("max_targets", 1))


static func flight_time_for_id(skill_id: String) -> float:
	var definition := definition_for_id(skill_id)
	return float(definition.get("flight_time", 0.1))
