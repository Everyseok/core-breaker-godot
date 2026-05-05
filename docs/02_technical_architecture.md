# Technical Architecture — game_junseokism.ver1

## 1. Architectural Direction

- **Presentation**: Godot scenes, gameplay node scripts, UI scripts, and input-facing glue.
- **Application**: orchestration and use-case helpers that decide progression, spawning, and other gameplay policy.
- **Domain**: pure rules/policies with no engine/service dependencies where practical.
- **Infrastructure**: JSON/config loading, persistence, audio/platform adapters, and other environment-facing concerns.
- **Autoloads**: persistent coordinators/services only. They may delegate work, but should not become god objects.

This structure is intentionally pragmatic. The project is a compact MVP, so the code favors clear boundaries over heavy abstraction.

---

## 2. Constitutional Layout (Override)

The following positions are hard constraints and override the older bottom-origin correction.

| Element | Node | Position |
|---------|------|----------|
| Core (game-over trigger) | `Core` (child of GameRoot) | Center of play field — local `(0, 0)`, world approx. `(195, 432)` |
| Weapon / launch origin | `Weapon` (child of GameRoot) | Co-located with the core area — local `(0, 0)` so projectiles originate from center |
| GameRoot anchor | `GameRoot` Node2D | Lowered play-field center at `(195, 432)` so the top rotating wall clears the fixed HUD |

> **Implementation note for the correction pass:** `GameRoot` stays anchored at the ring/core center. `Core` remains the kill zone at local `(0, 0)`. `Weapon` is also positioned at local `(0, 0)` so the projectile launch origin and the protected center share the same world-space point.

> **Launch-point note:** the exact projectile spawn coordinate must match the exact center of the visible cyan core point. Projectile-local visuals/collision should extend forward from that origin rather than being centered on it if centered geometry makes the launch look offset.

**This is central radial defense.** The weapon fires from the center core area outward toward segmented walls that shrink back toward that same center.

---

## 3. Runtime Scene Composition

### Main Run Path

`res://scenes/main/main.tscn`

```text
Main (Node)
├── GameRoot (instance: scenes/game/game_root.tscn)
│   ├── Core  (instance: scenes/game/core.tscn) — death zone at play-field center
│   ├── BrickLayer
│   ├── ProjectileLayer
│   ├── VfxLayer
│   ├── DamageNumberLayer
│   ├── Weapon  — launch origin at center core area
│   └── RingSpawner
├── DangerOverlay (CanvasLayer, layer=1)
│   └── EdgeTint
└── RootUI (instance: scenes/ui/root_ui.tscn, layer=2)
	├── SafeAreaContainer
	│   ├── HUD
	│   │   ├── HudBandShadow / HudBand / HudTopTrim / HudBottomTrim
	│   │   ├── LevelGauge
	│   │   │   ├── GaugeFillMask
	│   │   │   │   ├── GaugeFillRect / GaugeStripeRoot / GaugeShine
	│   │   │   └── LevelLabel
	│   │   ├── ThresholdWeaponModule
	│   │   │   ├── ThresholdAccentLine / ThresholdIconHolder
	│   │   │   └── ThresholdValueLabel / ThresholdNameLabel
	│   │   ├── MainNumberShadowLabel / MainNumberLabel
	│   │   ├── PauseButton
	│   │   │   └── PauseBarLeftShadow / PauseBarRightShadow / PauseBarLeft / PauseBarRight
	│   │   ├── Divider
	│   │   ├── CurrentWeaponModule
	│   │   │   └── CurrentWeaponAccent / WeaponLabel
	│   │   ├── BestKLabel
	│   │   └── WeaponFlash / WeaponImpactLabel
	│   ├── UnlockAnnouncement
	│   │   └── Panel
	│   │       └── Label
	│   ├── AimJoystick
	│   │   ├── MoveLeftButton
	│   │   ├── JoystickArea
	│   │   │   ├── BaseShadow / BasePlate / BaseInner
	│   │   │   ├── SocketShadow / Socket / ShaftShadow / Shaft
	│   │   │   └── KnobShadow / Knob / KnobShine / KnobSpec
	│   │   ├── MoveRightButton
	│   │   └── BuffButton
	├── GameOverScreen
	│   ├── ScoreLabel
	│   └── RestartButton
	├── PauseMenu (process_mode=ALWAYS)
	│   ├── DimOverlay
	│   ├── PauseTitle
	│   ├── ResumeButton
	│   ├── SoundToggleButton
	│   └── RestartButton
	└── ConfirmExitDialog (process_mode=ALWAYS)
		├── DimOverlay
		└── Panel
			├── MessageLabel
			├── StayButton
			└── LeaveButton
	└── MainMenu (process_mode=ALWAYS)
		├── Background
		├── TitleLabel
		├── BestLabel
		├── StartButton
		└── RankingButton
```

