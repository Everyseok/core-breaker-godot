extends RefCounted

const PlatformRuntimeRef := preload("res://scripts/platform/platform_runtime.gd")


func get_platform_id() -> String:
	return "app_in_toss_web_candidate"


func get_capabilities() -> Dictionary:
	return PlatformRuntimeRef.build_capabilities(get_platform_id()).to_dictionary()


func is_runtime_available() -> bool:
	return OS.has_feature("web")
