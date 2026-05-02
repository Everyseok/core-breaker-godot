extends Node2D
# Core — fixed center; game over when any brick enters the kill radius.
# KILL_RADIUS must be visible so players understand the danger zone.

signal core_breached()

const KILL_RADIUS := 40.0


func _ready() -> void:
	_build_kill_zone()
	_build_visual()


func _build_kill_zone() -> void:
	var area := Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 2
	area.area_entered.connect(_on_brick_entered)

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = KILL_RADIUS
	shape.shape = circle
	area.add_child(shape)
	add_child(area)


func _build_visual() -> void:
	# Kill-zone aura: shows the danger radius so players can judge when they lose
	var aura_size := KILL_RADIUS * 2.0
	var aura := ColorRect.new()
	aura.size = Vector2(aura_size, aura_size)
	aura.position = Vector2(-KILL_RADIUS, -KILL_RADIUS)
	aura.color = Color(1.0, 0.35, 0.1, 0.22)
	add_child(aura)

	# Inner ring band (border effect using a slightly smaller dark rect on top)
	var inner_size := (KILL_RADIUS - 4.0) * 2.0
	var inner := ColorRect.new()
	inner.size = Vector2(inner_size, inner_size)
	inner.position = Vector2(-(KILL_RADIUS - 4.0), -(KILL_RADIUS - 4.0))
	inner.color = Color(0.08, 0.08, 0.12, 0.88)
	add_child(inner)

	# Core point: bright, clearly central
	var core_size := 18.0
	var core := ColorRect.new()
	core.size = Vector2(core_size, core_size)
	core.position = Vector2(-core_size * 0.5, -core_size * 0.5)
	core.color = Color(0.3, 0.92, 1.0)
	add_child(core)


func get_launch_origin_global() -> Vector2:
	return global_position


func _on_brick_entered(_area: Area2D) -> void:
	core_breached.emit()
