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
