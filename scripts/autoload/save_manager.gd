extends Node
# SaveManager — persistence coordinator backed by a repository.

const SaveFileRepositoryRef := preload("res://scripts/infrastructure/persistence/save_file_repository.gd")
const SAVE_PATH := "user://save.json"

var _repository = SaveFileRepositoryRef.new(SAVE_PATH)
var _data: Dictionary = {}


func _ready() -> void:
	_data = SaveFileRepositoryRef.DEFAULT_DATA.duplicate(true)
	load_data()


func save() -> void:
	_repository.save_data(_data)


func load_data() -> void:
	_data = _repository.load_data()


func record_run_result(total_progress_value: int, level: int = 1, level_k: int = 0) -> void:
	update_best_progress(total_progress_value, level, level_k)
	save()


func update_best_k(value: int) -> void:
	if value > get_best_total_progress():
		_data["best_k"] = value


func update_best_progress(total_progress_value: int, level: int, level_k: int) -> void:
	var best_total_progress: int = get_best_total_progress()
	if total_progress_value <= best_total_progress:
		return
	_data["best_total_progress"] = total_progress_value
	_data["best_level"] = maxi(level, 1)
	_data["best_level_k"] = maxi(level_k, 0)
	_data["best_k"] = total_progress_value


func increment_sessions() -> void:
	_data["total_sessions"] = _data.get("total_sessions", 0) + 1


func get_best_k() -> int:
	return get_best_total_progress()


func get_best_total_progress() -> int:
	var legacy_best: int = int(_data.get("best_k", 0))
	var explicit_best: int = int(_data.get("best_total_progress", legacy_best))
	return maxi(legacy_best, explicit_best)


func get_best_level() -> int:
	if _data.has("best_level"):
		return maxi(int(_data.get("best_level", 1)), 1)
	return maxi(int(get_best_total_progress() / 1000) + 1, 1)


func get_best_level_k() -> int:
	if _data.has("best_level_k"):
		return maxi(int(_data.get("best_level_k", 0)), 0)
	return int(get_best_total_progress() % 1000)


func set_sound_enabled(value: bool) -> void:
	_data["sound_enabled"] = value


func get_sound_enabled() -> bool:
	return _data.get("sound_enabled", true)


func set_aim_joystick_position(value: String) -> void:
	_data["aim_joystick_position"] = value


func get_aim_joystick_position() -> String:
	return _data.get("aim_joystick_position", "center")


func set_user_id(id: String) -> void:
	_data["user_id"] = id


func get_user_id() -> String:
	return _data.get("user_id", "")


func set_game_user_key(key: String) -> void:
	# GC-05 / C-21: persist the game-specific hash from getUserKeyForGame.
	# This is NOT a secret auth token; it is for internal game user identification.
	_data["game_user_key"] = key


func get_game_user_key() -> String:
	return _data.get("game_user_key", "")
