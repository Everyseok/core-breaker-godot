class_name ProgressionService
extends RefCounted

var _tiers: Array = []


func configure(tiers: Array) -> void:
	_tiers.clear()
	for tier in tiers:
		if tier is Dictionary:
			_tiers.append(tier.duplicate(true))


func tier_for_k(k_value: int) -> int:
	var resolved_tier: int = 0
	for tier_variant in _tiers:
		var tier: Dictionary = tier_variant
		if not _is_enabled(tier):
			continue
		if not _matches_k(tier, k_value):
			continue
		resolved_tier = int(tier.get("tier", 0))
	return resolved_tier


func implemented_tier_for_k(k_value: int) -> int:
	var active_tier: int = 0
	for tier_variant in _tiers:
		var tier: Dictionary = tier_variant
		if not _is_enabled(tier):
			continue
		if not _matches_k(tier, k_value):
			continue
		if bool(tier.get("implemented", true)):
			active_tier = int(tier.get("tier", 0))
	return active_tier


func threshold_for_tier(target_tier: int) -> int:
	for tier_variant in _tiers:
		var tier: Dictionary = tier_variant
		if not _is_enabled(tier):
			continue
		if int(tier.get("tier", -1)) == target_tier:
			return int(tier.get("k_min", 0))
	return -1


func tier_definition_for_tier(target_tier: int) -> Dictionary:
	for tier_variant in _tiers:
		var tier: Dictionary = tier_variant
		if int(tier.get("tier", -1)) == target_tier:
			return tier.duplicate(true)
	return {}


func display_name_for_tier(target_tier: int) -> String:
	var tier: Dictionary = tier_definition_for_tier(target_tier)
	if tier.is_empty():
		return "알 수 없음"
	var display_name: String = String(tier.get("display_name", ""))
	if display_name != "":
		return display_name
	return String(tier.get("name", "unknown")).replace("_", " ")


func next_tier_after_k(k_value: int) -> Dictionary:
	for tier_variant in _tiers:
		var tier: Dictionary = tier_variant
		if not _is_enabled(tier):
			continue
		if k_value < int(tier.get("k_min", 0)):
			return tier.duplicate(true)
	return {}


func max_tier() -> int:
	var highest_tier: int = 0
	for tier_variant in _tiers:
		var tier: Dictionary = tier_variant
		if not _is_enabled(tier):
			continue
		highest_tier = maxi(highest_tier, int(tier.get("tier", 0)))
	return highest_tier


func get_tiers() -> Array:
	return _tiers.duplicate(true)


func loop_length() -> int:
	var highest_enabled_k_max: int = -1
	for tier_variant in _tiers:
		var tier: Dictionary = tier_variant
		if not _is_enabled(tier):
			continue
		highest_enabled_k_max = maxi(highest_enabled_k_max, int(tier.get("k_max", -1)))
	if highest_enabled_k_max < 0:
		return 3000
	return highest_enabled_k_max + 1


func _is_enabled(tier: Dictionary) -> bool:
	return bool(tier.get("enabled", true))


func _matches_k(tier: Dictionary, k_value: int) -> bool:
	var k_min: int = int(tier.get("k_min", 0))
	var k_max: int = int(tier.get("k_max", -1))
	if k_value < k_min:
		return false
	if k_max >= 0 and k_value > k_max:
		return false
	return true
