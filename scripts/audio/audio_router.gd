extends Node

var _catalog
var _last_played_ms: Dictionary = {}
var _active_counts: Dictionary = {}
var _stream_cache: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var _bgm_player: AudioStreamPlayer
var _bgm_event_id: StringName = &""


func setup(catalog) -> void:
	_catalog = catalog
	_rng.randomize()


func _exit_tree() -> void:
	for child in get_children():
		if child is AudioStreamPlayer:
			child.stop()
	_stream_cache.clear()


func play_event(event_id: StringName) -> bool:
	if _catalog == null:
		push_warning("[AudioRouter] Catalog is not ready.")
		return false
	var event: Dictionary = _catalog.get_event(event_id)
	if event.is_empty():
		push_warning("[AudioRouter] Missing event mapping: %s" % String(event_id))
		return false

	var now_ms := Time.get_ticks_msec()
	var cooldown_ms := int(event.get("cooldown_ms", 0))
	var last_ms := int(_last_played_ms.get(event_id, -1000000))
	if cooldown_ms > 0 and now_ms - last_ms < cooldown_ms:
		return false

	var max_instances := int(event.get("max_instances", 4))
	var active_count := int(_active_counts.get(event_id, 0))
	if max_instances > 0 and active_count >= max_instances:
		return false

	var path := String(event.get("path", ""))
	var stream := _get_stream(path) as AudioStream
	if stream == null:
		push_warning("[AudioRouter] Missing or invalid stream for %s: %s" % [String(event_id), path])
		return false

	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = _safe_bus_name(String(event.get("bus", "Master")))
	player.volume_db = float(event.get("volume_db", 0.0))
	player.pitch_scale = _pitch_scale(float(event.get("pitch_variation", 0.0)))
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)

	_active_counts[event_id] = active_count + 1
	_last_played_ms[event_id] = now_ms
	player.finished.connect(func() -> void:
		_active_counts[event_id] = maxi(int(_active_counts.get(event_id, 1)) - 1, 0)
		player.queue_free()
	)
	player.play()
	return true


func play_bgm(event_id: StringName) -> bool:
	if _catalog == null:
		push_warning("[AudioRouter] Catalog is not ready.")
		return false
	if _bgm_event_id == event_id and _bgm_player != null and _bgm_player.playing:
		return true
	var event: Dictionary = _catalog.get_event(event_id)
	if event.is_empty():
		push_warning("[AudioRouter] Missing BGM mapping: %s" % String(event_id))
		return false

	var path := String(event.get("path", ""))
	var stream := _get_stream(path) as AudioStream
	if stream == null:
		push_warning("[AudioRouter] Missing or invalid BGM stream for %s: %s" % [String(event_id), path])
		return false

	if _bgm_player == null:
		_bgm_player = AudioStreamPlayer.new()
		_bgm_player.name = "BgmPlayer"
		_bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(_bgm_player)
		var callback := Callable(self, "_on_bgm_finished")
		if not _bgm_player.finished.is_connected(callback):
			_bgm_player.finished.connect(callback)

	_bgm_event_id = event_id
	_bgm_player.stop()
	_bgm_player.stream = stream
	_bgm_player.bus = _safe_bus_name(String(event.get("bus", "Master")))
	_bgm_player.volume_db = float(event.get("volume_db", -14.0))
	_bgm_player.pitch_scale = 1.0
	_bgm_player.play()
	return true


func stop_bgm() -> void:
	_bgm_event_id = &""
	if _bgm_player != null:
		_bgm_player.stop()


func _on_bgm_finished() -> void:
	if _bgm_event_id != &"" and _bgm_player != null and _bgm_player.stream != null:
		_bgm_player.play()


func _get_stream(path: String):
	if path == "":
		return null
	if _stream_cache.has(path):
		return _stream_cache[path]
	if not ResourceLoader.exists(path):
		return null
	var stream := load(path)
	_stream_cache[path] = stream
	return stream


func _safe_bus_name(bus_name: String) -> String:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return bus_name
	return "Master"


func _pitch_scale(variation: float) -> float:
	if variation <= 0.0:
		return 1.0
	return clampf(1.0 + _rng.randf_range(-variation, variation), 0.1, 3.0)
