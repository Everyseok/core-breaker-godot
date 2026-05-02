extends Control
# GameOverScreen — shown on game over; restart reloads the scene

@onready var _score_label: Label = $ScoreLabel
@onready var _restart_button: Button = $RestartButton


func _ready() -> void:
	visible = false
	GameState.game_started.connect(_on_game_started)
	GameState.game_over.connect(_on_game_over)
	GameState.max_level_cleared.connect(_on_max_level_cleared)
	_restart_button.pressed.connect(_on_restart_pressed)


func _on_game_started() -> void:
	visible = false


func _on_game_over() -> void:
	_score_label.text = "GAME OVER\nLEVEL %d  K: %d\nTOTAL: %d\nBEST: %d" % [
		GameState.current_level,
		GameState.current_level_k,
		GameState.total_progress,
		SaveManager.get_best_k()
	]
	visible = true


func _on_max_level_cleared() -> void:
	_score_label.text = "MAX LEVEL CLEAR!\nLEVEL %d  K: %d\nTOTAL: %d\nBEST: %d" % [
		GameState.current_level,
		GameState.current_level_k,
		GameState.total_progress,
		SaveManager.get_best_k()
	]
	visible = true


func _on_restart_pressed() -> void:
	var roots: Array = get_tree().get_nodes_in_group("game_root")
	if roots.is_empty():
		get_tree().reload_current_scene()
		return
	visible = false
	roots[0].start_game()
