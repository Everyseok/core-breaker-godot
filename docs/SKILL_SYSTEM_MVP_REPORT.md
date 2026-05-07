Skill System MVP Report
Phase 1 — Skill Rules and SkillManager

Implemented:

Added scripts/domain/skills/skill_rules.gd
Added scripts/autoload/skill_manager.gd
Registered SkillManager in project.godot

Architecture notes:

No UI was added in this phase.
No targeting was added in this phase.
No damage logic was added in this phase.
No VFX was added in this phase.
No SFX was added in this phase.
No assets were added in this phase.

Expected behavior:

At current_level_k >= 1000, stone_throw becomes the default selected skill.
At current_level_k >= 1500, meteor appears in unlocked skill options.
At current_level_k >= 2000, machine_gun appears in unlocked skill options.

Validation commands:

git status --short

Validation results:

- `git status --short`: existing Godot editor/cache dirt remained; Phase 1 changed only `project.godot`, `docs/SKILL_SYSTEM_MVP_REPORT.md`, `scripts/autoload/skill_manager.gd`, and `scripts/domain/skills/skill_rules.gd`.
- `git diff --check`: passed.
- Godot headless specified paths:
  - `/Applications/Godot.app/Contents/MacOS/Godot`: unavailable.
  - `/Users/junseokism/Downloads/Godot.app/Contents/MacOS/Godot`: unavailable.
  - `godot`: unavailable in PATH.
- Godot headless fallback found at `/Users/junseokism/Downloads/Godot 2.app/Contents/MacOS/Godot`: exited with code 0. Godot reported shutdown warnings about leaked resources/resources still in use, but no parser/load failure.
- `du -sh .`: 121M.
- `du -sh assets`: 12M.

Phase 1.1 Refactor Summary:

- `SkillManager.sync_unlock_state()` now emits `skill_state_changed` only when actual skill state changes.
- New unlock announcements set `state_changed = true`.
- Default auto-selection at `current_level_k >= 1000` sets `state_changed = true`.
- Plain `GameState.k_changed` ticks with no new unlock/default selection no longer emit `skill_state_changed`.
- `request_skill_selection()`, `select_skill()`, `set_skill_panel_open()`, `reset_on_game_started()`, and `_cancel_runtime_state()` behavior remains unchanged.

Project.godot diff check:

- Removed unrelated `[editor] movie_writer/movie_file` dirty diff from `project.godot`.
- Kept only `SkillManager="*res://scripts/autoload/skill_manager.gd"` in the `[autoload]` section.

Phase 1.1 Validation results:

- `git diff --check`: passed.
- `git status --short`: confirmed Phase 1 intended files remain dirty/untracked; pre-existing `.godot` cache dirt remains.
- Godot headless with `/Users/junseokism/Downloads/Godot 2.app/Contents/MacOS/Godot --headless --audio-driver Dummy --display-driver headless --path . --quit`: exited with code 0. Godot reported shutdown warnings about leaked resources/resources still in use, but no parser/load failure.

## Phase 2 — Safe Skill Targeting and Damage Entry Points

Implemented:
- Added `DangerManager.get_tracked_rings_snapshot()`
- Added `RingInstance.get_skill_target_snapshot()`
- Added `RingInstance.get_segment_world_position_safe()`
- Added `RingInstance.apply_skill_hit()`
- Added `RingInstance.apply_skill_multi_hit()`

Architecture notes:
- No UI added.
- No SkillController added.
- No VFX added.
- No SFX added.
- No assets added.
- Skill damage entry points do not trigger weapon-choice procs.

Validation:
- `apply_skill_hit()` and `apply_skill_multi_hit()` do not call `_apply_active_weapon_choice_for_hit()`.
- `apply_projectile_hit()` behavior remains unchanged.
- Airborne jumping segments remain immune because `_damage_segment()` is reused.

Phase 3 — Automatic SkillController Runtime

Implemented:

