extends Control
# MainMenu — shown on app launch; hides when a run begins.

@onready var _start_btn: Button = $StartButton
@onready var _ranking_btn: Button = $RankingButton
@onready var _best_label: Label = $BestLabel


func _ready() -> void:
	visible = true
	_best_label.text = "Best: %d" % SaveManager.get_best_k()
	_start_btn.pressed.connect(_on_start_pressed)
	_ranking_btn.pressed.connect(_on_ranking_pressed)
	GameState.game_started.connect(_on_game_started)


func _on_start_pressed() -> void:
	var roots: Array = get_tree().get_nodes_in_group("game_root")
	if roots.is_empty():
		push_error("[MainMenu] 'game_root' group not found")
		return
	visible = false
	roots[0].start_game()


func _on_ranking_pressed() -> void:
	PlatformBridge.open_leaderboard()


func _on_game_started() -> void:
	visible = false
