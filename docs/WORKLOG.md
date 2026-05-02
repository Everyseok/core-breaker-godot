# Work Log — game_junseokism.ver1

Entries are append-only. Most recent at top.

---

## 2026-05-01 — Session 42: Phase 4.20 — Ads Integration Planning (docs only, no code)

**Outcome: Official App-in-Toss ad APIs confirmed. Placement policy locked. Prerequisites documented. No code implemented.**

### Official docs checked

| Doc URL | Key finding |
|---------|-------------|
| developers-apps-in-toss.toss.im/ads/intro.md | Three formats supported: full-screen, reward, banner. Recommended to combine all three. |
| developers-apps-in-toss.toss.im/ads/console.md | Prerequisites: business registration → terms → settlement → ad group creation (~2–3 business day settlement review). |
| developers-apps-in-toss.toss.im/ads/develop.md | Prohibited placements: active gameplay, loading, modal dialogs, game UI overlap, payment flows, tutorials. Test ad IDs provided. |
| developers-apps-in-toss.toss.im/ads/qa.md | QA requirements: preload before show; audio pause/resume during ad; frequency limits + cooldown; non-blocking failure handling; real device recommended. |
| developers-apps-in-toss.toss.im/bedrock/reference/framework/광고/IntegratedAd.md | APIs: `loadFullScreenAd()` → `showFullScreenAd()`. Events: requested, show, impression, clicked, dismissed, failedToShow, userEarnedReward. Min version: v5.247.0 (full v2); v5.227.0 (AdMob fallback). `isSupported()` required. |
| developers-apps-in-toss.toss.im/bedrock/reference/framework/광고/BannerAd.md | APIs: `TossAds.initialize()` → `TossAds.attachBanner()` → `TossAds.destroyAll()`. Min version: **v5.241.0**. Width: 100%; Height: 96px (fixed/list) or 410px (feed). Theme/tone/variant options. |

### Official-vs-skill-vs-engineering basis

| Decision | Basis |
|----------|-------|
| IntegratedAd v2 (`loadFullScreenAd`/`showFullScreenAd`) as the full-screen API | **Official** — IntegratedAd.md |
| BannerAd (`TossAds.attachBanner`) as the banner API | **Official** — BannerAd.md |
| Min version v5.247.0 for IntegratedAd v2 | **Official** — IntegratedAd.md |
| Min version v5.241.0 for BannerAd | **Official** — BannerAd.md |
| Business registration + settlement required before ad group creation | **Official** — ads/console.md |
| Modal dialogs are prohibited ad placement (PauseMenu excluded) | **Official** — ads/develop.md |
| Active gameplay, loading, tutorial, game UI overlap are prohibited | **Official** — ads/develop.md |
| Audio must pause during full-screen ad, resume on dismissed/failedToShow | **Official** — ads/qa.md |
| Frequency limit + cooldown required | **Official** — ads/qa.md |
| Preload before show | **Official** — ads/qa.md |
| Ad failure must not block gameplay or restart | **Official spirit** (non-blocking requirement) + **Engineering** |
| Banner height 96px, width 100% | **Official** — BannerAd.md |
| Interstitial at game-over / max-clear / between-run | **Official** placement rules + **Engineering** mapping to current GameState signals |
| Banner at bottom (below joystick/skill bar) | **Engineering** candidate — subject to device QA; no official position specified |
| Pause-screen interstitial is policy-risky | **Official** (modal prohibition) |

### Placement decisions locked

**Interstitial trigger points:**
- `GameState.game_over` signal → preload interstitial, show on game-over result screen
- `GameState.max_level_cleared` signal → show on max-clear result screen
- Between-run on restart tap (before new run starts)
- Frequency limit + cooldown (exact values to be confirmed in Phase 4.21)

**Interstitial exclusions (official prohibited):**
- Active gameplay → PROHIBITED
- Loading / intro → PROHIBITED
- PauseMenu (modal) → PROHIBITED; **pause-screen ad is explicitly excluded from plan**
- Game UI overlap → PROHIBITED

**Banner candidate:** 96px fixed at bottom of screen, below joystick + skill bar, inside safe area. Must not overlap gameplay controls. Requires device QA validation before finalizing.

### Ad failure behavior plan

- `loadFullScreenAd` failure → skip show; proceed to game-over/restart normally
- `showFullScreenAd failedToShow` → call `AudioManager.restore_mute_state()`; proceed normally
- BannerAd failure → hide banner container; no empty frame
- No game action gated on ad success

### Audio plan (official QA requirement)

- `AudioManager.mute_all()` immediately before `showFullScreenAd()`
- `AudioManager.restore_mute_state()` on `dismissed` or `failedToShow`
- Banner: no audio change required

### Bundle size impact

- Ad SDKs (IntegratedAd v2, BannerAd) are part of Toss WebView shell — NOT added to Godot `.pck` or `.wasm`
- PlatformBridge ad implementation adds only GDScript (~1 KB)
- Ad images loaded at runtime from Toss ad servers — not in bundle
- Rerun export audit after Phase 4.21 implementation to confirm

### PlatformBridge current state

- `show_ad(_ad_unit: String) -> void: pass` — stub exists (AD-01)
- Phase 4.21 will expand to: `preload_interstitial_ad()`, `show_interstitial_ad()`, banner attach/detach, version gates, audio hooks, signals

### Prerequisites for Phase 4.21 (BLOCKED)

1. Business registration in Toss console
2. Terms agreement
3. Settlement banking info (~2–3 business day review)
4. Ad group creation (IDs take ~2h to register with Google)

**Files changed this session:**
- `docs/00_product_spec.md` — section 9.3 expanded with official API details, placement rules, version requirements
- `docs/01_toss_release_checklist.md` — AD-01 through AD-06 updated with official findings and locked plan
- `docs/03_implementation_plan.md` — Phase 4.20 marked done; Phase 4.21 added (blocked)
- `docs/NEXT_STEP.md` — fully rewritten for Phase 4.21 blocked state
- `docs/STATUS.md` — ads row updated
- `docs/WORKLOG.md` — this entry
- `data/dev_status.json` — session 42, phase updated

**No gameplay code changed. No ad SDK added. No code changed.**

---

## 2026-05-01 — Session 40: Web Export Dry Run — Blocked: Export Templates Not Installed

**Outcome: Export blocked by missing Godot 4.6.2 Web export templates. No bundle produced. No gameplay change.**

**What was attempted:**

- Checked `~/Library/Application Support/Godot/export_templates/` — directory exists but is empty.
- Ran `godot --headless --export-release "Toss Web"` to confirm exact error.

**Exact Godot error:**

```
ERROR: Cannot export project with preset "Toss Web" due to configuration errors:
Missing export template:
  ~/Library/Application Support/Godot/export_templates/4.6.2.stable/web_nothreads_debug.zip
Missing export template:
  ~/Library/Application Support/Godot/export_templates/4.6.2.stable/web_nothreads_release.zip
ERROR: Project export for preset "Toss Web" failed.
```

**Root cause:** Godot 4.6.2 Web export templates were never downloaded on this machine.

**How to unblock:**

Option A — Godot editor (recommended):
1. Open project in Godot editor.
2. `Editor → Manage Export Templates → Download and Install`.
3. Select version `4.6.2.stable` → download.

Option B — Manual install:
1. Download `Godot_v4.6.2-stable_export_templates.tpz` from https://godotengine.org/download/archive/
2. Rename to `.zip` and extract; move the two files:
   - `web_nothreads_debug.zip`
   - `web_nothreads_release.zip`
   into `~/Library/Application Support/Godot/export_templates/4.6.2.stable/`.

**After templates are installed, re-run:**

```bash
mkdir -p /Volumes/junseokism_usb3.0/game/game_junseokism.ver1/exports/toss_web_dry_run
"/Users/junseokism/Downloads/Godot.app/Contents/MacOS/Godot" \
  --headless \
  --export-release "Toss Web" \
  /Volumes/junseokism_usb3.0/game/game_junseokism.ver1/exports/toss_web_dry_run/index.html \
  --path /Volumes/junseokism_usb3.0/game/game_junseokism.ver1
```

**Then audit:**
- Total unpacked size: `du -sh exports/toss_web_dry_run/`
- Top 30 files: `find exports/toss_web_dry_run -type f | xargs du -sh | sort -rh | head -30`
- Inspect generated `index.html` for `user-scalable=no`, `touch-action:none`, `overscroll-behavior:none`
- Confirm no duplicate viewport metas or stale `res://` refs

**Files changed this session:** docs only (WORKLOG, STATUS, NEXT_STEP, 03_implementation_plan, dev_status.json)

---

## 2026-05-01 — Session 41: Official App-in-Toss Benchmark Pass — Templates Installed + Web Export Dry Run

**Outcome: Godot 4.6.2 Web export templates installed from official GitHub release. Web export dry run produced. 36.40 MB (100MB limit: PASS). No gameplay change.**

### Task A — Template Verification

Templates were MISSING:
```
~/Library/Application Support/Godot/export_templates/4.6.2.stable/  (empty)
```

### Task B — Template Install

Downloaded `Godot_v4.6.2-stable_export_templates.tpz` from official GitHub release:
```
https://github.com/godotengine/godot/releases/download/4.6.2-stable/Godot_v4.6.2-stable_export_templates.tpz
```
(1.2 GB, official Godot Engine release, sha matches GitHub release page)

Extracted `web_nothreads_debug.zip` (9.6 MB) and `web_nothreads_release.zip` (9.1 MB) from the `.tpz` archive and copied to:
```
~/Library/Application Support/Godot/export_templates/4.6.2.stable/
```
Both files confirmed present.

### Task C — Web Export Dry Run

Command:
```bash
"/Users/junseokism/Downloads/Godot.app/Contents/MacOS/Godot" \
  --headless --export-release "Toss Web" \
  /Volumes/junseokism_usb3.0/game/game_junseokism.ver1/exports/toss_web_dry_run/index.html \
  --path /Volumes/junseokism_usb3.0/game/game_junseokism.ver1
```

Result: SUCCESS. Export output:
```
exports/toss_web_dry_run/
  index.html              5.5 KB
  index.js              308 KB
  index.pck             110 KB
  index.wasm             36 MB
  index.png              21 KB
  index.audio.worklet.js   7.1 KB
  index.audio.position.worklet.js  2.9 KB
  index.icon.png           3.6 KB
  index.apple-touch-icon.png  7.5 KB
```

The case-mismatch WARNINGs (junseokism_usb3.0 vs JUNSEOKISM_USB3.0) are harmless — USB drive uses uppercase filesystem name; export contents are correct.