Added scripts/gameplay/skill_controller.gd
Added SkillController node to scenes/game/game_root.tscn
Wired SkillController in scripts/gameplay/game_root.gd

Architecture notes:

No UI added.
No VFX added.
No SFX added.
No assets added.
No Core visual changes added.
No AimJoystick changes added.
SkillController reads selected skill from SkillManager.
SkillController reads active rings through DangerManager.
SkillController applies skill damage only through RingInstance skill methods.
Machine gun targets are grouped by RingInstance before calling apply_skill_multi_hit().

Runtime gating:

Does not fire when GameState.is_playing == false
Does not fire during revive prompt
Does not fire while the tree is paused
Does not fire while weapon choice panel is open
Does not fire while skill panel is open
Does not fire while buff roulette is in progress
Does not fire when no valid living brick targets exist

Validation:

Godot headless passed.
git diff --check passed.

## Phase 5A — Core Skill Companion Visuals

Implemented:

Added scripts/visual/skill_visual_factory.gd
Added SkillCompanionRoot under Core guardian visual root
Added stone_throw companion visual as a small wooden catapult
Added meteor companion visual as a small fantasy meteor cannon
Added machine_gun companion visual as three cute toy turret/drone companions
Core now listens to SkillManager skill state changes and rebuilds the companion visual

Architecture notes:

Phase 5A is visual-only.
No projectile flight VFX was added.
No impact VFX was added.
No SkillController changes were made.
No damage logic was added.
No targeting logic was added.
No SFX was added.
No PNG/assets were added.
Core does not call RingInstance, DangerManager, or SkillController.
Actual flying projectiles remain for Phase 5B.

Expected behavior:

Before skill selection / before unlock, no companion is shown.
When stone_throw is selected, a small catapult appears behind the core.
When meteor is selected, a small fantasy cannon appears behind the core.
When machine_gun is selected, three toy turrets/drones appear behind the core.
Existing front weapon module and muzzle flash remain unobstructed.

Validation:

Godot headless passed.
git diff --check passed.
Visual boundary grep checks passed.
No assets/audio/UI/SkillController/RingInstance/DangerManager changes were made.

## Phase 4 — Skill Selection UI

Implemented:

Added scenes/ui/skill_select_panel.tscn
Added scripts/ui/skill_select_panel.gd
Registered SkillSelectPanel in scenes/ui/root_ui.tscn
Added SkillButton next to BuffButton in scripts/ui/aim_joystick.gd
Added skill lock badge matching the existing buff lock badge tone
SkillButton opens SkillSelectPanel through SkillManager.request_skill_selection()
SkillSelectPanel selects skills through SkillManager.select_skill()

Architecture notes:

UI does not call SkillController.
UI does not call DangerManager.
UI does not call RingInstance.
UI does not apply damage.
UI does not spawn VFX.
UI does not create AudioStreamPlayer.
No assets were added.
No audio files were added.

Expected UI behavior:

Before 1000 score: SkillButton is disabled and shows 스킬\n1000개 with lock badge.
At 1000 score: SkillButton is enabled and stone can be selected / already auto-selected by SkillManager.
At 1500 score: stone and meteor appear in the skill panel.
At 2000 score: stone, meteor, and machine_gun appear in the skill panel.
SkillButton displays the selected skill display name.

Validation:

Godot headless passed.
git diff --check passed.
UI boundary grep checks passed.
No gameplay/Core/assets/audio changes were made.
No UI/Core/AimJoystick/assets/audio changes were made.

Phase 3.1 — Machine Gun Target Selection Safety Refactor

Implemented:

Replaced `Array.slice(0, max_targets)` in `SkillController._select_targets()` with an explicit loop.

Reason:

This avoids ambiguity in Godot `Array.slice()` end-index behavior and guarantees machine_gun selects exactly `max_targets` items when enough valid targets exist.

Validation:

Godot headless passed.
git diff --check passed.
