class_name EndlessScoreRules
extends RefCounted


static func gauge_max(best_record: int, fallback_max: int) -> int:
	return maxi(best_record, fallback_max)


static func gauge_progress(score: int, gauge_max_value: int) -> float:
	return clampf(float(score) / maxf(float(gauge_max_value), 1.0), 0.0, 1.0)


static func display_text(score: int, gauge_max_value: int) -> String:
	return "%d/%d" % [score, gauge_max_value]
