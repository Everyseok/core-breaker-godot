extends RefCounted

# Platform-neutral capability descriptor.
# This file is intentionally data-only and has no direct SDK calls.

var platform_id: String = "editor"
var runtime_possible: bool = false
var sdk_configured: bool = false
var feature_ready: bool = false
var supports_toss_bridge: bool = false
var supports_google_play_services: bool = false
var supports_leaderboards: bool = false
var supports_top_banner_ads: bool = false
var supports_interstitial_ads: bool = false
var supports_rewarded_ads: bool = false
var supports_user_key: bool = false
var requires_android_plugin: bool = false
var recommended_banner_edge: String = "none"


func to_dictionary() -> Dictionary:
	return {
		"platform_id": platform_id,
		"runtime_possible": runtime_possible,
		"sdk_configured": sdk_configured,
		"feature_ready": feature_ready,
		"supports_toss_bridge": supports_toss_bridge,
		"supports_google_play_services": supports_google_play_services,
		"supports_leaderboards": supports_leaderboards,
		"supports_top_banner_ads": supports_top_banner_ads,
		"supports_interstitial_ads": supports_interstitial_ads,
		"supports_rewarded_ads": supports_rewarded_ads,
		"supports_user_key": supports_user_key,
		"requires_android_plugin": requires_android_plugin,
		"recommended_banner_edge": recommended_banner_edge,
	}
