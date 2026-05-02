# Toss Mini App Release Checklist

Legend — **Status**: `[ ]` Not started · `[~]` In progress · `[x]` Done · `[N/A]` Not applicable

---

## A. Common Requirements

| ID | Requirement | Applies to MVP? | Planned Approach | Validation Method | Status |
|----|-------------|----------------|------------------|-------------------|--------|
| C-01 | App opens to first screen within 10 seconds | Yes | Minimal preload scene; defer heavy asset loads | Time from iframe load to first interactive frame in DevTools | `[ ]` |
| C-02 | Sound / music / SFX / haptics work correctly | Yes | AudioManager autoload; test on real device | Manual test: BGM plays, SFX fire on hit/destroy | `[ ]` |
| C-03 | User can turn sound on/off | Yes | PauseMenu Sound toggle calls `AudioManager.set_sound_enabled()` → `SaveManager` → `SaveFileRepository`; relaunch validation still pending | Toggle on → off → relaunch → confirm state persisted | `[~]` |
| C-04 | Backgrounding immediately stops sound | Yes | `PlatformBridge._on_js_visibility_change()` registers `visibilitychange` listener via `JavaScriptBridge`; hidden → `AudioManager.mute_all()`; wired and ready for Web export | Tab switch test on mobile browser | `[~]` |
| C-05 | Foreground return restores intended sound behavior | Yes | Same `visibilitychange` listener; visible → `AudioManager.restore_mute_state()`; wired and ready for Web export | Return from background; verify BGM resumes iff sound was on | `[~]` |
| C-06 | Close button visible/functional if container provides it | Yes | `PlatformBridge.request_close()` calls `TossBridge.close()` on Web or `get_tree().quit()` on native; container close button handled by container | Confirm container close works; game must not block it | `[~]` |
| C-07 | Safe area respected (iOS Dynamic Island, notch, bottom bar) | Yes | `RootUI` now applies `DisplayServer.get_display_safe_area()` to `SafeAreaContainer`; device validation still pending | Visual check on device with Dynamic Island | `[~]` |
| C-08 | No forced bottom sheet on entry | Yes | Game launches directly to gameplay — no bottom sheet anywhere in current code | Cold launch test | `[~]` |
| C-09 | No bottom-sheet coercion for required user actions | Yes | PauseMenu is a centered overlay, not a bottom sheet; GameOverScreen is a full overlay | Review all user flows | `[~]` |
| C-10 | User can exit from all screens | Yes | PauseMenu has Resume + Restart (reloads scene); GameOverScreen has Play Again; **no main menu yet** | Walk all screen transitions | `[~]` |
| C-11 | CTA labels clearly imply resulting action | Yes | Current labels: "Resume", "Restart", "Sound: ON/OFF", "Play Again" — verb-based, unambiguous | UI review against label list | `[~]` |
| C-12 | No forced navigation to own service/app install | Yes | No install prompts anywhere in codebase | Code review of all navigation calls | `[~]` |
| C-13 | No illegal or sexual content | Yes | Pixel art brick/shooter — no such content | Content review | `[x]` |
| C-14 | Fullscreen in-game screen | Yes | Godot HTML5 export fullscreen flag; CSS fullscreen API via PlatformBridge | Visual check: no browser chrome visible during gameplay | `[ ]` |
| C-15 | Intended orientation works correctly | Yes | `PlatformBridge._ready()` calls `DisplayServer.screen_set_orientation(SCREEN_PORTRAIT)` on non-Web; HTML5 orientation lock deferred to export config | Test on Android + iOS | `[~]` |
| C-16 | OS back gesture does not break experience | Yes | `PlatformBridge` registers `popstate` listener; back during active play → PauseMenu; back at game-over/paused → ConfirmExitDialog; history.pushState keeps page from navigating away | Press back during gameplay; confirm behavior | `[~]` |
| C-17 | All UI components work correctly | Yes | Manual QA pass on each screen | Test plan: all tappable elements, all transitions | `[ ]` |
| C-18 | Interaction latency under 2 seconds | Yes | Godot GL Compatibility renderer; no heavy shaders on critical path | FPS meter + tap-to-response stopwatch on mid-range device | `[ ]` |
| C-19 | Network and memory usage reasonable | Yes | No network calls during gameplay; assets loaded once at startup | Chrome DevTools Memory / Network tab audit | `[ ]` |
| C-20 | Confirm modal on app exit | Yes | `ConfirmExitDialog` (centered overlay, not bottom sheet) registered in group `exit_dialog`; `PlatformBridge._handle_back_gesture()` routes non-playing back presses here; "Leave" calls `PlatformBridge.request_close()` | Trigger exit; confirm modal appears; Stay keeps game open; runtime validation pending | `[~]` |
| C-21 | User identifier obtained and saved | Yes | **Phase 4.19 done:** `PlatformBridge.fetch_game_user_key()` calls `getUserKeyForGame()` on init; handles `undefined` (UNSUPPORTED_VERSION), `INVALID_CATEGORY`, `ERROR`, `NO_BRIDGE`, and `{type:"HASH",hash:...}` (OK); persists hash via `SaveManager.set_game_user_key()`; min version `v5.232.0` noted; emits `game_user_key_received`/`game_user_key_failed` | Toss sandbox/device test with supported app version; verify persistence and error handling | `[~]` |
| C-22 | User progress persists across sessions | Yes | `SaveManager` now persists local JSON via `SaveFileRepository`; best K and settings save in-code, but relaunch validation is still pending | Play → kill app → relaunch → verify K and unlocks restored | `[~]` |
| C-23 | App bundle `.ait` is 100MB or less after decompression | Yes | **Session 41 dry run:** Web export produced 36.40 MB unpacked (`.wasm` 36 MB + `.js` 308 KB + `.pck` 110 KB + misc). Well within the 100 MB official limit. Actual `.ait` bundle will differ but is expected to be similar. Re-audit after every SDK/resource pass before upload. | Build `.ait` → decompress → measure total unpacked size | `[~]` |
| C-24 | Release bundle excludes dev/source-only files | Yes | **Session 41:** Export folder hygiene CLEAN — no `.git/`, `.godot/`, `.gd`, `.tscn`, `docs/`, `.wav`, `.psd`, `.aseprite`. Minor: (1) Three `.import` metadata files generated alongside icons in export output dir — confirm excluded from `.ait` packaging. (2) `data/dev_status.json` packed into `index.pck` because it is under `res://data/`; consider adding per-file export filter before submission (wastes ~2 KB). | Inspect archive contents before upload | `[~]` |
| C-25 | App name and icon match Toss console registration exactly | Yes | `project.godot` `application/config/name` and icon must match the name and 600×600px squared icon registered in the Toss dev console; both light and dark modes must have a visible background | Visual comparison against console entry before submission | `[ ]` |
| C-26 | Pinch-zoom (user scaling) disabled on all game screens | Yes | **Session 39 done (structural):** `export_presets.cfg` created with Godot 4.6 "Toss Web" preset; `html/head_include` injects `<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">` plus `canvas{touch-action:none}` and `html,body{overscroll-behavior:none}` CSS; activates automatically when project is exported using Godot editor; no actual `.ait` export exists yet; device validation still required | Attempt pinch-zoom on Toss device after first real export; confirm no scale change | `[~]` |
| C-27 | Game simulation loop pauses on background, resumes on foreground | Yes | **Phase 4.19 done:** `on_visibility_hidden()` sets `get_tree().paused = true` (sets `_paused_for_background = true` flag) in addition to `AudioManager.mute_all()`; `on_visibility_visible()` restores audio and sets `get_tree().paused = false` only if `_paused_for_background` is true (preserves intentional manual pause) | Background/foreground test: alt-tab → return; confirm wall position and projectile state frozen and resumed | `[~]` |
| C-28 | Toss console scheme URL registered; scheme loads game correctly | Yes (pre-submission gate) | Register miniapp scheme in Toss dev console; test that opening the scheme URL from Toss app launches the game to the first interactive screen; no 404 or blank screen | Manual test via Toss QR / private test environment | `[ ]` |

