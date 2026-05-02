# Implementation Plan — game_junseokism.ver1

## Current Sequence

| Step | Focus | Status |
|------|-------|--------|
| 0 | Project scaffold | Complete |
| 1 | Core gameplay loop (prototype — center-origin) | Complete (prototype) |
| 2 | Danger presentation + pause/sound control | Complete |
| 2.5 | Architecture hardening / layered refactor | Complete |
| 3 | Skill bar + Overclock + HUD upgrades | Complete |
| 4 | Toss platform compliance wiring | Complete |
| 4.5 | Gameplay correction pass — shrinking continuous wall correction | Implemented |
| **4.6** | **Combat constitution correction** — center-origin firing + bounce/spread projectile rules | **Implemented, runtime validation next** |
| **4.7** | **Freeze-readiness validation** — remove hidden geometry coupling and run one final Godot smoke test | **In progress** |
| **4.8** | **Input system expansion** — virtual aim joystick with left/center/right placement switching | **Implemented, runtime validation next** |
| **4.9** | **Progression signaling / HUD generalization** — generic tier unlock signaling and current-weapon / next-threshold HUD | **Implemented, runtime validation next** |
| **4.10** | **Electric Split Arrow implementation** — real K `150–499` tier-3 combat + required 2-layer wall behavior | **Implemented, runtime validation next** |
| **4.11** | **Piercing Bomb Spear implementation** — original single-spear tier-4 combat pass | **Implemented, later superseded by 4.13 override** |
| **4.12** | **Late-game progression spec correction** — revise K `300–2000` progression/wall structure before further combat passes | **Implemented (doc-only, later partially overridden from K `500+`)** |
| **4.13** | **K `500+` Siege Override** — replace single-spear late-game with the current 7-shot siege volley and 5-layer walls | **Implemented, headless runtime validation passed** |
| **4.14** | **K `300–499` wall alignment + K `500` Overclock trigger** — keep Electric Split walls at Strong/Armored and unlock the shared attack-speed buff near the joystick | **Implemented, headless runtime validation passed** |
| **4.15** | **Top K Progress Bar + Level 1/2 Visualization** — add a top horizontal K gauge without changing gameplay rules | **Implemented, runtime validation next** |
| **4.16** | **K `1000` Level-Transition Design Realignment** — reclassify `K = 1000` as level clear / Level 2 restart instead of the next combat tier | **Implemented (doc-only)** |
| **4.17** | **Level-loop + late-band tuning validation** — K1000 level-loop, full-radius wall rotation, 7-shot siege, and faster shared Overclock passed headless Godot smoke validation; visible interactive follow-up remains | **Headless runtime passed; interactive follow-up pending** |
| **4.18** | **Max Level 100 Runtime Cap / Clear Rule** — add explicit Level 100 clear/end behavior and cap handling | **Implemented, headless 47/47 passed** |
| **4.19** | **Game Center Leaderboard + `getUserKeyForGame` Platform Pass** — submit `total_progress`, open leaderboard safely, and identify users with the game-specific Toss key | **Implemented, headless 61/61 passed (Toss-shell unverified)** |
| **4.19c** | **C-26 HTML Export Shell Pass** — create `export_presets.cfg` with Godot 4.6 "Toss Web" preset; `html/head_include` sets `user-scalable=no`, `touch-action:none`, `overscroll-behavior:none`; no gameplay change; static-validated | **Done (Session 39)** |
| **4.19d** | **Web Export Dry Run + Official Benchmark** — Godot 4.6.2 Web templates installed from official GitHub release; export dry run produced 36.40 MB; 100MB: PASS; HTML viewport/touch/overscroll confirmed; official App-in-Toss docs cross-checked | **Done (Session 41)** |
| **4.20** | **Ads Integration Planning / Policy-Safe Placement Pass** — official App-in-Toss ad APIs confirmed; placement policy locked; prerequisites documented; no code implemented | **Done — planning only (Session 42)** |
| **4.21** | **Ads Implementation Pass** — implement `loadFullScreenAd`/`showFullScreenAd` in PlatformBridge; wire `GameState.game_over` and `max_level_cleared` triggers; implement BannerAd; wire audio mute/restore; add `isSupported()` version gates; use test IDs; rerun bundle audit | **Blocked — requires console/business/settlement setup first** |
| 5 | Audio resource / legal pass | Pending |
| 6 | Art / resource optimization pass | Pending |
| 7 | Toss QR/device QA + bundle size audit | Pending |
| 8 | Pre-release validation | Pending |

---

