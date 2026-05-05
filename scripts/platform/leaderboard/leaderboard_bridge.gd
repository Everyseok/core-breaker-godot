extends RefCounted

# Base no-op leaderboard contract for future platform adapters.


func can_submit_scores() -> bool:
	return false


func can_open_leaderboard() -> bool:
	return false


func submit_score(_score: int) -> bool:
	return false


func open_leaderboard() -> bool:
	return false