`main.tscn` is intentionally small. Gameplay and UI subtrees live in their own scene files.

---

## 4. Continuous Segmented Radial Wall System

**This section replaces the older "discrete ring of bricks" description.**

### Wall Model

- Walls are concentric circles whose bricks tile the full circumference with no passable gaps at spawn.
- Segment count is derived from circumference: approximately `2π × current_radius / segment_size`.
- As a wall shrinks, segment count must decrease with radius so segments do not increasingly overlap.
- Count reduction must preserve a continuous wall band; it must not create large new passable gaps on its own.
- Gaps should remain attributable to destroyed segments, not geometry drift.
- All segment positions are recalculated each frame as `Vector2(cos(angle), sin(angle)) × current_radius`.
- `RingSpawnPlanner` must accept a `segment_size` parameter and compute count from radius.
- `data/game_config.json` provides the shared `play_field_radius`, and `segment_size` determines spawn density, but the active wall must continue to retile or compact as radius changes.

### Projectile / Wall Interaction Rules

- Projectile spread must respect circular indexing.
- Left/right adjacency is evaluated on the current logical segment order of the ring.
- Index wrap-around is mandatory, so a hit near segment `0` can still affect segments at the end of the array.
- Arrow impacts target a spread radius of `1` (3 total targeted segments).
- Thunder and Spark Lance currently keep the same-layer hit radius `1` readability rule while using their own projectile-count presentation.
- Wall compaction must preserve destroyed gaps as best it can without creating large new gaps on its own.

### What the Correction Pass Must Change

| Current (obsolete) | Required |
|-------------------|---------|
| `brick_count_for_k()` returns a fixed small number (10+K/10) | Count derived from circumference |
| Count fixed at spawn radius | Active count decreases with current radius |
| `ring_instance.gd` spawns N bricks at equal angles | Same, but N must tile the full circumference at the given radius and continue shrinking without accumulated overlap |
| No concept of segment size | `RingSpawnPlanner` and `RingInstance.setup()` must accept segment size |

---

## 5. Layer Ownership

### 5.1 Presentation

**Scenes**
- `scenes/main/main.tscn`
- `scenes/game/game_root.tscn`
- `scenes/game/core.tscn`
- `scenes/ui/root_ui.tscn`
- `scenes/gameplay/*.tscn`

**Gameplay / UI / visual scripts**
- `scripts/gameplay/game_root.gd`
- `scripts/gameplay/core.gd`
- `scripts/gameplay/ring_spawner.gd`
- `scripts/gameplay/ring_instance.gd`
- `scripts/gameplay/brick_instance.gd`
- `scripts/gameplay/weapon.gd`
- `scripts/gameplay/arrow_projectile.gd`
- `scripts/gameplay/thunder_bolt_projectile.gd`
- `scripts/gameplay/spark_lance_projectile.gd`
- `scripts/gameplay/electric_split_projectile.gd`
- `scripts/gameplay/piercing_bomb_spear_projectile.gd`
- `scripts/gameplay/input_handler.gd`
- `scripts/ui/root_ui.gd`
- `scripts/ui/aim_joystick.gd`
- `scripts/ui/hud.gd`
- `scripts/ui/danger_overlay.gd`
- `scripts/ui/game_over_screen.gd`
- `scripts/ui/pause_menu.gd`
- `scripts/ui/confirm_exit_dialog.gd`
- `scripts/ui/main_menu.gd`
- `scripts/ui/unlock_announcement.gd`
- `scripts/ui/ui_style.gd`
- `scripts/ui/weapon_choice_panel.gd`
- `scripts/visual/weapon_profile.gd`
- `scripts/visual/weapon_module_factory.gd`
- `scripts/visual/projectile_visual_factory.gd`
- `scripts/visual/game_background.gd`
- `scripts/visual/damage_number.gd`
- `scripts/visual/hit_effect_burst.gd`
- `scripts/visual/brick_break_effect.gd`
- `scripts/visual/combat_proc_effect.gd`
- `scripts/gameplay/prism_side_ray_projectile.gd`