---

## B. Feature-Specific — In-App Purchase

> **Out of scope for MVP unless IAP is enabled later.**

| ID | Requirement | Applies to MVP? | Planned Approach | Validation Method | Status |
|----|-------------|----------------|------------------|-------------------|--------|
| IAP-01 | IAP flow compliant with Toss store policy | No (future) | PlatformBridge `purchase(product_id)` stub ready | Full IAP regression when feature enabled | `[ ]` |
| IAP-02 | Purchase confirmation shown before charge | No (future) | Confirmation dialog before bridge call | User test | `[ ]` |
| IAP-03 | Failed purchases handled gracefully | No (future) | Error signal from bridge → user-facing error toast | Force-fail test | `[ ]` |
| IAP-04 | Purchase state persists and is not lost on crash | No (future) | Server-side receipt validation (future) | Kill process mid-purchase; verify refund/restore | `[ ]` |

---

## C. Feature-Specific — In-App Ads

> **Out of scope for MVP unless ads are enabled later.**

| ID | Requirement | Applies to MVP? | Planned Approach | Validation Method | Status |
|----|-------------|----------------|------------------|-------------------|--------|
| AD-01 | Ad shown only at appropriate moments (not mid-gameplay) | No (future) | **Phase 4.20 plan (official):** Interstitial only at game-over / max-level-clear / between-run. Official `ads/develop.md` prohibits: active gameplay, loading screens, modal dialogs, game UI overlap. **PauseMenu is a modal overlay → pause-screen interstitial is explicitly excluded.** | Review trigger code against prohibited list | `[ ]` |
| AD-02 | Skip / close button available per Toss policy | No (future) | IntegratedAd `showFullScreenAd` delivers close via `dismissed` event; Toss provides close UI. PlatformBridge must call `AudioManager.restore_mute_state()` on `dismissed` or `failedToShow`. | Test close flow on device | `[ ]` |
| AD-03 | No ad blocking gameplay required interaction | No (future) | **Phase 4.20 plan:** All ad calls are non-blocking. `loadFullScreenAd` failure → skip, proceed normally. `failedToShow` → proceed silently. Banner failure → hide container. No game action gated on ad success or failure. | Test ad failure path (network off) | `[ ]` |
| AD-04 | Interstitial shown only at expected transition points | No (future) | **Phase 4.20 plan — locked placement list:** `GameState.game_over` signal (game-over screen), `GameState.max_level_cleared` (max clear screen), between-run on restart tap. Frequency limit + cooldown required (official QA). **PauseMenu excluded — `ads/develop.md` prohibits modal-dialog placements.** | Confirm trigger code matches this list before implementation | `[ ]` |
| AD-05 | Ads preloaded; music pauses/resumes correctly during ad | No (future) | **Phase 4.20 plan (official QA requirement):** `loadFullScreenAd()` called at run-end trigger. `AudioManager.mute_all()` before `showFullScreenAd()`. `AudioManager.restore_mute_state()` on `dismissed`/`failedToShow`. Banner has no audio requirement. | Audio pause/resume test on real device | `[ ]` |
| AD-06 | Use Toss IntegratedAd v2 + BannerAd APIs; no raw AdMob SDK | No (future) | **Phase 4.20 plan (official APIs confirmed):** Full-screen/reward: `loadFullScreenAd()` → `showFullScreenAd()` (IntegratedAd v2, **min Toss v5.247.0**; AdMob fallback v5.227.0). Banner: `TossAds.initialize()` → `TossAds.attachBanner()` (**min Toss v5.241.0**; width 100%; height 96px fixed or 410px feed). All wrappers require `isSupported()` check. Test IDs: `ait-ad-test-interstitial-id`, `ait-ad-test-banner-id`, `ait-ad-test-rewarded-id`. All calls via `JavaScriptBridge` in PlatformBridge — no binary SDK added to Godot bundle. | Code review + runtime QA on Toss device | `[ ]` |

