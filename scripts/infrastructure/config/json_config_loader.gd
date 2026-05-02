class_name JsonConfigLoader
extends RefCounted


static func load_dictionary(path: String, fallback: Dictionary = {}) -> Dictionary:
	var parsed: Variant = _load_json(path)
	if parsed is Dictionary:
		var parsed_dictionary: Dictionary = parsed
		return parsed_dictionary.duplicate(true)
	return fallback.duplicate(true)


static func load_array(path: String, key: String = "", fallback: Array = []) -> Array:
	var parsed: Variant = _load_json(path)
	if parsed is Array:
		var parsed_array: Array = parsed
		return parsed_array.duplicate(true)
	if parsed is Dictionary:
		var value: Variant = parsed.get(key, fallback)
		if value is Array:
			var value_array: Array = value
			return value_array.duplicate(true)
	return fallback.duplicate(true)


static func _load_json(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("[JsonConfigLoader] Could not open %s" % path)
		return null
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed
