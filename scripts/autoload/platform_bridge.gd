extends Node
# PlatformBridge — Toss/container lifecycle, user identity, and Game Center bridge
# Compliance hooks: C-04, C-05, C-06, C-14, C-15, C-16, C-20, C-21, C-27, GC-01–GC-05

# Minimum Toss app versions for platform APIs (TQA-02)
const MIN_VERSION_LEADERBOARD: String = "5.221.0"   # submitGameCenterLeaderBoardScore, openGameCenterLeaderboard
const MIN_VERSION_USER_KEY: String = "5.232.0"       # getUserKeyForGame

signal exit_requested()
signal user_id_received(id: String)
signal game_user_key_received(key_hash: String)
signal game_user_key_failed(reason: String)
signal leaderboard_score_submitted(success: bool)

var _is_web: bool = false
var _js_callbacks: Array = []
# Duplicate submit prevention — reset each new run (GC-03, GM-02)
var _score_submitted_this_run: bool = false
# Track whether we paused the tree on background so we restore correctly (C-27, GC-02)
var _paused_for_background: bool = false


func _ready() -> void:
	_is_web = OS.get_name() == "Web"
	if not _is_web:
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_PORTRAIT)
	# Reset per-run submission flag when each new run starts (GM-02)
	GameState.game_started.connect(_on_game_started)
	init_platform()


func init_platform() -> void:
	if not _is_web:
		return

	# C-04/C-05: audio lifecycle tied to tab visibility
	var vis_cb := JavaScriptBridge.create_callback(_on_js_visibility_change)
	_js_callbacks.append(vis_cb)
	JavaScriptBridge.get_interface("document").addEventListener("visibilitychange", vis_cb)

	# C-16: intercept browser back / Android back gesture
	var pop_cb := JavaScriptBridge.create_callback(_on_js_popstate)
	_js_callbacks.append(pop_cb)
	JavaScriptBridge.get_interface("window").addEventListener("popstate", pop_cb)
	# Seed one history entry so the first popstate fires instead of leaving the page
	JavaScriptBridge.get_interface("history").pushState(null, "", "")

	# C-21: pull generic user identity and game-specific user key from Toss bridge
	fetch_user_id()
	fetch_game_user_key()


func request_close() -> void:
	# C-06: only called after ConfirmExitDialog is confirmed by user
	if _is_web:
		JavaScriptBridge.eval(
			"if (window.TossBridge && window.TossBridge.close) { window.TossBridge.close(); }"
		)
	else:
		get_tree().quit()


func on_visibility_hidden() -> void:
	# C-04: mute audio on background
	AudioManager.mute_all()
	# C-27: also pause game tree so walls and projectiles freeze
	if not get_tree().paused:
		_paused_for_background = true
		get_tree().paused = true


func on_visibility_visible() -> void:
	# C-05: restore audio on foreground return
	AudioManager.restore_mute_state()
	# C-27 / GC-02: unpause only if we were the ones who paused for background
	if _paused_for_background:
		_paused_for_background = false
		get_tree().paused = false


func fetch_user_id() -> void:
	# C-21: Toss getUser() — store ID so it persists with save data
	if not _is_web:
		return
	var result: String = JavaScriptBridge.eval(
		"(function(){ try { var u = window.TossBridge && window.TossBridge.getUser ? window.TossBridge.getUser() : null; return u ? JSON.stringify(u) : 'null'; } catch(e){ return 'null'; } })()"
	)
	if result == "null" or result == "":
		return
	var data = JSON.parse_string(result)
	if data is Dictionary and data.has("id"):
		var uid := str(data["id"])
		SaveManager.set_user_id(uid)
		SaveManager.save()
		user_id_received.emit(uid)


func _on_js_visibility_change(_args: Array) -> void:
	if JavaScriptBridge.get_interface("document").hidden:
		on_visibility_hidden()
	else:
		on_visibility_visible()


func _on_js_popstate(_args: Array) -> void:
	_handle_back_gesture()
	# Re-push so subsequent back presses fire popstate again
	JavaScriptBridge.get_interface("history").pushState(null, "", "")


