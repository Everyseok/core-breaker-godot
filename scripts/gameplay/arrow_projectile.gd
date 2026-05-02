extends Area2D
# ArrowProjectile — tier 0; fast, 1 damage, 3-bounce budget, 3-target spread.

const SPEED   := 620.0
const LIFETIME := 1.4
const BOUNCES := 3
const HIT_SPREAD_RADIUS := 1
const POST_HIT_PUSHBACK := 10.0
const HIT_COOLDOWN := 0.04

var direction: Vector2 = Vector2.UP
var _age: float = 0.0
var _bounces_remaining: int = BOUNCES
var _hit_cooldown: float = 0.0


func _ready() -> void:
	collision_layer = 4
	collision_mask = 2

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(6, 14)
	shape.shape = rect
	shape.position = Vector2(0, 7)
	add_child(shape)

	# Visual extends forward from the launch point so the tail begins at the core center.
	var visual := ColorRect.new()
	visual.size = Vector2(5, 16)
	visual.position = Vector2(-2.5, 0)
	visual.color = Color(1.0, 0.92, 0.25)
	add_child(visual)

	# Orient the whole node along the direction of travel
	rotation = direction.angle() - PI / 2.0

	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	position += direction * SPEED * delta
	_age += delta
	_hit_cooldown = maxf(_hit_cooldown - delta, 0.0)
	if _age >= LIFETIME:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if _hit_cooldown > 0.0:
		return

	var bounce_normal: Vector2 = Vector2.ZERO
	if area.has_method("get_bounce_normal"):
		var normal_variant: Variant = area.call("get_bounce_normal")
		if normal_variant is Vector2:
			bounce_normal = normal_variant

	if area.has_method("resolve_projectile_hit"):
		area.call("resolve_projectile_hit", 1, HIT_SPREAD_RADIUS)
	elif area.has_method("take_damage"):
		area.call("take_damage", 1)
	else:
		return

	if _bounces_remaining <= 0:
		queue_free()
		return

	if bounce_normal.length_squared() <= 0.001:
		bounce_normal = -direction

	direction = _reflect(direction, bounce_normal).normalized()
	rotation = direction.angle() - PI / 2.0
	global_position += bounce_normal * POST_HIT_PUSHBACK
	_bounces_remaining -= 1
	_hit_cooldown = HIT_COOLDOWN


func _reflect(vector: Vector2, normal: Vector2) -> Vector2:
	var safe_normal: Vector2 = normal.normalized()
	return vector - (2.0 * vector.dot(safe_normal) * safe_normal)
