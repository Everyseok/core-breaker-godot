extends Node
# BuffManager — owns one-run MVP random buff state.

const BuffRulesRef := preload("res://scripts/application/buffs/buff_rules.gd")

signal buff_roll_requested()
signal buff_state_changed()
signal buff_applied(buff_id: String, display_name: String)

var buff_used_this_run: bool = false
var active_buff_id: String = BuffRulesRef.BUFF_NONE

var _roll_in_progress: bool = false
var _rng := RandomNumberGenerator.new()
var _debug_forced_buff_id: String = BuffRulesRef.BUFF_NONE


func _ready() -> void:
	_rng.randomize()
	GameState.game_started.connect(reset_on_game_started)
	GameState.game_over.connect(_cancel_roll)
	GameState.max_level_cleared.connect(_cancel_roll)


func reset_on_game_started() -> void:
	buff_used_this_run = false
	active_buff_id = BuffRulesRef.BUFF_NONE
	_roll_in_progress = false
	_debug_forced_buff_id = BuffRulesRef.BUFF_NONE
	buff_state_changed.emit()


func is_buff_unlocked(current_level_k: int) -> bool:
	return current_level_k >= BuffRulesRef.UNLOCK_K


func can_open_buff(current_level_k: int) -> bool:
	return (
		GameState.is_playing
		and not get_tree().paused
		and is_buff_unlocked(current_level_k)
		and not buff_used_this_run
		and not _roll_in_progress
	)


func start_buff_roll() -> bool:
	if not can_open_buff(GameState.current_level_k):
		buff_state_changed.emit()
		return false
	_roll_in_progress = true
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
	if not _roll_in_progress:
		return false
	if not BuffRulesRef.is_valid_buff_id(buff_id):
		_cancel_roll()
		return false
	_roll_in_progress = false
	buff_used_this_run = true
	active_buff_id = buff_id
	if buff_id == BuffRulesRef.BUFF_OVERCLOCK:
		_request_current_weapon_overclock()
	buff_applied.emit(buff_id, get_buff_display_name(buff_id))
	buff_state_changed.emit()
	return true


func get_projectile_count_multiplier() -> int:
	if active_buff_id == BuffRulesRef.BUFF_PROJECTILE_COUNT_X2:
		return BuffRulesRef.PROJECTILE_COUNT_MULTIPLIER
	return 1


func get_damage_multiplier() -> float:
	if active_buff_id == BuffRulesRef.BUFF_DAMAGE_X15:
		return BuffRulesRef.DAMAGE_MULTIPLIER
	return 1.0


func apply_damage_multiplier(base_damage: int) -> int:
	return maxi(1, int(round(float(base_damage) * get_damage_multiplier())))


func is_roll_in_progress() -> bool:
	return _roll_in_progress


func get_unlock_k() -> int:
	return BuffRulesRef.UNLOCK_K


func get_active_buff_display_name() -> String:
	if active_buff_id == BuffRulesRef.BUFF_NONE:
		return "사용됨"
	return get_buff_display_name(active_buff_id)


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
	_roll_in_progress = false
	buff_state_changed.emit()