---

## D. Feature-Specific — Share Reward

> **Out of scope for MVP unless share feature is enabled later.**

| ID | Requirement | Applies to MVP? | Planned Approach | Validation Method | Status |
|----|-------------|----------------|------------------|-------------------|--------|
| SR-01 | Share action uses platform share sheet | No (future) | PlatformBridge `share(text, url)` stub | Test share sheet opens | `[ ]` |
| SR-02 | Reward granted only after confirmed share | No (future) | Callback confirmation before granting reward | Mock share callback test | `[ ]` |
| SR-03 | Share content complies with Toss content policy | No (future) | Review share text/image before enabling | Content review | `[ ]` |

---

## E. Feature-Specific — Webboard

> **Out of scope for MVP unless webboard integration is required.**

| ID | Requirement | Applies to MVP? | Planned Approach | Validation Method | Status |
|----|-------------|----------------|------------------|-------------------|--------|
| WB-01 | Webboard post/read flows work inside mini app | No (future) | PlatformBridge webboard API stubs | Integration test when enabled | `[ ]` |
| WB-02 | User authentication passed to webboard | No (future) | User ID from C-21 forwarded | Auth flow test | `[ ]` |

---

## F. Feature-Specific — Game Center / User Key

> **Required later as a separate platform pass.**

