extends Node
# GameState — slim gameplay session coordinator.

const ProgressionServiceRef := preload("res://scripts/application/progression/progression_service.gd")
const JsonConfigLoaderRef := preload("res://scripts/infrastructure/config/json_config_loader.gd")
const WeaponChoiceRulesRef := preload("res://scripts/domain/combat/weapon_choice_rules.gd")
const EndlessScoreRulesRef := preload("res://scripts/application/score/endless_score_rules.gd")
const WeaponChoiceScheduleRef := preload("res://scripts/application/weapon_choice/weapon_choice_schedule.gd")

const MAX_LEVEL: int = 100
const DEFAULT_SCORE_GAUGE_MAX: int = 2000
const FIRST_REPEATED_WEAPON_CHOICE_SCORE: int = 2000
const WEAPON_CHOICE_REPEAT_SCORE: int = 1000

signal k_changed(new_k: int)
signal tier_changed(new_tier: int)
signal unlock_progress_changed(current_k: int, threshold: int, unlocked: bool)
signal stone_unlock_reached(unlock_k: int, threshold: int)
signal tier_threshold_reached(unlocked_tier: int, threshold: int, display_name: String)
signal progression_display_changed(
	current_level: int,
	current_k: int,
	total_progress: int,
	current_weapon_name: String,
	next_unlock_name: String,
	next_unlock_threshold: int,
	ready_unlock_name: String,
	max_spec_tier_reached: bool
)
signal game_over()
signal game_started()
signal level_transitioned(new_level: int)
signal max_level_cleared()
signal revive_prompt_requested()
signal revive_granted()
signal weapon_choice_requested(options: Array)
signal weapon_choice_selected(choice_id: String, display_name: String)

var k: int = 0
var current_level: int = 1
var current_level_k: int = 0
var total_progress: int = 0
var is_playing: bool = false
var current_projectile_tier: int = 0
var current_progression_tier: int = 0
var stone_unlock_threshold: int = -1
var overclock_unlock_threshold: int = -1
var stone_unlocked: bool = false
var revive_prompt_pending: bool = false
var revive_used_this_run: bool = false
var _level_size_k: int = 3000
var active_weapon_choice_id: String = WeaponChoiceRulesRef.NO_CHOICE
var _weapon_choice_panel_open: bool = false
var _weapon_choice_schedule := WeaponChoiceScheduleRef.new(
	FIRST_REPEATED_WEAPON_CHOICE_SCORE,
	WEAPON_CHOICE_REPEAT_SCORE
)
var _weapon_choice_volley_count: int = 0
var _weapon_choice_hit_count: int = 0
var _weapon_choice_rng := RandomNumberGenerator.new()

var _progression = ProgressionServiceRef.new()


func _ready() -> void:
	_weapon_choice_rng.randomize()
	_load_progression()


func start_run() -> void:
	reset()
	is_playing = true
	game_started.emit()


func reset() -> void:
	current_level = 1
	current_level_k = 0
	revive_prompt_pending = false
	revive_used_this_run = false
	_reset_weapon_choice_state(true)
	_sync_progress_values()
	is_playing = false
	k_changed.emit(k)
	current_progression_tier = _progression.tier_for_k(current_level_k)
	_set_tier(_progression.implemented_tier_for_k(current_level_k))
	_refresh_unlock_progress(-1)


func add_k(amount: int) -> void:
	if amount <= 0:
		return
	if not is_playing:
		return
	var previous_score: int = current_level_k
	var previous_progression_tier: int = current_progression_tier
	current_level_k += amount
	_sync_progress_values()
	k_changed.emit(k)
	var progression_lookup_k := _progression_lookup_k()
	current_progression_tier = _progression.tier_for_k(progression_lookup_k)
	_set_tier(_progression.implemented_tier_for_k(progression_lookup_k))
	_refresh_unlock_progress(previous_progression_tier)
	if _should_request_weapon_choice(previous_score, current_level_k):
		_request_weapon_choice()


func trigger_game_over() -> void:
	if not is_playing:
		return
	_finalize_game_over()


func can_offer_rewarded_revive() -> bool:
	return is_playing and not revive_prompt_pending and not revive_used_this_run


func begin_revive_pending() -> bool:
	if not can_offer_rewarded_revive():
		return false
	# Revive pending is not final game-over. Do not save, submit, or emit game_over here.
	is_playing = false
	revive_prompt_pending = true
	revive_used_this_run = true
	revive_prompt_requested.emit()
	return true


