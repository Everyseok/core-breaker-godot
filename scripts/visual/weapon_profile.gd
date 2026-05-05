class_name WeaponProfile
extends RefCounted
# Centralized weapon visual identity map for both progression tiers and
# late-level evolution choices. Gameplay rules stay elsewhere; this file only
# describes how the active weapon family should look and feel.

const NO_CHOICE_ID := "no_choice"

const TIER_PROFILES: Array = [
	{
		"tier": 0,
		"profile_id": "arrow",
		"code_name": "arrow",
		"legacy_ids": ["arrow", "sparrow"],
		"display_name": "화살",
		"unlock_text": "",
		"vfx_style": "arrow",
		"projectile_style": "arrow",
		"hit_vfx_style": "arrow",
		"guardian_shape": "bow",
		"icon_style": "arrow",
		"primary_color": Color(0.96, 0.76, 0.22),
		"secondary_color": Color(1.0, 0.94, 0.70),
		"accent_color": Color(0.78, 0.46, 0.08),
		"aim_line_color": Color(1.0, 0.90, 0.52, 0.42),
		"muzzle_reach": 39.0,
		"muzzle_flash_scale": 0.95,
		"recoil_distance": 4.0,
		"shot_audio_hook": "arrow_shot",
	},
	{
		"tier": 1,
		"profile_id": "thunder",
		"code_name": "thunder",
		"legacy_ids": ["thunder", "thunder_bolt", "electric_fork"],
		"display_name": "번개",
		"unlock_text": "번개 무기 해금!",
		"vfx_style": "electric",
		"projectile_style": "thunder",
		"hit_vfx_style": "thunder",
		"guardian_shape": "fork",
		"icon_style": "thunder",
		"primary_color": Color(1.0, 0.88, 0.10),
		"secondary_color": Color(1.0, 0.98, 0.62),
		"accent_color": Color(0.52, 0.88, 1.0),
		"aim_line_color": Color(1.0, 0.92, 0.26, 0.42),
		"muzzle_reach": 41.0,
		"muzzle_flash_scale": 1.10,
		"recoil_distance": 5.0,
		"shot_audio_hook": "electric_shot",
	},
	{
		"tier": 2,
		"profile_id": "spark_lance",
		"code_name": "spark_lance",
		"legacy_ids": ["spark_lance"],
		"display_name": "스파크 랜스",
		"unlock_text": "스파크 랜스 해금!",
		"vfx_style": "lance",
		"projectile_style": "spark_lance",
		"hit_vfx_style": "spark_lance",
		"guardian_shape": "triple_lance",
		"icon_style": "prism",
		"primary_color": Color(0.16, 0.60, 1.0),
		"secondary_color": Color(0.74, 0.94, 1.0),
		"accent_color": Color(0.36, 0.42, 0.98),
		"aim_line_color": Color(0.42, 0.82, 1.0, 0.42),
		"muzzle_reach": 44.0,
		"muzzle_flash_scale": 1.18,
		"recoil_distance": 5.5,
		"shot_audio_hook": "energy_shot",
	},
	{
		"tier": 3,
		"profile_id": "volt_storm",
		"code_name": "volt_storm",
		"legacy_ids": ["volt_storm", "electric_split"],
		"display_name": "볼트 스톰",
		"unlock_text": "볼트 스톰 해금!",
		"vfx_style": "storm",
		"projectile_style": "volt_storm",
		"hit_vfx_style": "volt_storm",
		"guardian_shape": "storm_crown",
		"icon_style": "storm",
		"primary_color": Color(0.86, 0.30, 1.0),
		"secondary_color": Color(0.44, 0.95, 0.92),
		"accent_color": Color(0.50, 0.20, 0.94),
		"aim_line_color": Color(0.72, 0.50, 1.0, 0.42),
		"muzzle_reach": 44.0,
		"muzzle_flash_scale": 1.28,
		"recoil_distance": 6.5,
		"shot_audio_hook": "storm_shot",
	},
	{
		"tier": 4,
		"profile_id": "siege_cannon",
		"code_name": "siege_cannon",
		"legacy_ids": ["siege_cannon", "piercing_bomb_spear", "piercing_bomb_siege"],
		"display_name": "시즈 캐논",
		"unlock_text": "시즈 캐논 준비 완료!",
		"vfx_style": "cannon",
		"projectile_style": "siege_cannon",
		"hit_vfx_style": "siege_cannon",
		"guardian_shape": "cannon",
		"icon_style": "meteor",
		"primary_color": Color(1.0, 0.32, 0.10),
		"secondary_color": Color(1.0, 0.76, 0.38),
		"accent_color": Color(0.72, 0.10, 0.08),
		"aim_line_color": Color(1.0, 0.56, 0.26, 0.44),
		"muzzle_reach": 48.0,
		"muzzle_flash_scale": 1.55,
		"recoil_distance": 8.5,
		"shot_audio_hook": "cannon_shot",
	},
]

