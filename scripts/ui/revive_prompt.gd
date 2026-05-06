extends Control
# RevivePrompt — rewarded-ad revive decision UI. Final game-over stays separate.

const UiStyleRef := preload("res://scripts/ui/ui_style.gd")

@onready var _panel: Panel = $Panel
@onready var _title_label: Label = $Panel/TitleLabel
@onready var _message_label: Label = $Panel/MessageLabel
@onready var _yes_button: Button = $Panel/ButtonRow/YesButton
@onready var _no_button: Button = $Panel/ButtonRow/NoButton

var _ad_in_flight: bool = false
var _ad_attempted: bool = false


func _ready() -> void:
	visible = false
	add_to_group("revive_prompt")
	GameState.revive_prompt_requested.connect(_show_prompt)
	GameState.game_started.connect(_hide_prompt)
	GameState.game_over.connect(_hide_prompt)
	PlatformBridge.rewarded_revive_ad_completed.connect(_on_rewarded_revive_ad_completed)
	_yes_button.pressed.connect(_on_yes_pressed)
	_no_button.pressed.connect(_on_no_pressed)
	_apply_style()


func _show_prompt() -> void:
	_ad_in_flight = false
	_ad_attempted = false
	_yes_button.disabled = false
	_no_button.disabled = false
	_message_label.text = "광고를 끝까지 보면\n같은 기록으로 이어서 할 수 있어요."
	visible = true
	AudioEvents.ui_menu_open()


func _hide_prompt() -> void:
	visible = false
	_ad_in_flight = false


func _on_yes_pressed() -> void:
	if _ad_in_flight or _ad_attempted:
		return
	_ad_in_flight = true
	_ad_attempted = true
	_yes_button.disabled = true
	_no_button.disabled = true
	_message_label.text = "광고를 준비하는 중..."
	AudioEvents.ui_confirm()
	if not PlatformBridge.request_rewarded_revive_ad():
		_handle_ad_failure(PlatformBridge.get_last_rewarded_revive_ad_error())


func _on_no_pressed() -> void:
	if _ad_in_flight:
		return
	visible = false
	AudioEvents.ui_confirm()
	var roots := get_tree().get_nodes_in_group("game_root")
	if not roots.is_empty() and roots[0].has_method("finalize_game_over_after_decline_or_ad_failure"):
		roots[0].call("finalize_game_over_after_decline_or_ad_failure")
		return
	GameState.finalize_game_over_after_revive_decline()


func _on_rewarded_revive_ad_completed(success: bool, reason: String) -> void:
	if not visible or not _ad_in_flight:
		return
	_ad_in_flight = false
	if success:
		visible = false
		var roots := get_tree().get_nodes_in_group("game_root")
		if not roots.is_empty() and roots[0].has_method("revive_after_reward"):
			roots[0].call("revive_after_reward")
		return
	_handle_ad_failure(reason)


func _handle_ad_failure(reason: String) -> void:
	_ad_in_flight = false
	_yes_button.disabled = true
	_no_button.disabled = false
	_message_label.text = "%s\n아니오를 누르면 결과를 저장해요." % _failure_message_for(reason)
	AudioEvents.ui_error()


func _failure_message_for(reason: String) -> String:
	match reason:
		"NOT_WEB":
			return "현재 빌드에서는 광고를 볼 수 없어요."
		"MISSING_AD_GROUP_ID":
			return "토스 광고 그룹 ID 설정이 필요해요."
		"WEB_FRAMEWORK_BINDING_UNVERIFIED":
			return "토스 광고 연결 확인 후 사용할 수 있어요."
		"IN_FLIGHT":
			return "광고를 이미 준비하고 있어요."
		"FAILED_TO_SHOW":
			return "광고를 보여주지 못했어요."
		"DISMISSED":
			return "광고 시청이 완료되지 않았어요."
		_:
			return "광고를 사용할 수 없어요."


func _apply_style() -> void:
	UiStyleRef.apply_panel(_panel, UiStyleRef.PANEL_DARK, UiStyleRef.PANEL_BORDER)
	UiStyleRef.apply_menu_title(_title_label, 25, UiStyleRef.TEXT_MAIN, 5)
	UiStyleRef.apply_label(_message_label, 16, UiStyleRef.TEXT_SUB, 4)
	UiStyleRef.apply_arcade_button(_yes_button, UiStyleRef.MENU_SUCCESS_FILL, UiStyleRef.MENU_SUCCESS_BORDER, Color.WHITE, 18)
	UiStyleRef.apply_arcade_button(_no_button, UiStyleRef.MENU_DANGER_FILL, UiStyleRef.MENU_DANGER_BORDER, Color.WHITE, 18)
