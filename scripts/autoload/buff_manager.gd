extends Node
# BuffManager — owns timed random buff state and cooldown.

const BuffRulesRef := preload("res://scripts/application/buffs/buff_rules.gd")

signal buff_roll_requested()
signal buff_state_changed()
signal buff_applied(buff_id: String, display_name: String)

var active_buff_id: String = BuffRulesRef.BUFF_NONE
var active_time_remaining: float = 0.0
var cooldown_time_remaining: float = 0.0
var roll_in_progress: bool = false

var _rng := RandomNumberGenerator.new()
var _debug_forced_buff_id: String = BuffRulesRef.BUFF_NONE


func _ready() -> void:
	_rng.randomize()
	set_process(true)
	GameState.game_started.connect(reset_on_game_started)
	GameState.game_over.connect(_cancel_runtime_state)
	GameState.max_level_cleared.connect(_cancel_runtime_state)


func _process(delta: float) -> void:
	if not GameState.is_playing or get_tree().paused:
		return
	if roll_in_progress:
		return
	if active_buff_id != BuffRulesRef.BUFF_NONE:
		_tick_active_buff(delta)
		return
	if cooldown_time_remaining > 0.0:
		_tick_cooldown(delta)


func reset_on_game_started() -> void:
	active_buff_id = BuffRulesRef.BUFF_NONE
	active_time_remaining = 0.0
	cooldown_time_remaining = 0.0
	roll_in_progress = false
	_debug_forced_buff_id = BuffRulesRef.BUFF_NONE
	buff_state_changed.emit()


func is_buff_unlocked(current_level_k: int) -> bool:
	return current_level_k >= BuffRulesRef.UNLOCK_K


func can_open_buff(current_level_k: int) -> bool:
	return (
			GameState.is_playing
			and not get_tree().paused
			and is_buff_unlocked(current_level_k)
			and active_buff_id == BuffRulesRef.BUFF_NONE
			and cooldown_time_remaining <= 0.0
			and not roll_in_progress
		)


func start_buff_roll() -> bool:
	if not can_open_buff(GameState.current_level_k):
		buff_state_changed.emit()
		return false
	roll_in_progress = true
	buff_state_changed.emit()
	buff_roll_requested.emit()
	return true


func roll_random_buff_id() -> String:
	if BuffRulesRef.is_valid_buff_id(_debug_forced_buff_id):
		var forced := _debug_forced_buff_id
		_debug_forced_buff_id = BuffRulesRef.BUFF_NONE
		return forced
	var ids := BuffRulesRef.all_buff_ids()
	if ids.is_empty():
		return BuffRulesRef.BUFF_NONE
	return String(ids[_rng.randi_range(0, ids.size() - 1)])


func apply_selected_buff(buff_id: String) -> bool:
	if not roll_in_progress:
		return false
	if not BuffRulesRef.is_valid_buff_id(buff_id):
		_cancel_roll()
		return false
	roll_in_progress = false
	active_buff_id = buff_id
	active_time_remaining = _duration_for_buff(buff_id)
	if buff_id == BuffRulesRef.BUFF_OVERCLOCK:
		_request_current_weapon_overclock()
	buff_applied.emit(buff_id, get_buff_display_name(buff_id))
	buff_state_changed.emit()
	return true


func get_projectile_count_multiplier() -> int:
	if active_buff_id == BuffRulesRef.BUFF_PROJECTILE_COUNT_X2 and active_time_remaining > 0.0:
		return BuffRulesRef.PROJECTILE_COUNT_MULTIPLIER
	return 1


func get_damage_multiplier() -> float:
	if active_buff_id == BuffRulesRef.BUFF_DAMAGE_X15 and active_time_remaining > 0.0:
		return BuffRulesRef.DAMAGE_MULTIPLIER
	return 1.0


func apply_damage_multiplier(base_damage: int) -> int:
	return maxi(1, int(round(float(base_damage) * get_damage_multiplier())))


func is_roll_in_progress() -> bool:
	return roll_in_progress


func get_unlock_k() -> int:
	return BuffRulesRef.UNLOCK_K


func get_active_buff_display_name() -> String:
	if active_buff_id == BuffRulesRef.BUFF_NONE:
		return ""
	return get_buff_display_name(active_buff_id)


func is_buff_active() -> bool:
	return active_buff_id != BuffRulesRef.BUFF_NONE and active_time_remaining > 0.0


func is_in_cooldown() -> bool:
	return cooldown_time_remaining > 0.0


func get_active_time_remaining_ceil() -> int:
	return int(ceil(maxf(active_time_remaining, 0.0)))


func get_cooldown_time_remaining_ceil() -> int:
	return int(ceil(maxf(cooldown_time_remaining, 0.0)))


func get_buff_display_name(buff_id: String) -> String:
	return BuffRulesRef.display_name_for(buff_id)


func get_available_buff_display_names() -> Array:
	var names: Array = []
	for buff_id in BuffRulesRef.all_buff_ids():
		names.append(get_buff_display_name(String(buff_id)))
	return names


func debug_force_next_buff(buff_id: String) -> bool:
	if not OS.is_debug_build():
		return false
	if not BuffRulesRef.is_valid_buff_id(buff_id):
		return false
	_debug_forced_buff_id = buff_id
	return true


func _request_current_weapon_overclock() -> bool:
	var weapons := get_tree().get_nodes_in_group("weapon")
	if weapons.is_empty():
		push_warning("[BuffManager] Overclock buff selected, but no weapon node exists.")
		return false
	var weapon = weapons[0]
	if weapon == null or not is_instance_valid(weapon) or not weapon.has_method("activate_overclock"):
		push_warning("[BuffManager] Overclock buff selected, but weapon cannot activate overclock.")
		return false
	weapon.call("activate_overclock")
	return true


func _cancel_roll() -> void:
	roll_in_progress = false
	buff_state_changed.emit()


func _cancel_runtime_state() -> void:
	active_buff_id = BuffRulesRef.BUFF_NONE
	active_time_remaining = 0.0
	cooldown_time_remaining = 0.0
	roll_in_progress = false
	buff_state_changed.emit()


func _tick_active_buff(delta: float) -> void:
	var previous_seconds := get_active_time_remaining_ceil()
	active_time_remaining = maxf(active_time_remaining - delta, 0.0)
	var current_seconds := get_active_time_remaining_ceil()
	if active_time_remaining > 0.0:
		if current_seconds != previous_seconds:
			buff_state_changed.emit()
		return
	active_buff_id = BuffRulesRef.BUFF_NONE
	cooldown_time_remaining = BuffRulesRef.COOLDOWN_DURATION
	buff_state_changed.emit()


func _tick_cooldown(delta: float) -> void:
	var previous_seconds := get_cooldown_time_remaining_ceil()
	cooldown_time_remaining = maxf(cooldown_time_remaining - delta, 0.0)
	var current_seconds := get_cooldown_time_remaining_ceil()
	if cooldown_time_remaining <= 0.0 or current_seconds != previous_seconds:
		buff_state_changed.emit()


func _duration_for_buff(buff_id: String) -> float:
	match buff_id:
		BuffRulesRef.BUFF_PROJECTILE_COUNT_X2:
			return BuffRulesRef.PROJECTILE_COUNT_DURATION
		BuffRulesRef.BUFF_DAMAGE_X15:
			return BuffRulesRef.DAMAGE_DURATION
		BuffRulesRef.BUFF_OVERCLOCK:
			return BuffRulesRef.OVERCLOCK_DURATION
		_:
			return 0.0