const CHOICE_PROFILES := {
	"chain_lightning": {
		"profile_id": "chain_lightning",
		"legacy_ids": ["chain_lightning"],
		"display_name": "연쇄 번개",
		"unlock_text": "연쇄 번개 장착!",
		"vfx_style": "chain_lightning",
		"projectile_style": "chain_lightning",
		"hit_vfx_style": "chain_lightning",
		"guardian_shape": "chain_coil",
		"icon_style": "chain",
		"primary_color": Color(1.0, 0.86, 0.16),
		"secondary_color": Color(0.86, 0.98, 1.0),
		"accent_color": Color(0.40, 0.88, 1.0),
		"aim_line_color": Color(1.0, 0.92, 0.30, 0.44),
		"muzzle_reach": 47.0,
		"muzzle_flash_scale": 1.40,
		"recoil_distance": 7.2,
		"shot_audio_hook": "electric_shot",
	},
	"prism_lance": {
		"profile_id": "prism_lance",
		"legacy_ids": ["prism_lance"],
		"display_name": "프리즘 랜스",
		"unlock_text": "프리즘 랜스 장착!",
		"vfx_style": "prism_lance",
		"projectile_style": "prism_lance",
		"hit_vfx_style": "prism_lance",
		"guardian_shape": "prism_splitter",
		"icon_style": "prism",
		"primary_color": Color(0.20, 0.72, 1.0),
		"secondary_color": Color(0.84, 0.96, 1.0),
		"accent_color": Color(0.72, 0.38, 1.0),
		"aim_line_color": Color(0.44, 0.86, 1.0, 0.42),
		"muzzle_reach": 50.0,
		"muzzle_flash_scale": 1.36,
		"recoil_distance": 6.8,
		"shot_audio_hook": "energy_shot",
	},
	"meteor_cannon": {
		"profile_id": "meteor_cannon",
		"legacy_ids": ["meteor_cannon"],
		"display_name": "메테오 캐논",
		"unlock_text": "메테오 캐논 장착!",
		"vfx_style": "meteor_cannon",
		"projectile_style": "meteor_cannon",
		"hit_vfx_style": "meteor_cannon",
		"guardian_shape": "meteor_artillery",
		"icon_style": "meteor",
		"primary_color": Color(1.0, 0.34, 0.12),
		"secondary_color": Color(1.0, 0.84, 0.48),
		"accent_color": Color(1.0, 0.96, 0.84),
		"aim_line_color": Color(1.0, 0.60, 0.30, 0.46),
		"muzzle_reach": 52.0,
		"muzzle_flash_scale": 1.72,
		"recoil_distance": 10.0,
		"shot_audio_hook": "explosion_shot",
	},
}


static func get_profile(tier: int) -> Dictionary:
	return get_base_profile(tier)


static func get_base_profile(tier: int) -> Dictionary:
	for profile_variant in TIER_PROFILES:
		var profile: Dictionary = profile_variant
		if int(profile.get("tier", -1)) == tier:
			return profile.duplicate(true)
	return TIER_PROFILES[0].duplicate(true)


static func get_choice_profile(choice_id: String) -> Dictionary:
	if choice_id == "" or choice_id == NO_CHOICE_ID:
		return {}
	var profile_variant: Variant = CHOICE_PROFILES.get(choice_id, {})
	if profile_variant is Dictionary:
		return (profile_variant as Dictionary).duplicate(true)
	return {}