**Presentation rules**
- Scene-local scripts emit signals upward instead of directly mutating cross-cutting state.
- UI scripts bind to autoload/application state, not own gameplay rules.
- Input remains aim-only; firing stays automatic.
- `AimJoystick` owns virtual-stick presentation, the single remaining overclock button, and position-switch UI, while `InputHandler` remains the shared aim-state coordinator.
- `AimJoystick` also owns the bottom control-dock layout constants, including how low the joystick, side buttons, divider, and buff button sit in portrait view.
- `WeaponChoicePanel` owns the paused evolution-choice UI only; it does not own damage values or combat balance tables.
- `HUD` owns the full top-HUD hierarchy as one near-full-width top band: striped top level gauge, left current-band threshold module, center number-only broken-brick display with layered arcade typography, far-right pause button, divider, below-divider current-weapon module, best-record support label, and weapon-change impact feedback.
- `UiStyle` owns the shared font chain plus the HUD-ready display-font chain so the top panel can use a more game-like retro/cute font order without scattering font setup across unrelated scripts.
- `HitEffectBurst` owns local electric/storm contact arcs and impact sparks.
- `CombatProcEffect` owns long-distance chain-electric line rendering, prism proc flares, meteor/cannon proc bursts, and the electric arc visibility tuning for cross-brick connections.
- `Weapon` is presentation-side launch glue, but its projectile behaviors must reflect the constitutional combat rules.
- `Weapon` also owns the real Overclock state/effect so multiple UI surfaces can trigger the same buff without duplicating cooldown truth.
- `WeaponProfile` centralizes legacy/internal id -> player-facing weapon mapping plus tier/evolution names, colors, icon styles, projectile style ids, hit-VFX family ids, guardian weapon-module ids, muzzle reach, muzzle flash scale, recoil distance, and audio-hook ids so those values do not drift across multiple scripts.
- `WeaponModuleFactory` owns the reusable guardian-mounted weapon silhouettes and muzzle-flash shapes. `Core` asks it to rebuild modules instead of hardcoding every weapon shape inline.
- `ProjectileVisualFactory` owns the reusable projectile-body silhouettes. Projectile scripts keep movement/collision ownership and only request a style id plus a build helper.
- `Core` owns the fixed guardian body, aim-follow, recoil, and the tier-specific weapon module presentation around the same center-origin gameplay point.
- `GameBackground` owns the single `basicbackground.png` gameplay image plus the subtle level-based tint shift. No weapon-specific background switching remains active.
- `HitEffectBurst`, `CombatProcEffect`, `DamageNumber`, `BrickBreakEffect`, `UnlockAnnouncement`, and `GameBackground` are visual-only presentation layers; they must not change score, HP, damage, progression, or spawn policy.
- `UnlockAnnouncement` owns the short Korean weapon-change banner, while `AudioManager.play_weapon_change()` is the narrow no-op/future SFX hook for that same event.
- `AudioManager.play_weapon_proc()` is the narrow no-op/future SFX hook for chain/prism/meteor/cannon proc moments.
- `GameRoot` may expose narrow spawn helpers such as `spawn_damage_number(...)`, `spawn_brick_break_effect(...)`, and `spawn_combat_effect(...)`, but it must not own combat balance tables.
- `WeaponChoicePanel` still owns choice-card layout/copy, but its card colors/icons now come from `WeaponProfile` so visual identity is not duplicated in the domain layer.

### 5.2 Application

- `scripts/application/progression/progression_service.gd`
- `scripts/application/rings/ring_spawn_planner.gd`

**Responsibilities**
- `ProgressionService`: maps K thresholds to projectile tier and current level-loop length.
- `RingSpawnPlanner`: produces ring spawn specs from current K and radius; must support circumference-derived counts, the shrinking-wall tiling rule, and the `2000+` 5-layer → 8-layer escalation.

### 5.3 Domain

- `scripts/domain/bricks/brick_rules.gd`
- `scripts/domain/combat/damage_rules.gd`
- `scripts/domain/combat/weapon_choice_rules.gd`
- `scripts/domain/danger/danger_rules.gd`

**Responsibilities**
- `BrickRules`: segment type enum, numeric HP mapping, base colors, **segment size constant**.
- `DamageRules`: centralized per-tier numeric weapon damage table.
- `WeaponChoiceRules`: centralized `2000` trigger threshold, choice ids, card copy, proc intervals, and choice-specific constants.
- `DangerRules`: danger threshold policy from normalized radius.

### 5.4 Infrastructure

- `scripts/infrastructure/config/json_config_loader.gd`
- `scripts/infrastructure/persistence/save_file_repository.gd`

### 5.5 Autoload Coordinators

