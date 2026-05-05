extends "res://scripts/platform/leaderboard/leaderboard_bridge.gd"

# Android != Play Games Services setup. Scores stay disabled until the
# Android plugin, Play Console game service, and sign-in path are validated.

func can_submit_scores() -> bool:
	return false


func can_open_leaderboard() -> bool:
	return false
