extends RefCounted

var _events: Dictionary = {}


func load_from_path(path: String) -> bool:
	if not FileAccess.file_exists(path):
		push_error("[SoundCatalog] Missing catalog: %s" % path)
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("[SoundCatalog] Cannot open catalog: %s" % path)
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		push_error("[SoundCatalog] Catalog is not valid JSON object: %s" % path)
		return false
	_events = Dictionary(parsed).get("events", {})
	return true


func has_event(event_id: StringName) -> bool:
	return _events.has(String(event_id))


func get_event(event_id: StringName) -> Dictionary:
	var value: Variant = _events.get(String(event_id), {})
	if value is Dictionary:
		return Dictionary(value)
	return {}


func validate_files() -> Array[String]:
	var missing: Array[String] = []
	for event_id_variant in _events.keys():
		var event_id := String(event_id_variant)
		var event := get_event(StringName(event_id))
		var path := String(event.get("path", ""))
		if path == "" or not ResourceLoader.exists(path):
			missing.append("%s -> %s" % [event_id, path])
	return missing
