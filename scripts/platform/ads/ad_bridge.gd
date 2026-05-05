extends RefCounted

# Base no-op ad contract for future platform adapters.
# No production IDs or SDK calls are allowed in this pass.


func can_show_top_banner() -> bool:
	return false


func can_show_game_over_interstitial() -> bool:
	return false


func can_show_rewarded_continue() -> bool:
	return false


func get_reserved_banner_height() -> float:
	return 0.0


func show_top_banner() -> bool:
	return false


func hide_top_banner() -> void:
	pass


func show_game_over_interstitial() -> bool:
	return false


func show_rewarded_continue() -> bool:
	return false