static func resolve_profile(tier: int, choice_id: String = "") -> Dictionary:
	var choice_profile := get_choice_profile(choice_id)
	if not choice_profile.is_empty():
		return choice_profile
	return get_base_profile(tier)


static func get_profile_by_visual_id(visual_id: String) -> Dictionary:
	if visual_id == "":
		return {}
	for profile_variant in TIER_PROFILES:
		var profile: Dictionary = profile_variant
		if String(profile.get("profile_id", "")) == visual_id:
			return profile.duplicate(true)
	var choice_profile := get_choice_profile(visual_id)
	if not choice_profile.is_empty():
		return choice_profile
	return {}


static func resolve_visual_id(tier: int, choice_id: String = "") -> String:
	return String(resolve_profile(tier, choice_id).get("profile_id", "arrow"))


static func resolve_visual_id_from_legacy(legacy_id: String) -> String:
	if legacy_id == "":
		return ""
	for profile_variant in TIER_PROFILES:
		var profile: Dictionary = profile_variant
		for id_variant in profile.get("legacy_ids", []):
			if String(id_variant) == legacy_id:
				return String(profile.get("profile_id", ""))
	for choice_key in CHOICE_PROFILES.keys():
		var choice_profile := get_choice_profile(String(choice_key))
		for id_variant in choice_profile.get("legacy_ids", []):
			if String(id_variant) == legacy_id:
				return String(choice_profile.get("profile_id", ""))
	return ""


static func get_display_name(tier: int, choice_id: String = "") -> String:
	return String(resolve_profile(tier, choice_id).get("display_name", "알 수 없음"))


static func get_unlock_text(tier: int, choice_id: String = "") -> String:
	return String(resolve_profile(tier, choice_id).get("unlock_text", ""))


static func get_primary_color(tier: int, choice_id: String = "") -> Color:
	return Color(resolve_profile(tier, choice_id).get("primary_color", Color.WHITE))


static func get_secondary_color(tier: int, choice_id: String = "") -> Color:
	return Color(resolve_profile(tier, choice_id).get("secondary_color", Color.WHITE))


static func get_accent_color(tier: int, choice_id: String = "") -> Color:
	return Color(resolve_profile(tier, choice_id).get("accent_color", Color.WHITE))


static func get_aim_line_color(tier: int, choice_id: String = "") -> Color:
	return Color(resolve_profile(tier, choice_id).get("aim_line_color", Color(1.0, 1.0, 1.0, 0.35)))


static func get_guardian_shape(tier: int, choice_id: String = "") -> String:
	return String(resolve_profile(tier, choice_id).get("guardian_shape", "bow"))


static func get_vfx_style(tier: int, choice_id: String = "") -> String:
	return String(resolve_profile(tier, choice_id).get("vfx_style", "arrow"))


static func get_projectile_style(tier: int, choice_id: String = "") -> String:
	return String(resolve_profile(tier, choice_id).get("projectile_style", resolve_visual_id(tier, choice_id)))


static func get_hit_vfx_style(tier: int, choice_id: String = "") -> String:
	return String(resolve_profile(tier, choice_id).get("hit_vfx_style", get_vfx_style(tier, choice_id)))


static func get_icon_style(tier: int, choice_id: String = "") -> String:
	return String(resolve_profile(tier, choice_id).get("icon_style", "arrow"))


static func get_muzzle_reach(tier: int, choice_id: String = "") -> float:
	return float(resolve_profile(tier, choice_id).get("muzzle_reach", 40.0))


static func get_muzzle_flash_scale(tier: int, choice_id: String = "") -> float:
	return float(resolve_profile(tier, choice_id).get("muzzle_flash_scale", 1.0))


static func get_recoil_distance(tier: int, choice_id: String = "") -> float:
	return float(resolve_profile(tier, choice_id).get("recoil_distance", 4.0))


static func get_shot_audio_hook(tier: int, choice_id: String = "") -> String:
	return String(resolve_profile(tier, choice_id).get("shot_audio_hook", ""))
