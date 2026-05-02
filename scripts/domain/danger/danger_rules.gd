class_name DangerRules
extends RefCounted

const DANGER_1 := 0.60
const DANGER_2 := 0.35
const DANGER_3 := 0.15


static func level_for_ratio(radius_ratio: float) -> int:
	if radius_ratio <= DANGER_3:
		return 3
	if radius_ratio <= DANGER_2:
		return 2
	if radius_ratio <= DANGER_1:
		return 1
	return 0
