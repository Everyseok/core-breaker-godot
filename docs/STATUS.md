# Project Status

**Date:** 2026-05-01
**Phase:** 4.20 — Ads plan complete (planning only); official APIs confirmed; placement policy locked; Phase 4.21 blocked on Toss console prerequisites

> Live progress: [`data/dev_status.json`](../data/dev_status.json) · [`docs/WORKLOG.md`](WORKLOG.md) · [`docs/NEXT_STEP.md`](NEXT_STEP.md)

---

## Current Structural Reality

### What is already aligned in code

| Element | Current Runtime State |
|---------|------------------------|
| Core / launch origin | Center-origin, cyan-point launch path structurally in place |
| Aim controls | Virtual joystick with left/center/right placement and last-direction hold |
| Early combat | Arrow / Stone / Split Arrow implemented structurally |
| Mid combat | Electric Split Arrow implemented structurally with `Strong + Armored` wall composition across the current `150–499` runtime split |
| Late combat | K `500–999` now uses a 7-shot siege volley structurally; `K1000` now transitions into the next level instead of entering an active Hybrid band |
| Progression UI | Generic current-weapon / next-threshold HUD plus top LEVEL/K progress bar exist structurally |
| Buff UI | Overclock is now a shared attack-speed buff surfaced in both the skill slot and joystick area, with boosted fire rate now 3x baseline |
| Wall model | Continuous segmented radial wall with no-overlap compaction, radius-based segment-count reduction, and inward rotation that now continues until destruction or core breach |

### What is now aligned in docs/spec

| Element | Locked Spec |
|---------|-------------|
| K `300–499` | Electric Split Arrow + `2` layers `Strong + Armored` |
| K `500–999` | Piercing Bomb Siege + `5` layers `Strong + Strong + Normal + Strong + Armored` |
| K `1000 threshold` | Runtime now transitions Level 1 clear -> Level 2 restart loop |
| Ranking rule | Level first, then `current_level_k`, with normalized `total_progress` |
| Max level | `MAX_LEVEL = 100` in `game_state.gd`; Level 100 K1000 ends the run with MAX LEVEL CLEAR; `total_progress` caps at `100000` |

### What remains placeholder

- All visuals are ColorRects / ColorRect-derived — no pixel art sprites
- No background (pure black)
- No audio (print stubs only)
- No particle effects

---

## Current Constitutional Alignment

- Core at world `(195, 337)` — center of play field / ring system
- Weapon / projectile launch origin at the same center point
- Player controls aim only; firing remains automatic
- Virtual joystick remains the primary aim input
- Joystick anchor can switch between bottom-left / bottom-center / bottom-right
- Joystick release preserves the last valid normalized direction
- A placeholder buff button now sits above a divider line near the joystick area
- Overclock is now the first real attack-speed buff, unlocks at `K >= 500`, and boosts firing to `3x` baseline during its active window
- Continuous segmented radial walls remain mandatory
- Segment count still derives from circumference and compacts downward as radius shrinks
- Meaningful gaps should still come from destruction, not geometry drift
- Default arrow still uses a 3-bounce / 3-target pattern
- Stone still uses a 5-target pattern
- Electric total hit count preservation via reallocation remains part of the locked spec
- K `500+` wall thickness now means `5` real concentric layers
- HP readability remains fixed by type:
  - `Normal = 1`
  - `Strong = 2`
  - `Armored = 3`
- Top HUD still uses `K` as the single progression source
- Top HUD now also visualizes `K` as a horizontal level-band progress bar
- `GameState.tier_threshold_reached` remains the generic unlock hook for future VFX/SFX
- Toss-sensitive UI, pause, sound-toggle, save, and platform scaffolding remain structurally intact

---

## Spec / Runtime Gap

The current runtime no longer reflects the old single-spear K `500+` assumption. The remaining meaningful gameplay gap is now narrower:

- `K 150–499` Electric Split Arrow still runs under one broader runtime band
- `K1000` level-loop behavior is now implemented structurally
- runtime no longer executes an active `K1000+` continuation wall/combat band

The docs are now the source of truth for the revised late-game progression from K `300` upward and for the K1000 level-transition rule. Runtime code has now caught up for the K `500+` siege override, the K `300–499` wall-alignment correction, and the K1000 level-loop transition. Hybrid is no longer an active runtime continuation.

---

## Immediate Next Validation Need

| Check | Status |
|-------|--------|
| Godot runtime smoke test for the current implemented runtime stack | Passed in Godot 4.6.2 headless scripted runtime via `main.tscn` validation |
| Top horizontal K progress bar and LEVEL 1 / LEVEL 2 switching | Structurally present and now driven by real `current_level` / `current_level_k` state |
| K `300–499` Electric Split wall composition (`Strong + Armored`) | Passed in headless runtime smoke test |
| K `500` joystick-area Overclock unlock / shared cooldown path | Passed in headless runtime smoke test; boosted interval now validated at `0.116666...` (`3x` baseline fire rate) |
| Current K `500+` seven-shot siege volley and 5-layer wall behavior | Passed in headless runtime smoke test |
| K1000 level transition / Level 2 restart behavior | Passed in headless runtime smoke test |
| Full-radius wall rotation / no freeze near small radius | Passed in headless runtime smoke test |

