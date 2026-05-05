extends Control
# GameOverScreen — result overlay with Korean copy and restart CTA.

const UiStyleRef := preload("res://scripts/ui/ui_style.gd")

@onready var _score_label: Label = $ScoreLabel
@onready var _restart_button: Button = $RestartButton

var _card: Panel


func _ready() -> void:
	visible = false
	GameState.game_started.connect(_on_game_started)
	GameState.game_over.connect(_on_game_over)
	GameState.max_level_cleared.connect(_on_max_level_cleared)
	_restart_button.pressed.connect(_on_restart_pressed)
	_build_card()
	_apply_style()


func _on_game_started() -> void:
	visible = false


func _on_game_over() -> void:
	_score_label.text = "도전 실패!\n%d단계\n이번 단계 깬 벽돌: %d개\n총 깬 벽돌: %d개\n최고 기록: %d개" % [
		GameState.current_level,
		GameState.current_level_k,
		GameState.total_progress,
		SaveManager.get_best_record_value()
	]
	_score_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.92))
	visible = true


func _on_max_level_cleared() -> void:
	_score_label.text = "최고 단계 돌파!\n%d단계\n이번 단계 깬 벽돌: %d개\n총 깬 벽돌: %d개\n최고 기록: %d개" % [
		GameState.current_level,
		GameState.current_level_k,
		GameState.total_progress,
		SaveManager.get_best_record_value()
	]
	_score_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.58))
	visible = true


func _on_restart_pressed() -> void:
	var roots: Array = get_tree().get_nodes_in_group("game_root")
	if roots.is_empty():
		get_tree().reload_current_scene()
		return
	visible = false
	roots[0].start_game()


func _build_card() -> void:
	_card = Panel.new()
	_card.anchor_left = 0.5
	_card.anchor_top = 0.5
	_card.anchor_right = 0.5
	_card.anchor_bottom = 0.5
	_card.offset_left = -160.0
	_card.offset_top = -180.0
	_card.offset_right = 160.0
	_card.offset_bottom = 150.0
	add_child(_card)
	move_child(_card, 0)

	var header := ColorRect.new()
	header.position = Vector2(44.0, 168.0)
	header.size = Vector2(232.0, 8.0)
	header.color = Color(0.32, 0.52, 0.94, 0.92)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(header)


func _apply_style() -> void:
	UiStyleRef.apply_panel(_card, UiStyleRef.PANEL_DARK, UiStyleRef.PANEL_BORDER)
	UiStyleRef.apply_label(_score_label, 22, Color.WHITE, 5)
	UiStyleRef.apply_button(_restart_button, Color(0.16, 0.52, 0.88), Color(0.58, 0.86, 1.0), Color.WHITE, 20)
