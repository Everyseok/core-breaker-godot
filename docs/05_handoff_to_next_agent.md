# Handoff To Next Agent — 2026-04-30

## Current Addendum

This handoff document originally captured the post-architecture-hardening state from `2026-04-21`.
It is now partially historical.

The current authoritative progression/design correction is:

- `K = 1000` is **not** the next combat tier
- `K = 1000` is the **level transition threshold**
- Level 2 should restart the same structural loop as Level 1
- ranking should be based on:
  - `current_level`
  - `current_level_k`
  - `total_progress = (current_level - 1) * 1000 + current_level_k`
- `Hybrid` is **not** the immediate next implementation target

Important runtime drift still present:

- code/config still carry an active `K1000+` continuation band
- current runtime still falls back to the implemented K500+ siege behavior at K1000+
- current K1000+ wall composition is still active in runtime, but it is now design-inconsistent with the locked level-loop plan

Exact next implementation target after this handoff:

- implement the **K1000 Level Transition / Level-Loop Runtime Pass**
- do **not** implement Hybrid combat first

## Purpose

This document is the direct handoff for the next Claude Code session.
It assumes no memory from prior threads and is intended to let the project proceed cleanly from architecture hardening into freeze confirmation, then rules/progression specification.

---

## What Was Refactored

### Layer extraction

- Added **domain** rules:
  - `scripts/domain/bricks/brick_rules.gd`
  - `scripts/domain/danger/danger_rules.gd`
- Added **application** helpers:
  - `scripts/application/progression/progression_service.gd`
  - `scripts/application/rings/ring_spawn_planner.gd`
- Added **infrastructure** adapters:
  - `scripts/infrastructure/config/json_config_loader.gd`
  - `scripts/infrastructure/persistence/save_file_repository.gd`

### Autoload slimming

- `GameState` now coordinates runtime session state but delegates progression config loading and save-result recording.
- `SaveManager` now coordinates save state through `SaveFileRepository`.
- `DangerManager` now tracks rings and delegates threshold math to `DangerRules`.

### Presentation/business separation

- `BrickInstance` no longer calls `GameState.add_k()` directly.
- `Core` no longer calls `GameState.trigger_game_over()` directly.
- `RingInstance` and `RingSpawner` now bubble events upward by signal.
- `GameRoot` is now the orchestration point for score and game-over flow.

### Scene composition cleanup

- `scenes/main/main.tscn` is now a composition root.
- `scenes/game/game_root.tscn` now contains the gameplay subtree.
- `scenes/ui/root_ui.tscn` now contains the UI subtree.
- `scripts/ui/root_ui.gd` now centralizes safe-area application.

### Focused gameplay-structure correction

- The continuous radial wall system was corrected further:
  - wall segment count now derives from circumference
  - active segment count now compacts downward as radius decreases
  - visible brick-like segmentation is preserved
  - compaction is designed not to introduce large new passable gaps on its own
- `RingInstance` now owns logical segment state separately from spawned brick nodes so the wall can re-tile while preserving destroyed/alive state and typed HP state.

### Focused combat correction

- Center-origin firing is restored:
  - core stays centered in the play field
  - weapon / launch origin now shares that center core area through an explicit launch-origin provider
  - aim-line origin, aim input origin, and projectile spawn are all routed through the same source of truth
- Arrow behavior is corrected structurally:
  - 3-bounce budget
  - wrapped 3-target spread per hit
- Stone behavior is corrected structurally:
  - wrapped 5-target spread per hit
  - unlock threshold remains tunable through `data/progression.json`

### Targeted freeze-readiness fixes

- Hidden danger-geometry coupling is removed:
  - `DangerManager` no longer uses a stale hardcoded `380.0` reference radius
  - `DangerManager` now reads `play_field_radius` from `data/game_config.json`
  - `RingSpawnPlanner` now reads the same `play_field_radius` from `data/game_config.json`
- Freeze guidance is corrected:
  - the project does **not** need another broad architecture pass
  - the remaining gate is one final Godot smoke test before freezing the current structure

---

## What Was Intentionally Not Changed

- No gameplay roadmap expansion was done beyond the focused wall-structure correction and focused combat correction.
- No new combat features were added.
- No new projectile tiers beyond the existing foundation were added.
- No broad architecture rewrite was reopened.
- No monetization, ads, ranking, social, or extra product scope was added.
- No destructive scene rewrite was performed.

---

## Current Stable Entry Points

### Main runtime entry

- `project.godot`
- `scenes/main/main.tscn`

### Gameplay orchestration entry

- `scripts/gameplay/game_root.gd`

### Persistent coordinator entry points

- `scripts/autoload/game_state.gd`
- `scripts/autoload/save_manager.gd`
- `scripts/autoload/audio_manager.gd`
- `scripts/autoload/danger_manager.gd`
- `scripts/autoload/platform_bridge.gd`
- `scripts/gameplay/input_handler.gd` (autoloaded, but still physically located under `scripts/gameplay/`)

