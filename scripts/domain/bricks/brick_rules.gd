class_name BrickRules
extends RefCounted

enum BrickType { NORMAL = 0, STRONG = 1, ARMORED = 2 }

# Tangential segment width drives the wall-tiling count.
# Keep this aligned with BrickInstance's tangential collision/visual width.
const SEGMENT_SIZE: float = 28.0


static func hp_for_type(brick_type: int) -> int:
	match brick_type:
		BrickType.STRONG:
			return 2
		BrickType.ARMORED:
			return 3
		_:
			return 1


static func base_color_for_type(brick_type: int) -> Color:
	match brick_type:
		BrickType.STRONG:
			return Color(0.25, 0.45, 0.85)
		BrickType.ARMORED:
			return Color(0.55, 0.20, 0.75)
		_:
			return Color(0.75, 0.52, 0.18)