- `scripts/autoload/game_state.gd`
- `scripts/autoload/save_manager.gd`
- `scripts/autoload/audio_manager.gd`
- `scripts/autoload/danger_manager.gd`
- `scripts/autoload/platform_bridge.gd`
- `scripts/gameplay/input_handler.gd` (autoloaded coordinator)

---

## 6. Key Runtime Flows

### 6.1 Score Flow

1. `AimJoystick` updates `InputHandler.aim_direction` while preserving the last valid direction after release.
2. `Weapon` fires from the center core area toward `InputHandler.aim_direction`.
2. Projectile travels outward toward the shrinking ring wall.
3. Projectile hits a wall `BrickInstance`.
4. `RingInstance` resolves spread damage on the impacted segment and its wrapped neighbors.
5. Arrow projectiles reflect and continue until their 3-bounce budget is exhausted.
6. Destroyed segments still emit `brick_destroyed` upward through `RingInstance` and `RingSpawner`.
7. `GameRoot` increments K through `GameState.add_k(1)` once per actual destroyed segment.

### 6.1a Aim-Joystick Flow

1. `AimJoystick` renders inside `RootUI/SafeAreaContainer` with three placement states: left, center, right.
2. Left/right placeholder buttons move the joystick anchor between those states.
3. The joystick drag updates `InputHandler` with a normalized direction only; it never moves gameplay actors.
4. Releasing the joystick does not clear aim; `InputHandler` keeps the last valid normalized direction for auto-fire continuity.
5. The current joystick placement may be persisted as a lightweight player preference without changing combat rules.

### 6.1b Unlock-Progress Flow

1. `GameState` keeps using destroyed-brick count `K` as the progression source.
2. `ProgressionService` exposes the configured tier list, per-tier thresholds, display names, and which tiers are currently implemented in combat.
3. `GameState` tracks:
   - the current implemented combat tier
   - the current configured progression tier
   - the next configured unlock threshold
4. HUD reads that state and shows:
   - current visual level band (`1단계`, `2단계`, ...)
   - current level-band progress as a horizontal bar
   - current `깬 벽돌`
   - current combat weapon name
   - next unlock name + threshold, or next-stage state
5. When `K` crosses any configured tier threshold, `GameState` emits a generic tier-threshold event.
6. `UnlockAnnouncement` subscribes to that event for non-blocking Korean unlock banners, and `Core` may subscribe for a small guardian pulse.
6. The existing stone-specific hook remains available for compatibility with the first unlock.
7. The level bar is driven by real runtime state:
   - `GameState.current_level` — integer level counter (starts at `1`, increments at K `1000`)
   - `GameState.current_level_k` — K within the current level (resets to `0` on level-up)
   - `GameState.total_progress` — normalized ranking value (level-first, then `current_level_k`)
   - At K `1000` the runtime transitions to the next level (loop repeats `0–999`); no active K `1000+` continuation band exists

### 6.2 Game Over Flow

1. `Core` detects a brick entering the kill zone (ring has shrunk to core radius).
2. `Core` emits `core_breached`.
3. `GameRoot` calls `GameState.trigger_game_over()`.
4. `GameState` persists run result via `SaveManager` and emits `game_over`.
5. `GameRoot` stops spawning and resets danger state.
6. `GameOverScreen` reacts to the signal and shows the result.

### 6.3 Danger Flow

1. `RingInstance` registers/unregisters itself with `DangerManager`.
2. `DangerManager` tracks the nearest ring radius.
3. `DangerRules` converts normalized distance into danger level.
4. `DangerOverlay` and `AudioManager` react to the emitted level.

### 6.4 Persistence Flow

1. Save data loaded by `SaveManager` on startup.
2. `AudioManager` reads persisted sound state during `_ready()`.
3. `AimJoystick` may read/write the player's joystick anchor preference through `SaveManager`.
4. `GameState.trigger_game_over()` records best K through `SaveManager`.
5. `AudioManager.set_sound_enabled()` persists sound preference immediately.

### 6.5 Platform / Lifecycle Flow

1. `PlatformBridge.init_platform()` registers `visibilitychange` and `popstate` JS listeners on Web.
2. Tab hidden → `AudioManager.mute_all()`; tab visible → `AudioManager.restore_mute_state()`.
3. Back gesture during active play → `PauseMenu.show_menu()`.
4. Back gesture outside active play → `ConfirmExitDialog.show_dialog()`.
5. User confirms exit → `PlatformBridge.request_close()` → `TossBridge.close()` or `get_tree().quit()`.

---

## 7. Current Data Sources

