# Refactor Validation — 2026-04-21

## Scope

This document records what validation was actually performed for the architecture refactor, the shrinking-wall correction pass, the center-origin combat correction pass, and the targeted freeze-readiness fixes, and what still needs manual verification before the architecture is frozen.

---

## Validation Outcome

- **Runtime status:** not executed in this environment
- **Static structural status:** clean on the checks listed below
- **Freeze status:** pending one final Godot smoke test
- **Handoff confidence:** structurally ready for freeze confirmation, not yet runtime-verified

---

## Verified By Runtime

None.

No Godot editor session, headless run, or playable runtime session was executed during this pass.

---

## Verified By Static Structure Checks

- `project.godot` exists and still points to `res://scenes/main/main.tscn`
- all autoload target paths in `project.godot` resolve to existing scripts
- all `res://` references found across `project.godot`, `.tscn`, and `.gd` files resolve to existing files
- `scenes/main/main.tscn` cleanly composes:
  - `scenes/game/game_root.tscn`
  - `scenes/ui/root_ui.tscn`
- `scenes/game/game_root.tscn` and `scenes/ui/root_ui.tscn` contain the expected child nodes used by their attached scripts
- attached-script `$NodePath` lookups in the composed scenes were audited and resolved cleanly
- refactored cross-layer dependencies were checked for path consistency after the new `preload()` wiring

---

## Not Verifiable In This Environment

- actual Godot parser/compiler acceptance of the refactored scripts
- actual runtime launch of `scenes/main/main.tscn`
- actual autoload initialization order at runtime
- actual pause/restart/game-over loop execution
- actual shrinking-wall compaction feel and visual continuity on screen
- actual center-origin launch feel and bounce/spread combat behavior on screen
- actual safe-area behavior in the running UI
- actual persistence behavior after relaunch

Reason:
- no usable Godot CLI or editor/runtime was available in this environment during the validation pass

---

## Structural Checks Performed

### File/folder structure

- Confirmed new layer folders exist:
  - `scripts/domain/`
  - `scripts/application/`
  - `scripts/infrastructure/`
- Confirmed original presentation folders remain intact:
  - `scripts/gameplay/`
  - `scripts/ui/`
  - `scripts/autoload/`
  - `scenes/`
  - `data/`
  - `docs/`

### New source files present

- Confirmed creation of:
  - `scripts/domain/bricks/brick_rules.gd`
  - `scripts/domain/danger/danger_rules.gd`
  - `scripts/application/progression/progression_service.gd`
  - `scripts/application/rings/ring_spawn_planner.gd`
  - `scripts/infrastructure/config/json_config_loader.gd`
  - `scripts/infrastructure/persistence/save_file_repository.gd`
  - `scripts/ui/root_ui.gd`

### Correction-pass gameplay checks

- Reviewed the touched wall-correction files directly:
  - `scripts/domain/bricks/brick_rules.gd`
  - `scripts/application/rings/ring_spawn_planner.gd`
  - `scripts/gameplay/ring_spawner.gd`
  - `scripts/gameplay/ring_instance.gd`
  - `scripts/gameplay/brick_instance.gd`
  - `data/game_config.json`
- Confirmed the segment-size constant is aligned across planner, brick visuals/collision, and config.
- Confirmed the spawner passes the new `segment_size` argument into `RingInstance.setup(...)`.
- Confirmed the rebuilt `BrickInstance.setup(...)` signature remains backward-compatible through optional HP arguments.
- Found and fixed one structural parse blocker during the sweep:
  - extra indentation before `ring.setup(...)` in `scripts/gameplay/ring_spawner.gd`
- Confirmed `RingSpawnPlanner` now sources spawn radius from `data/game_config.json` instead of a stale geometry assumption.

### Combat-correction gameplay checks

- Reviewed the touched combat-correction files directly:
  - `scenes/game/game_root.tscn`
  - `scripts/gameplay/weapon.gd`
  - `scripts/gameplay/input_handler.gd`
  - `scripts/gameplay/arrow_projectile.gd`
  - `scripts/gameplay/stone_projectile.gd`
  - `scripts/gameplay/brick_instance.gd`
  - `scripts/gameplay/ring_instance.gd`
  - `data/progression.json`
