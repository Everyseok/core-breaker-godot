extends CanvasLayer
# DangerOverlay — full-screen red tint that escalates with danger level.
# Restrained: never obscures gameplay, no strobe effects.

@onready var _tint: ColorRect = $EdgeTint

var _tween: Tween


func _ready() -> void:
	DangerManager.danger_level_changed.connect(_on_danger_level)


func _on_danger_level(level: int) -> void:
	if _tween:
		_tween.kill()
		_tween = null

	match level:
		0:
			_tint.color.a = 0.0
		1:
			# Faint static tint — caution, not urgent
			_tint.color.a = 0.07
		2:
			# Slow pulse
			_start_pulse(0.05, 0.18, 1.1)
		3:
			# Faster pulse — critical
			_start_pulse(0.10, 0.30, 0.40)


func _start_pulse(min_a: float, max_a: float, period: float) -> void:
	_tint.color.a = min_a
	_tween = create_tween().set_loops()
	_tween.tween_property(_tint, "color:a", max_a, period * 0.5)
	_tween.tween_property(_tint, "color:a", min_a, period * 0.5)
