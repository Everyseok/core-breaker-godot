extends "res://scripts/platform/leaderboard/leaderboard_bridge.gd"

# Web != App-in-Toss Game Center setup. This adapter is skeleton-only until
# Toss console setup and shell/device validation are complete.

func can_submit_scores() -> bool:
	return false


func can_open_leaderboard() -> bool:
	return false