- Confirmed `Weapon` is now positioned at local `(0, 0)` in `game_root.tscn`, matching the centered core launch point.
- Confirmed arrow behavior is now structurally wired for:
  - 3-bounce budget
  - 3-target wrapped spread hit
- Confirmed stone behavior is now structurally wired for:
  - 5-target wrapped spread hit
- Confirmed projectile impacts now route through `BrickInstance.resolve_projectile_hit(...)` into `RingInstance.apply_projectile_hit(...)` so wrapped neighbor damage stays ring-aware.
- Confirmed the stone unlock threshold remains data-tunable through the tier-1 `k_min` entry in `data/progression.json`.
- Confirmed the current firing path uses an explicit launch-origin provider for aim origin and projectile spawn structurally.

### Freeze-readiness fix checks

- Reviewed `scripts/autoload/danger_manager.gd` after the targeted freeze fix.
- Confirmed `DangerManager` no longer normalizes against a stale hardcoded `380.0` radius.
- Confirmed `DangerManager` now reads `play_field_radius` from `data/game_config.json`.
- Confirmed `RingSpawnPlanner` and `DangerManager` now use the same config-backed geometry source for wall spawn radius / danger normalization.

### Scene composition structure

- Confirmed `scenes/main/main.tscn` now instances:
  - `scenes/game/game_root.tscn`
  - `scenes/ui/root_ui.tscn`
- Confirmed `scenes/game/game_root.tscn` now contains the gameplay subtree.
- Confirmed `scenes/ui/root_ui.tscn` now contains the UI subtree.
- Confirmed `scenes/game/core.tscn` now carries the real script binding.
- Confirmed composed scene node names line up with the child paths used by:
  - `scripts/gameplay/game_root.gd`
  - `scripts/ui/root_ui.gd`
  - `scripts/ui/game_over_screen.gd`
  - `scripts/ui/pause_menu.gd`
  - `scripts/ui/danger_overlay.gd`

---

## Autoload Consistency Checks Performed

- Read `project.godot` autoload section.
- Confirmed autoload registrations still point to:
  - `GameState="*res://scripts/autoload/game_state.gd"`
  - `InputHandler="*res://scripts/gameplay/input_handler.gd"`
  - `SaveManager="*res://scripts/autoload/save_manager.gd"`
  - `AudioManager="*res://scripts/autoload/audio_manager.gd"`
  - `DangerManager="*res://scripts/autoload/danger_manager.gd"`
  - `PlatformBridge="*res://scripts/autoload/platform_bridge.gd"`
- Confirmed those referenced script files still exist.
- Confirmed the refactor did **not** change autoload names, so scene/script consumers should still resolve the same singleton names.
- Confirmed no broken autoload target path was found by static inspection.
- Confirmed the shrinking-wall correction pass did not add or rename any autoloads.
- Confirmed the freeze-readiness danger fix did not add, rename, or re-point any autoload.

### Note

`InputHandler` is still autoload-consistent, but it remains a structural outlier because it lives under `scripts/gameplay/` instead of `scripts/autoload/`.

---

## Scene / Script / Path Consistency Checks Performed

### Scene resource paths

- Verified `project.godot` main scene still points to `res://scenes/main/main.tscn`.
- Verified `main.tscn` ext_resource paths point to existing scene/script files.
- Verified `game_root.tscn`, `root_ui.tscn`, and `core.tscn` ext_resource paths point to existing scene/script files.
- Verified projectile and gameplay sub-scenes still point to existing gameplay scripts.
- Verified all `res://` references found by repository-wide extraction resolved to existing files.
- Re-ran the repository-wide `res://` reference audit after the latest correction pass:
  - **41 references found**
  - **0 missing paths**

### Cross-script dependency checks

- Searched for all uses of:
  - `GameState`
  - `SaveManager`
  - `AudioManager`
  - `DangerManager`
  - `PlatformBridge`
  - `InputHandler`
- Confirmed refactored dependencies still resolve to existing script paths.
- Added explicit `preload()` references in the new cross-layer scripts so they do not rely only on global class-name resolution.