## Phase 4.6 — Combat Constitution Correction

**Goal:** Replace the now-obsolete bottom-origin firing model with the new central radial-defense model, while preserving the shrinking-wall correction and the existing platform/UI architecture.

**Current state:** center-origin firing, bounce, spread, exact launch-point geometry, and top-of-screen unlock readability are implemented structurally. The remaining work in this phase is live Godot validation.

### What Must Change

#### 1. Center-Origin Firing

- `scenes/game/game_root.tscn`: move `Weapon` back to the core center so projectile launch origin is the protected center.
- `scripts/gameplay/weapon.gd`: fire from the center core area and update presentation comments/visuals so they no longer imply bottom-origin shooting.
- `scripts/gameplay/input_handler.gd`: keep aim-direction handling, but ensure aim origin is the center launch point rather than the bottom-of-play-field position.
- Projectile-local visuals/collision may need to be biased forward from the node origin so the cyan point reads as the exact launch point on screen.

#### 2. Arrow Bounce + 3-Target Spread

- `scripts/gameplay/arrow_projectile.gd` must:
  - bounce **3 times**
  - apply spread hits to the impacted segment plus immediate left/right neighbors
  - handle circular wrap-around robustly
- `scripts/gameplay/ring_instance.gd` must expose ring-aware hit resolution so spread damage stays aligned with the logical segmented wall.
- `scripts/gameplay/brick_instance.gd` must remain a presentation-side segment view, but it may pass projectile hits back up to `RingInstance` so spread logic stays ring-aware.

#### 3. Stone 5-Target Spread + Tunable Unlock

- `scripts/gameplay/stone_projectile.gd` must apply spread hits to the impacted segment plus two neighbors on each side.
- The stone unlock threshold must stay configurable in data, not hardcoded in gameplay logic.
- `data/progression.json` remains the intended tuning point unless a better small config hook is required during implementation.

#### 4. Unlock Readability + Future Hook

- The destroyed-brick progression value used for stone unlock must be prominently visible at the top of the screen.
- If current `K` is reused for unlock progression, that top display must make the stone target threshold clear.
- A threshold-crossing hook/state should exist so future unlock SFX/VFX can subscribe without reshaping the gameplay architecture again.

### What Must NOT Change in This Pass

- Wall continuity / visible segmentation / segment-count reduction stay intact
- Layered architecture boundaries stay intact
- UI (HUD, SkillBar, PauseMenu, ConfirmExitDialog) stays intact
- Toss compliance wiring stays intact
- Brick typing (NORMAL/STRONG/ARMORED with HP > 1) stays intact
- No unrelated feature work added

### Acceptance Criteria

- [x] Projectiles originate from the center core area structurally
- [x] Aim direction is computed from the center launch point structurally
- [x] Continuous segmented wall behavior remains intact structurally
- [x] Active wall segment count still decreases with radius structurally
- [x] Default arrow now has a 3-bounce budget structurally
- [x] Default arrow targets 3 wrapped segments per hit structurally
- [x] Stone targets 5 wrapped segments per hit structurally
- [x] Stone unlock threshold remains configurable through progression data
- [x] K scoring, danger, pause, save, sound, and platform wiring remain intact structurally
- [x] Projectile visuals are authored to visibly originate from the exact cyan center point structurally
- [x] Stone unlock progress is prominently legible at the top structurally
- [x] Clean threshold-crossing hook is exposed for later unlock VFX/SFX
- [ ] Runtime/editor smoke test still required

## Phase 4.8 — Input System Expansion

**Goal:** Add a virtual aim joystick with left/center/right bottom placement switching while preserving the center-origin combat model and existing layered runtime structure.

**Current state:** the joystick is implemented structurally. The remaining work in this phase is a focused Godot smoke test of joystick usability and non-regression.

### What Changed

- `InputHandler` now acts as the shared aim-state service instead of owning raw pointer-to-aim conversion.
- `AimJoystick` now lives in `RootUI/SafeAreaContainer` and drives:
  - `InputHandler.aim_direction`
  - the weapon aim line
  - auto-fire launch direction
- The joystick defaults to bottom-center.
- Left/right placeholder buttons move the joystick anchor between bottom-left, bottom-center, and bottom-right.
- Releasing the joystick does not clear aim; the last valid normalized direction remains active.
- Joystick position is persisted as a lightweight preference through `SaveManager`.

### What Must NOT Change In This Pass