| ID | Requirement | Applies to MVP? | Planned Approach | Validation Method | Status |
|----|-------------|----------------|------------------|-------------------|--------|
| GC-01 | Score submission uses `submitGameCenterLeaderBoardScore` | No (future) | **Phase 4.19 done:** `PlatformBridge.submit_leaderboard_score(total_progress)` called in `game_root._on_game_over()` and `_on_max_level_cleared()`; score passed as numeric string; handles `NO_BRIDGE`, `UNSUPPORTED_VERSION`, `EXCEPTION`; emits `leaderboard_score_submitted(bool)` | Toss sandbox leaderboard test | `[~]` |
| GC-02 | Leaderboard opening uses `openGameCenterLeaderboard` and preserves game state | No (future) | **Phase 4.19 done:** `PlatformBridge.open_leaderboard()` implemented; C-27 `_paused_for_background` flag ensures tree is frozen when miniapp backgrounds and restored on return; UI trigger button to be wired in scene editor when added | Open/close leaderboard during test run | `[~]` |
| GC-03 | Duplicate submit for same run is prevented | No (future) | **Phase 4.19 done:** `_score_submitted_this_run` flag in `PlatformBridge`; set to `true` on first submit, reset to `false` via `_on_game_started()` on `GameState.game_started` signal | Retry / duplicate-tap test | `[~]` |
| GC-04 | Network failure / retry path handled gracefully | No (future) | Structured: `submit_leaderboard_score` catches exceptions and emits `leaderboard_score_submitted(false)` without crashing; does not block game-over screen; retry strategy deferred to future pass | Force failure / retry test | `[~]` |
| GC-05 | Game-specific user key uses `getUserKeyForGame` with version/error handling | No (future) | **Phase 4.19 done:** see C-21 above; full error handling for all documented result cases | Toss sandbox/device test | `[~]` |

---

## G. Resource / Legal — Audio

> **Required before release if audio assets are shipped.**