### Signal-flow checks by source inspection

- Confirmed `BrickInstance` emits `destroyed`.
- Confirmed `RingInstance` re-emits `brick_destroyed`.
- Confirmed `RingSpawner` re-emits `brick_destroyed`.
- Confirmed `GameRoot` listens and increments K via `GameState.add_k(1)`.
- Confirmed `Core` emits `core_breached`.
- Confirmed `GameRoot` handles `core_breached` and triggers game over.
- Confirmed no broken scene child path was found in the attached scripts audited above.
- Confirmed the only call site for `RingInstance.setup(...)` is `scripts/gameplay/ring_spawner.gd`, and it now matches the expanded signature.
- Confirmed the only wall-brick rebuild path uses `BrickInstance.setup(type, hp, max_hp)` and preserves typed HP state structurally.
- Confirmed projectile spread routing is internally consistent across:
  - `arrow_projectile.gd`
  - `stone_projectile.gd`
  - `brick_instance.gd`
  - `ring_instance.gd`
- Confirmed both danger normalization and ring spawn now pull radius from `data/game_config.json`, removing the last known hidden geometry mismatch.

---

## Whether Runtime Validation Was Actually Executed

**No. Runtime validation was not executed.**

What was actually true during this pass:
- No Godot editor run was performed.
- No headless Godot run was performed.
- No HTML5 export was performed.
- No gameplay session was manually played after the refactor, the shrinking-wall correction pass, or the center-origin combat correction pass.

Reason:
- Godot CLI was not installed on the machine used for this pass.
- No usable Godot editor/runtime was available to launch from this environment during this pass.

---

## What Still Requires Manual Godot Editor Verification

### Mandatory smoke test before further gameplay work

1. Open the project in Godot.
2. Run `scenes/main/main.tscn`.
3. Confirm there are no missing resource or autoload errors.

### Gameplay-preservation checks

- Aim direction still updates from touch/mouse input.
- Auto-fire still works.
- Projectiles actually spawn from the center core area.
- Rings still spawn and shrink.
- Shrinking rings visibly compact to fewer segments as radius decreases.
- Shrinking rings do not show obvious overlap buildup from a fixed segment count.
- No large new passable gaps appear unless the player destroyed segments.
- Default arrows bounce three times.
- Default arrow impacts hit the impacted segment plus wrapped left/right neighbors.
- Stone impacts hit the impacted segment plus two wrapped neighbors on each side.
- Destroyed bricks still increment K.
- Core breach still triggers game over.
- Restart still reloads correctly.
- Pause still opens and resumes correctly.
- Danger overlay still changes with ring proximity.
- Danger escalation still feels aligned to the actual ring distance now that radius is config-backed.

### UI / layout checks

- `RootUI` safe-area offsets do not push HUD or overlays into invalid positions.
- `GameOverScreen` and `PauseMenu` still render on top in the intended order.
- Portrait layout still looks correct at the base resolution.

### Persistence checks

- Sound toggle persists after relaunch.
- Best K persists after relaunch.
- Save-backed settings still load correctly on restart after the freeze-readiness fixes.

### Console/debugger checks

- No missing script/resource warnings from the new scene composition.
- No script errors from the new signal flow or preloaded helper classes.

---

## Confidence Level For Handing Back To Gameplay Work
The codebase is structurally ready for architecture freeze pending one final Godot smoke test.

Recommended handoff label for the next step: `NEEDS_ONE_FINAL_RUNTIME_CHECK`.

**Confidence: High for structural handoff, not runtime-complete.**

Why this is not low:
- The refactor was small-to-medium in scope, not a destructive rewrite.
- Static structure, pathing, autoload registration, and signal ownership were checked carefully.
- New cross-layer dependencies were made explicit with `preload()` references.

Why this is not high:
- No actual Godot runtime execution happened.
- The new scene composition and safe-area behavior still need live editor confirmation.

In other words: the project looks structurally clean enough to hand back, but it is still not runtime-verified.

---

## Handback Decision

The project can be handed back for freeze confirmation now, but the next Codex/Claude Code session should treat the Godot editor smoke test as the first non-optional action before declaring architecture freeze and moving on to rules/progression specification.
