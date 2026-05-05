extends Node
# SaveManager — persistence coordinator backed by a repository.

const SaveFileRepositoryRef := preload("res://scripts/infrastructure/persistence/save_file_repository.gd")
const ProgressionServiceRef := preload("res://scripts/application/progression/progression_service.gd")
const JsonConfigLoaderRef := preload("res://scripts/infrastructure/config/json_config_loader.gd")
const SAVE_PATH := "user://save.json"

signal best_record_changed(best_value: int)

var _repository = SaveFileRepositoryRef.new(SAVE_PATH)
var _data: Dictionary = {}


func _ready() -> void:
	_data = SaveFileRepositoryRef.DEFAULT_DATA.duplicate(true)
	load_data()


func save() -> void:
	_repository.save_data(_data)


func load_data() -> void:
	_data = _repository.load_data()
	var normalized := _normalize_best_record_fields()
	if normalized:
		save()
	best_record_changed.emit(get_best_record_value())


func record_run_result(total_progress_value: int, level: int = 1, level_k: int = 0) -> void:
	update_best_progress(total_progress_value, level, level_k)
	save()


func update_best_k(value: int) -> void:
	if value <= get_best_record_value():
		return
	_data["best_k"] = value
	_data["best_total_progress"] = value
	best_record_changed.emit(get_best_record_value())


func update_best_progress(total_progress_value: int, level: int, level_k: int) -> void:
	var best_total_progress: int = get_best_record_value()
	if total_progress_value <= best_total_progress:
		return
	_data["best_total_progress"] = total_progress_value
	_data["best_level"] = maxi(level, 1)
	_data["best_level_k"] = maxi(level_k, 0)
	_data["best_k"] = total_progress_value
	best_record_changed.emit(get_best_record_value())


func increment_sessions() -> void:
	_data["total_sessions"] = _data.get("total_sessions", 0) + 1


func get_best_k() -> int:
	return get_best_record_value()


func get_best_record_value() -> int:
	return get_best_total_progress()


func get_best_total_progress() -> int:
	var legacy_best: int = int(_data.get("best_k", 0))
	var explicit_best: int = int(_data.get("best_total_progress", legacy_best))
	return maxi(legacy_best, explicit_best)


func get_best_level() -> int:
	if _data.has("best_level"):
		return maxi(int(_data.get("best_level", 1)), 1)
	var level_size: int = _get_level_size_k()
	return maxi(int(get_best_total_progress() / level_size) + 1, 1)


func get_best_level_k() -> int:
	if _data.has("best_level_k"):
		return maxi(int(_data.get("best_level_k", 0)), 0)
	return int(get_best_total_progress() % _get_level_size_k())


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


func _get_level_size_k() -> int:
	var progression := ProgressionServiceRef.new()
	progression.configure(JsonConfigLoaderRef.load_array("res://data/progression.json", "tiers"))
	return maxi(progression.loop_length(), 1)


func _normalize_best_record_fields() -> bool:
	var canonical_best := get_best_total_progress()
	var changed := false
	if int(_data.get("best_total_progress", canonical_best)) != canonical_best:
		_data["best_total_progress"] = canonical_best
		changed = true
	if int(_data.get("best_k", canonical_best)) != canonical_best:
		_data["best_k"] = canonical_best
		changed = true
	if not _data.has("best_level"):
		_data["best_level"] = maxi(int(canonical_best / _get_level_size_k()) + 1, 1)
		changed = true
	if not _data.has("best_level_k"):
		_data["best_level_k"] = int(canonical_best % _get_level_size_k())
		changed = true
	return changed
