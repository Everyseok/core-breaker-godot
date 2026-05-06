# Late-Game Pattern Pass 5A Report

## Summary
- Added the first late-game wall pattern pass without monster or jumping bricks.
- K `2000` to `2999` now uses alternating wall rotation direction every `1.0` second.
- K `2000+` buff cooldown now becomes `10.0` seconds after the active buff ends.
- The max wall expansion now returns `10` layers instead of `8`.

## Buff Cooldown Scaling
- `BuffRules.COOLDOWN_DURATION` remains the default `30.0` second cooldown.
- `BuffRules.LATE_GAME_COOLDOWN_SCORE = 2000`.
- `BuffRules.LATE_GAME_COOLDOWN_DURATION = 10.0`.
- `BuffRules.cooldown_for_score(score)` returns:
  - `30.0` when `score < 2000`.
  - `10.0` when `score >= 2000`.
- `BuffManager` starts cooldown with `BuffRules.cooldown_for_score(GameState.current_level_k)` only after the active buff timer reaches zero.

## Max Wall Layer Sequence
The expanded late wall now uses this `10`-layer sequence:

1. `STRONG`
2. `STRONG`
3. `STRONG`
4. `NORMAL`
5. `STRONG`
6. `STRONG`
7. `ARMORED`
8. `STRONG`
9. `STRONG`
10. `ARMORED`

No brick HP values, brick enum values, segment sizing, layer spacing, or retile behavior were changed.

## Rotation Pattern Data Flow
- `RingSpawnPlanner.build_spawn_spec(k)` owns the score-to-rotation-mode decision.
- `RingSpawnPlanner` emits `rotation_mode` in the spawn spec:
  - below `2000`: `clockwise`
  - `2000 <= K < 3000`: `alternating_1s`
  - `3000+`: `clockwise` until Pass 5B defines monster/jump behavior
- `RingSpawner` only reads `spawn_spec["rotation_mode"]` and passes it to `RingInstance.setup(...)`.
- `RingInstance` stores `rotation_mode` and applies local elapsed-time direction:
  - `0~1s`: counter-clockwise
  - `1~2s`: clockwise
  - `2~3s`: counter-clockwise
  - repeat

`RingInstance` does not read `GameState.current_level_k` for rotation behavior.

## Intentionally Not Implemented
- Monster jumping bricks.
- Moving monster bricks.
- Airborne attack immunity.
- Core-breach immunity for monster/jumping states.
- New `BrickType` values.
- New scenes.
- Any projectile, damage, score, revive, platform, save, or leaderboard changes.

## Validation Checklist
- `git diff --check`: required.
- `jq . data/progression.json`: required.
- Godot headless main scene load: required.
- Forbidden file diff must remain empty for:
  - `scripts/autoload/game_state.gd`
  - `scripts/application/score/endless_score_rules.gd`
  - `scripts/application/weapon_choice/weapon_choice_schedule.gd`
  - `scripts/autoload/platform_bridge.gd`
  - `scripts/autoload/save_manager.gd`
  - `scripts/ui/revive_prompt.gd`
  - `scripts/application/combat/weapon_fire_pattern.gd`
  - `scripts/application/combat/combat_proc_resolver.gd`
  - `scripts/domain/combat/damage_rules.gd`
  - `scripts/domain/bricks/brick_rules.gd`
  - projectile scripts
  - `data/progression.json`

## Manual QA Checklist
- Below K `2000`, wall rotation behaves like before.
- K `2000~2999`, wall direction flips every `1` second.
- K `3000+` does not add monster/jumping behavior in this pass.
- K `1000+` max wall uses `10` layers.
- Buff cooldown below K `2000` is about `30` seconds.
- Buff cooldown at/above K `2000` is about `10` seconds.
- Score/gauge/repeated weapon choice still works.
- Revive, pause, and game over still work.

## Implementation Risk
- Static validation did not show scene rewiring or parser risk.
- Real device QA is still required to judge whether the 10-layer wall feels visually stable on phone screens.