func _handle_back_gesture() -> void:
	# C-16: back while actively playing → pause; back at any other state → exit confirm
	if GameState.is_playing and not get_tree().paused:
		var menus := get_tree().get_nodes_in_group("pause_menu")
		if not menus.is_empty():
			menus[0].show_menu()
		return
	var dialogs := get_tree().get_nodes_in_group("exit_dialog")
	if not dialogs.is_empty():
		dialogs[0].show_dialog()
	else:
		exit_requested.emit()


func fetch_game_user_key() -> void:
	# GC-05 / C-21: Retrieve the game-specific user hash from Toss (min v5.232.0).
	# Returns {type:"HASH", hash:string}, "INVALID_CATEGORY", "ERROR", or undefined.
	# Undefined means the Toss app version does not support getUserKeyForGame.
	if not _is_web:
		push_warning("[PlatformBridge] fetch_game_user_key: non-Web runtime; no-op")
		game_user_key_failed.emit("NOT_WEB")
		return
	var js_code: String = (
		"(function(){"
		+ "try {"
		+ "  if (!window.TossBridge || typeof window.TossBridge.getUserKeyForGame !== 'function') {"
		+ "    return JSON.stringify({status:'NO_BRIDGE'});"
		+ "  }"
		+ "  var r = window.TossBridge.getUserKeyForGame();"
		+ "  if (r === undefined || r === null) {"
		+ "    return JSON.stringify({status:'UNSUPPORTED_VERSION'});"
		+ "  }"
		+ "  if (r === 'INVALID_CATEGORY') { return JSON.stringify({status:'INVALID_CATEGORY'}); }"
		+ "  if (r === 'ERROR') { return JSON.stringify({status:'ERROR'}); }"
		+ "  if (typeof r === 'object' && r.type === 'HASH' && r.hash) {"
		+ "    return JSON.stringify({status:'OK', hash:String(r.hash)});"
		+ "  }"
		+ "  return JSON.stringify({status:'UNKNOWN', raw:String(r)});"
		+ "} catch(e) {"
		+ "  return JSON.stringify({status:'EXCEPTION', msg:String(e.message)});"
		+ "}"
		+ "})()"
	)
	var result: String = JavaScriptBridge.eval(js_code)
	var data = JSON.parse_string(result)
	if not (data is Dictionary):
		push_warning("[PlatformBridge] fetch_game_user_key: unexpected response: %s" % result)
		game_user_key_failed.emit("PARSE_ERROR")
		return
	var status: String = String(data.get("status", "UNKNOWN"))
	match status:
		"OK":
			var hash: String = String(data.get("hash", ""))
			SaveManager.set_game_user_key(hash)
			SaveManager.save()
			game_user_key_received.emit(hash)
		"UNSUPPORTED_VERSION":
			push_warning("[PlatformBridge] getUserKeyForGame: Toss app < v%s or undefined" % MIN_VERSION_USER_KEY)
			game_user_key_failed.emit("UNSUPPORTED_VERSION")
		"INVALID_CATEGORY":
			push_warning("[PlatformBridge] getUserKeyForGame: INVALID_CATEGORY — miniapp may not be registered as a game category yet (C-25/C-28)")
			game_user_key_failed.emit("INVALID_CATEGORY")
		"ERROR":
			push_warning("[PlatformBridge] getUserKeyForGame: ERROR from Toss bridge")
			game_user_key_failed.emit("ERROR")
		"NO_BRIDGE":
			push_warning("[PlatformBridge] getUserKeyForGame: TossBridge not available in this environment")
			game_user_key_failed.emit("NO_BRIDGE")
		_:
			push_warning("[PlatformBridge] getUserKeyForGame: status=%s" % status)
			game_user_key_failed.emit(status)