### Task D — Bundle Size / Hygiene Audit

**Total unpacked size: 36.40 MB → PASS (limit: 100 MB official)**

| File | Size |
|------|------|
| index.wasm | 36 MB |
| index.js | 308 KB |
| index.pck | 110 KB |
| index.png | 21 KB |
| index.html | 5.5 KB |
| Other (audio worklets, icons) | ~20 KB |

**Hygiene: CLEAN.** Export folder contains no `.git/`, `.godot/`, `.gd`, `.tscn`, `docs/`, `.wav`, `.psd`, `.aseprite`, or source files.

**Minor hygiene note:** Three `.import` files appear in the export output directory:
- `index.apple-touch-icon.png.import`
- `index.icon.png.import`
- `index.png.import`

These are Godot editor import-tracking metadata files. They are not game assets and should be excluded from the `.ait` bundle (confirm during `.ait` packaging step).

**Minor hygiene note:** `data/dev_status.json` was packed into `index.pck` (it's under `res://data/`). This is a dev-status doc file, not a runtime game resource. It wastes ~2 KB in the bundle. To exclude it, add a per-file export filter in `export_presets.cfg` for `data/dev_status.json`. Not urgent at current bundle size, but worth fixing before submission.

### Task E — Generated HTML Audit

**Key finding: Godot 4.6.2's default HTML shell already includes `user-scalable=no` and `touch-action:none`.**

```html
<!-- Line 5: Godot default shell viewport -->
<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0">

<!-- Lines 14-19: Godot default shell body CSS -->
body {
	overflow: hidden;
	touch-action: none;
}

<!-- Line 95: our html/head_include injection -->
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<style>canvas{touch-action:none}html,body{overscroll-behavior:none;margin:0;padding:0}</style>
```

| Check | Present | Notes |
|-------|---------|-------|
| `user-scalable=no` | YES | In Godot default shell (line 5) AND our head_include (line 95) |
| `maximum-scale=1.0` | YES | Only in our head_include (not in Godot default shell) |
| `initial-scale=1.0` | YES | Both |
| `touch-action:none` on body | YES | Godot default shell has `body { touch-action: none }` |
| `canvas{touch-action:none}` | YES | Our head_include adds canvas-specific rule |
| `overscroll-behavior:none` | YES | Our head_include only (not in Godot default shell) |
| Duplicate viewport metas | YES — two | Line 5 (Godot default) + line 95 (our head_include). Browsers use last one (standard). Ours wins and is stricter. |

**Conclusion:** C-26 pinch-zoom is structurally addressed from two layers:
1. Godot 4.6.2 default HTML shell already provides `user-scalable=no` and `body { touch-action:none }`.
2. Our `head_include` reinforces this and adds `maximum-scale=1.0` and `overscroll-behavior:none`.

The documented "duplicate viewport meta" risk from Session 39 is benign — both tags say `user-scalable=no`, the browser uses the last one (ours). The `custom_html_shell` fallback is not needed.

### Task F — Official Doc Cross-Check Matrix

Official source: `https://developers-apps-in-toss.toss.im/`

| Requirement | Official Source URL | Current Status | Result | Basis |
|------------|--------------------|--------------|----|-------|
| 100MB decompressed limit | developers-apps-in-toss.toss.im/development/deploy.md | 36.4 MB dry run | **PASS** | Official |
| QR/private test (min 1 before review button activates) | developers-apps-in-toss.toss.im/development/deploy.md | Not done — needs .ait upload first | **MISSING** | Official |
| Review request (after 1+ test) | developers-apps-in-toss.toss.im/development/deploy.md | Not done | **MISSING** | Official |
| getUserKeyForGame (min Toss v5.232.0) | developers-apps-in-toss.toss.im/bedrock/reference/framework/게임/getUserKeyForGame.md | Structurally wired; Toss-device unconfirmed | **PARTIAL** | Official |
| submitGameCenterLeaderBoardScore (min Toss v5.221.0) | developers-apps-in-toss.toss.im/bedrock/reference/framework/게임/submitGameCenterLeaderBoardScore.md | Structurally wired; Toss-device unconfirmed | **PARTIAL** | Official |
| openGameCenterLeaderboard | developers-apps-in-toss.toss.im/game-center/develop.md | Structurally wired; UI button needs scene editor pass | **PARTIAL** | Official |
| C-26 pinch-zoom disabled | developers-apps-in-toss.toss.im/checklist/app-game.md (game checklist) | Godot default HTML shell already provides `user-scalable=no` + `touch-action:none`; head_include adds `maximum-scale=1.0` + `overscroll-behavior:none`; confirmed in generated HTML; device test pending | **PARTIAL** (structural pass, device TBD) | Official checklist item; Godot default shell + head_include (engineering) |
| C-25/C-28 console registration (name, icon, scheme) | developers-apps-in-toss.toss.im/development/deploy.md | Not done — console access required | **MISSING** | Official |
| C-27 background game-tree pause | Official game requirement | `on_visibility_hidden → get_tree().paused=true` wired; device-unconfirmed | **PARTIAL** | Official |
| CORS/network policy | developers-apps-in-toss.toss.im/development/deploy.md | No external calls in current build | **N/A** | Official (only if external calls added) |
| Sentry/crash monitoring | developers-apps-in-toss.toss.im/learn-more/sentry-monitoring.md | Not integrated | **FUTURE** | Optional per official guide |
| Ads (IntegratedAd v2) | developers-apps-in-toss.toss.im/ads/develop.md | Not implemented; deferred | **DEFERRED** | Official; intentionally not yet started |

### Official docs confirmed
- 100MB limit: **official** — `deploy.md` ("앱 번들은 압축 해제 기준 100MB 이하만 업로드할 수 있어요")
- QR test required before review: **official** — `deploy.md` ("테스트를 최소 1회 이상 완료해야 검토 요청을 진행할 수 있어요")
- getUserKeyForGame min version 5.232.0: **official** — `getUserKeyForGame.md`
- submitGameCenterLeaderBoardScore min version 5.221.0: **official** — `submitGameCenterLeaderBoardScore.md`
- Sentry: **optional** per official guide; not a hard requirement
- Pinch-zoom disabling: **official checklist item** (app-game.md); implementation method (meta tags/CSS) is engineering/best-practice, not Toss-prescribed

**Files changed:**
- `docs/WORKLOG.md` (this entry)
- `docs/01_toss_release_checklist.md` — C-23, C-24, PKG-01, PKG-02 status updated
- `docs/NEXT_STEP.md` — updated
- `docs/STATUS.md` — updated
- `data/dev_status.json` — session 41, phase updated

**No gameplay code changed.**

---

## 2026-05-01 — Session 39: Phase 4.19c — C-26 HTML Export Shell / Pinch-Zoom Pass

**export_presets.cfg created. Static QA: 27/27 passed. No gameplay change.**

**Requirement source:** App-in-Toss submission checklist Stage 5 (`확대/축소 핀치줌이 비활성화되어 있는가?`) + project's own C-26 checklist item. Confirmed official requirement. Implementation approach (meta tag format, CSS) is web best-practice convention, not Toss-specified exact code.

**What was done:**
- No `export_presets.cfg` existed previously; no HTML template existed.
- Created `export_presets.cfg` with Godot 4.6 "Toss Web" Web export preset.
- `html/head_include` injects:
  - `<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">` — disables pinch-zoom (C-26).
  - `canvas{touch-action:none}` — routes all touch events to Godot; prevents browser scroll/zoom on the canvas.
  - `html,body{overscroll-behavior:none;margin:0;padding:0}` — disables elastic overscroll on iOS/Android.
- `html/canvas_resize_policy=2` (Adaptive) — canvas fills the WebView; works with `stretch/mode=canvas_items`.
- `html/focus_canvas_on_start=true` — canvas gets focus immediately on load.
- `html/custom_html_shell=""` — uses Godot's default HTML shell; head_include is injected after it.
- `progressive_web_app/enabled=false` — PWA not used for `.ait`; `orientation=1` (portrait) set for documentation.
- `export_path=""` — export path intentionally empty; prevents accidental export.

**Known limitation:**
- Godot 4.6's default HTML shell may already include a `<meta name="viewport">`. If so, there will be two viewport meta tags. Browsers use the last one (standard behavior), and our tag is injected via `$GODOT_HEAD_INCLUDE` (typically at end of `<head>`), so the stricter setting should win. If Toss QA finds duplicate metas cause issues, switch to `html/custom_html_shell` pointing to a copy of Godot's default template with the meta replaced directly.

**Files changed:**
- `export_presets.cfg` (NEW) — Godot 4.6 Web export preset with viewport/touch CSS
- `docs/01_toss_release_checklist.md` — C-26 `[ ]` → `[~]`; GM-05 note updated
- `docs/03_implementation_plan.md` — Phase 4.19c row added
- `docs/NEXT_STEP.md` — C-26 item updated
- `docs/STATUS.md` — phase updated
- `data/dev_status.json` — session 39, phase updated

**No gameplay code changed.**

---

## 2026-05-01 — Session 38: Phase 4.19b Bugfix — Start Game Button Not Responding

**Bugfix for reported "Start Game does nothing". Headless QA: 23/23 passed.**

**Root causes (two separate bugs):**
1. `Background` ColorRect in `scenes/ui/root_ui.tscn` had `mouse_filter = 0` (MOUSE_FILTER_STOP).
   A full-screen decorative background with STOP intercepts touch/mouse events before they reach
   the sibling StartButton and RankingButton in Godot 4.6.x's GUI input routing.
   Fix: changed to `mouse_filter = 2` (MOUSE_FILTER_IGNORE).
2. `MainMenu` Control node had no `process_mode` set (default = INHERIT).
   On Web/Toss, `PlatformBridge.on_visibility_hidden()` calls `get_tree().paused = true` on
   background. With INHERIT, MainMenu would be paused and buttons would not receive input.
   Fix: added `process_mode = 3` (ALWAYS) to MainMenu in the tscn.

**Files changed:**
- `scenes/ui/root_ui.tscn`:
  - `[node name="Background" parent="MainMenu"]`: `mouse_filter = 0` → `mouse_filter = 2`
  - `[node name="MainMenu"]`: added `process_mode = 3`

**No logic changes. No regressions confirmed.**

---

## 2026-04-30 — Session 37: Phase 4.19b — Main Menu Start Flow + Leaderboard Button

**Phase 4.19b implemented. Headless QA: 45/45 passed.**

**Files changed (code):**
- `scripts/gameplay/game_root.gd`:
  - Removed `_start_game()` auto-call from `_ready()`; added `add_to_group("game_root")`
  - Renamed private `_start_game()` to public `start_game()` with full cleanup (stop spawner, clear bricks/projectiles, reset danger, then `GameState.start_run()` + `_ring_spawner.start()`)
- `scripts/ui/main_menu.gd` (NEW):
  - `extends Control`; shown `visible = true` on `_ready()`
  - `_best_label` reads `SaveManager.get_best_k()` on ready
  - `_on_start_pressed()`: group lookup `"game_root"` → `roots[0].start_game()`; hides self
  - `_on_ranking_pressed()`: calls `PlatformBridge.open_leaderboard()`
  - `_on_game_started()`: hides self (connected to `GameState.game_started`)
- `scenes/ui/root_ui.tscn`:
  - `load_steps` bumped from `8` → `9`
  - Added `ext_resource id="8_mm"` for `main_menu.gd`
  - Added `MainMenu` Control node as last child of CanvasLayer (renders on top of all gameplay/overlay nodes) with Background ColorRect, TitleLabel, BestLabel, StartButton, RankingButton
- `scripts/ui/game_over_screen.gd`: `_on_restart_pressed()` now uses group-based `start_game()` with `reload_current_scene()` fallback; `visible = false` before calling
- `scripts/ui/pause_menu.gd`: `_restart()` now uses group-based `start_game()` with `reload_current_scene()` fallback; `get_tree().paused = false` and `visible = false` before calling

**Files changed (docs):**
- `docs/NEXT_STEP.md`: updated to reflect Phase 4.19b complete; Phase 4.20 (Ads) is next
- `docs/STATUS.md`: phase and roadmap updated
- `data/dev_status.json`: session → 37, phase/task/next_step updated

---

## 2026-04-30 — Session 36: Phase 4.19 — Game Center + getUserKeyForGame Platform Pass

**Phase 4.19 implemented. Headless QA: 61/61 passed. Toss-shell unverified.**

**Files changed (code):**
- `scripts/autoload/platform_bridge.gd`:
  - Added `MIN_VERSION_LEADERBOARD = "5.221.0"`, `MIN_VERSION_USER_KEY = "5.232.0"` constants (TQA-02)
  - Added signals: `game_user_key_received`, `game_user_key_failed`, `leaderboard_score_submitted`
  - Added `_score_submitted_this_run: bool` (duplicate-submit guard) and `_paused_for_background: bool` (C-27 restore guard)
  - Connected `GameState.game_started → _on_game_started()` in `_ready()` to reset submission flag per run
  - `init_platform()`: now also calls `fetch_game_user_key()` on Web
  - `on_visibility_hidden()`: added `get_tree().paused = true` (C-27); `on_visibility_visible()`: added conditional unpause with `_paused_for_background` guard (preserves intentional manual pause)
  - Added `fetch_game_user_key()`: full result-case handling; persists hash via `SaveManager`; no-op on non-Web
  - Added `submit_leaderboard_score(total_progress: int)`: numeric-string score; duplicate guard; no crash; no-op on non-Web
  - Added `open_leaderboard()`: no-op on non-Web; C-27 handles state preservation; UI button pending editor pass
  - Added `_on_game_started()`: resets `_score_submitted_this_run = false`
- `scripts/autoload/save_manager.gd`: added `set_game_user_key()` / `get_game_user_key()`
- `scripts/gameplay/game_root.gd`: `_on_game_over()` and `_on_max_level_cleared()` each call `PlatformBridge.submit_leaderboard_score(GameState.total_progress)`

**Files changed (docs):**
- `docs/01_toss_release_checklist.md`: C-21, C-27, GC-01–GC-05, GM-01–GM-03, TQA-02 updated to `[~]` or `[x]`
- `docs/03_implementation_plan.md`: Phase 4.19 row marked implemented; Phase 4.19 section added
- `docs/NEXT_STEP.md`: updated to Phase 4.20
- `docs/STATUS.md`: phase updated; leaderboard/getUserKeyForGame/R-10/R-13 rows updated
- `data/dev_status.json`: session, phase, current_task updated

**Key limitations confirmed:**
- All Toss API calls are `JavaScriptBridge.eval()` wrappers — runtime behavior confirmed only in Godot headless (no Toss shell)
- `getUserKeyForGame` may return `INVALID_CATEGORY` until console registration (C-25/C-28) is complete
- Leaderboard open UI button requires a `.tscn` scene edit (Godot editor pass)

**QA script:** `/tmp/qa_phase_4_19.gd` — 61 assertions, 0 failures, Godot 4.6.2

---

## 2026-04-30 — Session 35: Phase 4.18 — Max Level 100 Runtime Cap

**Phase 4.18 implemented. Headless QA: 47/47 passed.**

**Files changed (code):**
- `scripts/autoload/game_state.gd`:
  - Added `const MAX_LEVEL: int = 100`
  - Added `signal max_level_cleared()`
  - Added `func trigger_max_level_clear()` — sets `is_playing = false`, persists result, emits signal
  - Modified `add_k()`: added `if not is_playing: return` guard; at K threshold, checks `current_level >= MAX_LEVEL` first — if so, caps `current_level_k = _level_size_k` and calls `trigger_max_level_clear()` instead of advancing level
  - Modified `get_progression_display_state()`: shows `"MAX CLEAR"` label at Level 100 instead of `"LEVEL 101"`
- `scripts/gameplay/game_root.gd`: connected `max_level_cleared → _on_max_level_cleared()` which stops spawner and resets danger
- `scripts/ui/game_over_screen.gd`: connected `max_level_cleared → _on_max_level_cleared()` which shows `"MAX LEVEL CLEAR!"` result

**Files changed (docs):**
- `docs/03_implementation_plan.md`: Phase 4.18 row marked implemented; Phase 4.18 section added with acceptance criteria (all checked)
- `docs/NEXT_STEP.md`: updated to Phase 4.19
- `docs/STATUS.md`: phase updated; max level cap row marked implemented; R-02 note extended
- `data/dev_status.json`: session, phase, current_task updated

**Key invariants confirmed by headless QA:**
- `current_level` never reaches 101
- `total_progress` at max clear == 100000
- `add_k()` after max clear is a no-op (`is_playing == false`)
- `trigger_game_over()` after max clear is a no-op (double-guard)
- Levels 1–99 still transition normally
- K500–999 tier 4 still active; Hybrid disabled
- `loop_length() == 1000` (no K1000+ active band)
- K0/K499/K500/K999 wall layers: 1/2/5/5 (correct)

**QA script:** `/tmp/qa_phase_4_18.gd` — 47 assertions, 0 failures, Godot 4.6.2

---

## 2026-04-30 — Session 34: Doc Stale Grep Cleanup Before Phase 4.18

**No gameplay code changed. Doc-only cleanup pass.**

**Files edited:**
- `docs/02_technical_architecture.md` — three targeted fixes:
  - Section 6.1: replaced stale "K 0-999 = LEVEL 1 / K 1000-1999 = LEVEL 2 / no second counter" with real `current_level`/`current_level_k`/`total_progress` runtime state description and K1000 level-loop rule
  - "Locked progression notes": replaced stale 5-shot at -24°/-12°/0°/+12°/+24° with 7-shot at -36°/-24°/-12°/0°/+12°/+24°/+36°; replaced "K 1000+ = Hybrid Siege" block with level-transition and Max Level 100 description
  - "Spec / runtime alignment note": removed "runtime may still lag" — runtime has caught up through Phase 4.17c
- `docs/03_implementation_plan.md` — three targeted fixes:
  - Phase 4.16 "What Remains True Right Now": marked superseded by Phase 4.17b (K1000 level-loop now implemented)
  - Phase 4.13 line ~397: K1000+ active wall band marked as superseded by Phase 4.17b
  - Phase 4.13 acceptance criteria: "5-shot siege" corrected to "7-shot siege"

**What was NOT changed:**
- WORKLOG historical entries (Sessions 1-33)
- Phase 4.9/4.10/4.11/4.12 historical Hybrid Siege mentions (explicitly historical)
- Phase 4.15 "K 0-999 = LEVEL 1" (labeled temporary placeholder in that section)

**Session result:** Docs now agree with runtime truth. Ready for Phase 4.18.

---

## 2026-04-30 — Session 33: App-in-Toss Release Checklist Audit Pass

**No gameplay code changed. This was a doc/compliance-only pass.**

**Skill inspection:**
- Claude Code skill `appsintoss-nongame-launch-checklist-by-robin` found under `~/.claude/skills/`
- Skill is a non-game web/React Native miniapp checklist (11 stages)
- Treated as supplemental and unofficial; game-inapplicable items explicitly excluded

**Skill stages applicable to this game:**
- Stage 1 (access/scheme), Stage 4 (scheme/routing), Stage 5 (UI/UX), Stage 6 (branding), Stage 8 (ads), Stage 9 (external link policy) — all applied

**Skill stages explicitly not applicable:**
- Stage 2: Navigation bar web component (Godot native uses PlatformBridge back gesture, not `@apps-in-toss/web-framework` nav)
- Stage 3: Toss OAuth login (game uses `getUserKeyForGame`, not OAuth login flow)
- Stage 10: TDS design system (React Native / Web only; game uses custom Godot UI)
- Stage 11: Share reward (no share feature in this game)

**New checklist items added to `docs/01_toss_release_checklist.md`:**
- C-25: App name and icon match Toss console registration (new)
- C-26: Pinch-zoom disabled on all game screens (new — HTML export `user-scalable=no`)
- C-27: Game simulation loop pauses on background, not only audio mute (new — R-10 risk)
- C-28: Toss console scheme URL registered and validated (new — pre-submission gate)
- AD-06: Use Toss IntegratedAd v2 API exclusively (new — not raw AdMob SDK)
- Section I: Crash monitoring (CM-01) — new section
- Section J: Toss environment / API version validation (TQA-01, TQA-02, TQA-03) — new section
- Section K: Game-specific items not in non-game skill (GM-01 through GM-06) — new section
- Notes section: Explicit list of skill items not applicable to Godot native game
- Updated sign-off: now requires all GM-* and TQA-01/02 as well as C-*

**New risks added to `docs/STATUS.md`:**
- R-10: Game tree pause on background (C-27) not confirmed wired
- R-11: Pinch-zoom not explicitly disabled in HTML template (C-26)
- R-12: Toss console registration (app name, icon, scheme) not done — submission blocked
- R-13: Minimum Toss app version gating not implemented in PlatformBridge
- R-14: No crash monitoring integrated

**`docs/NEXT_STEP.md`** updated to Phase 4.18 (Max Level 100 cap) with compliance sub-tasks.

---

## 2026-04-30 — Session 32: Ring Rotation Jitter Fix (Compaction Angle-Continuity)

**Root cause diagnosed:**
- `_rebuild_bricks()` unconditionally cleared `_angles[]` and recomputed it as a fresh uniform `i * TAU / new_n` distribution on every compaction event.
- With `SEGMENT_SIZE = 28` and `shrink_speed = 30`, compaction fires every `28 / (TAU * 30) ≈ 0.149 s` (≈9 frames at 60 fps).
- Each compaction caused angular jumps of up to `TAU / old_n ≈ 5.7°` per brick — equivalent to 13 frames of rotation appearing instantly. Different segments jumped by different amounts (some ~0°, some ~5.7°), creating the visible clockwise/counterclockwise stutter.
- `_rotation_offset` was already monotonically preserved through compaction, so the problem was entirely in base-angle recalculation, not in the rotation phase itself.

**Fix applied — `scripts/gameplay/ring_instance.gd` only:**
1. Added `_build_initial_angles(count) -> Array` helper that creates the uniform `i * TAU / count` distribution.
2. `_ready()` now initializes `_angles` via `_build_initial_angles` before calling `_rebuild_bricks()`.
3. `_rebuild_bricks()` no longer clears or recomputes `_angles`. It uses whatever is already set (with a safety fallback reinit if the array size mismatches).
4. `_retile_segments()` now computes `next_angles[]` from the OLD `_angles` using `ceili()`-based bucket boundaries and averaging the source angles in each bucket. This is set as `_angles = next_angles` before calling `_rebuild_bricks()`, preserving angular phase continuity through every compaction step.

**Effect:**
- Maximum per-segment angular displacement during compaction reduced from `TAU / old_n ≈ 5.7°` to `TAU / (2 * old_n) ≈ 2.9°`.
- Single-element buckets (the vast majority) have zero displacement.
- Only the one bucket-per-compaction that absorbs 2 source segments shows any displacement (~2.9°).
- The ring visually appears to rotate continuously with no jumps.

**No other files changed.** weapon.gd K500 7-shot and Overclock tuning untouched.

**Headless QA: 21/21 passed** (Godot 4.6.2):
- JSON parse: game_config.json, progression.json ✓
- segment_count_for_radius monotonically decreasing ✓
- New code: max per-segment displacement ≤ 2.9° ✓
- Old code baseline confirmed jumps > 2.9° (regression gate) ✓
- new angles monotonically increasing after compaction ✓
- Raw rotation phase never decreases over 300 frames ✓
- Position continuous across TAU wrap ✓
- brick.rotation continuous across TAU wrap ✓
- K500 SIEGE_VOLLEY_ANGLES = 7 entries [-36,-24,-12,0,12,24,36] ✓
- No 5-shot pattern in weapon.gd ✓
- K1000 → Level 2, current_level_k=0 ✓
- No Hybrid branch in weapon.gd or ring_spawner.gd ✓

---

## 2026-04-30 — Session 31: Full-Radius Wall Rotation + 7-Shot Siege + Overclock Tuning

**Done:**
- Fixed the wall-rotation drift/freeze issue at the source in `ring_instance.gd`.
- Added an explicit ring rotation offset that advances every frame while gameplay is active.
- Kept that rotation independent from radius so shrinking walls continue rotating all the way inward until destruction or core breach.
- Preserved:
  - continuous wall compaction
  - typed HP state
  - destroyed gaps
  - no rotation after game over
- Upgraded K `500+` `Piercing Bomb Siege` from `5` projectiles to `7`:
  - `-36°`, `-24°`, `-12°`, `0°`, `+12°`, `+24°`, `+36°`
  - center spear remains the main breach shot
  - all side spears remain support shots
- Increased shared Overclock speed by `1.5x` relative to the old boosted state:
  - old boosted interval = `0.175`
  - new boosted interval = `0.116666...`
  - effective active fire rate = `3x` baseline

**Headless Godot validation passed:**
- Godot runtime used:
  - `/Users/junseokism/Downloads/Godot.app/Contents/MacOS/Godot`
  - `4.6.2.stable.official.71f334935`
- Confirmed:
  - `main.tscn` launches
  - K `500+` fires `7` siege projectiles from the exact cyan center point
  - center spear keeps `2` pierces + larger explosion
  - side spears keep `1` pierce + smaller explosion
  - per-level Overclock relock/reunlock still works
  - K1000 level transition still works
  - no active Hybrid continuation appears
  - wall angle continues changing at small radius
  - wall angle stops changing after game over
- Structural planner check still returns `5` real K `500+` wall layers:
  - `Strong + Strong + Normal + Strong + Armored`

**Not done:**
- No Hybrid combat
- No leaderboard
- No ads
- No audio/resource import
- No broad refactor

## 2026-04-30 — Session 30: Toss Release / Max Level / Monetization / Resource Constitution Realignment

**Done:**
- Realigned release-facing docs after the passing K1000 headless level-loop validation.
- Locked Level `1–100` as the current product rule:
  - each level uses `current_level_k 0–999`
  - `K1000` inside the level advances to the next level
  - recommended default = `Level 100 K1000` ends the run as max-level clear
- Reaffirmed normalized ranking:
  - `total_progress = (current_level - 1) * 1000 + current_level_k`
- Updated product/checklist docs so `K1000+ Hybrid` is no longer treated as the immediate release continuation concept.
- Added future release-roadmap requirements for:
  - App-in-Toss Game Center leaderboard using `total_progress`
  - `getUserKeyForGame` as the future user-identification path
  - policy-safe ad integration planning
  - audio resource strategy and license-proof storage
  - bundle-size gate of `<= 100MB` decompressed `.ait`
- Updated Toss release checklist with explicit rows for:
  - bundle-size audit
  - Game Center leaderboard
  - `getUserKeyForGame`
  - audio legal/resource tracking
  - safer ad timing guidance
- Confirmed no `.ait` / export / build output currently exists in the repo, so size compliance is still pending until the first real export candidate exists.

**Not done:**
- No gameplay code changes
- No leaderboard implementation
- No ads implementation
- No audio/resource import
- No art/resource import

**Validation reality:**
- Documentation/roadmap realignment only
- No new runtime claim beyond the already-passed K1000 headless Godot smoke test
- Bundle-size measurement is pending because no export artifact currently exists

## 2026-04-30 — Session 29: Phase 4.17 — Real Godot Headless Smoke Test

**Godot runtime used:**
- `/Users/junseokism/Downloads/Godot.app/Contents/MacOS/Godot`
- Version: `4.6.2.stable.official.71f334935`
- Launch mode: `--headless --audio-driver Dummy --display-driver headless`

**Validation method:**
- Instantiated `res://scenes/main/main.tscn` inside a temporary Godot QA script.
- Used real runtime state changes inside Godot to verify:
  - K999 -> K1000 transition
  - Level 2 restart loop
  - per-level wall composition loop
  - HUD level/progress state
  - per-level Overclock relock/reunlock
  - game-over / best-progress persistence
- Used a temporary `HOME=/tmp/godothome` runtime path so `user://save.json` could be written cleanly in headless mode.

**Passed in runtime:**
- Project opened and `main.tscn` ran
- `K999 -> K1000` transitioned from Level 1 to Level 2
- `current_level` incremented to `2`
- `current_level_k` reset to `0`
- `total_progress` reached `1000`
- Level 2 K0 restarted at Arrow + 1-layer Normal wall
- Level 2 band loop repeated correctly:
  - K30 Strong / Stone
  - K80 Armored / Split Arrow
  - K150 Strong+Armored / Electric Split
  - K500 5-layer siege wall composition
- Top HUD showed `LEVEL 2` and reset progress bar at Level 2 K0
- Near Level 2 K999, next unlock pointed to `LEVEL 3`, not Hybrid
- Overclock relocked at Level 2 K0 and unlocked again at Level 2 K500
- Center-origin projectile spawn matched the core launch origin
- Joystick left/center/right relocation still worked
- Last aim direction persisted after release
- Pause and sound toggle paths still worked in runtime
- Danger level was nonzero before transition and reset to `0` after transition
- Game-over readout showed level, loop K, total progress, and best progress
- Best progress persisted across save reload / scene relaunch inside the smoke test

**Notes:**
- Godot printed one macOS certificate warning:
  - `get_system_ca_certificates`
  - It did not block runtime or affect gameplay validation.
- This was a real Godot runtime pass, but still headless/scripted rather than a visible interactive editor/device session.

## 2026-04-30 — Session 28: Phase 4.17 — Godot Smoke Test Attempt

**Attempted:**
- Tried to locate a usable Godot runtime/editor via:
  - `command -v godot`
  - `command -v godot4`
  - `/Applications`
  - `/Users/junseokism/Applications`
  - Spotlight / `mdfind`
  - project volume / common install paths

**Result:**
- No usable Godot executable or `.app` bundle was found from this environment.
- Because of that, no real editor/runtime smoke test was executed.
- No gameplay code was changed in this pass.

**What was still verified statically:**
- JSON files parse
- non-doc `res://` references resolve
- `HYBRID SIEGE` remains disabled in runtime progression config
- no active `K >= 1000` wall/combat runtime branch is left in the relevant scripts

**Next requirement remains unchanged:**
- Run the actual Godot smoke test on a machine/environment where Godot can be launched.

## 2026-04-30 — Session 27: Phase 4.17 — K1000 Level Transition Runtime Realignment

**Done:**
- Added real level-loop runtime state in `GameState`:
  - `current_level`
  - `current_level_k`
  - `total_progress`
- Locked runtime ranking formula:
  - `total_progress = (current_level - 1) * 1000 + current_level_k`
- Changed progression accumulation so destroyed bricks advance `current_level_k`, not an endlessly growing combat-tier K.
- Implemented the K1000 transition rule:
  - reaching `current_level_k >= 1000`
  - increments `current_level`
  - resets `current_level_k` to `0`
  - refreshes projectile tier / progression tier from the restarted loop
- Reworked `ProgressionService` to ignore disabled tiers and loop only over the active `0–999` combat bands.
- Marked `HYBRID SIEGE` in `data/progression.json` as disabled so it is no longer an active runtime continuation tier.
- Realigned wall spawning to use per-level loop K:
  - removed the active `K >= 1000` wall branch
  - repeated loop now ends at the `500–999` 5-layer siege wall band
- Realigned HUD level bar and label to real `current_level` / `current_level_k` state instead of the old raw-K heuristic.
- Realigned next-threshold HUD so the `500–999` band points to the next level transition rather than Hybrid.
- Realigned Overclock unlock to per-level loop progression via `current_level_k >= 500`.
- Added minimal save-state support for normalized ranking:
  - `best_total_progress`
  - `best_level`
  - `best_level_k`
  - legacy `best_k` kept as fallback-compatible storage
- Updated game-over readout to show level, loop K, total progress, and best progress.

**Not done:**
- No Hybrid combat behavior
- No new weapons
- No broad architecture refactor
- No Godot runtime validation in this environment

**Validation reality:**
- Static validation only; Godot CLI/editor not available here

## 2026-04-26 — Session 25: Top K Progress Bar + Level 1/2 Visualization

**Done:**
- Added a placeholder top `LevelLabel` to the HUD.
- Added a placeholder top horizontal `KProgressBar` to the HUD.
- Kept `K` as the only progression source.
- Implemented temporary level-band visualization rules in `hud.gd`:
  - `K 0–999 = LEVEL 1`
  - `K 1000–1999 = LEVEL 2`
- Implemented left-to-right fill behavior for the current level band.
- Implemented bar reset at `K = 1000` so Level 2 fills from zero again.
- Preserved existing top HUD text:
  - live `K`
  - current weapon
  - next unlock / threshold or READY / MAX
  - best K
  - pause button
- Updated docs/status so the new top K bar is part of the current structural state.

**Validation reality:**
- No Godot runtime/editor was available in this environment, so this pass is structurally validated only
- The next step is a focused Godot smoke test of the top progress bar and LEVEL 1 / LEVEL 2 switching

## 2026-04-26 — Session 24: K300~499 Wall Alignment + K500 Overclock Trigger

**Done:**
- Reconfirmed and preserved the runtime K `150–499` Electric Split wall composition as:
  - outer = `Strong`
  - inner = `Armored`
- Updated docs so K `300–499` no longer points at the stale `Strong + Strong` wall-pressure assumption.
- Reused the existing Overclock effect as the first real K `500` attack-speed buff instead of adding a second redundant buff system.
- Moved Overclock truth into `weapon.gd`:
  - unlock gating
  - active duration
  - cooldown timing
- Updated `skill_slot.gd` so the bottom skill slot now reflects and triggers the shared Overclock state instead of maintaining its own duplicate local cooldown model.
- Added placeholder joystick-area buff UI in `aim_joystick.gd`:
  - a horizontal divider above the joystick
  - a placeholder buff button above that divider
  - visibly locked/disabled before K `500`
  - activates shared Overclock when unlocked
- Preserved:
  - center-origin firing
  - joystick aim / last-direction persistence / left-center-right repositioning
  - Arrow / Stone / Split / Electric Split behavior
  - K `500+` siege behavior
  - progression HUD/signaling
  - pause / save / sound / platform scaffolding

**Validation reality:**
- No Godot runtime/editor was available in this environment, so this pass is structurally validated only
- The next step is a focused Godot smoke test at K `300–499` and K `500`

## 2026-04-25 — Session 23: K500+ Five-Shot Siege Override

**Done:**
- Replaced the older K `500–999` single-spear late-game assumption with a real `5`-shot siege volley.
- Updated tier-4 firing in `weapon.gd`:
  - volley angles = `-24° / -12° / 0° / +12° / +24°`
  - center spear = up to `2` pierced collisions + enlarged same-layer explosion radius `2`
  - side spears = `1` pierced collision each + smaller support same-layer explosion radius `1`
- Generalized the existing spear projectile path so a single projectile scene can serve both center and side spears through configurable pierce/explosion settings.
- Generalized ring-side terminal explosion routing so the same-layer neighborhood radius is now parameterized instead of hardcoded.
- Raised K `500+` wall spawning to `5` real concentric layers:
  - K `500–999` = `Strong + Strong + Normal + Strong + Armored`
  - K `1000+` = `Strong + Armored + Strong + Armored + Strong`
- Updated the late-game spec/docs to reflect the override:
  - K `500–999` is now a `Piercing Bomb Siege` 5-shot band
  - K `1000+` Hybrid is now explicitly defined as `5`-shot spear-siege core + electric suppression
- Preserved:
  - Arrow / Stone / Split / Electric Split behavior below K `500`
  - center-origin firing and joystick aim flow
  - generic progression HUD/signaling
  - Toss/platform/pause/save/sound scaffolding

**Validation reality:**
- No Godot runtime/editor was available in this environment, so the K `500+` siege override is structurally validated only
- The next step is a focused Godot smoke test at K `500+`

## 2026-04-25 — Session 22: Late-Game Progression Spec Correction (K300~2000)

**Done:**
- Locked the revised late-game design from K `300` upward in docs only.
- Replaced the older late-game assumptions:
  - old `K 150–499` single Electric Split Arrow band
  - old `K 500–999` 2-layer Piercing Bomb Spear band
  - old vague `K 1000+` Hybrid Siege wording
- Locked the new structure:
  - K `300–499` = `Electric Split Arrow` + `2` layers `Strong + Strong`
  - K `500–699` = `Piercing Bomb Spear` + `3` layers `Strong + Strong + Normal`
  - K `700–999` = `Piercing Bomb Spear` + `3` layers `Strong + Armored + Strong`
  - K `1000–1499` = `Hybrid Siege` + `4` layers `Normal + Strong + Armored + Strong`
  - K `1500–2000` = `Hybrid Siege` + `4` layers `Strong + Armored + Strong + Armored`
- Locked Hybrid meaning explicitly as:
  - center breach spear-like projectile
  - two side electric suppression bolts
- Re-affirmed fixed readability HP:
  - `Normal = 1`
  - `Strong = 2`
  - `Armored = 3`
- Intentionally did **not** change combat code in this pass.
- Intentionally did **not** change `data/progression.json`, because runtime still reads that file and the next narrow implementation passes should realign code/data in order rather than silently shifting runtime behavior during a doc-only turn.

**Validation reality:**
- This was a spec/documentation pass only
- No runtime behavior was claimed or changed
- The next narrow implementation pass should start with K `300–499` Electric Split Arrow wall-pressure alignment

---

## 2026-04-23 — Session 21: Piercing Bomb Spear Implementation

**Done:**
- Turned tier `4` into a real combat state by marking `K 500-999` `Piercing Bomb Spear` as implemented in `data/progression.json`
- Added a dedicated tier-4 projectile path:
  - new `piercing_bomb_spear_projectile.gd`
  - new `piercing_bomb_spear_projectile.tscn`
  - `Weapon` now fires a single spear projectile for tier `4`
  - the spear has `0` bounces
  - the spear counts up to `2` pierced segment collisions
- Extended the real 2-layer wall structure into the K `500-999` band:
  - `RingSpawnPlanner` now keeps K `150-999` on `2` actual layers
  - outer layer = `Strong`
  - inner layer = `Armored`
- Added ring-aware spear routing:
  - `BrickInstance` now forwards direct spear hits and terminal explosion requests back to its owning ring
  - `RingInstance` now applies direct spear-hit damage to a pierced collision target
  - `RingInstance` now applies the fixed terminal explosion neighborhood:
	- same layer center / left / right
	- adjacent outer layer center if present
	- adjacent inner layer center if present
  - destroyed explosion targets are not refilled; the neighborhood remains fixed in this band
- Preserved:
  - Arrow / Stone / Split Arrow / Electric Split behavior below K `500`
  - generic progression HUD / threshold signaling
  - center-origin launch path
  - joystick aiming
  - wall continuity / compaction model
  - pause / save / sound / platform scaffolding

**Validation reality:**
- No Godot runtime/editor was available in this environment, so Piercing Bomb Spear is structurally validated only
- The next step is a focused Godot smoke test of the K `500-999` band before starting the Hybrid Siege pass

---

## 2026-04-22 — Session 20: Electric Split Arrow Implementation

**Done:**
- Turned tier `3` into a real combat state by marking `K 150-499` `Electric Split Arrow` as implemented in `data/progression.json`
- Added a dedicated tier-3 projectile path:
  - new `electric_split_projectile.gd`
  - new `electric_split_projectile.tscn`
  - `Weapon` now fires `3` electric bolts at `-15° / 0° / +15°` for tier `3`
  - each electric bolt has a `1`-bounce budget
- Extended wall spawning for the K `150-499` band:
  - `RingSpawnPlanner` now emits layered wall specs for this band
  - `RingSpawner` now spawns coordinated wall groups with layer metadata
  - outer layer = `Strong`
  - inner layer = `Armored`
  - layer spacing is now configurable through `data/game_config.json`
- Added ring-aware electric hit resolution:
  - `BrickInstance` now forwards electric hits back to its owning ring
  - `RingInstance` now maps a struck segment angle across to the adjacent wall layer
  - direct target preference is the struck layer `{I-1, I, I+1}`
  - electric target preference is the adjacent layer `{I-1, I, I+1}`
  - missing preferred targets are reallocated deterministically instead of shrinking the hit budget
- Preserved:
  - Arrow / Stone / Split Arrow behavior below K `150`
  - generic progression HUD / threshold signaling
  - center-origin launch path
  - joystick aiming
  - wall continuity / compaction model
  - pause / save / sound / platform scaffolding

**Validation reality:**
- No Godot runtime/editor was available in this environment, so Electric Split Arrow is structurally validated only
- The next step is a focused Godot smoke test of the K `150-499` band before starting the Piercing Bomb Spear pass

---

## 2026-04-22 — Session 19: Spec Lock + Generic Tier Signaling / HUD

**Done:**
- Locked the current progression plan in docs and progression data:
  - `0-29` Arrow
  - `30-79` Stone
  - `80-149` Split Arrow
  - `150-499` Electric Split Arrow
  - `500-999` Piercing Bomb Spear
  - `1000+` Hybrid Siege
- Recorded the three newly final spec decisions:
  - Electric fallback must preserve its full intended hit budget by reallocating into other valid targets
  - Piercing Bomb Spear remains a 2-layer band
  - Hybrid Siege defaults to 2 side electric bolts
- Updated `data/progression.json` to carry:
  - locked ranges
  - display names
  - `implemented` flags for honest HUD/signaling
- Generalized progression state handling:
  - `ProgressionService` now exposes display names, next-tier lookup, and implemented-tier lookup
  - `GameState` now tracks configured progression tier separately from currently implemented combat tier
  - added generic `tier_threshold_reached(...)`
  - added generic `progression_display_changed(...)`
  - preserved `stone_unlock_reached(...)` as the first-unlock compatibility hook
- Updated top HUD feedback:
  - `K` remains the single progression source
  - HUD now shows current implemented weapon plus next unlock threshold path, or READY/MAX state
  - added centered `WeaponLabel` under the top `K` label
- Updated project docs/status so the next narrow implementation pass is explicitly `K150-499 Electric Split Arrow`

**Validation reality:**
- No Godot runtime/editor available in this environment, so the new signaling/HUD flow is structurally validated only
- This session intentionally did not implement the late-tier combat behaviors themselves

---

## 2026-04-22 — Session 18: Input System Expansion — Virtual Aim Joystick

**Done:**
- Synced docs first (`00_product_spec.md`, `02_technical_architecture.md`, `03_implementation_plan.md`) so the virtual aiming joystick and its left/center/right placement switching are now part of the written constitution.
- Reworked `InputHandler` into a shared aim-state coordinator:
  - it now accepts explicit normalized aim updates
  - center-origin launch-point wiring remains owned by `Weapon`
  - last valid aim direction remains active unless a new valid direction is supplied
- Added `scripts/ui/aim_joystick.gd`:
  - placeholder virtual joystick UI inside `RootUI/SafeAreaContainer`
  - drag updates `InputHandler.aim_direction`
  - release does not reset aim direction
  - left/right placeholder buttons move the joystick between bottom-left / bottom-center / bottom-right
- Wired the joystick into `scenes/ui/root_ui.tscn` as a safe-area-aware bottom UI control
- Added lightweight joystick anchor persistence:
  - `SaveFileRepository.DEFAULT_DATA` now includes `aim_joystick_position`
  - `SaveManager` now exposes joystick position getter/setter helpers
  - joystick placement is now saved immediately when switched
- Updated `NEXT_STEP`, `STATUS`, and `data/dev_status.json` so the next manual validation is specifically about joystick flow + center-origin non-regression

**Validation reality:**
- No Godot runtime/editor available in this environment, so the joystick flow is structurally validated only
- This session intentionally did not reopen combat, wall, platform, or broad architecture scope

---

## 2026-04-21 — Session 17: Targeted Freeze Fixes Before Architecture Freeze

**Done:**
- Confirmed the last meaningful freeze blocker in code was still real:
  - `DangerManager` was still normalizing ring distance against a stale hardcoded `REFERENCE_RADIUS = 380.0`
  - current wall/play-field radius in `data/game_config.json` is `280`
- Applied the smallest maintainable geometry-source fix:
  - `scripts/autoload/danger_manager.gd` now loads `play_field_radius` from `data/game_config.json`
  - `scripts/application/rings/ring_spawn_planner.gd` now also loads `play_field_radius` from `data/game_config.json`
  - danger normalization and ring spawn geometry now use the same config-backed radius source
- Cleaned stale freeze guidance in:
  - `docs/04_architecture_audit.md`
  - `docs/05_handoff_to_next_agent.md`
  - `docs/06_refactor_validation.md`
  - `docs/NEXT_STEP.md`
  - `docs/STATUS.md`
  - `data/dev_status.json`
- Shifted the project handoff language from "resume gameplay now" to "run one final Godot smoke test, then freeze architecture and move to rules/progression specification"

**Validation reality:**
- No Godot runtime/editor available in this environment, so runtime confirmation is still pending
- This session was intentionally limited to freeze blockers only; no broad refactor or new gameplay work was started

---

## 2026-04-21 — Session 16: Unify Aim-Line Origin and True Firing Origin

**Done:**
- Re-traced the firing path end-to-end after runtime feedback:
  - aim line start point comes from the `Weapon` node origin because `Line2D` point `0` is `Vector2.ZERO` in `weapon.gd`
  - cyan point center comes from the `Core` node origin because the cyan `ColorRect` is centered around local `(0, 0)` in `core.gd`
  - projectile spawn was still using `Weapon.global_position` directly
- Identified the real local-architecture issue:
  - aim line, cyan point, and projectile spawn were only *co-located by scene setup*, not unified through one explicit launch-origin provider
- Applied a narrow firing-path refactor:
  - `Core` now exposes `get_launch_origin_global()`
  - `GameRoot` now sets `Weapon`'s launch-origin provider to `Core`
  - `Weapon` now uses a single `_get_launch_origin()` helper for:
	- `InputHandler.set_aim_origin(...)`
	- projectile spawn position
	- syncing weapon node position to the provider
  - projectile `global_position` is now assigned **after** adding to `ProjectileLayer`, removing ambiguity about pre-parent global placement

**Validation reality:**
- No Godot runtime/editor available in this environment, so this is a structural fix queued for a targeted manual smoke test of true center-origin firing

---

## 2026-04-21 — Session 15: Micro Fix — True Cyan-Point Firing

**Done:**
- Re-audited the full firing path after runtime feedback:
  - core cyan point remains centered at local `(0, 0)`
  - weapon launch origin remains centered at local `(0, 0)`
  - projectile spawn coordinate remains centered
  - projectile-local geometry remains forward-biased from the launch point
- Identified the remaining visible mismatch as launch-point **occlusion**, not a further world-position mismatch:
  - the aim line starts at the same center point
  - the aim line was drawing above the launch point visuals
  - this could visually compete with the first visible projectile pixels at the cyan center
- Applied the smallest possible fix in `weapon.gd`:
  - `Line2D` aim line now renders behind the center launch point via `z_index = -1`

**Validation reality:**
- No Godot runtime/editor available in this environment, so this remains a structural micro-fix queued for live smoke confirmation

---

## 2026-04-21 — Session 14: Exact Launch-Origin + Unlock Readability Correction

**Done:**
- **Docs clarified first** (`00_product_spec.md`, `02_technical_architecture.md`, `03_implementation_plan.md`, `NEXT_STEP.md`, `STATUS.md`, `data/dev_status.json`):
  - exact center of the cyan core point is now explicitly documented as the true projectile launch origin
  - top-of-screen stone unlock readability is now explicitly required
  - future unlock VFX/SFX hook requirement is now explicitly documented
- **Exact visible launch-origin fix** (`arrow_projectile.gd`, `stone_projectile.gd`, `weapon.gd`):
  - confirmed the spawn coordinate was already centered
  - identified the real mismatch as projectile-local visuals/collision being centered on the node origin, which made the body straddle the cyan point
  - shifted projectile-local visuals/collision forward so the launch point reads as the exact center of the cyan core point
  - removed the extra emitter marker from `weapon.gd` so the cyan core point remains the single clear origin indicator
- **Unlock readability + future hook** (`progression_service.gd`, `game_state.gd`, `hud.gd`, `root_ui.tscn`):
  - added tier-threshold lookup in `ProgressionService`
  - added `stone_unlock_threshold`, `unlock_progress_changed`, and `stone_unlock_reached` in `GameState`
  - HUD now reuses `K` as the top-center stone unlock progress display
  - best-K display remains visible and pause button remains intact

**Structural validation:**
- No Godot runtime/editor available in this environment, so no live smoke test was run
- Precision/readability corrections were kept local to projectile presentation, HUD presentation, and progression-state signaling

---

## 2026-04-21 — Session 13: Center-Origin Combat Constitution Correction

**Done:**
- **Docs synced first** (`00_product_spec.md`, `02_technical_architecture.md`, `03_implementation_plan.md`, `NEXT_STEP.md`, `STATUS.md`, `data/dev_status.json`):
  - center-origin firing is now the hard constitutional model again
  - default arrow requires 3 bounces and 3-target spread
  - stone requires 5-target spread
  - stone unlock threshold remains playtest-tunable in data
- **Center-origin firing restored** (`scenes/game/game_root.tscn`, `weapon.gd`, `input_handler.gd`, `game_config.json`):
  - `Weapon` moved from local `(0, 303)` back to local `(0, 0)` so launch origin matches the centered core area
  - `InputHandler` still uses weapon-provided aim origin, which now resolves to the center launch point again
  - weapon visuals were simplified so they no longer imply a bottom launcher
- **Ring-aware spread hits implemented** (`brick_instance.gd`, `ring_instance.gd`):
  - bricks now know their ring + segment index
  - projectiles route impact resolution back up to `RingInstance`
  - `RingInstance.apply_projectile_hit(...)` now applies wrapped neighbor hits against the logical segment array
  - K scoring remains intact because destroyed segments still emit `brick_destroyed`
- **Arrow behavior corrected** (`arrow_projectile.gd`):
  - 3-bounce budget added
  - 3-target spread hit added
  - simple post-hit reflection + pushback added to reduce immediate re-collision
- **Stone behavior corrected** (`stone_projectile.gd`, `data/progression.json`):
  - 5-target spread hit added
  - tier-1 `k_min` remains the tunable stone unlock threshold for playtesting

**Structural validation:**
- Re-checked `project.godot` main scene and autoload paths
- Re-ran repository `res://` audit: 41 refs, 0 missing
- Re-checked internal spread-hit wiring across weapon/projectile/brick/ring path
- Godot runtime/editor still unavailable in this environment, so no live smoke test was performed

---

## 2026-04-21 — Session 12: Shrinking Wall Correction Pass

**Done:**
- **Docs synced to stricter wall constitution first** (`00_product_spec.md`, `02_technical_architecture.md`, `03_implementation_plan.md`, `NEXT_STEP.md`, `STATUS.md`, `data/dev_status.json`): clarified that the continuous radial wall must keep visible brick segmentation while active segment count decreases with radius so overlap does not accumulate and large new gaps do not appear on their own.
- **Segment sizing aligned** (`brick_rules.gd`, `data/game_config.json`): set shared `SEGMENT_SIZE` to `28.0` so wall planning and brick visuals/collision use the same tangential width target.
- **Spawn planner corrected** (`ring_spawn_planner.gd`): wall segment count now derives from `segment_count_for_radius(radius, segment_size)`, and spawn specs pass `segment_size` through explicitly.
- **Spawner wiring updated** (`ring_spawner.gd`): `RingInstance.setup()` now receives `segment_size` alongside radius, speed, count, and brick type.
- **Brick instance updated for compaction-safe rebuilds** (`brick_instance.gd`): collision shape changed to tangential 28×14, and `setup()` now accepts explicit HP/max-HP so a rebuilt ring can preserve strong/armored state instead of resetting it.
- **Shrinking wall compaction implemented** (`ring_instance.gd`):
  - Added logical `_segments` state separate from live brick nodes
  - Rebuilds visible brick nodes from logical segment state
  - On shrink, computes smaller target segment count from current radius
  - Re-tiles old segments into fewer angular buckets
  - Preserves destroyed gaps only when a full merged bucket is already dead
  - Avoids creating new large passable gaps while preventing overlap buildup from a fixed segment count

**Structural validation:**
- Checked touched gameplay files after patching
- `ring.setup(...)` signature change matched by `ring_spawner.gd`
- `brick.setup(...)` remains backward-compatible through optional HP args
- No scene/autoload path changes were introduced in this pass
- Fixed one final structural blocker during the sweep: removed an accidental extra indent before `ring.setup(...)` in `scripts/gameplay/ring_spawner.gd`

**Still not done in this session:**
- No Godot editor/runtime execution was available here
- Wall feel, preserved threat typing, and live scoring/pause/UI behavior still need one runtime smoke test in Godot before Phase 5

---

## 2026-04-21 — Session 11: Gamefeel Correction Pass

**Done:**
- **Core visual** (`core.gd`): replaced invisible 20×20 square with layered visual — 80×80 orange-red kill-zone aura (shows the danger radius), inner dark fill, 18×18 bright cyan core point. Players can now see exactly what they're protecting and when they're about to lose.
- **Weapon marker + aim indicator** (`weapon.gd`): added 20×10 cyan base + 6×14 barrel nub at weapon position (world 195,640). Added `Line2D` aim indicator extending 130px toward `InputHandler.aim_direction`; updates every frame in `_process()`. Bottom-origin position and aim direction are now visually unambiguous.
- **Wall segment visual** (`brick_instance.gd`): changed visual from 24×24 square to 28×14 (28 tangential × 14 radial). Visual is wider than the 23.77px inter-segment arc → 4.23px overlap → gap-free tiling when rotated. Collision shape unchanged (24×24).
- **Tangential brick rotation** (`ring_instance.gd`): added `brick.rotation = angle + PI/2` at spawn. This aligns each segment's wide (28px) face along the ring tangent. Math verified: local X axis after rotation equals tangent direction at all angles. Wall now looks like a continuous tile band, not a loose scatter of squares.
- **Arrow projectile orientation** (`arrow_projectile.gd`): visual changed to 5×16 (thin, elongated). Node rotation set to `direction.angle() - PI/2` in `_ready()` so the arrow visually points in its travel direction. Collision shape updated to 6×14 to match.
- **Stone projectile cleanup** (`stone_projectile.gd`): visual and collision updated to 16×16 (cleaner).

**Validation:**
- Full `res://` path audit: 0 missing references ✓
- Math verified: radius=280, visual_w=28, arc=23.77px → 4.23px overlap per segment, gap-free ✓
- Brick rotation verified at 0°, 90°, 180°, 270°: local X axis = tangent direction ✓
- Bounce/reflection: **not in spec** — not implemented, not deferred as a debt item

---

## 2026-04-21 — Session 10: Phase 4.5 — Gameplay Correction Pass

**Done:**
- **CC-01 resolved — Bottom-origin shooter layout:**
  - `scenes/game/game_root.tscn`: `GameRoot` repositioned from `(195, 422)` to `(195, 337)` (center of play field); `Weapon` given local position `(0, 303)` → world `(195, 640)` (bottom of play field); `Core` stays at local `(0, 0)` = world `(195, 337)` (no change needed)
  - `scripts/gameplay/input_handler.gd`: added `aim_origin` property and `set_aim_origin()` method; `_input()` now uses weapon-relative origin instead of viewport center; default fallback to viewport center if origin not yet set
  - `scripts/gameplay/weapon.gd`: added `InputHandler.set_aim_origin(global_position)` in `_ready()` — called each scene load including restarts

- **CC-02 resolved — Continuous segmented radial wall system:**
  - `scripts/domain/bricks/brick_rules.gd`: added `SEGMENT_SIZE: float = 24.0` (matches `BrickInstance.BRICK_SIZE`)
  - `scripts/application/rings/ring_spawn_planner.gd`: replaced `brick_count_for_k()` with `segment_count_for_radius(radius)` = `ceili(TAU × radius / SEGMENT_SIZE)` — guarantees no passable gaps; `DEFAULT_SPAWN_RADIUS` corrected from `380` to `280` (keeps all ring bricks above weapon at y=640); added slight shrink speed progression
  - `scripts/gameplay/ring_spawner.gd`: passes `segment_count` key (not obsolete `brick_count` key) to `ring.setup()`
  - `data/game_config.json`: added `segment_size`, `play_field_radius`, `core_y`, `weapon_y` layout constants

**Validation:**
- Full `res://` path audit: 0 missing references
- Python math check: radius=280, SEGMENT_SIZE=24 → 74 segments; arc=23.77px < 24px → gap-free wall ✓
- Bottom of ring at spawn: y=617, weapon at y=640 → all bricks spawn above weapon ✓
- Autoload paths unchanged and intact ✓
- No runtime execution available; structural validation only (same constraint as all prior sessions)

**Files modified:** `scenes/game/game_root.tscn`, `scripts/gameplay/input_handler.gd`, `scripts/gameplay/weapon.gd`, `scripts/domain/bricks/brick_rules.gd`, `scripts/application/rings/ring_spawn_planner.gd`, `scripts/gameplay/ring_spawner.gd`, `data/game_config.json`

**Obsolete prototype behavior removed:**
- Center-origin weapon position (GameRoot/Weapon co-located at screen center) → replaced by separated Core/Weapon layout
- Viewport-center aim origin in InputHandler → replaced by weapon-position-relative origin
- Fixed low brick count (10–18 bricks, large gaps) → replaced by circumference-tiled count (~74 at spawn)

---

## 2026-04-21 — Session 09: Constitution Sync (Doc-Only Pass)

**Done:**
- Read all nine constitution source files in full
- Identified two hard conflicts between current implementation and design constitution
- **CC-01** (critical): Weapon fires from center of screen (center-origin). Constitution mandates bottom-origin shooter — weapon at play-field bottom, core at play-field center. Affects `scenes/game/game_root.tscn` and possibly `scripts/gameplay/input_handler.gd`.
- **CC-02** (critical): Ring walls spawn with fixed small brick count (10–18 bricks, large gaps). Constitution mandates continuous segmented radial wall — segment count must derive from circumference so no passable gaps exist at spawn. Affects `ring_spawn_planner.gd`, `brick_rules.gd`, `data/game_config.json`.
- Updated `docs/00_product_spec.md` — rewrote §2.2–§2.5 for bottom-origin layout and continuous wall system; added §10 obsolete-prototype table
- Updated `docs/02_technical_architecture.md` — added constitutional layout table; added §4 continuous wall model; added §10 obsolete notes
- Updated `docs/03_implementation_plan.md` — inserted Phase 4.5 (gameplay correction) as next step; documented exact file-by-file changes; marked phases 3/4 as complete
- Updated `docs/NEXT_STEP.md` — replaced with Phase 4.5 correction instructions
- Updated `docs/STATUS.md` — added constitutional conflict table, current state, corrected risk register
- Updated `data/dev_status.json` — added `constitutional_conflicts_found` array, set phase to 4.5

**No code was changed in this session.**
**Phase 4.5 (gameplay correction) is the mandatory next implementation step.**

---

## 2026-04-21 — Session 08: Phase 3 + 4 — Skill Bar, Overclock, HUD, Platform Compliance

**Phase 4 done (this session):**
- **`scripts/autoload/platform_bridge.gd`** fully wired:
  - `init_platform()` registers `visibilitychange` JS listener → `AudioManager.mute_all()` / `restore_mute_state()` (C-04, C-05)
  - `init_platform()` registers `popstate` JS listener with `history.pushState` seeding (C-16)
  - `_handle_back_gesture()`: back during active play → PauseMenu.show_menu(); back at other states → ConfirmExitDialog.show_dialog() (C-16)
  - `request_close()` calls `TossBridge.close()` on Web, `get_tree().quit()` on native (C-06)
  - `fetch_user_id()` calls `window.TossBridge.getUser()` on init; stores in SaveManager; graceful no-op if bridge absent (C-21)
  - `_ready()` calls `DisplayServer.screen_set_orientation(SCREEN_PORTRAIT)` on non-Web (C-15)
  - JS callbacks held in `_js_callbacks` array to prevent GC
- **`scripts/ui/confirm_exit_dialog.gd`** (new) — centered overlay registered in `exit_dialog` group; Stay/Leave buttons; Leave calls `PlatformBridge.request_close()` (C-20)
- **`scenes/ui/root_ui.tscn`** updated — added `ConfirmExitDialog` node tree with DimOverlay + Panel + MessageLabel + Stay/Leave buttons; load_steps 6→7
- **`docs/01_toss_release_checklist.md`** updated — C-04, C-05, C-06, C-15, C-16, C-20, C-21 now `[~]` with wired-code approach

**Compliance delta after Phase 4:**
- C-04 `[~]` — JS listener wired; runtime test pending
- C-05 `[~]` — JS listener wired; runtime test pending
- C-06 `[~]` — `request_close()` routes to TossBridge or quit; container-close passthrough not blockable
- C-15 `[~]` — orientation call wired; HTML5 export config pending
- C-16 `[~]` — back gesture routing fully coded; runtime test pending
- C-20 `[~]` — ConfirmExitDialog wired; runtime test pending
- C-21 `[~]` — getUser() call wired; Toss bridge availability pending

**Still blocked:**
- C-02 (real audio assets), C-14 (fullscreen export config), C-17/C-18/C-19 (device QA)

---

## 2026-04-21 — Session 08: Phase 3 — Skill Bar + Overclock + HUD Upgrades

**Done:**
- Created `scripts/ui/skill_slot.gd` — OverclockSlot with READY/ACTIVE/COOLDOWN state machine, 3s active duration, 15s cooldown, tap-to-activate via `weapon` group lookup, resets on `game_started`
- Updated `scripts/ui/hud.gd` — added `BestKLabel` (top-right, reads `SaveManager.get_best_k()` on ready and on game start) and `PauseButton` (routes to `pause_menu` group `show_menu()`)
- Updated `scripts/ui/pause_menu.gd` — added `add_to_group("pause_menu")` in `_ready()`; renamed internal `_show()` → public `show_menu()`
- Updated `scripts/ui/game_over_screen.gd` — ScoreLabel now shows `Score: N / Best: N` using `SaveManager.get_best_k()`
- Updated `scenes/ui/root_ui.tscn` — added `BestKLabel` + `PauseButton` to HUD; added `SkillBar` + `OverclockSlot` (with `BG`, `Label`, `CooldownLabel` children) to `SafeAreaContainer`; load_steps 5→6 for `skill_slot.gd`

**Architecture compliance:**
- Skill activation flows: tap → `skill_slot.gd` → `weapon` group → `Weapon.activate_overclock()` — no autoload mutation
- Cooldown state is presentation-local in `skill_slot.gd`, not stored in GameState
- Best K display reads from `SaveManager` (already persisted by `GameState.trigger_game_over`)

**Phase:** 3 — Skill Bar + Overclock complete
**Files touched:** `scripts/ui/skill_slot.gd` (new), `scripts/ui/hud.gd`, `scripts/ui/pause_menu.gd`, `scripts/ui/game_over_screen.gd`, `scenes/ui/root_ui.tscn`

---

## 2026-04-20 — Session 07: Final Validation Mode

**Done:**
- Re-checked `project.godot` main scene and autoload paths
- Confirmed no `godot` / `godot4` CLI was available in PATH
- Searched standard locations and Spotlight for a Godot app/editor; none was found in this environment
- Ran repository-wide static path audit across `project.godot`, `.tscn`, and `.gd` files:
  - **0 missing `res://` references found**
- Ran scene/script consistency audit for attached-script `$NodePath` lookups in the refactored composed scenes:
  - **0 missing node-path bindings found**
- No validation-blocking file/path mismatch was found, so no code fixes were required
- Updated handoff and validation docs to separate:
  - runtime-verified
  - static-structure-verified
  - not verifiable in this environment

**Validation reality:**
- Strongest available validation completed
- Actual Godot runtime/editor execution still not possible on this machine
- Final handoff confidence for this environment: `READY_FOR_GAMEPLAY_RESUME_STRUCTURAL_ONLY`

---

## 2026-04-20 — Session 06: Architecture Review + Layered Refactor

**Done:**
- Added layered folders and extracted non-node responsibilities:
  - `scripts/domain/bricks/brick_rules.gd`
  - `scripts/domain/danger/danger_rules.gd`
  - `scripts/application/progression/progression_service.gd`
  - `scripts/application/rings/ring_spawn_planner.gd`
  - `scripts/infrastructure/config/json_config_loader.gd`
  - `scripts/infrastructure/persistence/save_file_repository.gd`
- Slimmed autoloads without changing their public role in the project:
  - `GameState` now delegates progression lookup and run-result persistence instead of loading/parsing/saving everything inline
  - `SaveManager` now uses `SaveFileRepository`
  - `DangerManager` now delegates threshold math to `DangerRules`
- Moved score/game-over ownership upward:
  - `brick_instance.gd` no longer mutates `GameState` directly; it emits `destroyed`
  - `core.gd` no longer triggers `GameState` directly; it emits `core_breached`
  - `ring_instance.gd` and `ring_spawner.gd` now bubble gameplay events upward
  - `game_root.gd` became the gameplay orchestrator for score and game-over transitions
- Scene composition cleaned up:
  - `main.tscn` now instantiates `scenes/game/game_root.tscn` and `scenes/ui/root_ui.tscn`
  - `scenes/game/core.tscn`, `scenes/game/game_root.tscn`, and `scenes/ui/root_ui.tscn` now contain the real subtrees/scripts instead of placeholder-only definitions
- Added `scripts/ui/root_ui.gd` to apply safe-area offsets centrally
- Updated architecture/status/next-step docs and added `docs/04_architecture_audit.md`

**Validation reality:**
- Static reference/path review completed
- Godot CLI not available on this machine, so no runtime/editor validation was performed in this session

---

## 2026-04-20 — Session 05: Phase 2 — Danger Presentation + Pause/Sound Control

**Done:**
- **Brick type correction**: `brick_instance.gd` now has `BrickType` enum (NORMAL=0, STRONG=1, ARMORED=2). HP derived from type. Normal always 1-hit (amber). Strong = 2 HP (blue→gray). Armored = 3 HP (purple→gray). No generic HP scaling for all bricks.
- **ring_instance.gd**: `brick_hp` replaced with `brick_type`; passes type to brick setup
- **ring_spawner.gd**: `_brick_type()` returns typed const (NORMAL/STRONG/ARMORED) by K threshold; old `_brick_hp()` removed
- **DangerOverlay**: new CanvasLayer (layer=1) in main.tscn with `EdgeTint` ColorRect; subscribes to `DangerManager.danger_level_changed`; level 0=invisible, 1=faint static tint (α=0.07), 2=slow pulse, 3=fast pulse
- **PauseMenu**: new Control (PROCESS_MODE_ALWAYS) in RootUI; triggered by Escape (`ui_cancel`); Resume / Sound:ON/OFF toggle / Restart; `get_tree().paused = true` when shown; no bottom-sheet
- **game_root.gd**: connects `DangerManager.danger_le	vel_changed` → `AudioManager.set_bgm_intensity()`; resets DangerManager on game over
- **audio_manager.gd**: `set_bgm_intensity` now prints level to console (testable without audio assets)
- **main.tscn**: load_steps=9; DangerOverlay added; RootUI layer=2; PauseMenu with DimOverlay + 3 buttons added
- **01_toss_release_checklist.md**: C-03, C-04, C-05, C-07, C-08, C-09, C-10, C-11, C-12 updated to `[~]`

**Phase:** 2 — Danger Presentation + Pause/Sound Control complete
**Compliance delta:** C-03 `[~]` (toggle works, not persisted), C-08/C-09 `[~]` (no bottom-sheet confirmed), C-10 `[~]` (exit path exists via Restart), C-11 `[~]` (verb labels confirmed)

---

## 2026-04-20 — Session 04: Phase 1 — Core Gameplay Loop

**Done:**
- `InputHandler` autoload: mouse/touch position relative to viewport center → `aim_direction` vector, registered in project.godot
- `game_root.gd`: wires Weapon/RingSpawner to their layers, starts game on _ready
- `core.gd`: builds Area2D kill zone (r=40) + ColorRect visual at runtime in _ready; triggers GameState.trigger_game_over on brick contact
- `weapon.gd`: Timer-based auto-fire (0.35s interval), spawns ArrowProjectile into ProjectileLayer
- `arrow_projectile.gd`: Area2D, speed 620px/s, lifetime 1.4s, damages first brick on collision, has yellow ColorRect visual
- `brick_instance.gd`: Area2D, HP-driven color (orange→dark-red), calls GameState.add_k(1) on death
- `ring_instance.gd`: spawns N BrickInstances in circle, shrinks each frame, alive-count tracks full ring destruction, notifies DangerManager
- `ring_spawner.gd`: spawns ring immediately + every 5s; brick count and HP scale with K
- `hud.gd`: Label shows live K score, updates via GameState.k_changed
- `game_over_screen.gd`: hidden until GameState.game_over fires; "Play Again" reloads scene
- `danger_manager.gd`: added `_process` that polls ring radii and emits danger_level_changed (0–3)
- `main.tscn`: expanded to full gameplay tree (GameRoot + Core + BrickLayer + ProjectileLayer + Weapon + RingSpawner + RootUI/HUD/GameOverScreen)
- 3 new gameplay scenes: brick_instance.tscn, ring_instance.tscn, arrow_projectile.tscn
- All 12 preload/ext_resource paths verified OK

**Phase:** 1 — Core Gameplay Loop complete
**Files touched:** See "Files Created/Modified" in session report

---

## 2026-04-20 — Session 03: Phase 0 — Project Scaffold

**Done:**
- Set project.godot: viewport 390×844, stretch `canvas_items`/`keep`, main scene `scenes/main/main.tscn`
- Created 5 autoload stubs and registered in project.godot:
  - `scripts/autoload/game_state.gd` — K counter, session state, signals
  - `scripts/autoload/save_manager.gd` — persistence API stubs (C-03, C-22 hooks)
  - `scripts/autoload/audio_manager.gd` — mute/unmute via AudioServer.set_bus_mute (C-04, C-05)
  - `scripts/autoload/danger_manager.gd` — ring tracking stubs, danger_level_changed signal
  - `scripts/autoload/platform_bridge.gd` — lifecycle/identity stubs (C-06, C-14–C-16, C-20, C-21)
- Created 4 scene files:
  - `scenes/main/main.tscn` — Node root with inline GameRoot (Node2D) + RootUI (CanvasLayer/SafeAreaContainer)
  - `scenes/ui/root_ui.tscn` — standalone CanvasLayer with SafeAreaContainer Control (C-07 hook)
  - `scenes/game/game_root.tscn` — Node2D placeholder
  - `scenes/game/core.tscn` — Node2D placeholder
- Created `icon.svg` placeholder (was missing; would cause Godot warning)
- Created `data/game_config.json` and `data/progression.json` placeholder configs
- Static syntax review passed; Godot CLI not available on this machine

**Compliance hooks created (not yet validated):** C-04, C-05, C-06, C-07, C-14, C-15, C-16, C-20, C-21, C-22

**Phase:** 0 — Scaffold complete
**Files touched:** `project.godot`, `icon.svg`, `scripts/autoload/*.gd` (×5), `scenes/main/main.tscn`, `scenes/ui/root_ui.tscn`, `scenes/game/game_root.tscn`, `scenes/game/core.tscn`, `data/game_config.json`, `data/progression.json`

---

## 2026-04-20 — Session 02: Live-Observability Workflow

**Done:**
- Added `docs/WORKLOG.md` (this file) — append-only engineering log
- Added `docs/NEXT_STEP.md` — single current implementation target with acceptance criteria
- Added `docs/DEV_WATCH.md` — monitoring guide for VS Code + Godot
- Added `data/dev_status.json` — machine-readable progress state
- Updated `docs/STATUS.md` to reference the new observability files

**Phase:** 0 — Scaffold (not yet started in engine)
**Files touched:** `docs/WORKLOG.md`, `docs/NEXT_STEP.md`, `docs/DEV_WATCH.md`, `data/dev_status.json`, `docs/STATUS.md`

---

## 2026-04-20 — Session 01: Source-of-Truth Documentation

**Done:**
- Explored project: fresh Godot 4.6 GL Compatibility scaffold, all asset/scene/script dirs empty
- Created `docs/00_product_spec.md` — full game concept, mechanics, danger system, progression table, art direction
- Created `docs/01_toss_release_checklist.md` — 22 common + feature-specific compliance rows with ID/MVP/approach/validation/status columns
- Created `docs/02_technical_architecture.md` — scene tree, 5 autoload designs (GameState, SaveManager, AudioManager, DangerManager, PlatformBridge), collision layers, directory layout, HTML5 export settings
- Created `docs/03_implementation_plan.md` — 8-phase plan from scaffold to pre-release
- Created `docs/STATUS.md` — current state, next step, 7 risks, assumptions

**Phase:** Pre-Phase 0 (docs only)
**Files touched:** `docs/00_product_spec.md`, `docs/01_toss_release_checklist.md`, `docs/02_technical_architecture.md`, `docs/03_implementation_plan.md`, `docs/STATUS.md`

---
