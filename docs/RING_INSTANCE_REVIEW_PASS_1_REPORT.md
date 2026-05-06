# RingInstance Review Pass 1 Report

## Summary
- Date: 2026-05-07
- Purpose: review `scripts/gameplay/ring_instance.gd` after Pass 5B.
- Decision: `RingInstance` is large but acceptable until post-export QA; defer refactor.

## Current Responsibilities
`RingInstance` currently owns:
- continuous ring shrinking
- rotation mode application
- segment retile and angle preservation
- projectile hit routing
- per-segment damage mutation
- weapon-choice proc damage dispatch
- jumping monster metadata
- jumper timers and state transitions
- airborne damage immunity
- jump visual transforms
- collision-state delegation to `BrickInstance`

This is a lot for one file, but the current responsibility grouping is still runtime-local to a ring instance. The key release-safety boundary is preserved: score-to-pattern decisions stay outside `RingInstance`.

## Review Findings
- `RingSpawnPlanner` remains the owner of score-to-pattern decisions.
- `RingSpawner` remains a thin adapter that passes `rotation_mode` and `wall_pattern`.
- `RingInstance` does not read `GameState.current_level_k` for pattern decisions.
- `_damage_segment(...)` applies airborne immunity per segment, so spread/electric/explosion behavior can still damage non-airborne neighboring segments.
- Ring shrink continues during jumper updates.
- `_retile_segments(...)` snapshots and merges jumper metadata safely enough for current QA: merged jumper segments remain jumpers, and airborne merged buckets are reset into recovery instead of preserving invalid airborne state.
- Max wall remains 8 layers.

## Refactor Decision
No code refactor was performed in this pass.

Reason:
- Extracting jump monster constants and pure helpers into a new `JumpMonsterRules` class is plausible, but doing it before console registration would add another moving part without reducing current release risk.
- Runtime ownership should stay in `RingInstance` for now because segment dictionaries, timers, transforms, damage routing, and collision updates are tightly coupled.
- A safe extraction is better scheduled after fresh export/device QA confirms the pattern behavior on real hardware.

## Remaining Technical Debt
- `RingInstance` should eventually be split into smaller collaborators:
  - ring geometry / retile helper
  - hit routing helper
  - jump monster runtime helper
  - visual transform helper
- Jumper timing constants can later move to a pure rules file if QA shows the behavior is stable.
- Per-segment collision gating should be device-tested because Area2D overlap timing can vary when `monitorable` is restored near the core.

## Recommendation Before App-in-Toss Console Registration
- Do not refactor `RingInstance` further before the next export/device QA.
- Keep the current small safety fixes.
- Run real APK/Web export smoke tests for:
  - K 3000~3999 jumping monster behavior
  - airborne core-breach immunity
  - buff roulette during late-game cooldown
  - revive/pause/game-over interactions
