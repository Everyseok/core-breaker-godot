extends Node
# SkillManager — owns selected automatic skill state and unlock availability.
# This autoload must not deal damage, spawn VFX, or own UI nodes.

const SkillRulesRef := preload("res://scripts/domain/skills/skill_rules.gd")

signal skill_selection_requested(options: Array)
signal skill_selected(skill_id: String, display_name: String)
signal skill_state_changed()
signal skill_unlock_reached(skill_id: String, unlock_k: int)

var selected_skill_id: String = SkillRulesRef.NONE

var _skill_panel_open: bool = false
var _announced_unlocks: Dictionary = {}


func _ready() -> void:
	GameState.game_started.connect(reset_on_game_started)
	GameState.game_over.connect(_cancel_runtime_state)
	GameState.max_level_cleared.connect(_cancel_runtime_state)
	GameState.k_changed.connect(_on_k_changed)


func reset_on_game_started() -> void:
	selected_skill_id = SkillRulesRef.NONE
	_skill_panel_open = false
	_announced_unlocks.clear()
	skill_state_changed.emit()


func get_selected_skill_id() -> String:
	return selected_skill_id


func has_selected_skill() -> bool:
	return SkillRulesRef.is_valid_skill_id(selected_skill_id)


func get_selected_skill_display_name() -> String:
	return SkillRulesRef.display_name_for_id(selected_skill_id)


func get_unlocked_skill_options() -> Array:
	return SkillRulesRef.unlocked_definitions_for_k(GameState.current_level_k)


func is_any_skill_unlocked() -> bool:
	return not get_unlocked_skill_options().is_empty()


func is_skill_panel_open() -> bool:
	return _skill_panel_open


func set_skill_panel_open(is_open: bool) -> void:
	if _skill_panel_open == is_open:
		return
	_skill_panel_open = is_open
	skill_state_changed.emit()


func request_skill_selection() -> bool:
	sync_unlock_state()

	var options := get_unlocked_skill_options()
	if options.is_empty():
		skill_state_changed.emit()
		return false

	_skill_panel_open = true
	skill_selection_requested.emit(options)
	skill_state_changed.emit()
	return true


func select_skill(skill_id: String) -> bool:
	if not SkillRulesRef.is_valid_skill_id(skill_id):
		return false

	var unlocked_ids := SkillRulesRef.unlocked_ids_for_k(GameState.current_level_k)
	if not unlocked_ids.has(skill_id):
		return false

	selected_skill_id = skill_id
	_skill_panel_open = false
	skill_selected.emit(skill_id, SkillRulesRef.display_name_for_id(skill_id))
	skill_state_changed.emit()
	return true


func sync_unlock_state() -> void:
	var unlocked_ids := SkillRulesRef.unlocked_ids_for_k(GameState.current_level_k)
	var state_changed := false

	for skill_variant in unlocked_ids:
		var skill_id := String(skill_variant)
		if _announced_unlocks.has(skill_id):
			continue
		_announced_unlocks[skill_id] = true
		skill_unlock_reached.emit(skill_id, SkillRulesRef.unlock_k_for_id(skill_id))
		state_changed = true

	if selected_skill_id == SkillRulesRef.NONE:
		var default_skill := SkillRulesRef.default_skill_for_k(GameState.current_level_k)
		if default_skill != SkillRulesRef.NONE:
			selected_skill_id = default_skill
			skill_selected.emit(default_skill, SkillRulesRef.display_name_for_id(default_skill))
			state_changed = true

	if state_changed:
		skill_state_changed.emit()


func _on_k_changed(_new_k: int) -> void:
	sync_unlock_state()


func _cancel_runtime_state() -> void:
	_skill_panel_open = false
	skill_state_changed.emit()
