# Late-Game Pattern Pass 5B Report

## Summary
- Goal: add the jumping monster brick pattern without changing score, damage, HP, max wall layer count, buff rules, revive, or leaderboard behavior.
- Max wall layer count remains 8 layers.
- Score-to-pattern decisions remain owned by `RingSpawnPlanner`.
- `RingSpawner` only passes planner data into `RingInstance`.

## Score Band Formula
- If `K < 2000`: normal pattern.
- If `K >= 2000`: `band_index = floor((K - 2000) / 1000)`.
- Even `band_index`: alternating rotation.
- Odd `band_index`: jumping monster bricks.

## Pattern Table
| Score band | Rotation mode | Wall pattern |
|---|---|---|
| `< 2000` | `clockwise` | `normal` |
| `2000~2999` | `alternating_1s` | `normal` |
| `3000~3999` | `clockwise` | `jumping_monster` |
| `4000~4999` | `alternating_1s` | `normal` |
| `5000~5999` | `clockwise` | `jumping_monster` |
| `6000+` | repeats every 1000 score | repeats every 1000 score |

## Data Flow
`RingSpawnPlanner.build_spawn_spec(k)` now returns both:
- `rotation_mode`
- `wall_pattern`

`RingSpawner` reads those keys and passes them to `RingInstance.setup(...)`.

`RingInstance` applies:
- alternating rotation locally from `rotation_mode`
- jumper metadata/timers/visual offset/immunity locally from `wall_pattern`

## Jumping Monster Behavior
- Only active when `wall_pattern == "jumping_monster"`.
- A small random subset of alive segments becomes jumper candidates.
- Jumper candidates use local timers:
  - `idle`
  - `warning`
  - `airborne`
  - `recovery`
- Jumpers do not all jump together; each candidate has randomized delay and duration.
- Ring shrink continues while jumpers move.
- No new scenes or new brick types were added.

## Airborne Immunity
- Airborne jumper segments return early from `_damage_segment(...)`.
- Airborne jumper `BrickInstance` objects disable their collision layer and `monitorable` flag while airborne.
- This prevents projectile hits and core-breach Area2D entry from treating airborne bricks as active lethal/contact targets.
- When the segment lands/recoveries, collision is restored and normal damage/core-breach behavior returns.

## Intentionally Not Changed
- Max wall remains 8 layers.
- No 10-layer wall was reintroduced.
- `BrickRules` HP and enum are unchanged.
- `DamageRules` base values are unchanged.
- `GameState`, score/gauge scheduling, revive, SaveManager, PlatformBridge, projectile scripts, and buff duration/cooldown logic are unchanged.
- No monster jumping behavior was placed in `RingSpawner`; it stays a thin adapter.

## Manual QA Checklist
- [ ] K < 2000: normal/previous behavior.
- [ ] K 2000~2999: alternating rotation works.
- [ ] K 3000~3999: some bricks jump randomly.
- [ ] During jump, attacks do not damage the airborne brick.
- [ ] During jump, the airborne brick does not cause unavoidable death.
- [ ] After landing, the brick can be damaged again.
- [ ] Ring continues shrinking while jump happens.
- [ ] K 4000~4999: alternating rotation returns.
- [ ] K 5000~5999: jumping monster returns.
- [ ] Buff cooldown at 2000+ remains 10s.
- [ ] Score/gauge/repeated weapon choice still works.
- [ ] No duplicate weapon choice panels.
- [ ] Revive/pause/game over still work.

## Implementation Risk
- Core-breach immunity is implemented by disabling the airborne brick Area2D collision/monitorable state rather than editing `Core`. This keeps the change localized, but should be verified on device because Godot Area2D overlap timing can vary when collision is re-enabled while already overlapping.
