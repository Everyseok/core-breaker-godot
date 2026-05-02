# Architecture Audit — 2026-04-20

## Scope

This pass was limited to architecture review and pragmatic refactoring.
Gameplay scope was intentionally paused except where small structural changes were required to preserve the existing loop on cleaner boundaries.

---

## Smells Found

| Smell | Why It Was Risky | Action Taken |
|------|-------------------|--------------|
| `BrickInstance` directly called `GameState.add_k()` | Low-level presentation node owned session scoring | Replaced with `destroyed` signal bubbled upward to `GameRoot` |
| `Core` directly called `GameState.trigger_game_over()` | Core scene mixed collision presentation with session policy | Replaced with `core_breached` signal handled by `GameRoot` |
| `RingSpawner` embedded K-based spawn policy and brick-type thresholds | Gameplay rule changes would require editing node-level scene code | Moved policy into `RingSpawnPlanner` |
| `GameState` loaded JSON config and triggered persistence inline | Autoload was drifting toward god-object behavior | Delegated config parsing to `JsonConfigLoader` and persistence trigger to `SaveManager` repository flow |
| `DangerManager` owned both registry and danger threshold math | Mixed coordination with pure rule evaluation | Moved threshold policy into `DangerRules` |
| `SaveManager` mixed in-memory state with file I/O details | Harder to test/replace persistence boundary | Added `SaveFileRepository` |
| `main.tscn` held the real runtime subtree while `game_root.tscn` and `root_ui.tscn` were mostly placeholders | Folder structure and actual runtime composition had drifted apart | `main.tscn` now composes real `GameRoot` and `RootUI` scenes |
| Safe-area handling existed as documentation intent only | Toss-sensitive layout risk lived outside executable code | Added centralized safe-area application in `scripts/ui/root_ui.gd` |
| Multiple docs still described scaffold-era or planned-only architecture | Increased risk of future work following outdated assumptions | Rewrote architecture/status/plan docs to match the actual project |

---

## Refactor Summary

### Layer Additions

- **Domain**
  - `brick_rules.gd`
  - `danger_rules.gd`
- **Application**
  - `progression_service.gd`
  - `ring_spawn_planner.gd`
- **Infrastructure**
  - `json_config_loader.gd`
  - `save_file_repository.gd`

### Behavioral Ownership Changes

- **Scoring** now flows through signals into `GameRoot`, not from `BrickInstance` into `GameState`.
- **Game over** now flows through `Core -> GameRoot -> GameState`, not directly from `Core` into `GameState`.
- **Ring spawning** now asks a planner for spawn specs.
- **Danger level math** is now pure policy invoked by `DangerManager`.
- **Save I/O** is now delegated from `SaveManager` to `SaveFileRepository`.

### Scene Composition Changes

- `main.tscn` is now the composition root only.
- `game_root.tscn` contains the gameplay subtree.
- `root_ui.tscn` contains the UI subtree.

---

## Layer Map After Refactor

### Presentation

- `scripts/gameplay/*.gd`
- `scripts/ui/*.gd`
- `scenes/**`
- `InputHandler` autoload

### Application

- `scripts/application/progression/progression_service.gd`
- `scripts/application/rings/ring_spawn_planner.gd`

### Domain

- `scripts/domain/bricks/brick_rules.gd`
- `scripts/domain/danger/danger_rules.gd`

### Infrastructure

- `scripts/infrastructure/config/json_config_loader.gd`
- `scripts/infrastructure/persistence/save_file_repository.gd`

### Slim Autoload Coordinators

- `GameState`
- `SaveManager`
- `AudioManager`
- `DangerManager`
- `PlatformBridge`
- `InputHandler`

---

## Preserved Behaviors

- Aim direction remains player-controlled
- Firing remains automatic
- Central core remains fixed
- Rings still shrink inward
- Core breach still causes game over
- K still increments from destroyed bricks
- Typed bricks still behave as 1-hit / 2-hit / 3-hit by type
- Danger overlay and danger-driven audio intensity hook remain in place
- Pause, sound toggle, and restart flow remain present

---

## Deferred / Not Solved In This Pass

- Godot runtime/editor verification
- Higher projectile tiers beyond the current foundation
- Toss JS bridge surface verification in a real runtime
- Real audio playback assets/logic
- Device validation for safe-area behavior and save persistence

---

## Post-Audit Freeze Fixes — 2026-04-21

- `DangerManager` no longer normalizes against a stale hardcoded radius.
- `RingSpawnPlanner` and `DangerManager` now both read `play_field_radius` from `data/game_config.json`, removing the hidden geometry coupling that was still blocking freeze confidence.
- The main remaining freeze gate is now a real Godot smoke test, not another architecture pass.

---

## Recommendation

One more architecture-only pass is **not** recommended right now.
The project should freeze the current structure after one final Godot smoke test confirms center-origin firing, preserved wall behavior, and Toss-sensitive UI/lifecycle flows.
