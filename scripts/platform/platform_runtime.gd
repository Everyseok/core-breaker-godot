extends RefCounted

const PlatformCapabilitiesRef := preload("res://scripts/platform/platform_capabilities.gd")


static func detect_platform_id() -> String:
	if OS.has_feature("web"):
		return "app_in_toss_web_candidate"
	if OS.has_feature("android"):
		return "google_play_android_candidate"
	if Engine.is_editor_hint():
		return "editor"
	return OS.get_name().to_lower()


static func build_capabilities(platform_id: String = "") -> PlatformCapabilitiesRef:
	var resolved_id: String = platform_id if platform_id != "" else detect_platform_id()
	var capabilities := PlatformCapabilitiesRef.new()
	capabilities.platform_id = resolved_id
	match resolved_id:
		"app_in_toss_web_candidate":
			# Web only means the runtime is possible. It does not prove App-in-Toss,
			# Toss Ads, or Game Center are configured and review-validated.
			capabilities.runtime_possible = OS.has_feature("web")
			capabilities.supports_toss_bridge = false
			capabilities.supports_leaderboards = false
			capabilities.supports_top_banner_ads = false
			capabilities.supports_interstitial_ads = false
			capabilities.supports_rewarded_ads = false
			capabilities.supports_user_key = false
			capabilities.recommended_banner_edge = "top_or_bottom_after_device_qa"
		"google_play_android_candidate":
			# Android only means the runtime is possible. It does not prove AdMob,
			# Play Games Services, package setup, or console configuration exists.
			capabilities.runtime_possible = OS.has_feature("android")
			capabilities.supports_google_play_services = false
			capabilities.supports_leaderboards = false
			capabilities.supports_top_banner_ads = false
			capabilities.supports_interstitial_ads = false
			capabilities.supports_rewarded_ads = false
			capabilities.requires_android_plugin = true
			capabilities.recommended_banner_edge = "top_or_bottom_after_device_qa"
		_:
			capabilities.runtime_possible = Engine.is_editor_hint()
			capabilities.recommended_banner_edge = "none"
	return capabilities