- `data/progression.json`: projectile-tier thresholds, display names, and whether a configured tier is already implemented in combat.
- `data/game_config.json`: global config (shared play-field radius, segment size, core layout values).
- `user://save.json`: local save file managed by `SaveFileRepository`.

### Locked progression notes

- K `0–29` = `화살`
  - gold starter arrow identity
  - `3` bounces
  - same-layer hit radius `1`
- K `30–79` = `번개`
  - `2` yellow electric projectiles
  - `3` bounces each
  - same-layer hit radius `1`
- K `80–149` = `스파크 랜스`
  - `3` blue electric lances
  - `3` bounces each
  - same-layer hit radius `1`
- K `150–299` = `볼트 스톰` (runtime uses the stable electric split combat path)
  - `2` wall layers
  - composition = `Strong + Armored`
  - electric hit budget must preserve its full intended effective hit count by reallocating into other valid targets if preferred targets are already destroyed
- K `300–499` = `볼트 스톰`
  - still the same weapon family
  - `2` wall layers
  - composition = `Strong + Armored`
  - electric hit budget must still be preserved through deterministic reallocation
- K `500–2999` = `시즈 캐논` (`Piercing Bomb Siege`)
  - `5` wall layers
  - composition = `Strong + Strong + Normal + Strong + Armored`
  - attack pattern = `7` center-origin spears at `-36° / -24° / -12° / 0° / +12° / +24° / +36°`
  - center spear = `0` bounce, up to `2` pierced collisions, enlarged terminal explosion neighborhood = same layer `{I-2, I-1, I, I+1, I+2}` plus adjacent outer / inner layer centers if present
  - three side spears each side = `0` bounce, `1` pierced collision each, smaller support explosion for readability
- K `3000` = level transition threshold
  - `current_level` increments; `current_level_k` resets to `0`
  - gameplay loop restarts at the K `0` band of the new level (identical structure)
  - max level is `100`; reaching Level `100` K `3000` ends the run
- Overclock / attack-speed buff
  - the existing Overclock effect is reused as the first real attack-speed buff
  - unlock threshold = `K >= 500`
  - activation can come from:
    - the bottom skill-slot scaffold
    - the placeholder buff button above the joystick divider
  - both UI surfaces must drive the same underlying buff state

### Spec / runtime alignment note

- The late-game design spec is locked from K `300` upward in the docs.
- Runtime code has caught up through the original-repo apply branch (`feature/design-rebuild-apply-pass`): the Korean UI pass, single-background tint policy, brick redesign, guardian/core rebuild, tier-aware hit effects, stronger proc VFX, unlock announcements, K `500–2999` 7-shot siege, K `3000` level-loop transition, and Level `100` max-clear rule are all present and headless-validated.
- `data/progression.json` retains the same K thresholds, but the visible UI uses Korean names and the player-facing `깬 벽돌` terminology.

---

## 8. Toss-Sensitive Notes

- Portrait-first main run path is preserved.
- Safe-area padding is centralized in `scripts/ui/root_ui.gd`.
- The aim joystick lives inside the same safe-area container, so left/center/right switching stays within the mini-app-safe UI bounds.
- Audio mute/unmute lifecycle is wired to JS `visibilitychange` via `PlatformBridge`.
- Persistence foundation exists; relaunch validation still needs a real editor/export run.
- Exit confirmation wired through `ConfirmExitDialog` + `PlatformBridge.request_close()`.

---

## 9. Deferred Items

- Central-firing correction validation in a live Godot run
- Bounce/spread combat validation in a live Godot run
- Hybrid electric-suppression behavior beyond the newly revised K `500+` siege core
- Real audio implementation beyond mute/intensity stubs
- Safe-area and persistence validation in actual Godot/Web runtime
- Toss JS bridge surface verification (TossBridge.close, TossBridge.getUser shape)
- Export config (fullscreen, portrait CSS lock)
- Skill bar: additional skill slots beyond Overclock

---

## 10. Obsolete Prototype Notes (Do Not Restore)

| What Was True in the Prototype | Correct Target |
|-------------------------------|----------------|
| `Weapon` at bottom of play field while `Core` stayed centered | `Weapon` and `Core` share the center launch/death zone |
| Ring spawn with fixed small brick count (10 + K scaling) | Segment count derived from current circumference |
| Wall count fixed after spawn | Active wall count decreases with radius to avoid overlap |
| Projectile hits only the directly collided segment | `화살` spreads to 3 same-layer hits and bounces 3 times; `번개` keeps same-layer 3-target electric spread as the Tier 2 runtime rule |
