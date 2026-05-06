extends CanvasLayer
# RootUI — applies safe-area padding for all child controls in one place.

const AdLayoutRef := preload("res://scripts/ui/ad_layout.gd")

@onready var _ad_banner_reserve: Control = $AdBannerReserve
@onready var _ad_banner_backdrop: ColorRect = $AdBannerReserve/Backdrop
@onready var _ad_banner_padding: ColorRect = $AdBannerReserve/BottomPadding
@onready var _safe_area_container: Control = $SafeAreaContainer


func _ready() -> void:
	_apply_safe_area()
	get_viewport().size_changed.connect(_apply_safe_area)


func _apply_safe_area() -> void:
	var safe_area: Rect2i = DisplayServer.get_display_safe_area()
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var ad_reserved_top := AdLayoutRef.RESERVED_TOP_HEIGHT

	if safe_area.size == Vector2i.ZERO:
		_safe_area_container.offset_left = 0.0
		_safe_area_container.offset_top = ad_reserved_top
		_safe_area_container.offset_right = 0.0
		_safe_area_container.offset_bottom = 0.0
		_layout_ad_banner_reserve(0.0, 0.0, viewport_size.x)
		return

	var left := float(safe_area.position.x)
	var top := float(safe_area.position.y)
	var right := maxf(0.0, viewport_size.x - float(safe_area.position.x + safe_area.size.x))
	var bottom := maxf(0.0, viewport_size.y - float(safe_area.position.y + safe_area.size.y))

	_safe_area_container.offset_left = left
	_safe_area_container.offset_top = top + ad_reserved_top
	_safe_area_container.offset_right = -right
	_safe_area_container.offset_bottom = -bottom
	_layout_ad_banner_reserve(left, top, maxf(viewport_size.x - left - right, 0.0))


func _layout_ad_banner_reserve(left: float, top: float, width: float) -> void:
	_ad_banner_reserve.position = Vector2(left, top)
	_ad_banner_reserve.size = Vector2(width, AdLayoutRef.RESERVED_TOP_HEIGHT)
	_ad_banner_backdrop.position = Vector2.ZERO
	_ad_banner_backdrop.size = Vector2(width, AdLayoutRef.BANNER_HEIGHT)
	_ad_banner_padding.position = Vector2(0.0, AdLayoutRef.BANNER_HEIGHT)
	_ad_banner_padding.size = Vector2(width, AdLayoutRef.BANNER_TOP_PADDING)