- Center-origin firing stays intact
- Automatic firing stays intact
- Wall continuity / compaction / no-overlap stay intact
- Bounce / spread projectile behavior stays intact
- K scoring, danger, pause, sound, save, platform hooks, and skill-slot UI stay intact
- No final art/UI polish in this pass

### Acceptance Criteria

- [x] Virtual aiming joystick exists structurally
- [x] Default joystick position is bottom-center structurally
- [x] Left/right buttons move the joystick between left / center / right structurally
- [x] Joystick updates aim direction without moving the core/player structurally
- [x] Auto-fire keeps using the last valid aim direction after release structurally
- [x] Joystick position can persist as a lightweight preference structurally
- [ ] Runtime/editor smoke test still required

## Phase 4.9 — Generic Tier Signaling / HUD Progression Feedback

**Goal:** Lock the progression plan in data/docs and generalize player-facing tier feedback without implementing the late-tier combat behaviors yet.

**Current state:** generic tier unlock signaling and HUD current-weapon / next-threshold display are implemented structurally. Late-tier combat remains intentionally deferred.

### What Changed

- `data/progression.json` now carries:
  - locked K bands
  - display names
  - per-tier `implemented` flags
- `ProgressionService` now exposes:
  - current configured progression tier
  - current implemented combat tier
  - next configured tier
  - display names
- `GameState` now emits:
  - generic `tier_threshold_reached(...)`
  - generic `progression_display_changed(...)`
  - while preserving the stone-specific compatibility hook
- HUD now shows:
  - current `K`
  - current implemented weapon name
  - next unlock name + threshold, or READY/MAX state

### Locked spec decisions recorded in this phase

- Electric Split Arrow keeps its full intended electric-hit quota by reallocating into other valid targets when preferred targets are already destroyed.
- Piercing Bomb Spear was still a 2-layer band at the time of this phase, but that late-game assumption is now superseded by Phase 4.13.
- Hybrid Siege defaults to 2 side electric bolts; later docs now define that on top of a siege core that has since been tuned from 5 shots to 7 shots.

### What Must NOT Change In This Pass

- No full Electric Split Arrow combat behavior yet
- No full Piercing Bomb Spear combat behavior yet
- No full Hybrid Siege combat behavior yet
- No broad architecture refactor
- No regressions to current arrow / stone / split-arrow combat

### Acceptance Criteria

- [x] Progression plan is locked in docs/data
- [x] Generic tier-threshold signaling exists structurally
- [x] HUD shows current weapon and next threshold path structurally
- [x] K remains the single progression source structurally
- [ ] Runtime/editor smoke test still required

## Phase 4.10 — Electric Split Arrow Implementation

**Goal:** Make K `150–499` a real combat band with a true tier-3 Electric Split Arrow path and the minimum required 2-layer wall behavior.

**Current state:** the tier-3 combat path and 2-layer wall spawn are now implemented structurally. The remaining work in this phase is a focused Godot smoke test of the K `150–499` band.

### What Changed

- `data/progression.json` now marks tier `3` (`Electric Split Arrow`) as implemented.
- `Weapon` now maps tier `3` to a dedicated electric bolt split-fire path instead of falling back to an older projectile.
- Added `electric_split_projectile.gd` / `electric_split_projectile.tscn`:
  - `3` bolts at `-15° / 0° / +15°`
  - `1` bounce per bolt
  - ring-aware electric hit resolution
- `RingSpawnPlanner` now emits layered wall spawn specs for K `150–499`:
  - outer layer = `STRONG`
  - inner layer = `ARMORED`
  - layer spacing now comes from `data/game_config.json`
- `RingSpawner` now spawns one or multiple coordinated `RingInstance` layers from planner output.
- `RingInstance` now supports:
  - wall group / layer identity
  - angle-to-segment mapping across layers with different segment counts
  - deterministic electric target selection across the struck layer and adjacent layer
  - fallback/reallocation that preserves the intended `6` logical hits when preferred cells are already gone
- `BrickInstance` now exposes `resolve_electric_projectile_hit(...)` so the projectile stays thin and ring-aware logic stays in the wall layer.

### Locked behavior implemented in this phase

- K `150–499` = `Electric Split Arrow`
- `3` bolts at `-15° / 0° / +15°`
- `1` bounce per bolt
- Preferred logical hit sets:
  - struck layer `{I-1, I, I+1}`
  - adjacent layer `{I-1, I, I+1}`
- Missing preferred targets are reallocated deterministically so the electric effect preserves its full intended hit budget instead of shrinking
- Wall thickness for this band is real `2`-layer structure, not fake single-ring density

### What Must NOT Change In This Pass