func grant_revive() -> bool:
	if not revive_prompt_pending:
		return false
	revive_prompt_pending = false
	is_playing = true
	_emit_progression_display()
	revive_granted.emit()
	return true


func finalize_game_over_after_revive_decline() -> void:
	if not revive_prompt_pending:
		return
	_finalize_game_over()


func trigger_max_level_clear() -> void:
	if not is_playing:
		return
	is_playing = false
	var previous_best := SaveManager.get_best_record_value()
	SaveManager.record_run_result(total_progress, current_level, current_level_k)
	if total_progress > previous_best:
		AudioEvents.high_score()
	max_level_cleared.emit()


func _finalize_game_over() -> void:
	is_playing = false
	revive_prompt_pending = false
	var previous_best := SaveManager.get_best_record_value()
	SaveManager.record_run_result(total_progress, current_level, current_level_k)
	if total_progress > previous_best:
		AudioEvents.high_score()
	game_over.emit()


func _load_progression() -> void:
	_progression.configure(JsonConfigLoaderRef.load_array("res://data/progression.json", "tiers"))
	_level_size_k = maxi(_progression.loop_length(), 1)
	stone_unlock_threshold = _progression.threshold_for_tier(1)
	overclock_unlock_threshold = _progression.threshold_for_tier(4)
	_reset_weapon_choice_state(true)
	_sync_progress_values()
	current_progression_tier = _progression.tier_for_k(_progression_lookup_k())
	_set_tier(_progression.implemented_tier_for_k(_progression_lookup_k()))
	_refresh_unlock_progress(-1)


func _set_tier(new_tier: int) -> void:
	if new_tier == current_projectile_tier:
		return
	current_projectile_tier = new_tier
	tier_changed.emit(current_projectile_tier)


func _refresh_unlock_progress(previous_progression_tier: int) -> void:
	var threshold: int = stone_unlock_threshold
	var unlocked_now: bool = threshold >= 0 and current_progression_tier >= 1 and current_level_k >= threshold
	if previous_progression_tier >= 0 and current_progression_tier > previous_progression_tier:
		for unlocked_tier in range(previous_progression_tier + 1, current_progression_tier + 1):
			var unlock_threshold: int = _progression.threshold_for_tier(unlocked_tier)
			var display_name: String = _progression.display_name_for_tier(unlocked_tier)
			tier_threshold_reached.emit(unlocked_tier, unlock_threshold, display_name)
			if unlocked_tier == 1:
				stone_unlock_reached.emit(current_level_k, unlock_threshold)
	stone_unlocked = unlocked_now
	unlock_progress_changed.emit(current_level_k, threshold, stone_unlocked)
	_emit_progression_display()


func get_progression_display_state() -> Dictionary:
	var next_tier: Dictionary = _progression.next_tier_after_k(_progression_lookup_k())
	var ready_unlock_name: String = ""
	if current_progression_tier > current_projectile_tier:
		ready_unlock_name = _progression.display_name_for_tier(current_progression_tier)
	var next_unlock_name: String = String(next_tier.get("display_name", ""))
	var next_unlock_threshold: int = int(next_tier.get("k_min", -1))
	var max_spec_tier_reached: bool = false
	if next_tier.is_empty():
		next_unlock_name = "기록 갱신"
		next_unlock_threshold = -1
		max_spec_tier_reached = true
	return {
		"current_level": current_level,
		"current_k": current_level_k,
		"total_progress": total_progress,
		"current_weapon_name": _progression.display_name_for_tier(current_projectile_tier),
		"next_unlock_name": next_unlock_name,
		"next_unlock_threshold": next_unlock_threshold,
		"ready_unlock_name": ready_unlock_name,
		"max_spec_tier_reached": max_spec_tier_reached,
	}


func get_overclock_unlock_threshold() -> int:
	return overclock_unlock_threshold


func is_overclock_unlocked() -> bool:
	return overclock_unlock_threshold >= 0 and current_level_k >= overclock_unlock_threshold


func get_level_size_k() -> int:
	return _level_size_k


func get_score_gauge_max() -> int:
	return EndlessScoreRulesRef.gauge_max(SaveManager.get_best_record_value(), DEFAULT_SCORE_GAUGE_MAX)


func get_score_gauge_progress() -> float:
	return EndlessScoreRulesRef.gauge_progress(total_progress, get_score_gauge_max())


