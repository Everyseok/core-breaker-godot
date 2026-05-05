extends "res://scripts/platform/ads/ad_bridge.gd"

# Android != AdMob setup. These stay false until the Google Mobile Ads
# SDK/plugin, app IDs, test IDs, and device QA are explicitly configured.

func can_show_top_banner() -> bool:
	return false


func can_show_game_over_interstitial() -> bool:
	return false


func can_show_rewarded_continue() -> bool:
	return false