- Arrow / Stone / Split Arrow behavior below K `150`
- Center-origin firing and joystick aim flow
- Progression HUD/signaling model
- Toss/platform/pause/save/sound scaffolding
- Piercing Bomb Spear and Hybrid Siege combat behavior

### Acceptance Criteria

- [x] Tier `3` no longer falls back to an older projectile
- [x] Electric Split Arrow launches as a `3`-bolt split pattern structurally
- [x] Each effective electric hit event preserves the intended `6` logical-hit budget structurally
- [x] K `150–499` wall spawn uses `2` actual layers structurally
- [x] Outer/inner layer composition is `Strong` / `Armored` structurally
- [x] Generic tier HUD/signaling still works structurally
- [ ] Runtime/editor smoke test still required

## Phase 4.11 — Piercing Bomb Spear Implementation

**Goal:** Historical phase. This originally made K `500–999` a real tier-4 combat band under the older single-spear / 2-layer assumption. Phase 4.13 now supersedes that late-game runtime model.

**Current state:** kept for historical traceability only. The later K `500+` runtime model is now governed by Phase 4.13.

### What Changed

- `data/progression.json` now marks tier `4` (`Piercing Bomb Spear`) as implemented.
- `Weapon` now maps tier `4` to a dedicated spear projectile instead of falling back to an older tier.
- Added `piercing_bomb_spear_projectile.gd` / `piercing_bomb_spear_projectile.tscn`:
  - single spear projectile
  - `0` bounces
  - up to `2` pierced segment collisions
  - one terminal explosion on the last allowed pierce
- `RingSpawnPlanner` now keeps K `150–999` on real `2`-layer wall spawn:
  - outer layer = `STRONG`
  - inner layer = `ARMORED`
- `BrickInstance` now exposes:
  - `resolve_piercing_spear_hit(...)`
  - `trigger_terminal_explosion(...)`
  - `get_segment_hit_key()`
- `RingInstance` now supports:
  - direct spear-hit routing
  - deterministic fixed-neighborhood terminal explosion targeting
  - outward / inward layer lookup by layer index

### Locked behavior implemented in this phase

## Phase 4.16 — K1000 Level-Transition Design Realignment

**Goal:** Stop treating `K1000+` as the immediate Hybrid combat continuation and lock `K = 1000` as the level-transition threshold instead.

**Current state:** this is a design/spec correction only. Runtime code has **not** been realigned yet.

### What Changed In The Design

- `K 0–999` is now **Level 1**.
- When `current_level_k` reaches `1000`, the current level is cleared.
- The game then transitions to **Level 2**.
- Level 2 restarts the same structural progression loop as Level 1:
  - `0–29` Arrow
  - `30–79` Stone
  - `80–149` Split Arrow
  - `150–499` Electric Split Arrow
  - `500–999` Piercing Bomb Siege
- Ranking should be derived from level first, then K inside the level:
  - `total_progress = (current_level - 1) * 1000 + current_level_k`

### What This Supersedes

- The old assumption that `K1000+` is the immediate `Hybrid Siege` combat band
- The old assumption that the active K1000+ wall composition is the intended next runtime behavior
- The old assumption that the top `LEVEL 1 / LEVEL 2` bar is only a cosmetic display over raw K forever

### What Remains True Right Now

> **Superseded by Phase 4.17b.** The K `1000` level-loop transition is now implemented and headless-validated. `K1000+` is no longer an active runtime continuation band. Hybrid remains only a future optional concept and is not in the current runtime.

- Hybrid remains only a **future optional concept**, not a current runtime feature.

### Acceptance Criteria

- [x] Product/docs no longer imply `K1000+ Hybrid` is the immediate continuation
- [x] `K1000` is explicitly documented as the level-transition threshold
- [x] Level 2 is explicitly documented as a Level 1-like structural restart
- [x] Ranking is explicitly documented as level-first, then `current_level_k`
- [ ] Runtime level-loop implementation still required

- K `500–999` = `Piercing Bomb Spear`
- single spear projectile
- `0` bounces
- up to `2` pierced segment collisions
- terminal explosion neighborhood:
  - same layer = `{I, I-1, I+1}`
  - adjacent outer layer center = `{L-1, I}` if that layer exists
  - adjacent inner layer center = `{L+1, I}` if that layer exists
- destroyed explosion targets are not refilled; the neighborhood remains fixed and may yield fewer live hits
- K `500–999` remains at `2` real wall layers only

### What Must NOT Change In This Pass

