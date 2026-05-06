extends Node

const SoundCatalogRef := preload("res://scripts/audio/sound_catalog.gd")
const AudioRouterRef := preload("res://scripts/audio/audio_router.gd")
const CATALOG_PATH := "res://data/audio/sound_catalog.json"

var _catalog = SoundCatalogRef.new()
var _router: Node
var _last_danger_level: int = 0
var _active_bgm_state: StringName = &""
var _active_bgm_k_value: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_router = Node.new()
	_router.set_script(AudioRouterRef)
	_router.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_router)
	if not _catalog.load_from_path(CATALOG_PATH):
		return
	_router.setup(_catalog)
	var missing := _catalog.validate_files()
	for missing_entry in missing:
		push_warning("[AudioEvents] Missing catalog file: %s" % missing_entry)


func _exit_tree() -> void:
	bgm_stop()


func play(event_id: StringName) -> void:
	if _router != null and _router.has_method("play_event"):
		_router.call("play_event", event_id)


func play_hook(hook_name: String) -> void:
	match hook_name:
		"weapon_change":
			weapon_tier_up()
		"weapon_choice_open":
			weapon_choice_open()
		"weapon_choice_select":
			weapon_choice_select()
		"weapon_choice_proc":
			_keep_bgm_alive()
		"meteor_cannon_proc":
			weapon_proc(&"meteor_cannon")
		"ranking_failed":
			ui_error()
		_:
			play(StringName(hook_name))


func game_start() -> void:
	pass


func game_over() -> void:
	play(&"game.over")


func game_max_clear() -> void:
	play(&"game.max_clear")


func level_transition() -> void:
	pass


func ui_tap() -> void:
	play(&"ui.button_tap")


func ui_menu_open() -> void:
	play(&"ui.menu_open")


func ui_menu_close() -> void:
	play(&"ui.menu_close")


func ui_confirm() -> void:
	play(&"ui.confirm")


func ui_error() -> void:
	play(&"ui.error")


func ui_switch() -> void:
	play(&"ui.switch")


func ui_pause() -> void:
	ui_menu_open()


func ui_resume() -> void:
	ui_menu_close()


func weapon_hit(tier: int, choice_id: StringName = &"") -> void:
	match choice_id:
		&"chain_lightning":
			play(&"weapon.hit.chain_lightning")
			return
		&"prism_lance":
			play(&"weapon.hit.prism_lance")
			return
		&"meteor_cannon":
			play(&"weapon.hit.meteor_cannon")
			return
	match tier:
		0:
			play(&"weapon.hit.arrow")
		1:
			play(&"weapon.hit.thunder")
		2:
			play(&"weapon.hit.spark_lance")
		3:
			play(&"weapon.hit.volt_storm")
		4:
			play(&"weapon.hit.siege_cannon")
		_:
			brick_hit()


func weapon_proc(choice_id: StringName) -> void:
	match choice_id:
		&"chain_lightning":
			play(&"weapon.proc.chain_lightning")
		&"prism_lance":
			play(&"weapon.proc.prism_lance")
		&"meteor_cannon":
			play(&"weapon.proc.meteor_cannon")
		_:
			pass
	_keep_bgm_alive()


func weapon_choice_open() -> void:
	play(&"weapon.choice.open")


func weapon_choice_select() -> void:
	play(&"weapon.choice.select")
	_keep_bgm_alive()


func weapon_tier_up() -> void:
	_keep_bgm_alive()


func weapon_overclock_start() -> void:
	pass


func weapon_overclock_end() -> void:
	pass


func brick_hit() -> void:
	play(&"brick.hit")


func brick_break() -> void:
	play(&"brick.break")


func high_score() -> void:
	pass


func danger_level(level: int) -> void:
	_last_danger_level = level
	_keep_bgm_alive()


func bgm_set_state(state: StringName, k_value: float) -> void:
	_active_bgm_state = state
	_active_bgm_k_value = k_value
	if _router != null and _router.has_method("play_bgm"):
		_router.call("play_bgm", &"bgm.core_loop")


func bgm_stop() -> void:
	_active_bgm_state = &""
	_active_bgm_k_value = 0.0
	if _router != null and _router.has_method("stop_bgm"):
		_router.call("stop_bgm")


func _keep_bgm_alive() -> void:
	if _active_bgm_state == &"":
		return
	bgm_set_state(_active_bgm_state, _active_bgm_k_value)
