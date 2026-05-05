extends RefCounted

# Centralized playfield-safe layout contract for future top-banner support.
# This service is intentionally not wired into gameplay yet.
# Future consumers: RingSpawnPlanner, RingInstance, Core, projectiles, VFX,
# and DamageNumbers should read one computed playfield rect instead of carrying
# separate banner offsets.


func compute_layout(
	viewport_size: Vector2,
	top_safe_area: float,
	top_hud_height: float,
	banner_reserved_height: float,
	bottom_control_height: float,
	horizontal_padding: float = 8.0
) -> Dictionary:
	var top_reserved: float = maxf(top_safe_area, 0.0) + maxf(top_hud_height, 0.0) + maxf(banner_reserved_height, 0.0)
	var bottom_reserved: float = maxf(bottom_control_height, 0.0)
	var available_width: float = maxf(viewport_size.x - (horizontal_padding * 2.0), 1.0)
	var available_height: float = maxf(viewport_size.y - top_reserved - bottom_reserved, 1.0)
	var playfield_rect := Rect2(
		Vector2(horizontal_padding, top_reserved),
		Vector2(available_width, available_height)
	)
	var center := Vector2(
		playfield_rect.position.x + (playfield_rect.size.x * 0.5),
		playfield_rect.position.y + (playfield_rect.size.y * 0.5)
	)
	var max_ring_radius: float = maxf(minf(playfield_rect.size.x, playfield_rect.size.y) * 0.5, 1.0)
	return {
		"playfield_rect": playfield_rect,
		"center": center,
		"max_ring_radius": max_ring_radius,
		"banner_reserved_height": maxf(banner_reserved_height, 0.0),
		"top_reserved_height": top_reserved,
		"bottom_reserved_height": bottom_reserved,
	}