| ID | Requirement | Applies to MVP? | Planned Approach | Validation Method | Status |
|----|-------------|----------------|------------------|-------------------|--------|
| AU-01 | All shipped BGM/SFX have saved license proof | Yes (future release) | Store evidence under `docs/legal/music_licenses/` | Manual legal audit | `[ ]` |
| AU-02 | Audio license covers commercial app/game distribution and ad-supported use | Yes (future release) | Verify license terms before import | Manual legal audit | `[ ]` |
| AU-03 | Audio resource manifest exists | Yes (future release) | Track final BGM/SFX/stems/variants in one manifest | Manifest review | `[ ]` |
| AU-04 | Raw source audio files are excluded from release bundle | Yes (future release) | Keep source masters outside shipped `.ait` | Archive contents audit | `[ ]` |

---

## H. Packaging / Bundle Size

> **Required before upload to Toss.**

| ID | Requirement | Applies to MVP? | Planned Approach | Validation Method | Status |
|----|-------------|----------------|------------------|-------------------|--------|
| PKG-01 | Uploaded `.ait` is <= 100MB after decompression | Yes | **Session 41 dry run: 36.40 MB.** Main contributor is Godot Web engine `.wasm` (36 MB) — this is the GL Compatibility renderer baseline. Game assets (`.pck`: 110 KB) are negligible. 63.6 MB headroom remains before hitting the limit. | Decompress and `du -sh` after each export | `[~]` |
| PKG-02 | Large resources are optimized or lazy-loaded if they threaten the bundle limit | Yes | Current `.wasm` is 36 MB (Godot GL Compatibility Web engine — expected). Game `.pck` is only 110 KB (no audio/art assets yet). No optimization needed at this size. Will need recheck after audio/art assets are added. | Compare bundle size before/after resource pass | `[~]` |
| PKG-03 | Bundle audit rerun after each SDK/resource pass | Yes | Treat bundle size as a standing release gate | Checklist sign-off per pass | `[ ]` |

---

## I. Crash Monitoring

> **Recommended before release; not a hard Toss policy requirement but reduces post-launch risk.**

| ID | Requirement | Applies to MVP? | Planned Approach | Validation Method | Status |
|----|-------------|----------------|------------------|-------------------|--------|
| CM-01 | Crash / unhandled error reporting integrated before release | Recommended | Integrate Sentry JS SDK (or equivalent) into the Godot HTML5 export shell; capture uncaught exceptions and Godot-level crashes; send to a monitored project | Trigger a forced error in QA build; confirm event appears in dashboard | `[ ]` |

---

## J. Toss Environment / API Version Validation

> **Required before public submission.** The Toss QR private-test flow is the only way to confirm the miniapp works inside the real Toss app shell before review.

| ID | Requirement | Applies to MVP? | Planned Approach | Validation Method | Status |
|----|-------------|----------------|------------------|-------------------|--------|
| TQA-01 | Game tested end-to-end via Toss QR code (private test mode) before public submission | Yes | Generate QR from Toss dev console → scan from supported Toss app on real device → complete full gameplay loop including game-over, save, and leaderboard stub | Full gameplay walkthrough on device in private-test mode; confirm no blank screen, crash, or policy violation | `[ ]` |
| TQA-02 | Minimum Toss app version gates confirmed for all platform APIs used | Yes | **Phase 4.19 done (structural):** `MIN_VERSION_LEADERBOARD = "5.221.0"` and `MIN_VERSION_USER_KEY = "5.232.0"` constants in `PlatformBridge`; all three API wrappers detect `undefined` return (= unsupported version) and degrade gracefully with `push_warning` + signal; no crash on old versions; **Toss-device runtime confirmation still required** | Test on a device running a version below each threshold; confirm graceful fallback | `[~]` |
| TQA-03 | No CORS or external-network errors in console during Toss-hosted session | Yes | Game assets should be self-contained in the `.ait` bundle; if a CDN or external API is introduced later, its origin must be added to the App-in-Toss allowed-origin policy | Check browser/Toss console during private test for CORS errors or unexpected network calls | `[ ]` |

---

## K. Game-Specific Items — Not in Standard Non-Game Skill Checklist

> Items in this section are specific to games published on App-in-Toss. They are not covered by the standard non-game miniapp checklist skill.

