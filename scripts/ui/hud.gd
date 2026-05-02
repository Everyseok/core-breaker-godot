extends Control
# HUD — live score and pause trigger

@onready var _level_label: Label = $LevelLabel
@onready var _k_progress_bar: ProgressBar = $KProgressBar
@onready var _k_label: Label = $KLabel
@onready var _weapon_label: Label = $WeaponLabel
@onready var _best_label: Label = $BestKLabel
@onready var _pause_btn: Button = $PauseButton


func _ready() -> void:
	GameState.k_changed.connect(_on_k_changed)
	GameState.unlock_progress_changed.connect(_on_unlock_progress_changed)
	GameState.progression_display_changed.connect(_on_progression_display_changed)
	GameState.game_started.connect(_on_game_started)
	_pause_btn.pressed.connect(_on_pause_pressed)
	_on_k_changed(GameState.current_level_k)
	var progression_state: Dictionary = GameState.get_progression_display_state()
	_on_progression_display_changed(
		int(progression_state.get("current_level", GameState.current_level)),
		int(progression_state.get("current_k", GameState.k)),
		int(progression_state.get("total_progress", GameState.total_progress)),
		String(progression_state.get("current_weapon_name", "ARROW")),
		String(progression_state.get("next_unlock_name", "")),
		int(progression_state.get("next_unlock_threshold", -1)),
		String(progression_state.get("ready_unlock_name", "")),
		bool(progression_state.get("max_spec_tier_reached", false))
	)
	_best_label.text = "Best: %d" % SaveManager.get_best_k()


func _on_k_changed(new_k: int) -> void:
	_on_unlock_progress_changed(new_k, GameState.stone_unlock_threshold, GameState.stone_unlocked)


func _on_game_started() -> void:
	_on_k_changed(GameState.current_level_k)
	_best_label.text = "Best: %d" % SaveManager.get_best_k()


func _on_unlock_progress_changed(current_k: int, threshold: int, unlocked: bool) -> void:
	_update_level_progress(GameState.current_level, current_k)
	if threshold < 0:
		_k_label.text = "K: %d" % current_k
		return
	if unlocked:
		_k_label.text = "K: %d" % current_k
		return
	_k_label.text = "K: %d" % current_k


func _on_progression_display_changed(
	current_level: int,
	current_k: int,
	_total_progress: int,
	current_weapon_name: String,
	next_unlock_name: String,
	next_unlock_threshold: int,
	ready_unlock_name: String,
	max_spec_tier_reached: bool
) -> void:
	_update_level_progress(current_level, current_k)
	_k_label.text = "K: %d" % current_k
	if ready_unlock_name != "":
		_weapon_label.text = "WEAPON: %s | READY: %s" % [current_weapon_name, ready_unlock_name]
		return
	if max_spec_tier_reached:
		_weapon_label.text = "WEAPON: %s | MAX SPEC TIER" % current_weapon_name
		return
	if next_unlock_threshold >= 0 and next_unlock_name != "":
		_weapon_label.text = "WEAPON: %s | NEXT: %s @ %d" % [
			current_weapon_name,
			next_unlock_name,
			next_unlock_threshold,
		]
		return
	_weapon_label.text = "WEAPON: %s" % current_weapon_name


func _on_pause_pressed() -> void:
	if not GameState.is_playing:
		return
	var menus := get_tree().get_nodes_in_group("pause_menu")
	if not menus.is_empty():
		menus[0].show_menu()


func _update_level_progress(current_level: int, current_k: int) -> void:
	var level_size: float = maxf(float(GameState.get_level_size_k()), 1.0)
	var normalized_progress: float = clampf(float(current_k) / level_size, 0.0, 1.0)
	_level_label.text = "LEVEL %d" % current_level
	_k_progress_bar.max_value = 1.0
	_k_progress_bar.value = normalized_progress