---

## Current Folder / Layer Structure

### Presentation

- `scenes/main/`
- `scenes/game/`
- `scenes/gameplay/`
- `scenes/ui/`
- `scripts/gameplay/`
- `scripts/ui/`

### Application

- `scripts/application/progression/`
- `scripts/application/rings/`

### Domain

- `scripts/domain/bricks/`
- `scripts/domain/danger/`

### Infrastructure

- `scripts/infrastructure/config/`
- `scripts/infrastructure/persistence/`

### Autoload coordinators

- `scripts/autoload/`
- plus `scripts/gameplay/input_handler.gd` as an autoloaded coordinator

---

## Current Playable Behavior Preserved

- Player still controls aim direction only.
- Weapon still auto-fires.
- Central core is still fixed.
- Projectiles now originate from the center core area.
- Rings still spawn and shrink inward.
- Spawned walls are still continuous and segmented at the outer radius.
- Strong/armored wall typing is still preserved structurally during wall compaction.
- Default arrow now has a 3-bounce budget and 3-target wrapped spread.
- Stone now has a 5-target wrapped spread.
- Typed bricks still exist:
  - normal = 1 hit
  - strong = 2 hit
  - armored = 3 hit
- Destroyed bricks still increase K.
- Core breach still triggers game over.
- Danger overlay and danger-driven BGM intensity hook are still wired.
- Pause, sound toggle, restart, and play-again flow are still present.

---

## Unresolved Risks

- **Highest risk:** runtime/editor verification has not yet been executed after the center-origin combat correction pass and the final freeze-readiness fixes.
- No Godot CLI was available in this environment, so no real project run occurred here.
- Final structural validation completed after the correction pass:
  - zero missing `res://` references were found
  - autoload target paths were clean
  - touched setup-call wiring was re-checked
- The current remaining uncertainty is runtime feel, not structural wiring:
  - exact cyan-point firing still needs live confirmation
  - bounce behavior may need live tuning
  - spread behavior on strong/armored walls still needs real play verification
  - danger escalation should be re-checked once against the config-backed radius
- Safe-area logic is now implemented but still needs real device/editor verification.
- Save persistence is now repository-backed in code, but relaunch behavior still needs real validation.
- `InputHandler` remains physically under `scripts/gameplay/` even though it acts as an autoload coordinator.
- The wall compaction algorithm may still need feel-tuning after first live smoke test even if it is structurally correct.
- Toss bridge, back handling, exit confirmation, and identity integration remain present as scaffolding but still need real Toss/runtime validation later.

---

## Files Requiring Special Attention

- `scenes/main/main.tscn`
  - Confirm the composed `GameRoot` and `RootUI` instances resolve cleanly in Godot.
- `scenes/game/game_root.tscn`
  - Confirm node names still match `scripts/gameplay/game_root.gd` expectations.
- `scenes/ui/root_ui.tscn`
  - Confirm safe-area offsets do not misplace HUD or overlays.
- `scripts/gameplay/game_root.gd`
  - This is now the key orchestration file for score and game-over flow.
- `scripts/autoload/game_state.gd`
  - Session start/reset/tier behavior now lives here in slimmer coordinator form.
- `scripts/autoload/save_manager.gd`
  - Save flow now depends on `SaveFileRepository`.
- `scripts/gameplay/ring_spawner.gd`
  - Spawn policy now routes through `RingSpawnPlanner`; this file also received the final smoke-test blocker fix on the `ring.setup(...)` call.
- `scripts/gameplay/ring_instance.gd`
  - Main wall-compaction logic and wrapped spread-hit resolution now live here; this is the most important file to watch if runtime feel is off.
- `scripts/gameplay/brick_instance.gd`
  - Brick destruction still emits upward; setup now also supports preserving HP state during ring rebuilds, plus ring-aware projectile hit routing.
- `scripts/gameplay/arrow_projectile.gd`
  - 3-bounce and 3-target wrapped spread behavior now live here.
- `scripts/gameplay/stone_projectile.gd`
  - 5-target wrapped spread behavior now lives here.
- `scripts/ui/root_ui.gd`
  - New safe-area handling entry point.

---

## Exact Next Recommended Step

Open the project in the Godot editor, run `scenes/main/main.tscn`, and verify exact cyan-point firing, preserved segmented-wall compaction/continuity, and Toss-sensitive pause/save/sound/platform flows one more time before freezing the current architecture.

## Whether Gameplay Implementation Can Safely Resume Now

Not yet.

The project is structurally close to freeze-ready, but gameplay work should wait until the final Godot smoke test above confirms the current center-origin combat path, wall behavior, and Toss-sensitive flows.

Current handoff status: structurally ready for freeze confirmation, not yet cleared for post-freeze gameplay expansion.
