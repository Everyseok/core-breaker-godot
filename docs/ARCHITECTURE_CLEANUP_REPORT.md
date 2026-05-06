# Architecture Cleanup Report

## Scope

This pass was a small behavior-preserving extraction, not a gameplay or UI feature pass.

## Extracted

- `scripts/application/combat/combat_proc_resolver.gd`
  - Owns pure weapon-choice proc calculations for Chain Lightning and Meteor Cannon.
  - Returns dictionaries with effect IDs, target indices, and fallback offsets.
  - Does not mutate ring segments, bricks, nodes, damage, VFX, or audio.

- `scripts/application/combat/weapon_fire_pattern.gd`
  - Owns tier-to-fire-pattern data for projectile selection and angle offsets.
  - Preserves the existing tier patterns:
    - Tier 0: one arrow.
    - Tier 1: thunder at `-8`, `+8`.
    - Tier 2: spark lance at `-15`, `0`, `+15`.
    - Tier 3: electric bolt at `-15`, `0`, `+15`.
    - Tier 4: siege cannon volley at `-36`, `-24`, `-12`, `0`, `12`, `24`, `36`.
  - Preserves the center siege projectile values: `max_pierce_collisions = 2`, `explosion_same_layer_radius = 2`.
  - Preserves side siege projectile values: `max_pierce_collisions = 1`, `explosion_same_layer_radius = 1`.

- `scripts/gameplay/game_root.gd`
  - Adds a thin `spawn_weapon_choice_effect(...)` alias that delegates to the existing `spawn_combat_effect(...)`.
  - This fixes the existing call-path mismatch without renaming `spawn_combat_effect`.

## Intentionally Not Touched

- HUD refactoring was intentionally not done in this pass.
- No `.tscn` files were moved or renamed.
- No scene hierarchy or node names were changed.
- No gameplay balance values were changed.
- No projectile damage values were changed.
- No K thresholds were changed.
- No wall shrink or segment retile behavior was changed.
- No UI redesign was performed.
- No APK workflow files were changed.

## HUD Deferral

HUD cleanup is out of scope because this pass targets combat proc and weapon fire pattern ownership only. Refactoring HUD at the same time would mix UI risk with gameplay-preservation validation.

## Runtime Verification Notes

Static validation can confirm parser/load safety and unchanged references. The following behavior still needs hands-on gameplay QA because it depends on live combat timing and random/progression triggers:

- Chain Lightning proc timing and visible effect.
- Meteor Cannon proc timing and visible effect.
- Tier upgrade flow through normal play.
- Prism side volley remains unchanged.

## Manual QA Checklist

- [ ] Project opens.
- [ ] Main scene is still `res://scenes/main/main.tscn`.
- [ ] Main menu appears.
- [ ] Start button starts gameplay.
- [ ] Core-origin auto-fire works.
- [ ] Aim joystick changes fire direction.
- [ ] Rings spawn and shrink.
- [ ] Bricks take damage.
- [ ] Arrow bounce still works.
- [ ] K increases on brick destruction.
- [ ] Tier upgrades still occur at the same thresholds.
- [ ] Weapon choice panel still appears at the same trigger K.
- [ ] Chain Lightning proc still produces damage/effect.
- [ ] Meteor Cannon proc still produces damage/effect.
- [ ] Game over still triggers when core is breached.
- [ ] Restart works.
- [ ] Pause works.
- [ ] APK workflow files are not changed unless parser validation requires it.
