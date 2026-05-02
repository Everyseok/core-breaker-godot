extends Area2D
# StoneProjectile — tier 1; slower, larger, 5-target spread.

const SPEED   := 480.0
const LIFETIME := 1.8
const HIT_SPREAD_RADIUS := 2

var direction: Vector2 = Vector2.UP
var _age: float = 0.0


func _ready() -> void:
	collision_layer = 4
	collision_mask = 2

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 16)
	shape.shape = rect
	shape.position = Vector2(0, 8)
	add_child(shape)

	var visual := ColorRect.new()
	visual.size = Vector2(16, 16)
	visual.position = Vector2(-8, 0)
	visual.color = Color(0.60, 0.45, 0.25)
	add_child(visual)

	rotation = direction.angle() - PI / 2.0
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	position += direction * SPEED * delta
	_age += delta
	if _age >= LIFETIME:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("resolve_projectile_hit"):
		area.call("resolve_projectile_hit", 1, HIT_SPREAD_RADIUS)
	elif area.has_method("take_damage"):
		area.call("take_damage", 1)
	else:
		return
	queue_free()