func submit_leaderboard_score(total_progress_value: int) -> void:
	# GC-01 / GM-01 / GM-02: Submit total_progress to Game Center leaderboard.
	# Called only at run completion (game-over or max-level-clear).
	# Duplicate submission within the same run is blocked by _score_submitted_this_run.
	# Minimum Toss app version: v5.221.0. Undefined return = unsupported version.
	if _score_submitted_this_run:
		push_warning("[PlatformBridge] submit_leaderboard_score: already submitted this run; skipping (GC-03)")
		return
	_score_submitted_this_run = true
	if not _is_web:
		push_warning("[PlatformBridge] submit_leaderboard_score: non-Web runtime; no-op (score=%d)" % total_progress_value)
		leaderboard_score_submitted.emit(false)
		return
	var score_str: String = str(total_progress_value)
	var js_code: String = (
		"(function(){"
		+ "try {"
		+ "  if (!window.TossBridge || typeof window.TossBridge.submitGameCenterLeaderBoardScore !== 'function') {"
		+ "    return JSON.stringify({status:'NO_BRIDGE'});"
		+ "  }"
		+ "  var r = window.TossBridge.submitGameCenterLeaderBoardScore({score:'" + score_str + "'});"
		+ "  if (r === undefined || r === null) {"
		+ "    return JSON.stringify({status:'UNSUPPORTED_VERSION'});"
		+ "  }"
		+ "  return JSON.stringify({status:'OK', result:String(r)});"
		+ "} catch(e) {"
		+ "  return JSON.stringify({status:'EXCEPTION', msg:String(e.message)});"
		+ "}"
		+ "})()"
	)
	var response: String = JavaScriptBridge.eval(js_code)
	var data = JSON.parse_string(response)
	if not (data is Dictionary):
		push_warning("[PlatformBridge] submit_leaderboard_score: parse error; response=%s" % response)
		leaderboard_score_submitted.emit(false)
		return
	var status: String = String(data.get("status", "UNKNOWN"))
	match status:
		"OK":
			print("[PlatformBridge] submit_leaderboard_score: OK score=%s" % score_str)
			leaderboard_score_submitted.emit(true)
		"UNSUPPORTED_VERSION":
			push_warning("[PlatformBridge] submitGameCenterLeaderBoardScore: Toss app < v%s" % MIN_VERSION_LEADERBOARD)
			leaderboard_score_submitted.emit(false)
		"NO_BRIDGE":
			push_warning("[PlatformBridge] submitGameCenterLeaderBoardScore: TossBridge not available")
			leaderboard_score_submitted.emit(false)
		_:
			push_warning("[PlatformBridge] submitGameCenterLeaderBoardScore: status=%s" % status)
			leaderboard_score_submitted.emit(false)


func open_leaderboard() -> void:
	# GC-02 / GM-03: Open the Game Center leaderboard UI.
	# Must be user-triggered (not automatic on game entry).
	# Minimum Toss app version: v5.221.0.
	# Opening backgrounds the miniapp — C-27 visibilitychange will handle the tree pause.
	# Suitable trigger: a button on the game-over/result screen added when scene is updated.
	if not _is_web:
		push_warning("[PlatformBridge] open_leaderboard: non-Web runtime; no-op")
		return
	JavaScriptBridge.eval(
		"(function(){"
		+ "try {"
		+ "  if (!window.TossBridge || typeof window.TossBridge.openGameCenterLeaderboard !== 'function') {"
		+ "    console.warn('[PlatformBridge] openGameCenterLeaderboard: TossBridge not available (< v"
		+ MIN_VERSION_LEADERBOARD
		+ " or no bridge)');"
		+ "    return;"
		+ "  }"
		+ "  var r = window.TossBridge.openGameCenterLeaderboard();"
		+ "  if (r === undefined) {"
		+ "    console.warn('[PlatformBridge] openGameCenterLeaderboard: undefined (Toss app < v"
		+ MIN_VERSION_LEADERBOARD
		+ ")');"
		+ "  }"
		+ "} catch(e) {"
		+ "  console.error('[PlatformBridge] openGameCenterLeaderboard exception: ' + String(e.message));"
		+ "}"
		+ "})()"
	)


func _on_game_started() -> void:
	# GM-02 / GC-03: reset per-run submission gate when a new run begins
	_score_submitted_this_run = false


# Future stubs — not implemented for MVP
func purchase(_product_id: String) -> void:
	pass  # IAP-01

func show_ad(_ad_unit: String) -> void:
	pass  # AD-01

func share(_text: String, _url: String) -> void:
	pass  # SR-01
