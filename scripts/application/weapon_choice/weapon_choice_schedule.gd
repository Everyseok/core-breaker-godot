class_name WeaponChoiceSchedule
extends RefCounted

var first_score: int
var interval: int

var _next_score: int
var _deferred_due_to_open: bool = false


func _init(initial_first_score: int = 2000, repeat_interval: int = 1000) -> void:
	first_score = initial_first_score
	interval = repeat_interval
	reset()


func reset() -> void:
	_next_score = first_score
	_deferred_due_to_open = false


func get_next_score() -> int:
	return _next_score


func should_trigger(previous_score: int, new_score: int, panel_open: bool) -> bool:
	if previous_score >= _next_score or new_score < _next_score:
		return false
	if panel_open:
		mark_deferred()
		return false
	return true


func mark_triggered() -> void:
	_deferred_due_to_open = false
	_next_score += interval


func mark_deferred() -> void:
	_deferred_due_to_open = true


func consume_deferred() -> bool:
	var was_deferred := _deferred_due_to_open
	_deferred_due_to_open = false
	return was_deferred


func should_trigger_deferred(current_score: int, panel_open: bool) -> bool:
	return not panel_open and current_score >= _next_score
