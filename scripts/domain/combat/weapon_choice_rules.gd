class_name WeaponChoiceRules
extends RefCounted

const NO_CHOICE := "no_choice"
const CHAIN_LIGHTNING := "chain_lightning"
const PRISM_LANCE := "prism_lance"
const METEOR_CANNON := "meteor_cannon"

const CHOICE_TRIGGER_K: int = 2000
const CHAIN_CHANCE: float = 0.35
const CHAIN_RANGE: int = 2
const PRISM_VOLLEY_INTERVAL: int = 4
const PRISM_SIDE_ANGLES: Array[int] = [-26, 26]
const METEOR_HIT_INTERVAL: int = 5
const METEOR_RADIUS: int = 2

const AUDIO_HOOK_OPEN := "weapon_choice_open"
const AUDIO_HOOK_SELECT := "weapon_choice_select"
const AUDIO_HOOK_PROC := "weapon_choice_proc"

const CHOICES: Array = [
	{
		"id": CHAIN_LIGHTNING,
		"display_name": "연쇄 번개",
		"description": "번개가 근처 벽돌로 튀어요",
		"tag": "짜릿함",
		"confirm_text": "연쇄 번개 장착!",
		"proc_audio_hook": AUDIO_HOOK_PROC,
	},
	{
		"id": PRISM_LANCE,
		"display_name": "프리즘 랜스",
		"description": "빛의 창이 갈라져 날아가요",
		"tag": "화려함",
		"confirm_text": "프리즘 랜스 장착!",
		"proc_audio_hook": AUDIO_HOOK_PROC,
	},
	{
		"id": METEOR_CANNON,
		"display_name": "메테오 캐논",
		"description": "묵직한 폭발이 터져요",
		"tag": "한방감",
		"confirm_text": "메테오 캐논 장착!",
		"proc_audio_hook": "meteor_cannon_proc",
	},
]


static func get_choices() -> Array:
	var result: Array = []
	for choice_variant in CHOICES:
		if choice_variant is Dictionary:
			result.append(choice_variant.duplicate(true))
	return result


static func definition_for_id(choice_id: String) -> Dictionary:
	for choice_variant in CHOICES:
		var choice: Dictionary = choice_variant
		if String(choice.get("id", "")) == choice_id:
			return choice.duplicate(true)
	return {}


static func is_selectable_choice(choice_id: String) -> bool:
	return not definition_for_id(choice_id).is_empty()


static func display_name_for_id(choice_id: String) -> String:
	var choice := definition_for_id(choice_id)
	if choice.is_empty():
		return ""
	return String(choice.get("display_name", ""))


static func confirm_text_for_id(choice_id: String) -> String:
	var choice := definition_for_id(choice_id)
	if choice.is_empty():
		return ""
	return String(choice.get("confirm_text", ""))


static func proc_audio_hook_for_id(choice_id: String) -> String:
	var choice := definition_for_id(choice_id)
	if choice.is_empty():
		return AUDIO_HOOK_PROC
	return String(choice.get("proc_audio_hook", AUDIO_HOOK_PROC))
