class_name BrickRules
extends RefCounted

enum BrickType { NORMAL = 0, STRONG = 1, ARMORED = 2 }

# Tangential segment width drives the wall-tiling count.
# Keep this aligned with BrickInstance's tangential collision/visual width.
const SEGMENT_SIZE: float = 28.0


static func hp_for_type(brick_type: int) -> int:
	match brick_type:
		BrickType.STRONG:
			return 6000
		BrickType.ARMORED:
			return 9000
		_:
			return 3000


static func base_color_for_type(brick_type: int) -> Color:
	match brick_type:
		BrickType.STRONG:
			return Color(0.18, 0.44, 0.82)
		BrickType.ARMORED:
			return Color(0.32, 0.20, 0.46)
		_:
			return Color(0.84, 0.52, 0.18)


static func frame_color_for_type(brick_type: int) -> Color:
	match brick_type:
		BrickType.STRONG:
			return Color(0.78, 0.92, 1.0)
		BrickType.ARMORED:
			return Color(0.92, 0.78, 1.0)
		_:
			return Color(1.0, 0.92, 0.68)


static func highlight_color_for_type(brick_type: int) -> Color:
	match brick_type:
		BrickType.STRONG:
			return Color(0.52, 0.82, 1.0)
		BrickType.ARMORED:
			return Color(0.66, 0.46, 0.82)
		_:
			return Color(1.0, 0.78, 0.28)


static func detail_color_for_type(brick_type: int) -> Color:
	match brick_type:
		BrickType.STRONG:
			return Color(0.08, 0.20, 0.44)
		BrickType.ARMORED:
			return Color(0.18, 0.08, 0.26)
		_:
			return Color(0.56, 0.22, 0.08)


static func shadow_color_for_type(brick_type: int) -> Color:
	match brick_type:
		BrickType.STRONG:
			return Color(0.05, 0.12, 0.26)
		BrickType.ARMORED:
			return Color(0.16, 0.07, 0.22)
		_:
			return Color(0.42, 0.20, 0.08)


static func underside_color_for_type(brick_type: int) -> Color:
	match brick_type:
		BrickType.STRONG:
			return Color(0.12, 0.26, 0.52)
		BrickType.ARMORED:
			return Color(0.28, 0.14, 0.40)
		_:
			return Color(0.70, 0.34, 0.10)