| ID | Requirement | Applies to MVP? | Planned Approach | Validation Method | Status |
|----|-------------|----------------|------------------|-------------------|--------|
| GM-01 | Score submitted only at run completion (game-over or max-level-clear), never mid-run | Yes | **Phase 4.19 done:** `PlatformBridge.submit_leaderboard_score()` called only in `game_root._on_game_over()` and `_on_max_level_cleared()`; no mid-run call sites | Code review: search for all `submitGameCenterLeaderBoardScore` call sites | `[x]` |
| GM-02 | Duplicate score submission prevented within the same completed run | Yes | **Phase 4.19 done:** `_score_submitted_this_run` flag in `PlatformBridge`; reset on `GameState.game_started` | Double-tap / rapid-restart test on game-over screen | `[~]` |
| GM-03 | Leaderboard open/close preserves full game state and save | Yes | **Phase 4.19 done (structural):** `open_leaderboard()` implemented; C-27 `_paused_for_background` flag freezes game tree when miniapp backgrounds; state preserved on return; UI button not yet in scene (requires editor pass) | Open leaderboard mid-session; close; verify state unchanged | `[~]` |
| GM-04 | Max Level 100 clear rule defined and runtime cap implemented | Yes | **Phase 4.18 done:** Level 100 K1000 → `trigger_max_level_clear()`; `total_progress` caps at 100000; score submitted at max clear; headless QA 47/47 passed | Headless smoke test for Level 100 K1000 crossing | `[x]` |
| GM-05 | Portrait orientation enforced and not overrideable by device auto-rotate | Yes | `DisplayServer.screen_set_orientation(SCREEN_PORTRAIT)` on native; `export_presets.cfg` sets `progressive_web_app/orientation=1` (portrait) for documentation; actual WebView orientation lock is owned by App-in-Toss container; runtime lock via PlatformBridge still primary; validate on iOS and Android | Rotate device in all four directions during gameplay; confirm UI does not flip | `[~]` |
| GM-06 | All gameplay UI elements remain within safe area on all target devices | Yes | `SafeAreaContainer` applies `DisplayServer.get_display_safe_area()` insets to HUD, joystick, skill bar; validate on Dynamic Island iPhone and Android with gesture bar | Visual inspection on physical device | `[~]` |

---

## Notes on Skill Checklist Items Not Applicable to This Game

The Claude Code App-in-Toss checklist skill (`appsintoss-nongame-launch-checklist-by-robin`) is designed for **non-game** web/React-Native miniapps. The following stages from that skill are **not applicable** to this Godot native game:

| Skill Stage | Reason Not Applicable |
|-------------|----------------------|
| Stage 2: Navigation Bar (web `navigationBar` config) | Godot native game has no web navigation bar component; back gesture is handled by `PlatformBridge` → C-16/C-20 |
| Stage 3: Toss OAuth Login (`appLogin`, AccessToken, RefreshToken) | Game uses `getUserKeyForGame` (C-21/GC-05), not user-facing Toss login |
| Stage 10: TDS Design System (`@toss/tds-mobile`, etc.) | TDS is a React Native / Web framework package; Godot game uses custom Godot UI |
| Stage 11: Share Reward (`getTossShareLink`) | No share feature in this game for MVP |
| IAP Stage 7 / TossPay | No payment for MVP; covered as out-of-scope in Section B |

Items from skill Stages 1, 4, 5, 6, 8, 9 **do apply** and are incorporated into this checklist.

---

## Validation Sign-Off

Before submitting to Toss review:
1. All `C-*` rows must be `[x]`.
2. All `GM-*` rows relevant to the submitted build must be `[x]`.
3. `TQA-01` and `TQA-02` must be `[x]`.
4. Run on physical iPhone (latest iOS) and mid-range Android.
5. Run Lighthouse audit on exported HTML5 build.
6. Record a full screen-capture walkthrough covering every checklist item.
