# Endless Score Model Pass 1 Report

## Summary
- Replaced the old per-level score loop with an endless current-run score model.
- `current_level_k` remains as a compatibility field, but it now represents the continuous current-run score.
- `total_progress` now equals the current-run score.
- The HUD top gauge now uses the best-record range instead of level-loop progress.
- Repeated weapon choice now opens at score `2000`, then every `+1000` score.

## Old Model
- A run used `current_level` and `current_level_k`.
- `current_level_k` reset to `0` when it reached `_level_size_k`.
- `current_level` incremented after the reset.
- `total_progress = ((current_level - 1) * _level_size_k) + current_level_k`.
- `level_transitioned` emitted during normal score progression.
- `max_level_cleared` could occur from score progression at the level cap.

## New Model
- A run starts at score `0`.
- Destroyed bricks increment `current_level_k` continuously.
- `k`, `current_level_k`, and `total_progress` stay synchronized to the current-run score.
- Normal scoring never resets `current_level_k`.
- Normal scoring no longer emits `level_transitioned`.
- Normal scoring no longer triggers `max_level_cleared`.
- `current_level` remains as legacy compatibility state and does not drive score reset.

## Gauge Formula
- `best = SaveManager.get_best_record_value()`
- `gauge_max = max(best, 2000)`
- `normalized = clamp(current_score / gauge_max, 0.0, 1.0)`
- HUD text displays `current_score/gauge_max`.
- If `current_score > gauge_max`, the gauge remains full and the text still shows `current_score/gauge_max`.

## Repeated Weapon Choice
- First repeated weapon choice score: `2000`.
- Repeat interval: `1000`.
- Thresholds: `2000`, `3000`, `4000`, `5000`, ...
- The existing `WeaponChoicePanel` is reused.
- Score is not reset after selection.
- Existing active weapon-choice behavior remains unchanged.
- If the choice panel is already open, a crossed threshold is deferred instead of opening a duplicate panel.

## Files Changed
- `scripts/autoload/game_state.gd`
- `scripts/ui/hud.gd`
- `docs/ENDLESS_SCORE_MODEL_PASS_1_REPORT.md`
- `docs/STATUS.md`

## Intentionally Not Changed
- `scripts/autoload/platform_bridge.gd`
- `scripts/autoload/save_manager.gd`
- `scripts/ui/revive_prompt.gd`
- `scripts/autoload/buff_manager.gd`
- `scripts/ui/buff_roulette_panel.gd`
- `scripts/application/rings/ring_spawn_planner.gd`
- `scripts/domain/combat/weapon_choice_rules.gd`
- `scripts/application/combat/weapon_fire_pattern.gd`
- `scripts/application/combat/combat_proc_resolver.gd`
- `data/progression.json`
- Wall patterns, buff cooldown/repeat, ads, rewarded revive, leaderboard, and new enemies.

## Manual QA Checklist
- Start a new run with no or low best record.
- Gauge uses `2000` as max.
- Score increases continuously.
- Passing `1500` does not reset score.
- Passing `2000` keeps gauge full and score continues increasing.
- Weapon choice appears at `2000`.
- Weapon choice appears again at `3000`, `4000`, `5000`, ...
- Die after passing `2000` and confirm best record is saved.
- Start next run and confirm gauge max uses saved best record.
- Confirm revive prompt still works.
- Confirm buff button still works.
- Confirm pause still works.
- Confirm no level-up reset occurs.
