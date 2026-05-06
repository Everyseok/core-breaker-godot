# Critical Gameplay Safety Fix Report

## Summary
- Date: 2026-05-07
- Purpose: final pre-console gameplay safety pass before App-in-Toss console registration.
- Scope: two small runtime safety fixes only.

## Problem 1: Overclock Buff Waste
At K >= 2000, `BuffRules.cooldown_for_score()` returns 10 seconds, while `Weapon.OVERCLOCK_COOLDOWN` remains 15 seconds. That meant the roulette could select the overclock buff while the current weapon still could not activate it, wasting a roll.

## Fix 1: Dynamic Overclock Candidate Filtering
Changed `scripts/autoload/buff_manager.gd`.

Behavior:
- `BuffManager` now checks the current node in group `"weapon"`.
- `BUFF_OVERCLOCK` is excluded from dynamic roulette candidates unless the weapon has `can_activate_overclock()` and it returns `true`.
- `BUFF_OVERCLOCK` remains in `BuffRules.BUFF_IDS`; it is filtered only at roll time.
- If debug-forced overclock is unavailable, the forced value is discarded and the roll falls back to valid candidates.
- `apply_selected_buff()` also defensively refuses overclock if activation is unavailable, without starting cooldown or marking it active.

## Problem 2: Airborne Core-Breach Guard
Jumping monster bricks already disable collision while airborne, and `BrickInstance` exposes `is_airborne_for_core_breach()`. `Core` still had no defensive guard if an airborne brick area reached `_on_brick_entered(...)`.

## Fix 2: Core-Side Guard
Changed `scripts/gameplay/core.gd`.

Behavior:
- `_on_brick_entered(area)` now checks whether the entering area has `is_airborne_for_core_breach()`.
- If it returns `true`, `core_breached` is not emitted.
- Otherwise, `core_breached.emit()` runs exactly as before.

## Files Changed
- `scripts/autoload/buff_manager.gd`
- `scripts/gameplay/core.gd`
- `docs/CRITICAL_GAMEPLAY_SAFETY_FIX_REPORT.md`
- `docs/RING_INSTANCE_REVIEW_PASS_1_REPORT.md`

## Validation Results
- `git diff --check`: OK.
- `jq . data/progression.json`: OK.
- Godot headless main scene load: not run; no `godot`/`godot4` CLI or Godot app bundle was found in this environment.
- Forbidden files: OK; path-specific diff check found no changes to `GameState`, `SaveManager`, `PlatformBridge`, `RevivePrompt`, score/weapon-choice helpers, ring planner/spawner, combat helpers, rules, progression data, scenes, or projectile scripts.

## Manual QA Checklist
- [ ] Overclock buff works when Weapon overclock is available.
- [ ] Overclock buff is not wasted when Weapon overclock is on cooldown.
- [ ] `projectile_count_x2` still works.
- [ ] `damage_x15` still works.
- [ ] K >= 2000 buff cooldown still 10 seconds.
- [ ] K < 2000 buff cooldown still 30 seconds.
- [ ] Airborne jumping monster does not trigger core breach.
- [ ] Landed monster can trigger core breach normally.
- [ ] Airborne monster still ignores damage.
- [ ] Landed monster takes damage normally.
- [ ] Revive/pause/game over still work.
- [ ] 2000~2999 alternating rotation still works.
- [ ] 3000~3999 jumping monster still works.
- [ ] 4000~4999 alternating rotation returns.
- [ ] 5000~5999 jumping monster returns.
- [ ] Max wall remains 8 layers.
