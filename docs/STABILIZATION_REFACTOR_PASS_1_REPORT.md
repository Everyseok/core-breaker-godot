# Stabilization Refactor Pass 1 Report

## Why This Pass Was Needed
- Recent gameplay work added endless score, repeated weapon choices, rewarded revive, and timed buffs.
- `GameState` had started owning both runtime state and pure score/weapon-choice calculations.
- `BuffManager` still owns runtime buff timers, but pure duration lookup now belongs with buff constants.
- This pass keeps behavior unchanged while moving pure rules behind small helpers.

## What Was Extracted
- `scripts/application/score/endless_score_rules.gd`
  - `gauge_max(best_record, fallback_max)`
  - `gauge_progress(score, gauge_max_value)`
  - `display_text(score, gauge_max_value)`
- `scripts/application/weapon_choice/weapon_choice_schedule.gd`
  - Repeated weapon-choice threshold tracking.
  - First trigger remains `2000`.
  - Repeat interval remains `1000`.
  - Deferred trigger behavior remains panel-safe.
- `scripts/application/buffs/buff_rules.gd`
  - Added `duration_for_buff(buff_id)` so duration lookup lives with buff constants.

## What Was Intentionally Not Touched
- No score, weapon threshold, wall pattern, projectile damage, brick HP, or base damage values changed.
- No `RingSpawnPlanner`, `progression.json`, `WeaponFirePattern`, `CombatProcResolver`, `PlatformBridge`, `SaveManager`, or `RevivePrompt` changes.
- No HUD refactor in this pass.
- No scene hierarchy or node names changed.
- No ads, moving bricks, monster patterns, or new gameplay features added.

## Behavior Preservation Evidence
- Score still starts from `0` through `GameState.reset()`.
- `GameState.add_k()` still increments `current_level_k` and syncs `k` / `total_progress` to the same continuous score.
- `level_transitioned` is not emitted during normal scoring.
- Gauge max still resolves as `max(SaveManager.get_best_record_value(), 2000)`, now through `EndlessScoreRules`.
- HUD gauge text and normalized progress are routed through `GameState` helper methods backed by `EndlessScoreRules`.
- Repeated weapon choice still starts at `2000` and advances by `1000` through `WeaponChoiceSchedule`.
- If the weapon choice panel is already open, the schedule marks the trigger deferred and does not open a duplicate panel.
- Buff active/cooldown runtime ownership stays in `BuffManager`.
- `projectile_count_x2`, `damage_x15`, and `overclock` durations remain `10.0`, `10.0`, and `3.0` seconds.
- Buff cooldown remains `30.0` seconds.

## Manual QA Checklist
- Start a run and confirm score starts at `0`.
- Confirm score increases continuously and does not reset past `1500` or `2000`.
- Confirm HUD gauge uses `max(best_record, 2000)` and remains full if score exceeds the gauge max.
- Confirm weapon choice appears at `2000`, then again at `3000`, `4000`, `5000`.
- Confirm no duplicate weapon-choice panels open while one is already visible.
- Confirm buff is locked below K `500`.
- Confirm buff is available at K `500+` when no buff is active and cooldown is finished.
- Confirm projectile x2 lasts about `10` seconds, then returns to normal.
- Confirm damage x1.5 lasts about `10` seconds, then returns to normal.
- Confirm overclock still calls existing `Weapon.activate_overclock()`.
- Confirm cooldown lasts about `30` seconds and the buff can be used again afterward.
- Confirm revive prompt, game over save, leaderboard submit path, and pause still work.

## Validation Notes
- Static validation and Godot headless load were run for this pass.
- Device/manual QA is still recommended after the next APK artifact build.
