class_name SaveFileRepository
extends RefCounted

const DEFAULT_DATA := {
	"best_k": 0,
	"sound_enabled": true,
	"aim_joystick_position": "center",
	"user_id": "",
	"total_sessions": 0,
}

var _save_path: String


func _init(save_path: String = "user://save.json") -> void:
	_save_path = save_path


func load_data() -> Dictionary:
	var data := DEFAULT_DATA.duplicate(true)
	if not FileAccess.file_exists(_save_path):
		return data

	var file := FileAccess.open(_save_path, FileAccess.READ)
	if file == null:
		push_warning("[SaveFileRepository] Could not read %s" % _save_path)
		return data

	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		for key in parsed:
			data[key] = parsed[key]
	return data


func save_data(data: Dictionary) -> bool:
	var file := FileAccess.open(_save_path, FileAccess.WRITE)
	if file == null:
		push_error("[SaveFileRepository] Cannot write to %s" % _save_path)
		return false

	var merged := DEFAULT_DATA.duplicate(true)
	for key in data:
		merged[key] = data[key]

	file.store_string(JSON.stringify(merged))
	file.close()
	return true
