# Buff System MVP Report

## Summary
- Added an MVP one-roll random buff system.
- Scope intentionally excludes endless-run/progress-gauge redesign, level logic changes, best-record gauge changes, weapon-choice timing changes, ads, leaderboard, and rewarded revive changes.
- Buff unlock is `current_level_k >= 500`.
- One buff selection is allowed per run; buffs do not stack.

## Files Changed
- `project.godot`: registers `BuffManager` autoload.
- `scripts/application/buffs/buff_rules.gd`: single source of buff constants.
- `scripts/autoload/buff_manager.gd`: current-run buff state, random selection, multipliers, and overclock request.
- `scenes/ui/buff_roulette_panel.tscn`: pause-safe roulette overlay.
- `scripts/ui/buff_roulette_panel.gd`: roulette animation and selection application.
- `scripts/ui/aim_joystick.gd`: buff button state and roll request only.
- `scripts/gameplay/weapon.gd`: reads projectile-count multiplier and expands fire specs after `WeaponFirePattern`.
- `scripts/gameplay/*projectile.gd`: reads damage multiplier after `DamageRules` base damage.

## Ownership
- `BuffRules` owns constants:
  - `UNLOCK_K = 500`
  - `BUFF_PROJECTILE_COUNT_X2`
  - `BUFF_OVERCLOCK`
  - `BUFF_DAMAGE_X15`
  - `DAMAGE_MULTIPLIER = 1.5`
  - `PROJECTILE_COUNT_MULTIPLIER = 2`
- `BuffManager` owns run state:
  - `buff_used_this_run`
  - `active_buff_id`
  - `is_buff_unlocked(current_level_k)`
  - `can_open_buff(current_level_k)`
  - `start_buff_roll()`
  - `apply_selected_buff(buff_id)`
  - `get_projectile_count_multiplier()`
  - `get_damage_multiplier()`
  - `reset_on_game_started()`
- `AimJoystick` only shows button state and requests `BuffManager.start_buff_roll()`.
- `BuffRoulettePanel` owns pause-safe roll animation and calls `BuffManager.apply_selected_buff()`.
- `Weapon` still owns timer, overclock timer/cooldown, projectile instantiation, and prism volley.

## Button States
- Below K 500: disabled, text `버프\n500개`.
- K >= 500 and unused: enabled, text `버프`.
- Rolling: disabled, text `선택중`.
- Used: disabled, text is selected buff name.

## Buff Effects
- Projectile count x2:
  - `Weapon.gd` reads `BuffManager.get_projectile_count_multiplier()`.
  - It expands the returned `WeaponFirePattern.specs_for_tier()` result without changing `WeaponFirePattern`.
  - Duplicates receive a small angle offset to avoid exact overlap.
  - Prism side-ray proc remains unchanged because it is a weapon-choice special volley, not the default tier fire pattern.
- Damage x1.5:
  - Projectiles keep reading base damage from `DamageRules`.
  - The final projectile damage uses `BuffManager.apply_damage_multiplier(...)`.
  - Applied to arrow, thunder, spark lance, volt storm, siege cannon, and prism side ray.
- Overclock:
  - `BuffManager` requests the current weapon node to call existing `Weapon.activate_overclock()`.
  - Existing overclock duration, cooldown, and timer logic remain in `Weapon`.

## Pause / Resume
- `BuffRoulettePanel` uses `process_mode = ALWAYS`.
- On roll open, it pauses the tree with `get_tree().paused = true`.
- The roulette animation continues while gameplay is paused.
- After selection reveal, it unpauses the tree.
- `GameState.is_playing` is not set to false, so revive/game-over/leaderboard state is not involved.

## Debug Selection Hook
- `BuffManager.debug_force_next_buff(buff_id)` is available only in debug builds through `OS.is_debug_build()`.
- Production random selection remains unchanged.

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

## Manual QA Checklist
- Start a run.
- Below K 500, buff button shows `버프 / 500개` and is disabled.
- At K 500+, buff button shows `버프` and is enabled.
- Tapping it pauses gameplay and shows the roulette panel.
- Roulette cycles labels with a `뾰로로로롱` feel.
- After reveal, gameplay resumes.
- Projectile x2 roughly doubles tier fire projectiles without exact overlap.
- Damage x1.5 increases displayed hit numbers by 1.5x.
- Overclock selection uses the existing fast-fire behavior and naturally ends.
- Buff cannot be selected a second time in the same run.
- PauseMenu and RevivePrompt still work.