- Arrow / Stone / Split Arrow / Electric Split Arrow behavior below K `500`
- Center-origin firing and joystick aim flow
- Progression HUD/signaling model
- Toss/platform/pause/save/sound scaffolding
- Hybrid Siege combat behavior

### Acceptance Criteria

- [x] Tier `4` no longer falls back to an older projectile
- [x] Piercing Bomb Spear now launches as a single dedicated projectile structurally
- [x] The `2`-pierce rule is implemented structurally
- [x] Terminal explosion uses the locked deterministic neighborhood structurally
- [x] K `500–999` stays on `2` real wall layers structurally
- [x] Generic tier HUD/signaling still works structurally
- [ ] Runtime/editor smoke test still required

## Phase 4.12 — Late-Game Progression Spec Correction

**Goal:** Revise and lock the late-game design from K `300` upward before more combat code is added.

**Current state:** this historical spec-correction phase is now mostly archival. Its older K `500+` and K `1000+` assumptions are superseded by later phases, especially 4.13, 4.14, and 4.16.

### What Changed

- Replaced the old assumption that K `150–499` is one flat Electric Split Arrow band.
- Replaced the old assumption that K `500–999` stays on `2` wall layers.
- Replaced the old assumption that K `1000+` is a vague `3`-layer Hybrid Siege band.
- Locked a then-current late-game draft that was useful for the next spec discussions, but is no longer authoritative:
  - K `300–499` = `Electric Split Arrow` + `2` layers `Strong + Strong`
  - K `500–699` = `Piercing Bomb Spear` + `3` layers `Strong + Strong + Normal`
  - K `700–999` = `Piercing Bomb Spear` + `3` layers `Strong + Armored + Strong`
  - K `1000–1499` = `Hybrid Siege` + `4` layers `Normal + Strong + Armored + Strong`
  - K `1500–2000` = `Hybrid Siege` + `4` layers `Strong + Armored + Strong + Armored`
- That draft Hybrid meaning was:
  - center breach spear-like shot
  - two side electric suppression bolts
- Those K `1000+` Hybrid-continuation assumptions are now superseded by Phase 4.16, which reclassifies `K = 1000` as a level-transition threshold instead of the next immediate combat band.
- Preserved HP readability as fixed by type:
  - `Normal = 1`
  - `Strong = 2`
  - `Armored = 3`

### What Must NOT Change In This Pass

- No new combat code
- No broad architecture refactor
- No Toss/platform/UI redesign
- No retroactive early-game redesign below K `300`

### Acceptance Criteria

- [x] K `300–2000` late-game progression ranges are explicitly documented
- [x] Old K `500–999` `2`-layer assumption is replaced in docs
- [x] Old K `1000+` `3`-layer / vague Hybrid assumption is replaced in docs
- [x] Hybrid meaning is explicit and implementable
- [x] The next narrow implementation pass is clearly defined

## Phase 4.13 — K `500+` Siege Override

**Goal:** Replace the older single-spear K `500–999` late-game pattern with the current siege volley and raise K `500+` wall pressure to 5 real concentric layers.

**Current state:** the K `500–999` runtime path now uses the current 7-shot siege volley structurally, and K `500+` wall spawn now uses 5 real layers structurally. Its old K `1000+` continuation assumption is now superseded at the design level by Phase 4.16.

### What Changed

- Tier `4` no longer fires a single spear.
- `Weapon` now fires a `7`-shot siege volley at:
  - `-36° / -24° / -12° / 0° / +12° / +24° / +36°`
- The center spear now acts as the main breach projectile:
  - `0` bounces
  - up to `2` pierced collisions
  - enlarged terminal explosion neighborhood with same-layer radius `2`
- The six side spears now act as support breach shots:
  - `0` bounces
  - `1` pierced collision each
  - smaller support explosion neighborhood with same-layer radius `1`
- `RingSpawnPlanner` now raises K `500+` wall pressure to `5` real layers:
  - K `500–999` = `Strong + Strong + Normal + Strong + Armored`
  - K `1000+` active wall band: **superseded** — Phase 4.17b replaced this with a level-loop transition; no active K `1000+` continuation band exists in current runtime
- Explosion targeting remains deterministic and logical:
  - same-layer segment neighborhood
  - adjacent outer / inner layer centers when those layers exist

### What Must NOT Change In This Pass

- Arrow / Stone / Split Arrow / Electric Split Arrow behavior below K `500`
- Center-origin firing and joystick aim flow
- Generic progression HUD/signaling model
- Toss/platform/pause/save/sound scaffolding
- Any future optional Hybrid electric-suppression combat behavior beyond the doc-level definition

