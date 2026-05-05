extends "res://scripts/platform/ads/ad_bridge.gd"

# Web != App-in-Toss Ads setup. These stay false until the Toss runtime,
# ads console setup, and device QA are explicitly validated.

func can_show_top_banner() -> bool:
	return false


func can_show_game_over_interstitial() -> bool:
	return false


func can_show_rewarded_continue() -> bool:
	return false
