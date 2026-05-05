class_name DamageRules
extends RefCounted

# Centralized per-tier numeric damage values.
# Gameplay/application code should read from here instead of scattering
# unrelated hardcoded damage tables across projectile scripts.

const DEFAULT_DAMAGE: int = 3000
const TIER_DAMAGE := {
	0: 3000, # 화살
	1: 4000, # 번개
	2: 5000, # 스파크 랜스
	3: 6000, # 볼트 스톰
	4: 9000, # 시즈 캐논
}


static func damage_for_tier(tier: int) -> int:
	return int(TIER_DAMAGE.get(tier, DEFAULT_DAMAGE))