### Acceptance Criteria

- [x] Tier `4` no longer fires as a single spear structurally
- [x] K `500–999` now uses a real `7`-shot siege volley structurally
- [x] K `500+` now uses `5` real wall layers structurally
- [x] K `500–999` uses the locked `Strong + Strong + Normal + Strong + Armored` composition structurally
- [x] K `1000+` wall spawn uses the then-locked `Strong + Armored + Strong + Armored + Strong` composition structurally
- [x] Earlier combat bands remain intact structurally
- [ ] Runtime/editor smoke test still required

## Phase 4.14 — K `300–499` Wall Alignment + K `500` Overclock Trigger

**Goal:** Keep K `300–499` on the real Electric Split wall composition already accepted for runtime, and expose the first real attack-speed buff near the joystick by reusing the existing Overclock effect.

**Current state:** runtime and docs are now aligned on K `300–499 = Electric Split Arrow + 2 layers Strong/Armored`, and Overclock is now shared between the bottom skill slot and the new joystick-area trigger. Runtime/editor validation is still required.

### What Changed

- Reaffirmed the K `150–499` Electric Split wall composition in runtime as:
  - outer = `Strong`
  - inner = `Armored`
- Reused the existing Overclock effect instead of adding a second attack-speed buff system.
- Moved the true Overclock cooldown / active-state ownership into `Weapon`, so multiple UI triggers now point at the same buff truth.
- `skill_slot.gd` now reads and triggers the shared weapon Overclock state rather than running a separate local cooldown model.
- `aim_joystick.gd` now builds:
  - a placeholder horizontal divider above the joystick
  - a placeholder buff button above that divider
- The new joystick-area buff button unlocks at `K >= 500`.
- Before `K 500`, Overclock UI remains visibly locked/disabled instead of silently hidden.

### What Must NOT Change In This Pass

- Arrow / Stone / Split Arrow / Electric Split combat behavior
- K `500+` siege volley behavior
- Center-origin firing and joystick aim logic
- Generic progression HUD/signaling model
- Toss/platform/pause/save/sound scaffolding

### Acceptance Criteria

- [x] K `300–499` remains aligned to `2` layers `Strong + Armored` structurally
- [x] Existing Overclock effect is reused as the K `500` attack-speed buff
- [x] A placeholder buff button exists above the joystick divider structurally
- [x] The buff button unlocks at K `500` and activates the shared Overclock effect structurally
- [x] The bottom skill-slot scaffold still exists and points to the same Overclock state
- [x] Earlier combat tiers and K `500+` siege behavior remain intact structurally
- [ ] Runtime/editor smoke test still required

## Phase 4.15 — Top K Progress Bar + Level 1/2 Visualization

**Goal:** Add a top horizontal K progress bar that improves player-facing progression readability without adding a new progression system.

**Current state:** the top HUD now includes a placeholder level label and horizontal progress bar driven by the existing `K` value. That raw-K heuristic is now superseded by the level-loop design locked in Phase 4.16, but the runtime conversion has not happened yet.

### What Changed

- Added a top `LevelLabel` to HUD.
- Added a top horizontal `KProgressBar` to HUD.
- Kept `K` as the only progression source.
- Locked temporary level-band interpretation for the HUD at the time of this phase:
  - `K 0–999 = LEVEL 1`
  - `K 1000–1999 = LEVEL 2`
- The bar fills left-to-right within the active level band.
- At `K >= 1000`, the bar resets and fills again using Level 2 progress.
- Existing `K`, weapon name, next-threshold, best-K, and pause button HUD elements remain in place.
- This is now considered a placeholder visualization that should be replaced by real `current_level` / `current_level_k` state in the next runtime pass.

### What Must NOT Change In This Pass

- No combat rule changes
- No wall model changes
- No joystick behavior changes
- No second progression counter
- No final visual polish

### Acceptance Criteria

- [x] Top horizontal K progress bar exists structurally
- [x] LEVEL 1 / LEVEL 2 switching exists structurally
- [x] Bar fills left-to-right from the same K source structurally
- [x] Existing HUD progression text remains intact structurally
- [ ] Runtime/editor smoke test still required

## Phase 4.19 — Game Center Leaderboard + getUserKeyForGame Platform Pass

**Goal:** Wire App-in-Toss platform APIs for game user identity (`getUserKeyForGame`) and Game Center leaderboard (score submit, open UI). Implement version gating, duplicate-submit prevention, and C-27 background game-tree pause. No gameplay code changed.