---

## Release Roadmap Reality

| Area | Current State |
|------|---------------|
| Visible interactive Godot validation | Still pending after the passing headless smoke test |
| Max Level 100 runtime cap | Implemented in Phase 4.18; headless QA 47/47 passed |
| Game Center leaderboard | Phase 4.19 done: `submit_leaderboard_score()` and `open_leaderboard()` wired in `PlatformBridge`. Ranking button in main menu calls `open_leaderboard()`. Toss-shell runtime test pending (TQA-01) |
| `getUserKeyForGame` | Phase 4.19 done: `fetch_game_user_key()` wired with all result-case handling; hash persisted via `SaveManager`; Toss-shell test pending |
| Main Menu launch flow | Phase 4.19b done: app launches to `MainMenu` (Start Game + Ranking); `GameRoot.start_game()` is public + group-accessible; restart paths bypass scene reload |
| Ads | **Phase 4.20 planning done (Session 42):** Official APIs confirmed (IntegratedAd v2 min v5.247.0; BannerAd min v5.241.0). Placement policy locked: interstitial at game-over / max-clear / between-run only; PauseMenu excluded (modal prohibition). Phase 4.21 implementation blocked on Toss console business/settlement setup. |
| Audio resources / legal proof | Missing; future dedicated resource/legal pass required |
| Web export dry run | **Done (Session 41):** Godot 4.6.2 Web templates installed from official GitHub release. Export produced at `exports/toss_web_dry_run/`. Total: 36.40 MB. |
| `.ait` bundle size audit | **PASS (dry run, Session 41):** 36.40 MB unpacked. 63.6 MB headroom. Dominant contributor: Godot engine `.wasm` (36 MB). Game `.pck` only 110 KB (no audio/art yet). Re-audit required after audio/art pass. |
| Viewport / pinch-zoom in HTML | **Confirmed (Session 41):** Godot 4.6.2 default shell already includes `user-scalable=no` and `body{touch-action:none}`. Our `head_include` adds `maximum-scale=1.0` and `overscroll-behavior:none`. Device validation still pending. |

---

## Risks & Blockers

| # | Risk | Severity | Status |
|---|------|----------|--------|
| R-01 | Validation used Godot 4.6.2 headless scripted runtime, not visible interactive editor/device play | Medium | Open |
| R-02 | Visible/game-feel aspects such as touch ergonomics, inner-radius rotation readability, 7-shot spread readability, and max-clear result screen still need interactive confirmation | Medium | Open |
| R-03 | Save migration passed in a temporary HOME-based runtime path and should still be rechecked in the user’s normal local Godot app-data path | Medium | Open |
| R-04 | Toss/device-specific behavior remains outside this headless runtime pass | Medium | Open |
| R-05 | TossBridge API surface unverified | High | Blocked on Toss test harness |
| R-06 | Audio assets and license proofs do not exist | Medium | Blocked until audio/legal pass |
| R-07 | Safe-area not device-validated | Medium | Blocked until device available |
| R-08 | No real `.ait` export candidate exists yet, so the 100MB decompressed-size gate is still unmeasured | Medium | Open |
| R-09 | Ad timing on pause screens is a policy risk and should not be treated as the default interstitial plan | High | Open |
| R-10 | C-27: PlatformBridge mutes audio on background but game simulation loop (tree pause) on background is not confirmed wired | Medium | **Phase 4.19 done structurally** — `get_tree().paused = true` on hidden, `false` on visible with `_paused_for_background` guard; device test still pending |
| R-11 | C-26: Pinch-zoom not explicitly disabled in HTML export template; may allow user to scale the game view on mobile browsers | Medium | Open — needs HTML template audit before export |
| R-12 | C-25/C-28: Toss console registration (app name, icon, scheme URL) not yet done; submission blocked until console is configured | High | Blocked on console access |
| R-13 | TQA-02: Minimum Toss app version gating (`v5.221.0` for Game Center, `v5.232.0` for getUserKeyForGame) not yet implemented in PlatformBridge; older app versions may crash instead of degrading gracefully | Medium | **Phase 4.19 done structurally** — constants declared; all wrappers detect `undefined` return (= unsupported version) and degrade gracefully; Toss-device validation still pending |
| R-14 | CM-01: No crash/error monitoring (Sentry or equivalent) integrated yet; post-launch issues will be blind | Low–Medium | Open — recommended before production submission |
