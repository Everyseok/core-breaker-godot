extends Node
# AudioManager — sound toggle and lifecycle (C-02, C-03, C-04, C-05)

var _sound_enabled: bool = true
var _muted_by_background: bool = false


func _ready() -> void:
	# SaveManager is autoload #3, AudioManager is #4 — data already loaded
	_sound_enabled = SaveManager.get_sound_enabled()
	_apply_mute_state()


func set_sound_enabled(enabled: bool) -> void:
	_sound_enabled = enabled
	SaveManager.set_sound_enabled(enabled)
	SaveManager.save()  # C-03: persist immediately
	_apply_mute_state()


func get_sound_enabled() -> bool:
	return _sound_enabled


func mute_all() -> void:
	# C-04: app backgrounded
	_muted_by_background = true
	_apply_mute_state()


func restore_mute_state() -> void:
	# C-05: app foregrounded
	_muted_by_background = false
	_apply_mute_state()


func set_bgm_intensity(level: int) -> void:
	print("[AudioManager] BGM intensity → %d" % level)
	# Phase 5: swap/crossfade BGM variants per level


func _apply_mute_state() -> void:
	var should_mute := _muted_by_background or not _sound_enabled
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), should_mute)