### What Changed

- **`scripts/autoload/platform_bridge.gd`**
  - Added constants `MIN_VERSION_LEADERBOARD = "5.221.0"`, `MIN_VERSION_USER_KEY = "5.232.0"` (TQA-02)
  - Added signals: `game_user_key_received(key_hash)`, `game_user_key_failed(reason)`, `leaderboard_score_submitted(success)`
  - Added vars: `_score_submitted_this_run: bool` (duplicate guard), `_paused_for_background: bool` (C-27 restore guard)
  - Connected `GameState.game_started → _on_game_started()` in `_ready()` to reset `_score_submitted_this_run`
  - `init_platform()`: now also calls `fetch_game_user_key()` on Web init
  - `on_visibility_hidden()`: now also sets `get_tree().paused = true` (C-27) with `_paused_for_background` guard
  - `on_visibility_visible()`: now also sets `get_tree().paused = false` only if `_paused_for_background` (C-27, GC-02)
  - Added `func fetch_game_user_key()`: handles `OK/HASH`, `INVALID_CATEGORY`, `ERROR`, `UNSUPPORTED_VERSION`, `NO_BRIDGE`, `EXCEPTION`; persists hash via `SaveManager`
  - Added `func submit_leaderboard_score(total_progress: int)`: score as numeric string; blocks on `_score_submitted_this_run`; no crash on failure
  - Added `func open_leaderboard()`: no-op on non-Web; C-27 tree-pause handles state freeze on backgrounding
  - Added `func _on_game_started()`: resets `_score_submitted_this_run = false` (GM-02)
- **`scripts/autoload/save_manager.gd`**: added `set_game_user_key()` / `get_game_user_key()` storing `"game_user_key"` in `_data`
- **`scripts/gameplay/game_root.gd`**: `_on_game_over()` and `_on_max_level_cleared()` each call `PlatformBridge.submit_leaderboard_score(GameState.total_progress)` (GM-01)

### Acceptance Criteria

- [x] `fetch_game_user_key()` handles all documented result cases
- [x] `submit_leaderboard_score()` uses numeric string score; blocks on duplicate flag
- [x] `open_leaderboard()` implemented; C-27 handles state preservation
- [x] `MIN_VERSION_LEADERBOARD = "5.221.0"` and `MIN_VERSION_USER_KEY = "5.232.0"` declared
- [x] `_score_submitted_this_run` prevents duplicate submission; reset on new run
- [x] Score submitted only at game-over and max-level-clear (GM-01)
- [x] `SaveManager` stores `"game_user_key"` hash
- [x] C-27: game tree pauses on background; resumes on foreground (with manual-pause guard)
- [x] Non-Web graceful no-op with `push_warning`, no crash
- [x] Headless QA: 61/61 passed (Godot 4.6.2)
- [ ] **Toss-shell runtime validation pending** (TQA-01) — requires Toss QR private-test environment

---

## Phase 4.18 — Max Level 100 Runtime Cap / Clear Rule

**Goal:** Turn the newly locked Level `1–100` rule into explicit runtime behavior.

### Steps
1. Add the Level `100` cap and end-of-run clear behavior.
2. Define the exact `Level 100 K1000` completion flow.
3. Confirm `total_progress` handling at the cap.
4. Validate that no extra level or overflow continuation appears after max clear.

---

## Phase 4.19 — Game Center Leaderboard + `getUserKeyForGame`

**Goal:** Integrate Toss game-specific identity and leaderboard APIs without changing combat rules.

### Steps
1. Replace placeholder user-ID assumptions with `getUserKeyForGame`.
2. Submit `total_progress` through the official Game Center leaderboard API at game-over / run-complete.
3. Prevent duplicate submit for the same run.
4. Handle unsupported app version, retry, and foreground/background return safely when opening the leaderboard.

---

## Phase 4.20 — Ads Integration Planning / Policy-Safe Placement

**Goal:** Lock the final monetization plan before ad SDK/runtime integration.

### Steps
1. Confirm supported App-in-Toss ad APIs / minimum versions.
2. Lock banner placement that does not block gameplay or safe area.
3. Lock interstitial timing at expected transitions only.
4. Explicitly avoid treating pause-modal timing as the default interstitial slot.
5. Define preload / mute / resume requirements for ads.

---

## Phase 5 — Audio Resource / Legal Pass

**Goal:** Add production audio in a controlled, licensed, bundle-aware way.