func get_score_gauge_display_text(score: int = -1) -> String:
	var display_score := total_progress if score < 0 else score
	return EndlessScoreRulesRef.display_text(display_score, get_score_gauge_max())


func get_tier_threshold(tier: int) -> int:
	return _progression.threshold_for_tier(tier)


func get_tier_display_name(tier: int) -> String:
	return _progression.display_name_for_tier(tier)


func get_weapon_choice_threshold() -> int:
	return _weapon_choice_schedule.first_score


func get_weapon_choice_options() -> Array:
	return WeaponChoiceRulesRef.get_choices()


func get_active_weapon_choice_definition() -> Dictionary:
	return WeaponChoiceRulesRef.definition_for_id(active_weapon_choice_id)


func get_active_weapon_choice_display_name() -> String:
	return WeaponChoiceRulesRef.display_name_for_id(active_weapon_choice_id)


func has_weapon_choice_this_level() -> bool:
	return _weapon_choice_schedule.get_next_score() > _weapon_choice_schedule.first_score


func is_weapon_choice_panel_open() -> bool:
	return _weapon_choice_panel_open


func select_weapon_choice(choice_id: String) -> void:
	if not WeaponChoiceRulesRef.is_selectable_choice(choice_id):
		return
	active_weapon_choice_id = choice_id
	_weapon_choice_panel_open = false
	_weapon_choice_volley_count = 0
	_weapon_choice_hit_count = 0
	weapon_choice_selected.emit(choice_id, WeaponChoiceRulesRef.display_name_for_id(choice_id))
	if _weapon_choice_schedule.should_trigger_deferred(current_level_k, _weapon_choice_panel_open):
		_queue_deferred_weapon_choice_check()


func consume_prism_volley_trigger() -> bool:
	if active_weapon_choice_id != WeaponChoiceRulesRef.PRISM_LANCE:
		return false
	_weapon_choice_volley_count += 1
	return _weapon_choice_volley_count % WeaponChoiceRulesRef.PRISM_VOLLEY_INTERVAL == 0


func roll_chain_lightning_trigger() -> bool:
	if active_weapon_choice_id != WeaponChoiceRulesRef.CHAIN_LIGHTNING:
		return false
	return _weapon_choice_rng.randf() < WeaponChoiceRulesRef.CHAIN_CHANCE


func consume_meteor_trigger() -> bool:
	if active_weapon_choice_id != WeaponChoiceRulesRef.METEOR_CANNON:
		return false
	_weapon_choice_hit_count += 1
	return _weapon_choice_hit_count % WeaponChoiceRulesRef.METEOR_HIT_INTERVAL == 0


func _sync_progress_values() -> void:
	k = current_level_k
	total_progress = current_level_k


func _emit_progression_display() -> void:
	var state: Dictionary = get_progression_display_state()
	progression_display_changed.emit(
		int(state.get("current_level", 1)),
		int(state.get("current_k", 0)),
		int(state.get("total_progress", 0)),
		String(state.get("current_weapon_name", "알 수 없음")),
		String(state.get("next_unlock_name", "")),
		int(state.get("next_unlock_threshold", -1)),
		String(state.get("ready_unlock_name", "")),
		bool(state.get("max_spec_tier_reached", false))
	)


func _should_request_weapon_choice(previous_score: int, new_score: int) -> bool:
	return _weapon_choice_schedule.should_trigger(previous_score, new_score, _weapon_choice_panel_open)


func _request_weapon_choice() -> void:
	_weapon_choice_panel_open = true
	_weapon_choice_schedule.mark_triggered()
	weapon_choice_requested.emit(get_weapon_choice_options())


func _reset_weapon_choice_state(clear_selection: bool) -> void:
	_weapon_choice_panel_open = false
	_weapon_choice_schedule.reset()
	_weapon_choice_volley_count = 0
	_weapon_choice_hit_count = 0
	if clear_selection:
		active_weapon_choice_id = WeaponChoiceRulesRef.NO_CHOICE


func _progression_lookup_k() -> int:
	return mini(current_level_k, maxi(_level_size_k - 1, 0))


func _queue_deferred_weapon_choice_check() -> void:
	var timer := get_tree().create_timer(0.0)
	timer.timeout.connect(_request_deferred_weapon_choice_if_needed)


func _request_deferred_weapon_choice_if_needed() -> void:
	if not is_playing or _weapon_choice_panel_open:
		return
	if _weapon_choice_schedule.should_trigger_deferred(current_level_k, _weapon_choice_panel_open):
		_request_weapon_choice()
