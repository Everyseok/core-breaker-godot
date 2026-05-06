class_name BuffRules
extends RefCounted

const UNLOCK_K: int = 500

const BUFF_NONE := ""
const BUFF_PROJECTILE_COUNT_X2 := "projectile_count_x2"
const BUFF_OVERCLOCK := "overclock"
const BUFF_DAMAGE_X15 := "damage_x15"

const DAMAGE_MULTIPLIER: float = 1.5
const PROJECTILE_COUNT_MULTIPLIER: int = 2

const BUFF_IDS := [
	BUFF_PROJECTILE_COUNT_X2,
	BUFF_OVERCLOCK,
	BUFF_DAMAGE_X15,
]

const BUFF_DISPLAY_NAMES := {
	"projectile_count_x2": "탄환 2배",
	"overclock": "가속",
	"damage_x15": "공격력 1.5배",
}


static func all_buff_ids() -> Array:
	return BUFF_IDS.duplicate()


static func is_valid_buff_id(buff_id: String) -> bool:
	return BUFF_IDS.has(buff_id)


static func display_name_for(buff_id: String) -> String:
	return String(BUFF_DISPLAY_NAMES.get(buff_id, "사용됨"))