### Steps
1. Prepare the audio resource manifest.
2. Import only licensed / provable BGM and SFX assets.
3. Prefer banded BGM or intensity-stem variation over `100` unique tracks.
4. Validate C-02 through C-05 on target devices.
5. Keep raw source masters out of the shipped `.ait`.

---

## Phase 6 — Art / Resource Optimization Pass

**Goal:** Replace placeholders while protecting gameplay readability and bundle limits.

### Steps
1. Import pixel-art wall segments/projectiles/UI assets.
2. Preserve readability at portrait mobile scale.
3. Re-check danger readability and bottom skill-slot clarity.
4. Verify continuous wall visual coherence with the new tiled segment count.
5. Remove raw source files and optimize shipped assets.

---

## Phase 7 — Toss QR/Device QA + Bundle Size Audit

**Goal:** Validate real Toss runtime behavior and confirm upload-size compliance.

### Steps
1. Export the real upload candidate `.ait`.
2. Run QR/device checks for lifecycle, safe area, orientation, exit flow, leaderboard backgrounding, and ad timing.
3. Measure decompressed bundle size and largest files.
4. Confirm the upload candidate stays within the `100MB` decompressed limit.

---

## Phase 8 — Pre-Release Validation

**Goal:** Submission-ready build, checklist, legal evidence, and release packaging.

### Steps
1. Full playtest pass.
2. Final device sanity checks.
3. Legal/resource/license sign-off.
4. Final checklist sign-off and release prep.

---

## Phase 4.18 — Max Level 100 Runtime Cap / Clear Rule

**Goal:** Implement the Level 100 clear/end behavior (GM-04). When the player reaches Level 100 K1000, end the run with a distinct MAX LEVEL CLEAR result instead of advancing to Level 101.

### What Changed

- **`game_state.gd`**
  - Added `const MAX_LEVEL: int = 100`
  - Added `signal max_level_cleared()`
  - Added `func trigger_max_level_clear()`: sets `is_playing = false`, persists result, emits `max_level_cleared`
  - Modified `add_k()`: added `if not is_playing: return` guard; at `current_level_k >= _level_size_k`, checks `current_level >= MAX_LEVEL` first — if so, caps `current_level_k = _level_size_k` and calls `trigger_max_level_clear()` instead of advancing level
  - Modified `get_progression_display_state()`: when `next_tier` is empty, returns `"MAX CLEAR"` label (instead of `"LEVEL 101"`) if `current_level >= MAX_LEVEL`
- **`game_root.gd`**
  - Connected `GameState.max_level_cleared` → `_on_max_level_cleared()`
  - `_on_max_level_cleared()` calls `_ring_spawner.stop()` and `DangerManager.reset()` (same as `_on_game_over`)
- **`game_over_screen.gd`**
  - Connected `GameState.max_level_cleared` → `_on_max_level_cleared()`
  - `_on_max_level_cleared()` shows `"MAX LEVEL CLEAR!"` prefix instead of `"GAME OVER"`

### Final Cap Formula

```
total_progress at max clear = (MAX_LEVEL - 1) * _level_size_k + _level_size_k
							= (100 - 1) * 1000 + 1000
							= 100000
```

### What Must NOT Change In This Pass

- K500–999 7-shot Piercing Bomb Siege
- Overclock 3x baseline fire rate
- Wall rotation behavior
- K1000 level-loop for Levels 1–99
- Ordinary core-breach game-over path

### Acceptance Criteria

- [x] `MAX_LEVEL = 100` constant in `game_state.gd`
- [x] `signal max_level_cleared` added
- [x] Level 100 K1000 → `trigger_max_level_clear()` called, NOT level 101
- [x] `current_level` never becomes 101
- [x] `total_progress` at max clear == 100000
- [x] `is_playing` set to false on max clear (subsequent `add_k` calls are no-ops)
- [x] `SaveManager.record_run_result()` called on max clear (best_total_progress, best_level, best_level_k persist)
- [x] `game_over_screen` shows `"MAX LEVEL CLEAR!"` on max clear
- [x] Ordinary `trigger_game_over()` path unchanged
- [x] HUD at Level 100 K500-999 shows `NEXT: MAX CLEAR @ 1000` instead of `LEVEL 101`
- [x] Level 1–99 K1000 transitions still advance to next level normally
- [x] Headless QA: 47/47 passed (Godot 4.6.2)

---

## Superseded Prototype Phases (Reference Only)

Phase 1 produced an early center-origin prototype, and later passes temporarily moved firing to the bottom while fixing wall structure. The current correction re-establishes center-origin combat while preserving the improved wall model and layered runtime structure.
