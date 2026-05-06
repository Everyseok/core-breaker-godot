# Buff Timed Cooldown Report

## Summary
- Converted the random buff MVP from a one-use-per-run model to a timed, repeatable cooldown model.
- Buff unlock remains `current_level_k >= 500`.
- The existing roulette panel remains the only buff selection UI.
- Buffs do not stack: a new roll is blocked while a buff is active, while roulette is rolling, or while cooldown remains.

## Old Model
- `BuffManager.buff_used_this_run` permanently locked the buff after one successful roulette selection.
- `projectile_count_x2` and `damage_x15` stayed active until the run ended.
- The button showed the selected buff name forever after use.

## New Model
- `projectile_count_x2` is active for `10.0` seconds.
- `damage_x15` is active for `10.0` seconds.
- `overclock` uses the existing `Weapon.activate_overclock()` behavior and is tracked as active for `3.0` seconds.
- After the active buff ends, `BuffManager` starts a `30.0` second cooldown.
- After cooldown reaches `0`, the buff button becomes usable again if the run score is still at least `500`.

## Button States
| State | Button text | Enabled |
|---|---:|---:|
| Locked below K 500 | `버프\n500개` | No |
| Roulette rolling | `선택중` | No |
| Projectile count active | `탄환 2배\nN초` | No |
| Damage active | `공격력 1.5배\nN초` | No |
| Overclock active | `가속\nN초` | No |
| Cooldown | `대기\nN` | No |
| Available | `버프` | Yes |

## Ownership
- `scripts/application/buffs/buff_rules.gd` owns duration and cooldown constants.
- `scripts/autoload/buff_manager.gd` owns active buff state, active timer, cooldown timer, and roulette in-flight state.
- `scripts/ui/aim_joystick.gd` only renders the button state and requests a roll.
- `Weapon.gd` still reads `BuffManager.get_projectile_count_multiplier()` and keeps projectile instantiation ownership.
- Projectile scripts still read `BuffManager.apply_damage_multiplier(...)`; base `DamageRules` values were not changed.

## Runtime Rules
- Buff timers tick only when `GameState.is_playing` is true and the tree is not paused.
- Timers do not advance while the roulette panel pauses the tree.
- Timers reset on `GameState.game_started`.
- Timers cancel on `GameState.game_over` and `GameState.max_level_cleared`.
- Cooldown starts only after the active buff timer reaches zero.

## Files Changed
- `scripts/application/buffs/buff_rules.gd`
- `scripts/autoload/buff_manager.gd`
- `scripts/ui/aim_joystick.gd`
- `docs/BUFF_SYSTEM_MVP_REPORT.md`
- `docs/BUFF_TIMED_COOLDOWN_REPORT.md`
- `docs/STATUS.md`

## Intentionally Not Changed
- Rewarded revive logic.
- `PlatformBridge`.
- `SaveManager`.
- Leaderboard submit logic.
- App-in-Toss ad stubs.
- `CombatProcResolver`.
- `WeaponFirePattern`.
- `data/progression.json`.
- `scripts/application/rings/ring_spawn_planner.gd`.
- `scripts/domain/combat/weapon_choice_rules.gd`.
- `BrickRules` and `DamageRules` base values.
- Endless score and best-record gauge logic.

## Manual QA Checklist
- K < 500 locked: to verify on device.
- K >= 500 available: to verify on device.
- Projectile x2 returns to normal after about 10 seconds: to verify on device.
- Damage x1.5 returns to normal after about 10 seconds: to verify on device.
- Overclock uses existing weapon overclock behavior and then enters cooldown: to verify on device.
- Cooldown starts after buff ends: to verify on device.
- Buff can be used again after cooldown: to verify on device.
- No stacking during active/rolling/cooldown states: to verify on device.
- PauseMenu / RevivePrompt / GameOver interaction remains unchanged: to verify on device.
