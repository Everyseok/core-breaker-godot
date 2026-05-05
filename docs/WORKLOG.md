# Work Log — game_junseokism.ver1

Entries are append-only. Most recent at top.

---

## 2026-05-04 — Session 60: Global Korean UI Font Application

**Focus**
- Apply the user-provided Korean UI font globally without touching gameplay/domain logic and without scattering font loads across many scripts.

**Asset organization**
- Found user-provided font at `res://game_ui_kr.ttf`
- Copied it into the canonical UI asset path:
  - `res://assets/fonts/game_ui_kr.ttf`
- The root copy remains in the repo as the original supplied file, but the active UI code path now points only to `res://assets/fonts/game_ui_kr.ttf`

**What changed**
- `scripts/ui/ui_style.gd`
  - Added `UI_FONT_PATH = "res://assets/fonts/game_ui_kr.ttf"`
  - Centralized font ownership there
  - `get_font()` and `get_display_font()` now resolve to the same Korean UI font resource
  - System-font chains remain only as fallback if the asset cannot be loaded
- Existing UI components that already use `UiStyle` or `UiStyleRef.get_display_font()` now inherit the new font automatically:
  - Main Menu
  - Pause Menu
  - HUD
  - Game Over / result
  - Confirm-exit dialog
  - Unlock banner
  - Weapon choice panel
  - Aim-joystick position/buff buttons
- No gameplay/domain files were edited for the font pass

**Exceptions**
- Damage numbers were left unchanged because they are part of the visual/combat feedback layer rather than the Korean UI layer and may not remain readable with the pixel-style font.

**Validation**
- `git diff --check` passed
- `jq '.' data/dev_status.json` passed
- `rg` audit confirmed the canonical path is centralized in `scripts/ui/ui_style.gd`
- Godot headless project-open smoke test passed with `/Users/junseokism/Downloads/Godot 2.app/Contents/MacOS/Godot`
- No separate `.godot/imported/game_ui_kr...` artifact appeared; Godot loaded the `.ttf` directly in this setup
- Automated screenshot generation still failed, so visible success is still not being claimed

**Phase:** 4.21ZK — Global Korean UI font asset integrated; visible screenshot verification still pending
**Files touched:** `assets/fonts/game_ui_kr.ttf`, `scripts/ui/ui_style.gd`, docs/status files

---

## 2026-05-03 — Session 59: Title Screen + Best-Score + Pause Panel + Font Recovery

**Focus**
- Apply a narrow recovery pass for four user-reported issues only: duplicate baked-title overlay on the title screen, suspicious best-score binding, pause-panel wrapping failure, and text treatment that still felt too plain.

**Diagnosis**
- Result: `STRUCTURALLY_CLEAN_NEEDS_NARROW_FIX`
- Evidence:
  - `MainMenu` and `PauseMenu` were already scene-owned; no duplicate runtime card builder remained.
  - `mainbackground.png` was already loading from `res://mainbackground.png`.
  - The visible title duplication came from `TitleShadow` / `TitleLabel` staying active even when the poster background already contained a baked title/logo.
  - The best-score problem was not two different save files; it was ambiguous API naming (`best_k` vs `best_total_progress`) and no clearly named authoritative getter/signal for UI consumers.
  - The pause plate did not actually contain its title/buttons because those nodes were still siblings of `PausePlate`, not children inside it.
  - No bundled Korean font asset exists in the repo; only system-font chains were available.

**What changed**
- `scripts/ui/main_menu.gd`
  - Added conditional title hiding: when the loaded title-screen background file is `mainbackground.png`, `TitleShadow`, `TitleLabel`, and `MenuTrim` are hidden so the baked poster title is not duplicated.
  - Switched the best-record label to the authoritative SaveManager getter.
  - Upgraded the best-record label to the display-font chain for a slightly cuter/game-like treatment.
- `scripts/autoload/save_manager.gd`
  - Added `best_record_changed(best_value)` signal.
  - Added `get_best_record_value()` as the explicit source-of-truth getter for UI.
  - Normalized legacy `best_k` and explicit `best_total_progress` on load so UI does not depend on ambiguous fallback behavior.
- `scripts/infrastructure/persistence/save_file_repository.gd`
  - Added default keys for `best_total_progress`, `best_level`, and `best_level_k` so the save contract is explicit instead of half-legacy.
- `scripts/ui/hud.gd`
  - Switched the HUD best label to the new authoritative getter and refresh signal.
  - Moved the HUD best label to the display-font chain for better readability/game feel.
- `scripts/ui/game_over_screen.gd`
  - Switched result-screen best-record copy to the same authoritative getter for consistency.
- `scenes/ui/root_ui.tscn` + `scripts/ui/pause_menu.gd`
  - Reparented `PauseTrimTop`, `PauseTrimBottom`, `PauseTitleShadow`, `PauseTitle`, `ResumeButton`, `SoundToggleButton`, and `RestartButton` under `PausePlate`.
  - Expanded/tuned the plate so the title and all three buttons now sit inside one coherent panel with real padding.

**Save / best-record snapshot**
- Persisted file path:
  - `/Users/junseokism/Library/Application Support/Godot/app_userdata/game_junseokism.ver1/save.json`
- Observed persisted record in this environment:
  - `best_k = 100000`
  - `best_total_progress = 100000`
- After this pass, the intended UI metric is explicitly the persisted total-progress record exposed as `SaveManager.get_best_record_value()`.

**Validation**
- `git diff --check` passed
- `jq '.' data/dev_status.json` passed
- `rg` audit confirmed:
  - no runtime `Panel.new()` / `Button.new()` / `Label.new()` menu builders remain
  - one `PausePlate` content tree owns the pause title and buttons
  - UI consumers now reference `get_best_record_value()` / `best_record_changed`
- Godot binary found at `/Users/junseokism/Downloads/Godot 2.app/Contents/MacOS/Godot`
- `Godot --headless --scene res://scenes/main/main.tscn --quit-after 5` passed
- Automated screenshot generation still failed, so visible success is still not being claimed

**Phase:** 4.21ZI — Narrow title/best/pause/font recovery applied; visible screenshot verification still pending
**Files touched:** `scenes/ui/root_ui.tscn`, `scripts/ui/main_menu.gd`, `scripts/ui/pause_menu.gd`, `scripts/ui/hud.gd`, `scripts/ui/game_over_screen.gd`, `scripts/autoload/save_manager.gd`, `scripts/infrastructure/persistence/save_file_repository.gd`, docs/status files

---

## 2026-05-03 — Session 58: Main Menu / Pause Menu Recovery + Entanglement Diagnosis

**Focus**
- Diagnose whether the rebuilt title screen / pause menu were structurally tangled or simply visually weak, then recover only the menu presentation without touching gameplay/domain rules.

**Diagnosis**
- Result: `STRUCTURALLY_CLEAN_BUT_VISUALLY_POOR`
- Evidence:
  - `MainMenu` is now scene-owned in `scenes/ui/root_ui.tscn` and no longer builds runtime cards/emblems/stars.
  - `PauseMenu` is now scene-owned in `scenes/ui/root_ui.tscn` and no longer has `_card` / `_build_card()` / runtime `Panel.new()` builders.
  - Runtime Godot diagnosis confirmed `res://mainbackground.png` is actually loaded, `BackgroundTexture` is visible, and `BackgroundFallback` is hidden.
  - Therefore the remaining problem was not duplicate systems or a wrong background path; it was the menu still reading too dark / too heavy visually.

**What changed**
- Reduced Main Menu overlay strength so the poster background reads more clearly:
  - `TopOverlay` alpha `0.46 -> 0.18`
  - `BottomOverlay` alpha `0.58 -> 0.28`
  - `Left/RightVignette` alpha `0.30 -> 0.14`
- Tightened Main Menu title/button layout so the title sits higher and the button stack sits lower over the poster.
- Kept the real UI title/button layer while still allowing the current `mainbackground.png` poster to remain visible.
- Slimmed Pause Menu so it no longer reads as a giant old card:
  - dim alpha `0.74 -> 0.58`
  - smaller `PausePlate` / `PausePlateShadow`
  - lighter trim lines and lighter menu plate styling
- Confirmed again that menu behavior remains script-owned while scene nodes own the visible structure.

**Runtime diagnosis snapshot**
- `loaded_background_path = res://mainbackground.png`
- `background_texture_visible = true`
- `background_texture_has_texture = true`
- `background_fallback_visible = false`
- `main_menu_visible = true`
- `pause_menu_visible = false`

**Validation**
- `git diff --check` passed
- `jq '.' data/dev_status.json` passed
- `Godot --headless --scene res://scenes/main/main.tscn --quit-after 5` passed using `/Users/junseokism/Downloads/Godot 2.app/Contents/MacOS/Godot`
- Screenshot generation was attempted but still failed under automated capture paths, so visible success is still not being claimed

**Phase:** 4.21ZH — Menu recovery applied after entanglement diagnosis; screenshot automation still incomplete
**Files touched:** `scenes/ui/root_ui.tscn`, `scripts/ui/main_menu.gd`, `scripts/ui/pause_menu.gd`, `scripts/ui/ui_style.gd`, docs/status files

---

## 2026-05-03 — Session 57: Main Menu + Pause Menu Visual Rebuild Pass

**Focus**
- Rebuild `MainMenu` and `PauseMenu` so they match the newer HUD language instead of using runtime-generated prototype cards / big generic boxes, while cleanly wiring the cinematic `mainbackground.png` hook.

**What changed**
- Rebuilt `MainMenu` into one scene-owned title-screen tree in `scenes/ui/root_ui.tscn`:
  - `BackgroundFallback`
  - `BackgroundTexture`
  - `TopOverlay` / `BottomOverlay`
  - `LeftVignette` / `RightVignette`
  - `TitleShadow` / `TitleLabel`
  - `MenuTrim`
  - `BestLabel`
  - `StartButton`
  - `RankingButton`
- Rewrote `scripts/ui/main_menu.gd` so it no longer generates runtime cards, emblem blocks, stars, or border lines.
- Added clean background loading order for the title screen:
  - `res://assets/backgrounds/mainbackground.png`
  - fallback `res://mainbackground.png`
  - fallback color surface if neither exists
- Rebuilt `PauseMenu` into one scene-owned overlay tree:
  - `DimOverlay`
  - `PausePlateShadow`
  - `PausePlate`
  - `PauseTrimTop`
  - `PauseTrimBottom`
  - `PauseTitleShadow`
  - `PauseTitle`
  - `ResumeButton`
  - `SoundToggleButton`
  - `RestartButton`
- Rewrote `scripts/ui/pause_menu.gd` so it no longer creates a runtime `_card` panel or header line.
- Extended `scripts/ui/ui_style.gd` with shared menu language helpers and constants:
  - menu surface / trim colors
  - arcade button styles
  - menu title treatment
  - dedicated `apply_menu_plate()` helper

**Validation**
- Static duplicate-button / stale-panel audits run successfully
- Gameplay/domain rule owners were not edited in this pass
- Fresh Godot screenshot/runtime capture is still blocked until a working Godot binary path is available again

**Phase:** 4.21ZG — Main Menu + Pause Menu visual rebuild applied; runtime screenshot pending
**Files touched:** `scenes/ui/root_ui.tscn`, `scripts/ui/main_menu.gd`, `scripts/ui/pause_menu.gd`, `scripts/ui/ui_style.gd`, docs/status files

---

## 2026-05-03 — Session 56: Reference-Match Top HUD Visual Rebuild Pass

**Focus**
- Remove the remaining small-box / prototype-panel feeling from the top HUD and rebuild it as one wide reference-style top band without touching gameplay math or progression rules.

**What changed**
- Rebuilt the HUD scene structure in `scenes/ui/root_ui.tscn` so the active top HUD is now one explicit tree:
  - `HudBand`
  - `LevelGauge` + centered `LevelLabel`
  - `ThresholdWeaponModule`
  - `MainNumberShadowLabel` + `MainNumberLabel`
  - `PauseButton` with explicit pause bars
  - `Divider`
  - `CurrentWeaponModule`
  - `BestKLabel`
  - `WeaponFlash` / `WeaponImpactLabel`
- Rewrote `scripts/ui/hud.gd` to consume that scene-owned tree instead of dynamically building another boxed HUD on top of it
- Removed the old boxed/prototype look by design:
  - no threshold panel box
  - no current-weapon box panel
  - no center-number card
  - no nested small colored boxes around the main HUD elements
- The center number is now layered arcade text:
  - cyan/sky-blue shadow label
  - white main label
  - dark outline
  - no visible rectangle behind it
- The threshold-band info above the divider is now a compact icon/text group with a thin accent line, not a form-field-like box
- The current weapon row below the divider is now a compact accent line + label, not a big colored rectangle
- The pause button is now a dedicated rounded button with explicit pause-bar subnodes instead of label text `II`
- Grouped the HUD geometry into constants in `hud.gd`, and kept weapon color/name/icon data sourced from `WeaponProfile`
- Added a runtime cleanup pass in `hud.gd` that frees old legacy dynamic HUD nodes if they appear

**Validation**
- `git diff --check`: passed
- `jq '.' data/dev_status.json`: passed
- Stale HUD-label grep: no matches for:
  - `NextUnlockLabel`
  - `CountCaptionLabel`
  - `WeaponCaptionLabel`
  - `SupportStrip`
  - `ProgressTextLabel`
  - `StageLabel`
  - `TurnLabel`
- Duplicate-role grep confirms one active scene-owned set of:
  - `LevelGauge`
  - `ThresholdWeaponModule`
  - `MainNumberLabel`
  - `PauseButton`
  - `CurrentWeaponModule`
- `scripts/ui/hud.gd` still has no references to `DamageRules`, `BrickRules`, damage application, or wall-spawn ownership
- Godot screenshot/extra runtime validation was attempted, but the previously used Godot binary path became unavailable during this pass, so no fresh capture was produced

**Limits / honest gap**
- No true visible GUI observation was performed in-session
- The required screenshot attempt was made, but no PNG was generated because the Godot binary path was unavailable at capture time
- Final visual judgment still needs a real Godot/editor visible pass

---

## 2026-05-03 — Session 55: Strict Reference Top HUD Correction Pass

**Focus**
- Replace the still-too-boxed top HUD with a reference-like wide top band: top striped level gauge, left threshold-band module, huge center number, right pause button, divider, and a below-divider current-weapon row.

**What changed**
- Rebuilt `scripts/ui/hud.gd` again around a near-full-width top shell instead of the previous compact centered-card feel
- The top HUD now uses:
  - a wide striped `Lv.X` gauge across the top
  - a compact threshold-band module on the left above the divider
  - a large center number-only broken-brick display with no `깬 벽돌` label and no `K`
  - a thick rounded pause button at the far right
  - a full-width divider
  - a below-divider current-weapon row and a compact best-record label
- Tightened the layout to fit `390x844` more safely:
  - narrower threshold chip
  - slightly smaller but still dominant center number
  - pause button pushed farther right
- Kept the threshold/current-weapon meaning split intact:
  - above divider = current progression band
  - below divider = actual current weapon

**Validation**
- Godot 4.6.2 headless project-open smoke test: passed
- `/private/tmp/design_strict_top_hud_validation.gd`: passed
  - shell width is now near full viewport width
  - top level gauge exists and is wide
  - threshold module is above divider on the left
  - center number is number-only
  - pause button is on the far right
  - current weapon row is below divider
- Existing progression validation `/tmp/design_progression_choice_validation.gd`: passed
- `git diff --check`: passed
- `jq '.' data/dev_status.json`: passed

**Limits / honest gap**
- No true visible GUI observation was performed in-session
- No reliable screenshot was produced from headless runtime
- The final premium feel still needs a real Godot/editor visible check

---

## 2026-05-03 — Session 54: Final Top HUD + Electric Arc Visibility Pass

**Focus**
- Rebuild the top HUD around the final reference structure:
  striped top level gauge, threshold-band module, center number-only display, divider, and a below-divider current-weapon module.
- Make electric chain/arc VFX obviously visible without touching damage/progression math.

**What changed**
- Rebuilt `scripts/ui/hud.gd` again into the final compact structure:
  - top striped level gauge with centered `Lv.X`
  - left current-band threshold module (`0+ 화살`, `30+ 번개`, etc.)
  - center number-only current broken-brick display
  - right rounded pause button
  - horizontal divider
  - below-divider current weapon module
  - small best-record label on the right
- Removed the previous HUD behaviors that made the top area feel too label-heavy:
  - no `깬 벽돌` text around the center number
  - no top-left `단계` block
  - no active next-unlock HUD row
- Added narrow read-only progression getters in `scripts/autoload/game_state.gd` so the HUD can read the active band threshold/name without duplicating threshold constants
- Strengthened electric-arc readability in:
  - `scripts/visual/combat_proc_effect.gd`
  - `scripts/visual/hit_effect_burst.gd`
- `combat_proc_effect.gd` now renders chain lightning with:
  - thicker cyan/sky-blue/white arcs
  - multi-layer glow/core lines
  - more jagged points across long distances
  - larger endpoint flashes and spark clusters
- `hit_effect_burst.gd` now renders stronger local electric/storm contact arcs for:
  - `번개`
  - `연쇄 번개`
  - `볼트 스톰`
- `scripts/ui/ui_style.gd` display-font chain remains the central HUD font owner; no new bundled font asset was added in this pass

**Validation**
- Godot 4.6.2 headless project-open smoke test: passed
- `/tmp/design_top_hud_final_layout_validation.gd`: passed
  - top level gauge exists
  - stripe pattern exists
  - `Lv.` text centered inside gauge
  - threshold module exists above divider
  - center number is number-only
  - current-weapon module exists below divider
  - old next-unlock HUD row is gone
- `/tmp/design_electric_arc_visibility_validation.gd`: passed
  - chain effect spawns multiple thick blue/cyan lines
  - long-distance arc uses enough jagged points
  - endpoint flashes/sparks exist
  - thunder/storm impacts now spawn thicker electric arcs
- Existing progression validation `/tmp/design_progression_choice_validation.gd`: passed
- Existing weapon-constitution validation `/tmp/design_weapon_constitution_validation.gd`: passed
- `git diff --check`: passed
- `jq '.' data/dev_status.json`: passed

**Limits / honest gap**
- No true visible GUI observation was performed in-session
- No reliable screenshot was produced from headless runtime
- Final judgment on the HUD’s boldness and the chain-lightning readability still needs a visible playtest

---

## 2026-05-03 — Session 53: Top HUD Full Redesign Pass

**Focus**
- Replace the previous top HUD arrangement with a much bolder information hierarchy and a more game-like font feel without changing gameplay/progression math.

**What changed**
- Rebuilt `scripts/ui/hud.gd` into a new top-deck arrangement:
  - fixed outer shell
  - top row level chip
  - large broken-brick count card
  - separate progress row with `current / max`
  - separate weapon card
  - small support strip for next unlock + best record
- The main `깬 벽돌` card is now the most visually prominent status element
- The weapon card now shows the current weapon name more cleanly while keeping the weapon-only dynamic color rule
- Added distinct internal HUD nodes for:
  - `CountCard`
  - `CountCaptionLabel`
  - `WeaponCaptionLabel`
  - `ProgressTextLabel`
  - `SupportStrip`
- Updated `scripts/ui/ui_style.gd` with a dedicated display-font chain that prefers cute/retro/pixel-like Korean-capable system fonts if available:
  - `NeoDunggeunmo`
  - `DungGeunMo`
  - `Galmuri`
  - `CookieRun`
  - `NanumSquareRound`
  - then safe Korean-capable fallbacks
- The top HUD now uses the display-font chain for the level chip, main broken-brick count, weapon card, and short impact text
- Compact support copy remains Korean and secondary:
  - `다음 해금: ...`
  - `최고 ...개`

**Validation**
- Godot 4.6.2 headless project-open smoke test: passed
- Existing HUD/control validation `/tmp/design_hud_polish_validation.gd`: passed
- New top-HUD redesign validation `/tmp/design_top_hud_redesign_validation.gd`: passed
  - new shell/count/support/progress/weapon-caption nodes exist
  - main count is larger than the weapon label
  - weapon label is larger than support labels
  - display font is applied to the main count and weapon label
  - level chip / pause, count / weapon, and next / best do not overlap
  - outer shell remains fixed while the weapon card recolors
- `git diff --check`: passed
- `jq '.' data/dev_status.json`: passed

**Limits / honest gap**
- No true visible GUI observation was performed in-session
- No screenshot could be reliably generated in headless mode
- Final judgment on the new top-HUD boldness and the font feel still needs a visible Godot playtest

---

## 2026-05-03 — Session 52: Global Weapon Visual Constitution Pass

**Focus**
- Unify all player-facing weapon families under one clean visual constitution:
  `화살`, `번개`, `스파크 랜스`, `볼트 스톰`, `시즈 캐논`, plus the evolution choices `연쇄 번개`, `프리즘 랜스`, `메테오 캐논`.
- Improve the fixed guardian and per-weapon presentation without touching stable damage/progression/wall rules.

**What changed**
- Replaced `scripts/visual/weapon_profile.gd` with a fuller centralized visual owner that now maps:
  - base tiers
  - evolution choices
  - legacy/internal ids
  - display names
  - icon styles
  - guardian module styles
  - projectile style ids
  - hit/proc VFX styles
  - muzzle flash scale / muzzle reach
  - recoil category
  - audio hook ids
- Added:
  - `scripts/visual/weapon_module_factory.gd`
  - `scripts/visual/projectile_visual_factory.gd`
- `weapon_module_factory.gd` now owns guardian-mounted weapon silhouettes and muzzle-flash construction for:
  - `화살`
  - `번개`
  - `스파크 랜스`
  - `볼트 스톰`
  - `시즈 캐논`
  - `연쇄 번개`
  - `프리즘 랜스`
  - `메테오 캐논`
- `projectile_visual_factory.gd` now owns projectile-body silhouettes so the active projectile scripts no longer carry their own inline shape tables
- `scripts/gameplay/core.gd` now delegates weapon-module and muzzle-flash building to the new visual factory while keeping:
  - fixed guardian identity
  - aim-follow
  - recoil
  - center-origin launch ownership
- `scripts/gameplay/weapon.gd` now injects the active projectile visual style id into spawned projectiles and keeps the aim-line colors in sync with the active tier/evolution profile
- Active projectile scripts now stay thin:
  - each keeps movement / collision / hit logic
  - each resolves its projectile visual style through `WeaponProfile`
  - each asks `ProjectileVisualFactory` to build its body
  - each passes the resolved visual style id into hit-effect configuration
- `scripts/visual/hit_effect_burst.gd` now resolves its impact family by visual profile rather than just tier number, so choice/evolution weapons can show their own impact language:
  - `연쇄 번개` chain-electric impact
  - `프리즘 랜스` prism flare impact
  - `메테오 캐논` hotter meteor burst
- `scripts/visual/combat_proc_effect.gd` now also pulls colors from `WeaponProfile` instead of duplicating visual fields in the domain layer
- `scripts/domain/combat/weapon_choice_rules.gd` had visual-only fields removed; it now keeps only choice ids, copy, trigger constants, and proc/balance constants
- `scripts/ui/weapon_choice_panel.gd` now gets choice-card colors/icons from `WeaponProfile`, so the domain layer no longer owns presentation color data
- `scripts/ui/hud.gd` and `scripts/ui/unlock_announcement.gd` now show the selected evolution weapon as the current visible weapon family using the same centralized visual profile

**Validation**
- Godot 4.6.2 headless project-open smoke test: passed
- `/tmp/design_weapon_constitution_validation.gd`: passed
  - all 8 player-facing weapon profiles resolve
  - legacy/internal ids map correctly
  - siege still fires 7 shots
  - evolution choices switch the HUD label
  - evolution choices inject the correct projectile visual style id
- Previous VFX validation `/private/tmp/design_weapon_vfx_validation.gd`: passed
- Previous progression/layout validation `/tmp/design_progression_choice_validation.gd`: passed
- `git diff --check`: passed
- `jq '.' data/dev_status.json`: passed
- grep/audit checks confirmed:
  - no `GameState.add_k()` or hit/damage application calls inside `scripts/visual`
  - no stale `weapon_choice_proc_effect` or `spawn_weapon_choice_effect` runtime references
  - no active `stone_projectile` runtime references

**Limits / honest gap**
- No true visible GUI observation was performed in-session
- The guardian/weapon premium feel and the distinction between `볼트 스톰`, `시즈 캐논`, and `메테오 캐논` still need a real on-screen playtest
- `AudioManager` remains hook-only; no production weapon SFX assets were added

---

## 2026-05-03 — Session 51: Targeted Weapon VFX + Guardian Polish Pass

**Focus**
- Make electric / lance / storm / cannon combat feedback much more legible and satisfying without touching damage math, thresholds, or wall rules.
- Upgrade the center guardian and visible weapon module so they look more intentional, distinct by tier, and more premium in motion.

**What changed**
- Expanded `scripts/visual/weapon_profile.gd` so it now also centralizes:
  - VFX family id (`arrow / electric / lance / storm / cannon`)
  - muzzle reach
  - muzzle flash scale
  - recoil distance
- Rebuilt `scripts/visual/hit_effect_burst.gd` into clear per-family impact builders:
  - `화살`: modest gold streak / flash
  - `번개`: blue-white / cyan crackle with electric spark bursts
  - `스파크 랜스`: sharper blue-violet lance flares and prism glints
  - `볼트 스톰`: richer storm-energy arcs plus plasma ring
  - `시즈 캐논`: heavier flash / shock ring / fragment / smoke burst
- Replaced the old choice-proc effect owner with:
  - `scenes/vfx/combat_proc_effect.tscn`
  - `scripts/visual/combat_proc_effect.gd`
- `combat_proc_effect.gd` now owns:
  - `연쇄 번개` chain arcs between origin and target
  - `프리즘 랜스` center flare + split energy rays
  - `메테오 캐논` / cannon-impact explosion bursts
- `scripts/gameplay/game_root.gd` now uses `spawn_combat_effect(...)` as the active narrow proc-VFX spawn path
- `scripts/gameplay/ring_instance.gd` now requests the centralized proc VFX and audio hooks for:
  - chain-lightning jumps
  - meteor impacts
  - cannon-style terminal explosions
- `scripts/gameplay/weapon.gd` now:
  - adds a faint aim glow line behind the existing aim line
  - requests prism proc VFX through the centralized spawn path
  - forwards visual-only fire feedback to the guardian/core
- `scripts/gameplay/core.gd` now owns the guardian presentation more explicitly:
  - fixed base body identity preserved
  - tier-specific weapon module silhouette swaps
  - aim-follow preserved
  - short recoil offset on fire
  - tier-aware muzzle flash near the weapon tip
- `scripts/autoload/audio_manager.gd` now exposes `play_weapon_proc(...)` as a clean no-op/future hook for proc-style combat effects
- `scripts/visual/game_background.gd` remains on the simplified single-background policy:
  - only `basicbackground.png`
  - subtle level-based tint shift
  - no weapon-specific background switching

**Validation**
- Godot 4.6.2 headless project-open smoke test: passed
- Targeted VFX/guardian validation `/private/tmp/design_weapon_vfx_validation.gd`: passed
  - guardian module exists for all tiers
  - muzzle flash spawns for all tiers
  - `hit_effect_burst` builds for all tiers
  - `combat_proc_effect` builds for `chain_lightning / prism_lance / meteor_cannon / cannon_impact`
  - `GameRoot.spawn_combat_effect(...)` instantiates the new proc effect path
- Existing progression/layout validation `/tmp/design_progression_choice_validation.gd`: passed after updating it to the new proc-effect owner
- Existing HUD/control validation `/tmp/design_hud_polish_validation.gd`: passed
- Existing single-background validation `/tmp/design_single_background_validation.gd`: passed
- `git diff --check`: passed
- `jq '.' data/dev_status.json`: passed

**Limits / honest gap**
- No true visible GUI observation was performed in-session
- The new electric/explosion spectacle still needs an actual on-screen playtest for final readability judgment
- `AudioManager.play_weapon_proc(...)` is still a hook only; no production SFX asset was added

---

## 2026-05-03 — Session 50: Additional Joystick Visual Design Block

**Focus**
- Upgrade the lowered virtual stick into a cute retro pseudo-3D arcade lever without changing what it controls.

**What changed**
- Rebuilt `scripts/ui/aim_joystick.gd` around an arcade-stick visual structure:
  - `BaseShadow`
  - `BasePlate`
  - `BaseInner`
  - `BaseHighlightTop`
  - `BaseHighlightLeft`
  - `BaseLowlightBottom`
  - `SocketShadow`
  - `Socket`
  - `ShaftShadow`
  - `Shaft`
  - `KnobShadow`
  - `Knob`
  - `KnobShine`
  - `KnobSpec`
- Replaced the old flat cross-pad look with:
  - a beveled dark base plate
  - a metallic-looking shaft
  - a bright red ball-top knob
- Kept the lower control dock position unchanged from the previous pass
- The red knob now visibly moves with current drag direction
- The shaft visually follows the knob through a live `Line2D` tilt path
- When the player releases the input, the knob now smoothly returns to center visually while gameplay aim logic remains unchanged
- Side left/right placement buttons were restyled to match the arcade family better

**Validation**
- Godot 4.6.2 headless project-open smoke test: passed
- Targeted joystick validation `/tmp/design_arcade_joystick_validation.gd`: passed
  - joystick stayed in the lowered bottom zone
  - buff button stayed in the lowered zone
  - knob moved in response to aim input
  - shaft endpoint followed the knob
  - release returned the knob toward center
  - left/right placement buttons still moved the control dock
- Previous HUD/control validation `/tmp/design_hud_polish_validation.gd`: still passed
- Previous progression/layout validation `/tmp/design_progression_choice_validation.gd`: still passed

**Limits / honest gap**
- No true rendered GUI observation was performed in-session
- Final thumb readability and the exact pseudo-3D feel still need a visible playtest

---

## 2026-05-03 — Session 49: Targeted HUD / Control Polish Pass

**Focus**
- Address the latest visible-playtest UI complaints without touching gameplay/progression math:
  - move the lower control dock much farther down
  - remove the top-HUD overlap
  - keep the outer HUD shell fixed while only the weapon display changes color
  - make weapon changes hit with a short, punchy Korean feedback moment

**What changed**
- Lowered the entire joystick control dock much further in `scripts/ui/aim_joystick.gd`
  - bottom-control margin moved from `46` to `6`
  - divider/buff gaps tightened so the buff button also moves downward with the joystick
- Rebuilt the top HUD layout in `scripts/ui/hud.gd`
  - fixed shell panel remains a constant dark navy frame
  - current level chip, progress bar, broken-brick row, weapon chip, next-unlock row, and best-record row now use separate bands
  - created a dedicated `NextUnlockLabel` instead of overloading one multiline `WeaponLabel`
- Kept weapon color changes isolated to the weapon chip only through `WeaponProfile`
- Added a short weapon-change chip punch/flash in `scripts/ui/hud.gd`
  - chip briefly scales/pops
  - flash overlay bursts over the chip
  - small `쾅!` impact text pops and fades
- Updated `scripts/ui/unlock_announcement.gd` so tier changes now announce:
  - `번개 장착!`
  - `스파크 랜스 장착!`
  - `볼트 스톰 장착!`
  - `시즈 캐논 장착!`
- Added a narrow audio hook in `scripts/autoload/audio_manager.gd`
  - `play_weapon_change()`
  - still a no-op/future hook, no real SFX asset imported

**Validation**
- Godot 4.6.2 headless project-open smoke test: passed
- Targeted HUD/control validation `/tmp/design_hud_polish_validation.gd`: passed
  - joystick center lowered to `772`
  - buff button center lowered to `660`
  - HUD labels no longer overlap structurally
  - outer HUD shell color stays fixed across tier changes
  - weapon chip color changes by tier
  - weapon-change impact feedback and audio hook both trigger structurally
- Broad progression/layout validation `/tmp/design_progression_choice_validation.gd`: passed again
  - `3000` level size preserved
  - `2000` choice trigger preserved
  - `5 -> 8` wall escalation preserved
  - DamageRules and BrickRules stayed unchanged

**Limits / honest gap**
- No true rendered GUI observation was performed in-session
- The new lower thumb feel and the top-HUD readability still need one real on-screen portrait playtest

---

## 2026-05-03 — Session 48: Targeted Progression + Layout Pass

**Focus**
- Apply the user’s narrow visible-playtest requests without doing another broad redesign:
  - lower the bottom controls
  - make damage text slightly smaller
  - expand one level to `3000`
  - add a `2000` weapon-evolution choice event
  - escalate the late 5-layer wall plan to 8 layers from `2000+`

**What changed**
- Lowered the joystick + buff button area further downward in `scripts/ui/aim_joystick.gd`
- Tuned `scripts/visual/damage_number.gd` slightly smaller while keeping the same `3K/4K/5K/...` formatting
- Changed `data/progression.json` so the active siege tier now spans `500–2999`
- `ProgressionService.loop_length()` now resolves to `3000`
- `GameState` now owns:
  - once-per-level weapon-choice trigger state
  - active selected choice id
  - prism volley counter
  - meteor hit counter
  - `weapon_choice_requested` / `weapon_choice_selected` signals
- Added centralized choice definitions/constants in:
  - `scripts/domain/combat/weapon_choice_rules.gd`
- Added the new paused Korean choice UI:
  - `scenes/ui/weapon_choice_panel.tscn`
  - `scripts/ui/weapon_choice_panel.gd`
- Implemented the three choices:
  - `연쇄 번개`
  - `프리즘 랜스`
  - `메테오 캐논`
- Added choice-specific procedural VFX:
  - `scenes/vfx/weapon_choice_proc_effect.tscn`
  - `scripts/visual/weapon_choice_proc_effect.gd`
- Added prism side-ray projectile support:
  - `scenes/gameplay/prism_side_ray_projectile.tscn`
  - `scripts/gameplay/prism_side_ray_projectile.gd`
- `RingSpawnPlanner` now escalates the late `5`-layer wall plan to `8` real layers once `current_level_k >= 2000`
- Updated `SaveManager` fallback best-level math to derive the current loop length from progression data instead of assuming `1000`

**Validation**
- Godot 4.6.2 headless project-open smoke test: passed
- Targeted progression/layout validation `/tmp/design_progression_choice_validation.gd`: passed
  - `3000` level size
  - `2000` choice trigger
  - Korean choice panel
  - choice selection + resume
  - chain/prism/meteor modifier behavior
  - `2000+` 5→8 wall escalation
  - Level `100` max clear under the new `3000` rule
- `git diff --check`: passed
- `jq '.' data/progression.json` and `jq '.' data/dev_status.json`: passed
- `rg` confirmed `2000` trigger centralization in `weapon_choice_rules.gd`

**Limits / honest gap**
- No true visible GUI observation was performed in-session
- The lower controls and choice-panel “dopamine feel” still need a real on-screen playtest

---

## 2026-05-02 — Session 47: Targeted Combat Feedback Pass

**Focus**
- Add a real numeric damage/HP model and make brick destruction read as local impact feedback instead of vague absorption.

**What changed**
- Added centralized weapon damage rules in:
  - `scripts/domain/combat/damage_rules.gd`
- Converted brick HP in `scripts/domain/bricks/brick_rules.gd` from the old `1 / 2 / 3` model to:
  - `Normal = 3000`
  - `Strong = 6000`
  - `Armored = 9000`
- Updated all active projectile scripts to query centralized per-tier damage instead of pushing hardcoded `1` damage values:
  - `화살 = 3000`
  - `번개 = 4000`
  - `스파크 랜스 = 5000`
  - `볼트 스톰 = 6000`
  - `시즈 캐논 = 9000`
- Upgraded `scripts/visual/damage_number.gd` to format compact arcade values such as `3K`, `4K`, `5K`, `9K`, and `11.3K`
- Added brick-type-specific in-place destruction feedback in:
  - `scripts/visual/brick_break_effect.gd`
  - `scenes/vfx/brick_break_effect.tscn`
- Extended `game_root.gd` with a narrow `spawn_brick_break_effect(...)` helper
- Updated `ring_instance.gd` / `brick_instance.gd` so damage popups and break effects spawn at the damaged brick position
- Confirmed the active runtime does not contain a brick-death fly-to-core / absorb tween path
- Kept spread/bounce/siege behaviors intact while switching to numeric damage

**Validation**
- `git diff --check`: passed
- `jq '.' data/progression.json` and `jq '.' data/dev_status.json`: passed
- Godot 4.6.2 headless targeted combat-feedback validation `/tmp/design_combat_feedback_validation.gd`: passed
  - brick HP table
  - weapon damage table
  - `3K/4K/5K/9K/11.3K` formatting
  - in-place brick break effect spawning
  - normal brick dies to one `화살` hit
  - strong/armored survive a single `화살` hit with expected remaining HP
- Broad regression validation `/tmp/design_rebuild_apply_validation.gd`: passed
  - MainMenu / Start / Ranking path
  - Korean UI
  - tier progression
  - K `500–999` siege
  - K `1000` level transition
  - Level `100` max clear
- `rg` checks confirmed:
  - no active runtime `stone_projectile` references
  - no duplicate damage-number system
  - no duplicate brick-break-effect system
  - projectile scripts now read centralized `DamageRules`

**Limits / honest gap**
- No true rendered GUI observation was performed in-session
- The pass is structurally and headless-validated, but the feel of the new popups/break effects still needs a visible playtest

---

## 2026-05-02 — Session 46: Targeted Visible-Playtest Fix Pass

**Focus**
- Address the first real visible playtest complaints in the original `/Volumes` repo without changing gameplay math or platform flow.

**What changed**
- Added layered floating damage numbers in:
  - `scripts/visual/damage_number.gd`
  - `scenes/vfx/damage_number.tscn`
- Hooked damage popups into confirmed brick-damage paths through `ring_instance.gd`, `brick_instance.gd`, and `game_root.gd`
- Lowered the active playfield by moving `GameRoot` down in `scenes/game/game_root.tscn`
- Removed the old bottom square buff slot from `scenes/ui/root_ui.tscn`
- Deleted the now-unused:
  - `scripts/ui/skill_slot.gd`
  - `scripts/ui/skill_slot.gd.uid`
- Redesigned the joystick with layered base/knob depth and kept the single buff button above it
- Fixed the top level chip so `LevelLabel` visibly renders over the dark-blue plate
- Added guardian aim-follow / lean behavior in `core.gd`
- Added subtle aim-based background parallax and stronger brick bevel/shadow treatment

**Validation**
- `git diff --check`: passed
- `jq '.' data/progression.json` and `jq '.' data/dev_status.json`: passed
- `rg` confirmed no active `SkillBar`, `OverclockSlot`, or `stone_projectile` runtime references remain
- Godot 4.6.2 headless smoke test on the original repo: passed
- Targeted validation script `/tmp/design_visible_fix_validation.gd`: passed
  - level chip text visible in Korean
  - bottom square buff slot removed
  - joystick-area buff button retained
  - joystick layered redesign nodes present
  - playfield lowered below HUD structurally
  - damage numbers spawn on confirmed brick hit
  - guardian follows aim direction structurally
  - center launch origin preserved
- Broad regression script `/tmp/design_rebuild_apply_validation.gd`: passed
  - MainMenu / Start / Ranking path
  - Korean UI
  - `번개` / `스파크 랜스`
  - K `500–999` seven-shot siege
  - K `1000` level transition
  - Level `100` max clear

**Limits / honest gap**
- No true rendered GUI observation was performed in-session
- Cute/game-feel tuning still needs a human visible playtest in the editor or on device

---

## 2026-05-02 — Session 45: Original Repo Partial Apply + Stronger Visible Design Pass

**Branch / safety**
- Target repo: `/Volumes/junseokism_usb3.0/game/game_junseokism.ver1`
- Saved the dirty original worktree before branch work:
  - safety patch: `/tmp/game_junseokism_original_pre_apply_20260502.patch`
  - safety stash: `pre-apply-2026-05-02-original-repo-safety`
- Created `feature/design-rebuild-apply-pass` from `88d0ffe` in the original repo instead of continuing on the dirty Session 43 branch

**What was ported selectively from the temp rebuild**
- Korean player-facing UI strings
- Visible `K → 깬 벽돌` terminology replacement
- Tier ladder/presentation data:
  - `화살`
  - `번개`
  - `스파크 랜스`
  - `볼트 스톰`
  - `시즈 캐논`
- `번개` / `스파크 랜스` projectile scene+script paths
- `WeaponProfile`, `ui_style`, `unlock_announcement`, procedural background, guardian/core, and brick presentation hooks

**What was intentionally strengthened instead of blindly copied**
- MainMenu rebuilt with a larger pixel-card composition, emblem, accent bars, and stronger Korean hierarchy
- HUD rebuilt with panel framing, tier-colored weapon plate, and clearer portrait-safe label treatment
- Pause / result panels given stronger game-like framing instead of plain prototype text blocks
- Hit effects made more visible than the temp version with larger flashes, longer shard/beam silhouettes, and slightly longer fade windows
- Guardian/core silhouette and aura enlarged for clearer tier identity
- Brick type treatment (`Normal` / `Strong` / `Armored`) made more readable in motion with stronger shape contrast

**Cleanup**
- Removed active runtime Stone resources:
  - `scripts/gameplay/stone_projectile.gd`
  - `scenes/gameplay/stone_projectile.tscn`
- Confirmed the original repo now contains the applied Korean UI and tier-presentation structure

**Validation**
- `git diff --check`: passed
- `jq '.' data/progression.json`: passed
- `jq '.' data/dev_status.json`: passed
- Godot 4.6.2 headless project-open smoke test on the original `/Volumes` repo: passed
- Headless scripted runtime validation on the original `/Volumes` repo: passed
  - MainMenu launch path
  - Start Game path
  - Ranking path non-crash behavior
  - Korean menu/HUD/pause/result text
  - Tier hit-effect scene loading
  - Tier projectile spawn counts and progression thresholds
  - K `500–999` seven-shot siege preserved
  - K `1000` level transition preserved
  - Level `100` max clear preserved

**Limits / honest gap**
- No actual visible GUI/editor observation was performed in-session
- The pass is structurally and headless-validated in the original repo, but visible game-feel still needs a real on-screen playtest

---

## 2026-05-02 — Session 44: Clean Design Rebuild from Session 42 Base

**Branch / base**
- Preserved the dirty original worktree and created a clean rebuild worktree/branch from `88d0ffe`
- New clean branch: `feature/design-rebuild-clean-pass`
- Session 43 (`1d1bffc`) was inspected by diff only and **not** used as the implementation base

**What was intentionally discarded**
- The Session 43 visual implementation as the active base
- The old Stone presentation in the active runtime
- English-first placeholder UI presentation

**What was rebuilt**
- Added `docs/design_constitution.md` as the new visual source of truth
- Rebuilt weapon presentation around:
  - `화살`
  - `번개`
  - `스파크 랜스`
  - `볼트 스톰`
  - `시즈 캐논`
- Added `scripts/visual/weapon_profile.gd` to centralize names/colors/unlock copy/guardian silhouettes
- Added `scripts/visual/game_background.gd` for procedural portrait background atmosphere
- Added `scripts/visual/hit_effect_burst.gd` + `scenes/vfx/hit_effect_burst.tscn` for tier-aware visual-only hit bursts
- Added `scripts/ui/unlock_announcement.gd` for Korean unlock banners
- Added `scripts/ui/ui_style.gd` for Korean-friendly UI styling and shared panel/button/label rules
- Rebuilt the center guardian/core presentation in `core.gd`
- Rebuilt brick visuals in `brick_instance.gd`
- Rebuilt menu/HUD/pause/result presentation and Korean player-facing copy

**Gameplay/platform rules preserved**
- MainMenu launch flow
- `PlatformBridge.open_leaderboard()` ranking path
- K `500–999` seven-shot siege behavior
- Overclock / `가속` = `3x` baseline
- K `1000` level transition
- Level `100` K `1000` max clear
- Existing leaderboard / user-key wrappers and App-in-Toss scaffolding

**Cleanup**
- Removed `scripts/gameplay/stone_projectile.gd`
- Removed `scenes/gameplay/stone_projectile.tscn`
- Confirmed no active runtime references remain to the deleted Stone projectile resources

**Validation**
- Godot 4.6.2 headless project-open smoke test: passed
- Headless scripted runtime validation: passed
  - MainMenu visible on launch
  - Start Game path
  - Ranking button non-crash path
  - Korean UI labels
  - tier hit-effect scene instantiation
  - tier projectile spawn counts
  - unlock banner thresholds
  - K `1000` level transition
  - Level `100` max clear

**Notes**
- The QA helper was created outside the repo in `/private/tmp` and was not committed
- Remaining work is visible interactive validation and polish, not another broad systems rewrite

---

## 2026-05-01 — Session 42: Phase 4.20 — Ads Integration Planning (docs only, no code)

**Outcome: Official App-in-Toss ad APIs confirmed. Placement policy locked. Prerequisites documented. No code implemented.**

### Official docs checked

| Doc URL | Key finding |
|---------|-------------|
| developers-apps-in-toss.toss.im/ads/intro.md | Three formats supported: full-screen, reward, banner. Recommended to combine all three. |
| developers-apps-in-toss.toss.im/ads/console.md | Prerequisites: business registration → terms → settlement → ad group creation (~2–3 business day settlement review). |
| developers-apps-in-toss.toss.im/ads/develop.md | Prohibited placements: active gameplay, loading, modal dialogs, game UI overlap, payment flows, tutorials. Test ad IDs provided. |
| developers-apps-in-toss.toss.im/ads/qa.md | QA requirements: preload before show; audio pause/resume during ad; frequency limits + cooldown; non-blocking failure handling; real device recommended. |
| developers-apps-in-toss.toss.im/bedrock/reference/framework/광고/IntegratedAd.md | APIs: `loadFullScreenAd()` → `showFullScreenAd()`. Events: requested, show, impression, clicked, dismissed, failedToShow, userEarnedReward. Min version: v5.247.0 (full v2); v5.227.0 (AdMob fallback). `isSupported()` required. |
| developers-apps-in-toss.toss.im/bedrock/reference/framework/광고/BannerAd.md | APIs: `TossAds.initialize()` → `TossAds.attachBanner()` → `TossAds.destroyAll()`. Min version: **v5.241.0**. Width: 100%; Height: 96px (fixed/list) or 410px (feed). Theme/tone/variant options. |

### Official-vs-skill-vs-engineering basis

| Decision | Basis |
|----------|-------|
| IntegratedAd v2 (`loadFullScreenAd`/`showFullScreenAd`) as the full-screen API | **Official** — IntegratedAd.md |
| BannerAd (`TossAds.attachBanner`) as the banner API | **Official** — BannerAd.md |
| Min version v5.247.0 for IntegratedAd v2 | **Official** — IntegratedAd.md |
| Min version v5.241.0 for BannerAd | **Official** — BannerAd.md |
| Business registration + settlement required before ad group creation | **Official** — ads/console.md |
| Modal dialogs are prohibited ad placement (PauseMenu excluded) | **Official** — ads/develop.md |
| Active gameplay, loading, tutorial, game UI overlap are prohibited | **Official** — ads/develop.md |
| Audio must pause during full-screen ad, resume on dismissed/failedToShow | **Official** — ads/qa.md |
| Frequency limit + cooldown required | **Official** — ads/qa.md |
| Preload before show | **Official** — ads/qa.md |
| Ad failure must not block gameplay or restart | **Official spirit** (non-blocking requirement) + **Engineering** |
| Banner height 96px, width 100% | **Official** — BannerAd.md |
| Interstitial at game-over / max-clear / between-run | **Official** placement rules + **Engineering** mapping to current GameState signals |
| Banner at bottom (below joystick/skill bar) | **Engineering** candidate — subject to device QA; no official position specified |
| Pause-screen interstitial is policy-risky | **Official** (modal prohibition) |

### Placement decisions locked

**Interstitial trigger points:**
- `GameState.game_over` signal → preload interstitial, show on game-over result screen
- `GameState.max_level_cleared` signal → show on max-clear result screen
- Between-run on restart tap (before new run starts)
- Frequency limit + cooldown (exact values to be confirmed in Phase 4.21)

**Interstitial exclusions (official prohibited):**
- Active gameplay → PROHIBITED
- Loading / intro → PROHIBITED
- PauseMenu (modal) → PROHIBITED; **pause-screen ad is explicitly excluded from plan**
- Game UI overlap → PROHIBITED

**Banner candidate:** 96px fixed at bottom of screen, below joystick + skill bar, inside safe area. Must not overlap gameplay controls. Requires device QA validation before finalizing.

### Ad failure behavior plan

- `loadFullScreenAd` failure → skip show; proceed to game-over/restart normally
- `showFullScreenAd failedToShow` → call `AudioManager.restore_mute_state()`; proceed normally
- BannerAd failure → hide banner container; no empty frame
- No game action gated on ad success

### Audio plan (official QA requirement)

- `AudioManager.mute_all()` immediately before `showFullScreenAd()`
- `AudioManager.restore_mute_state()` on `dismissed` or `failedToShow`
- Banner: no audio change required

### Bundle size impact

- Ad SDKs (IntegratedAd v2, BannerAd) are part of Toss WebView shell — NOT added to Godot `.pck` or `.wasm`
- PlatformBridge ad implementation adds only GDScript (~1 KB)
- Ad images loaded at runtime from Toss ad servers — not in bundle
- Rerun export audit after Phase 4.21 implementation to confirm

### PlatformBridge current state

- `show_ad(_ad_unit: String) -> void: pass` — stub exists (AD-01)
- Phase 4.21 will expand to: `preload_interstitial_ad()`, `show_interstitial_ad()`, banner attach/detach, version gates, audio hooks, signals

### Prerequisites for Phase 4.21 (BLOCKED)

1. Business registration in Toss console
2. Terms agreement
3. Settlement banking info (~2–3 business day review)
4. Ad group creation (IDs take ~2h to register with Google)

**Files changed this session:**
- `docs/00_product_spec.md` — section 9.3 expanded with official API details, placement rules, version requirements
- `docs/01_toss_release_checklist.md` — AD-01 through AD-06 updated with official findings and locked plan
- `docs/03_implementation_plan.md` — Phase 4.20 marked done; Phase 4.21 added (blocked)
- `docs/NEXT_STEP.md` — fully rewritten for Phase 4.21 blocked state
- `docs/STATUS.md` — ads row updated
- `docs/WORKLOG.md` — this entry
- `data/dev_status.json` — session 42, phase updated

**No gameplay code changed. No ad SDK added. No code changed.**

---

## 2026-05-01 — Session 40: Web Export Dry Run — Blocked: Export Templates Not Installed

**Outcome: Export blocked by missing Godot 4.6.2 Web export templates. No bundle produced. No gameplay change.**

**What was attempted:**

- Checked `~/Library/Application Support/Godot/export_templates/` — directory exists but is empty.
- Ran `godot --headless --export-release "Toss Web"` to confirm exact error.

**Exact Godot error:**

```
ERROR: Cannot export project with preset "Toss Web" due to configuration errors:
Missing export template:
  ~/Library/Application Support/Godot/export_templates/4.6.2.stable/web_nothreads_debug.zip
Missing export template:
  ~/Library/Application Support/Godot/export_templates/4.6.2.stable/web_nothreads_release.zip
ERROR: Project export for preset "Toss Web" failed.
```

**Root cause:** Godot 4.6.2 Web export templates were never downloaded on this machine.

**How to unblock:**

Option A — Godot editor (recommended):
1. Open project in Godot editor.
2. `Editor → Manage Export Templates → Download and Install`.
3. Select version `4.6.2.stable` → download.

Option B — Manual install:
1. Download `Godot_v4.6.2-stable_export_templates.tpz` from https://godotengine.org/download/archive/
2. Rename to `.zip` and extract; move the two files:
   - `web_nothreads_debug.zip`
   - `web_nothreads_release.zip`
   into `~/Library/Application Support/Godot/export_templates/4.6.2.stable/`.

**After templates are installed, re-run:**

```bash
mkdir -p /Volumes/junseokism_usb3.0/game/game_junseokism.ver1/exports/toss_web_dry_run
"/Users/junseokism/Downloads/Godot.app/Contents/MacOS/Godot" \
  --headless \
  --export-release "Toss Web" \
  /Volumes/junseokism_usb3.0/game/game_junseokism.ver1/exports/toss_web_dry_run/index.html \
  --path /Volumes/junseokism_usb3.0/game/game_junseokism.ver1
```

**Then audit:**
- Total unpacked size: `du -sh exports/toss_web_dry_run/`
- Top 30 files: `find exports/toss_web_dry_run -type f | xargs du -sh | sort -rh | head -30`
- Inspect generated `index.html` for `user-scalable=no`, `touch-action:none`, `overscroll-behavior:none`
- Confirm no duplicate viewport metas or stale `res://` refs

**Files changed this session:** docs only (WORKLOG, STATUS, NEXT_STEP, 03_implementation_plan, dev_status.json)

---

## 2026-05-01 — Session 41: Official App-in-Toss Benchmark Pass — Templates Installed + Web Export Dry Run

**Outcome: Godot 4.6.2 Web export templates installed from official GitHub release. Web export dry run produced. 36.40 MB (100MB limit: PASS). No gameplay change.**

### Task A — Template Verification

Templates were MISSING:
```
~/Library/Application Support/Godot/export_templates/4.6.2.stable/  (empty)
```

### Task B — Template Install

Downloaded `Godot_v4.6.2-stable_export_templates.tpz` from official GitHub release:
```
https://github.com/godotengine/godot/releases/download/4.6.2-stable/Godot_v4.6.2-stable_export_templates.tpz
```
(1.2 GB, official Godot Engine release, sha matches GitHub release page)

Extracted `web_nothreads_debug.zip` (9.6 MB) and `web_nothreads_release.zip` (9.1 MB) from the `.tpz` archive and copied to:
```
~/Library/Application Support/Godot/export_templates/4.6.2.stable/
```
Both files confirmed present.

### Task C — Web Export Dry Run

Command:
```bash
"/Users/junseokism/Downloads/Godot.app/Contents/MacOS/Godot" \
  --headless --export-release "Toss Web" \
  /Volumes/junseokism_usb3.0/game/game_junseokism.ver1/exports/toss_web_dry_run/index.html \
  --path /Volumes/junseokism_usb3.0/game/game_junseokism.ver1
```

Result: SUCCESS. Export output:
```
exports/toss_web_dry_run/
  index.html              5.5 KB
  index.js              308 KB
  index.pck             110 KB
  index.wasm             36 MB
  index.png              21 KB
  index.audio.worklet.js   7.1 KB
  index.audio.position.worklet.js  2.9 KB
  index.icon.png           3.6 KB
  index.apple-touch-icon.png  7.5 KB
```

The case-mismatch WARNINGs (junseokism_usb3.0 vs JUNSEOKISM_USB3.0) are harmless — USB drive uses uppercase filesystem name; export contents are correct.

### Task D — Bundle Size / Hygiene Audit

**Total unpacked size: 36.40 MB → PASS (limit: 100 MB official)**

| File | Size |
|------|------|
| index.wasm | 36 MB |
| index.js | 308 KB |
| index.pck | 110 KB |
| index.png | 21 KB |
| index.html | 5.5 KB |
| Other (audio worklets, icons) | ~20 KB |

**Hygiene: CLEAN.** Export folder contains no `.git/`, `.godot/`, `.gd`, `.tscn`, `docs/`, `.wav`, `.psd`, `.aseprite`, or source files.

**Minor hygiene note:** Three `.import` files appear in the export output directory:
- `index.apple-touch-icon.png.import`
- `index.icon.png.import`
- `index.png.import`

These are Godot editor import-tracking metadata files. They are not game assets and should be excluded from the `.ait` bundle (confirm during `.ait` packaging step).

**Minor hygiene note:** `data/dev_status.json` was packed into `index.pck` (it's under `res://data/`). This is a dev-status doc file, not a runtime game resource. It wastes ~2 KB in the bundle. To exclude it, add a per-file export filter in `export_presets.cfg` for `data/dev_status.json`. Not urgent at current bundle size, but worth fixing before submission.

### Task E — Generated HTML Audit

**Key finding: Godot 4.6.2's default HTML shell already includes `user-scalable=no` and `touch-action:none`.**

```html
<!-- Line 5: Godot default shell viewport -->
<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0">

<!-- Lines 14-19: Godot default shell body CSS -->
body {
	overflow: hidden;
	touch-action: none;
}

<!-- Line 95: our html/head_include injection -->
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<style>canvas{touch-action:none}html,body{overscroll-behavior:none;margin:0;padding:0}</style>
```

| Check | Present | Notes |
|-------|---------|-------|
| `user-scalable=no` | YES | In Godot default shell (line 5) AND our head_include (line 95) |
| `maximum-scale=1.0` | YES | Only in our head_include (not in Godot default shell) |
| `initial-scale=1.0` | YES | Both |
| `touch-action:none` on body | YES | Godot default shell has `body { touch-action: none }` |
| `canvas{touch-action:none}` | YES | Our head_include adds canvas-specific rule |
| `overscroll-behavior:none` | YES | Our head_include only (not in Godot default shell) |
| Duplicate viewport metas | YES — two | Line 5 (Godot default) + line 95 (our head_include). Browsers use last one (standard). Ours wins and is stricter. |

**Conclusion:** C-26 pinch-zoom is structurally addressed from two layers:
1. Godot 4.6.2 default HTML shell already provides `user-scalable=no` and `body { touch-action:none }`.
2. Our `head_include` reinforces this and adds `maximum-scale=1.0` and `overscroll-behavior:none`.

The documented "duplicate viewport meta" risk from Session 39 is benign — both tags say `user-scalable=no`, the browser uses the last one (ours). The `custom_html_shell` fallback is not needed.

### Task F — Official Doc Cross-Check Matrix

Official source: `https://developers-apps-in-toss.toss.im/`

| Requirement | Official Source URL | Current Status | Result | Basis |
|------------|--------------------|--------------|----|-------|
| 100MB decompressed limit | developers-apps-in-toss.toss.im/development/deploy.md | 36.4 MB dry run | **PASS** | Official |
| QR/private test (min 1 before review button activates) | developers-apps-in-toss.toss.im/development/deploy.md | Not done — needs .ait upload first | **MISSING** | Official |
| Review request (after 1+ test) | developers-apps-in-toss.toss.im/development/deploy.md | Not done | **MISSING** | Official |
| getUserKeyForGame (min Toss v5.232.0) | developers-apps-in-toss.toss.im/bedrock/reference/framework/게임/getUserKeyForGame.md | Structurally wired; Toss-device unconfirmed | **PARTIAL** | Official |
| submitGameCenterLeaderBoardScore (min Toss v5.221.0) | developers-apps-in-toss.toss.im/bedrock/reference/framework/게임/submitGameCenterLeaderBoardScore.md | Structurally wired; Toss-device unconfirmed | **PARTIAL** | Official |
| openGameCenterLeaderboard | developers-apps-in-toss.toss.im/game-center/develop.md | Structurally wired; UI button needs scene editor pass | **PARTIAL** | Official |
| C-26 pinch-zoom disabled | developers-apps-in-toss.toss.im/checklist/app-game.md (game checklist) | Godot default HTML shell already provides `user-scalable=no` + `touch-action:none`; head_include adds `maximum-scale=1.0` + `overscroll-behavior:none`; confirmed in generated HTML; device test pending | **PARTIAL** (structural pass, device TBD) | Official checklist item; Godot default shell + head_include (engineering) |
| C-25/C-28 console registration (name, icon, scheme) | developers-apps-in-toss.toss.im/development/deploy.md | Not done — console access required | **MISSING** | Official |
| C-27 background game-tree pause | Official game requirement | `on_visibility_hidden → get_tree().paused=true` wired; device-unconfirmed | **PARTIAL** | Official |
| CORS/network policy | developers-apps-in-toss.toss.im/development/deploy.md | No external calls in current build | **N/A** | Official (only if external calls added) |
| Sentry/crash monitoring | developers-apps-in-toss.toss.im/learn-more/sentry-monitoring.md | Not integrated | **FUTURE** | Optional per official guide |
| Ads (IntegratedAd v2) | developers-apps-in-toss.toss.im/ads/develop.md | Not implemented; deferred | **DEFERRED** | Official; intentionally not yet started |

### Official docs confirmed
- 100MB limit: **official** — `deploy.md` ("앱 번들은 압축 해제 기준 100MB 이하만 업로드할 수 있어요")
- QR test required before review: **official** — `deploy.md` ("테스트를 최소 1회 이상 완료해야 검토 요청을 진행할 수 있어요")
- getUserKeyForGame min version 5.232.0: **official** — `getUserKeyForGame.md`
- submitGameCenterLeaderBoardScore min version 5.221.0: **official** — `submitGameCenterLeaderBoardScore.md`
- Sentry: **optional** per official guide; not a hard requirement
- Pinch-zoom disabling: **official checklist item** (app-game.md); implementation method (meta tags/CSS) is engineering/best-practice, not Toss-prescribed

**Files changed:**
- `docs/WORKLOG.md` (this entry)
- `docs/01_toss_release_checklist.md` — C-23, C-24, PKG-01, PKG-02 status updated
- `docs/NEXT_STEP.md` — updated
- `docs/STATUS.md` — updated
- `data/dev_status.json` — session 41, phase updated

**No gameplay code changed.**

---

## 2026-05-01 — Session 39: Phase 4.19c — C-26 HTML Export Shell / Pinch-Zoom Pass

**export_presets.cfg created. Static QA: 27/27 passed. No gameplay change.**

**Requirement source:** App-in-Toss submission checklist Stage 5 (`확대/축소 핀치줌이 비활성화되어 있는가?`) + project's own C-26 checklist item. Confirmed official requirement. Implementation approach (meta tag format, CSS) is web best-practice convention, not Toss-specified exact code.

**What was done:**
- No `export_presets.cfg` existed previously; no HTML template existed.
- Created `export_presets.cfg` with Godot 4.6 "Toss Web" Web export preset.
- `html/head_include` injects:
  - `<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">` — disables pinch-zoom (C-26).
  - `canvas{touch-action:none}` — routes all touch events to Godot; prevents browser scroll/zoom on the canvas.
  - `html,body{overscroll-behavior:none;margin:0;padding:0}` — disables elastic overscroll on iOS/Android.
- `html/canvas_resize_policy=2` (Adaptive) — canvas fills the WebView; works with `stretch/mode=canvas_items`.
- `html/focus_canvas_on_start=true` — canvas gets focus immediately on load.
- `html/custom_html_shell=""` — uses Godot's default HTML shell; head_include is injected after it.
- `progressive_web_app/enabled=false` — PWA not used for `.ait`; `orientation=1` (portrait) set for documentation.
- `export_path=""` — export path intentionally empty; prevents accidental export.

**Known limitation:**
- Godot 4.6's default HTML shell may already include a `<meta name="viewport">`. If so, there will be two viewport meta tags. Browsers use the last one (standard behavior), and our tag is injected via `$GODOT_HEAD_INCLUDE` (typically at end of `<head>`), so the stricter setting should win. If Toss QA finds duplicate metas cause issues, switch to `html/custom_html_shell` pointing to a copy of Godot's default template with the meta replaced directly.

**Files changed:**
- `export_presets.cfg` (NEW) — Godot 4.6 Web export preset with viewport/touch CSS
- `docs/01_toss_release_checklist.md` — C-26 `[ ]` → `[~]`; GM-05 note updated
- `docs/03_implementation_plan.md` — Phase 4.19c row added
- `docs/NEXT_STEP.md` — C-26 item updated
- `docs/STATUS.md` — phase updated
- `data/dev_status.json` — session 39, phase updated

**No gameplay code changed.**

---

## 2026-05-01 — Session 38: Phase 4.19b Bugfix — Start Game Button Not Responding

**Bugfix for reported "Start Game does nothing". Headless QA: 23/23 passed.**

**Root causes (two separate bugs):**
1. `Background` ColorRect in `scenes/ui/root_ui.tscn` had `mouse_filter = 0` (MOUSE_FILTER_STOP).
   A full-screen decorative background with STOP intercepts touch/mouse events before they reach
   the sibling StartButton and RankingButton in Godot 4.6.x's GUI input routing.
   Fix: changed to `mouse_filter = 2` (MOUSE_FILTER_IGNORE).
2. `MainMenu` Control node had no `process_mode` set (default = INHERIT).
   On Web/Toss, `PlatformBridge.on_visibility_hidden()` calls `get_tree().paused = true` on
   background. With INHERIT, MainMenu would be paused and buttons would not receive input.
   Fix: added `process_mode = 3` (ALWAYS) to MainMenu in the tscn.

**Files changed:**
- `scenes/ui/root_ui.tscn`:
  - `[node name="Background" parent="MainMenu"]`: `mouse_filter = 0` → `mouse_filter = 2`
  - `[node name="MainMenu"]`: added `process_mode = 3`

**No logic changes. No regressions confirmed.**

---

## 2026-04-30 — Session 37: Phase 4.19b — Main Menu Start Flow + Leaderboard Button

**Phase 4.19b implemented. Headless QA: 45/45 passed.**

**Files changed (code):**
- `scripts/gameplay/game_root.gd`:
  - Removed `_start_game()` auto-call from `_ready()`; added `add_to_group("game_root")`
  - Renamed private `_start_game()` to public `start_game()` with full cleanup (stop spawner, clear bricks/projectiles, reset danger, then `GameState.start_run()` + `_ring_spawner.start()`)
- `scripts/ui/main_menu.gd` (NEW):
  - `extends Control`; shown `visible = true` on `_ready()`
  - `_best_label` reads `SaveManager.get_best_k()` on ready
  - `_on_start_pressed()`: group lookup `"game_root"` → `roots[0].start_game()`; hides self
  - `_on_ranking_pressed()`: calls `PlatformBridge.open_leaderboard()`
  - `_on_game_started()`: hides self (connected to `GameState.game_started`)
- `scenes/ui/root_ui.tscn`:
  - `load_steps` bumped from `8` → `9`
  - Added `ext_resource id="8_mm"` for `main_menu.gd`
  - Added `MainMenu` Control node as last child of CanvasLayer (renders on top of all gameplay/overlay nodes) with Background ColorRect, TitleLabel, BestLabel, StartButton, RankingButton
- `scripts/ui/game_over_screen.gd`: `_on_restart_pressed()` now uses group-based `start_game()` with `reload_current_scene()` fallback; `visible = false` before calling
- `scripts/ui/pause_menu.gd`: `_restart()` now uses group-based `start_game()` with `reload_current_scene()` fallback; `get_tree().paused = false` and `visible = false` before calling

**Files changed (docs):**
- `docs/NEXT_STEP.md`: updated to reflect Phase 4.19b complete; Phase 4.20 (Ads) is next
- `docs/STATUS.md`: phase and roadmap updated
- `data/dev_status.json`: session → 37, phase/task/next_step updated

---

## 2026-04-30 — Session 36: Phase 4.19 — Game Center + getUserKeyForGame Platform Pass

**Phase 4.19 implemented. Headless QA: 61/61 passed. Toss-shell unverified.**

**Files changed (code):**
- `scripts/autoload/platform_bridge.gd`:
  - Added `MIN_VERSION_LEADERBOARD = "5.221.0"`, `MIN_VERSION_USER_KEY = "5.232.0"` constants (TQA-02)
  - Added signals: `game_user_key_received`, `game_user_key_failed`, `leaderboard_score_submitted`
  - Added `_score_submitted_this_run: bool` (duplicate-submit guard) and `_paused_for_background: bool` (C-27 restore guard)
  - Connected `GameState.game_started → _on_game_started()` in `_ready()` to reset submission flag per run
  - `init_platform()`: now also calls `fetch_game_user_key()` on Web
  - `on_visibility_hidden()`: added `get_tree().paused = true` (C-27); `on_visibility_visible()`: added conditional unpause with `_paused_for_background` guard (preserves intentional manual pause)
  - Added `fetch_game_user_key()`: full result-case handling; persists hash via `SaveManager`; no-op on non-Web
  - Added `submit_leaderboard_score(total_progress: int)`: numeric-string score; duplicate guard; no crash; no-op on non-Web
  - Added `open_leaderboard()`: no-op on non-Web; C-27 handles state preservation; UI button pending editor pass
  - Added `_on_game_started()`: resets `_score_submitted_this_run = false`
- `scripts/autoload/save_manager.gd`: added `set_game_user_key()` / `get_game_user_key()`
- `scripts/gameplay/game_root.gd`: `_on_game_over()` and `_on_max_level_cleared()` each call `PlatformBridge.submit_leaderboard_score(GameState.total_progress)`

**Files changed (docs):**
- `docs/01_toss_release_checklist.md`: C-21, C-27, GC-01–GC-05, GM-01–GM-03, TQA-02 updated to `[~]` or `[x]`
- `docs/03_implementation_plan.md`: Phase 4.19 row marked implemented; Phase 4.19 section added
- `docs/NEXT_STEP.md`: updated to Phase 4.20
- `docs/STATUS.md`: phase updated; leaderboard/getUserKeyForGame/R-10/R-13 rows updated
- `data/dev_status.json`: session, phase, current_task updated

**Key limitations confirmed:**
- All Toss API calls are `JavaScriptBridge.eval()` wrappers — runtime behavior confirmed only in Godot headless (no Toss shell)
- `getUserKeyForGame` may return `INVALID_CATEGORY` until console registration (C-25/C-28) is complete
- Leaderboard open UI button requires a `.tscn` scene edit (Godot editor pass)

**QA script:** `/tmp/qa_phase_4_19.gd` — 61 assertions, 0 failures, Godot 4.6.2

---

## 2026-04-30 — Session 35: Phase 4.18 — Max Level 100 Runtime Cap

**Phase 4.18 implemented. Headless QA: 47/47 passed.**

**Files changed (code):**
- `scripts/autoload/game_state.gd`:
  - Added `const MAX_LEVEL: int = 100`
  - Added `signal max_level_cleared()`
  - Added `func trigger_max_level_clear()` — sets `is_playing = false`, persists result, emits signal
  - Modified `add_k()`: added `if not is_playing: return` guard; at K threshold, checks `current_level >= MAX_LEVEL` first — if so, caps `current_level_k = _level_size_k` and calls `trigger_max_level_clear()` instead of advancing level
  - Modified `get_progression_display_state()`: shows `"MAX CLEAR"` label at Level 100 instead of `"LEVEL 101"`
- `scripts/gameplay/game_root.gd`: connected `max_level_cleared → _on_max_level_cleared()` which stops spawner and resets danger
- `scripts/ui/game_over_screen.gd`: connected `max_level_cleared → _on_max_level_cleared()` which shows `"MAX LEVEL CLEAR!"` result

**Files changed (docs):**
- `docs/03_implementation_plan.md`: Phase 4.18 row marked implemented; Phase 4.18 section added with acceptance criteria (all checked)
- `docs/NEXT_STEP.md`: updated to Phase 4.19
- `docs/STATUS.md`: phase updated; max level cap row marked implemented; R-02 note extended
- `data/dev_status.json`: session, phase, current_task updated

**Key invariants confirmed by headless QA:**
- `current_level` never reaches 101
- `total_progress` at max clear == 100000
- `add_k()` after max clear is a no-op (`is_playing == false`)
- `trigger_game_over()` after max clear is a no-op (double-guard)
- Levels 1–99 still transition normally
- K500–999 tier 4 still active; Hybrid disabled
- `loop_length() == 1000` (no K1000+ active band)
- K0/K499/K500/K999 wall layers: 1/2/5/5 (correct)

**QA script:** `/tmp/qa_phase_4_18.gd` — 47 assertions, 0 failures, Godot 4.6.2

---

## 2026-04-30 — Session 34: Doc Stale Grep Cleanup Before Phase 4.18

**No gameplay code changed. Doc-only cleanup pass.**

**Files edited:**
- `docs/02_technical_architecture.md` — three targeted fixes:
  - Section 6.1: replaced stale "K 0-999 = LEVEL 1 / K 1000-1999 = LEVEL 2 / no second counter" with real `current_level`/`current_level_k`/`total_progress` runtime state description and K1000 level-loop rule
  - "Locked progression notes": replaced stale 5-shot at -24°/-12°/0°/+12°/+24° with 7-shot at -36°/-24°/-12°/0°/+12°/+24°/+36°; replaced "K 1000+ = Hybrid Siege" block with level-transition and Max Level 100 description
  - "Spec / runtime alignment note": removed "runtime may still lag" — runtime has caught up through Phase 4.17c
- `docs/03_implementation_plan.md` — three targeted fixes:
  - Phase 4.16 "What Remains True Right Now": marked superseded by Phase 4.17b (K1000 level-loop now implemented)
  - Phase 4.13 line ~397: K1000+ active wall band marked as superseded by Phase 4.17b
  - Phase 4.13 acceptance criteria: "5-shot siege" corrected to "7-shot siege"

**What was NOT changed:**
- WORKLOG historical entries (Sessions 1-33)
- Phase 4.9/4.10/4.11/4.12 historical Hybrid Siege mentions (explicitly historical)
- Phase 4.15 "K 0-999 = LEVEL 1" (labeled temporary placeholder in that section)

**Session result:** Docs now agree with runtime truth. Ready for Phase 4.18.

---

## 2026-04-30 — Session 33: App-in-Toss Release Checklist Audit Pass

**No gameplay code changed. This was a doc/compliance-only pass.**

**Skill inspection:**
- Claude Code skill `appsintoss-nongame-launch-checklist-by-robin` found under `~/.claude/skills/`
- Skill is a non-game web/React Native miniapp checklist (11 stages)
- Treated as supplemental and unofficial; game-inapplicable items explicitly excluded

**Skill stages applicable to this game:**
- Stage 1 (access/scheme), Stage 4 (scheme/routing), Stage 5 (UI/UX), Stage 6 (branding), Stage 8 (ads), Stage 9 (external link policy) — all applied

**Skill stages explicitly not applicable:**
- Stage 2: Navigation bar web component (Godot native uses PlatformBridge back gesture, not `@apps-in-toss/web-framework` nav)
- Stage 3: Toss OAuth login (game uses `getUserKeyForGame`, not OAuth login flow)
- Stage 10: TDS design system (React Native / Web only; game uses custom Godot UI)
- Stage 11: Share reward (no share feature in this game)

**New checklist items added to `docs/01_toss_release_checklist.md`:**
- C-25: App name and icon match Toss console registration (new)
- C-26: Pinch-zoom disabled on all game screens (new — HTML export `user-scalable=no`)
- C-27: Game simulation loop pauses on background, not only audio mute (new — R-10 risk)
- C-28: Toss console scheme URL registered and validated (new — pre-submission gate)
- AD-06: Use Toss IntegratedAd v2 API exclusively (new — not raw AdMob SDK)
- Section I: Crash monitoring (CM-01) — new section
- Section J: Toss environment / API version validation (TQA-01, TQA-02, TQA-03) — new section
- Section K: Game-specific items not in non-game skill (GM-01 through GM-06) — new section
- Notes section: Explicit list of skill items not applicable to Godot native game
- Updated sign-off: now requires all GM-* and TQA-01/02 as well as C-*

**New risks added to `docs/STATUS.md`:**
- R-10: Game tree pause on background (C-27) not confirmed wired
- R-11: Pinch-zoom not explicitly disabled in HTML template (C-26)
- R-12: Toss console registration (app name, icon, scheme) not done — submission blocked
- R-13: Minimum Toss app version gating not implemented in PlatformBridge
- R-14: No crash monitoring integrated

**`docs/NEXT_STEP.md`** updated to Phase 4.18 (Max Level 100 cap) with compliance sub-tasks.

---

## 2026-04-30 — Session 32: Ring Rotation Jitter Fix (Compaction Angle-Continuity)

**Root cause diagnosed:**
- `_rebuild_bricks()` unconditionally cleared `_angles[]` and recomputed it as a fresh uniform `i * TAU / new_n` distribution on every compaction event.
- With `SEGMENT_SIZE = 28` and `shrink_speed = 30`, compaction fires every `28 / (TAU * 30) ≈ 0.149 s` (≈9 frames at 60 fps).
- Each compaction caused angular jumps of up to `TAU / old_n ≈ 5.7°` per brick — equivalent to 13 frames of rotation appearing instantly. Different segments jumped by different amounts (some ~0°, some ~5.7°), creating the visible clockwise/counterclockwise stutter.
- `_rotation_offset` was already monotonically preserved through compaction, so the problem was entirely in base-angle recalculation, not in the rotation phase itself.

**Fix applied — `scripts/gameplay/ring_instance.gd` only:**
1. Added `_build_initial_angles(count) -> Array` helper that creates the uniform `i * TAU / count` distribution.
2. `_ready()` now initializes `_angles` via `_build_initial_angles` before calling `_rebuild_bricks()`.
3. `_rebuild_bricks()` no longer clears or recomputes `_angles`. It uses whatever is already set (with a safety fallback reinit if the array size mismatches).
4. `_retile_segments()` now computes `next_angles[]` from the OLD `_angles` using `ceili()`-based bucket boundaries and averaging the source angles in each bucket. This is set as `_angles = next_angles` before calling `_rebuild_bricks()`, preserving angular phase continuity through every compaction step.

**Effect:**
- Maximum per-segment angular displacement during compaction reduced from `TAU / old_n ≈ 5.7°` to `TAU / (2 * old_n) ≈ 2.9°`.
- Single-element buckets (the vast majority) have zero displacement.
- Only the one bucket-per-compaction that absorbs 2 source segments shows any displacement (~2.9°).
- The ring visually appears to rotate continuously with no jumps.

**No other files changed.** weapon.gd K500 7-shot and Overclock tuning untouched.

**Headless QA: 21/21 passed** (Godot 4.6.2):
- JSON parse: game_config.json, progression.json ✓
- segment_count_for_radius monotonically decreasing ✓
- New code: max per-segment displacement ≤ 2.9° ✓
- Old code baseline confirmed jumps > 2.9° (regression gate) ✓
- new angles monotonically increasing after compaction ✓
- Raw rotation phase never decreases over 300 frames ✓
- Position continuous across TAU wrap ✓
- brick.rotation continuous across TAU wrap ✓
- K500 SIEGE_VOLLEY_ANGLES = 7 entries [-36,-24,-12,0,12,24,36] ✓
- No 5-shot pattern in weapon.gd ✓
- K1000 → Level 2, current_level_k=0 ✓
- No Hybrid branch in weapon.gd or ring_spawner.gd ✓

---

## 2026-04-30 — Session 31: Full-Radius Wall Rotation + 7-Shot Siege + Overclock Tuning

**Done:**
- Fixed the wall-rotation drift/freeze issue at the source in `ring_instance.gd`.
- Added an explicit ring rotation offset that advances every frame while gameplay is active.
- Kept that rotation independent from radius so shrinking walls continue rotating all the way inward until destruction or core breach.
- Preserved:
  - continuous wall compaction
  - typed HP state
  - destroyed gaps
  - no rotation after game over
- Upgraded K `500+` `Piercing Bomb Siege` from `5` projectiles to `7`:
  - `-36°`, `-24°`, `-12°`, `0°`, `+12°`, `+24°`, `+36°`
  - center spear remains the main breach shot
  - all side spears remain support shots
- Increased shared Overclock speed by `1.5x` relative to the old boosted state:
  - old boosted interval = `0.175`
  - new boosted interval = `0.116666...`
  - effective active fire rate = `3x` baseline

**Headless Godot validation passed:**
- Godot runtime used:
  - `/Users/junseokism/Downloads/Godot.app/Contents/MacOS/Godot`
  - `4.6.2.stable.official.71f334935`
- Confirmed:
  - `main.tscn` launches
  - K `500+` fires `7` siege projectiles from the exact cyan center point
  - center spear keeps `2` pierces + larger explosion
  - side spears keep `1` pierce + smaller explosion
  - per-level Overclock relock/reunlock still works
  - K1000 level transition still works
  - no active Hybrid continuation appears
  - wall angle continues changing at small radius
  - wall angle stops changing after game over
- Structural planner check still returns `5` real K `500+` wall layers:
  - `Strong + Strong + Normal + Strong + Armored`

**Not done:**
- No Hybrid combat
- No leaderboard
- No ads
- No audio/resource import
- No broad refactor

## 2026-04-30 — Session 30: Toss Release / Max Level / Monetization / Resource Constitution Realignment

**Done:**
- Realigned release-facing docs after the passing K1000 headless level-loop validation.
- Locked Level `1–100` as the current product rule:
  - each level uses `current_level_k 0–999`
  - `K1000` inside the level advances to the next level
  - recommended default = `Level 100 K1000` ends the run as max-level clear
- Reaffirmed normalized ranking:
  - `total_progress = (current_level - 1) * 1000 + current_level_k`
- Updated product/checklist docs so `K1000+ Hybrid` is no longer treated as the immediate release continuation concept.
- Added future release-roadmap requirements for:
  - App-in-Toss Game Center leaderboard using `total_progress`
  - `getUserKeyForGame` as the future user-identification path
  - policy-safe ad integration planning
  - audio resource strategy and license-proof storage
  - bundle-size gate of `<= 100MB` decompressed `.ait`
- Updated Toss release checklist with explicit rows for:
  - bundle-size audit
  - Game Center leaderboard
  - `getUserKeyForGame`
  - audio legal/resource tracking
  - safer ad timing guidance
- Confirmed no `.ait` / export / build output currently exists in the repo, so size compliance is still pending until the first real export candidate exists.

**Not done:**
- No gameplay code changes
- No leaderboard implementation
- No ads implementation
- No audio/resource import
- No art/resource import

**Validation reality:**
- Documentation/roadmap realignment only
- No new runtime claim beyond the already-passed K1000 headless Godot smoke test
- Bundle-size measurement is pending because no export artifact currently exists

## 2026-04-30 — Session 29: Phase 4.17 — Real Godot Headless Smoke Test

**Godot runtime used:**
- `/Users/junseokism/Downloads/Godot.app/Contents/MacOS/Godot`
- Version: `4.6.2.stable.official.71f334935`
- Launch mode: `--headless --audio-driver Dummy --display-driver headless`

**Validation method:**
- Instantiated `res://scenes/main/main.tscn` inside a temporary Godot QA script.
- Used real runtime state changes inside Godot to verify:
  - K999 -> K1000 transition
  - Level 2 restart loop
  - per-level wall composition loop
  - HUD level/progress state
  - per-level Overclock relock/reunlock
  - game-over / best-progress persistence
- Used a temporary `HOME=/tmp/godothome` runtime path so `user://save.json` could be written cleanly in headless mode.

**Passed in runtime:**
- Project opened and `main.tscn` ran
- `K999 -> K1000` transitioned from Level 1 to Level 2
- `current_level` incremented to `2`
- `current_level_k` reset to `0`
- `total_progress` reached `1000`
- Level 2 K0 restarted at Arrow + 1-layer Normal wall
- Level 2 band loop repeated correctly:
  - K30 Strong / Stone
  - K80 Armored / Split Arrow
  - K150 Strong+Armored / Electric Split
  - K500 5-layer siege wall composition
- Top HUD showed `LEVEL 2` and reset progress bar at Level 2 K0
- Near Level 2 K999, next unlock pointed to `LEVEL 3`, not Hybrid
- Overclock relocked at Level 2 K0 and unlocked again at Level 2 K500
- Center-origin projectile spawn matched the core launch origin
- Joystick left/center/right relocation still worked
- Last aim direction persisted after release
- Pause and sound toggle paths still worked in runtime
- Danger level was nonzero before transition and reset to `0` after transition
- Game-over readout showed level, loop K, total progress, and best progress
- Best progress persisted across save reload / scene relaunch inside the smoke test

**Notes:**
- Godot printed one macOS certificate warning:
  - `get_system_ca_certificates`
  - It did not block runtime or affect gameplay validation.
- This was a real Godot runtime pass, but still headless/scripted rather than a visible interactive editor/device session.

## 2026-04-30 — Session 28: Phase 4.17 — Godot Smoke Test Attempt

**Attempted:**
- Tried to locate a usable Godot runtime/editor via:
  - `command -v godot`
  - `command -v godot4`
  - `/Applications`
  - `/Users/junseokism/Applications`
  - Spotlight / `mdfind`
  - project volume / common install paths

**Result:**
- No usable Godot executable or `.app` bundle was found from this environment.
- Because of that, no real editor/runtime smoke test was executed.
- No gameplay code was changed in this pass.

**What was still verified statically:**
- JSON files parse
- non-doc `res://` references resolve
- `HYBRID SIEGE` remains disabled in runtime progression config
- no active `K >= 1000` wall/combat runtime branch is left in the relevant scripts

**Next requirement remains unchanged:**
- Run the actual Godot smoke test on a machine/environment where Godot can be launched.

## 2026-04-30 — Session 27: Phase 4.17 — K1000 Level Transition Runtime Realignment

**Done:**
- Added real level-loop runtime state in `GameState`:
  - `current_level`
  - `current_level_k`
  - `total_progress`
- Locked runtime ranking formula:
  - `total_progress = (current_level - 1) * 1000 + current_level_k`
- Changed progression accumulation so destroyed bricks advance `current_level_k`, not an endlessly growing combat-tier K.
- Implemented the K1000 transition rule:
  - reaching `current_level_k >= 1000`
  - increments `current_level`
  - resets `current_level_k` to `0`
  - refreshes projectile tier / progression tier from the restarted loop
- Reworked `ProgressionService` to ignore disabled tiers and loop only over the active `0–999` combat bands.
- Marked `HYBRID SIEGE` in `data/progression.json` as disabled so it is no longer an active runtime continuation tier.
- Realigned wall spawning to use per-level loop K:
  - removed the active `K >= 1000` wall branch
  - repeated loop now ends at the `500–999` 5-layer siege wall band
- Realigned HUD level bar and label to real `current_level` / `current_level_k` state instead of the old raw-K heuristic.
- Realigned next-threshold HUD so the `500–999` band points to the next level transition rather than Hybrid.
- Realigned Overclock unlock to per-level loop progression via `current_level_k >= 500`.
- Added minimal save-state support for normalized ranking:
  - `best_total_progress`
  - `best_level`
  - `best_level_k`
  - legacy `best_k` kept as fallback-compatible storage
- Updated game-over readout to show level, loop K, total progress, and best progress.

**Not done:**
- No Hybrid combat behavior
- No new weapons
- No broad architecture refactor
- No Godot runtime validation in this environment

**Validation reality:**
- Static validation only; Godot CLI/editor not available here

## 2026-04-26 — Session 25: Top K Progress Bar + Level 1/2 Visualization

**Done:**
- Added a placeholder top `LevelLabel` to the HUD.
- Added a placeholder top horizontal `KProgressBar` to the HUD.
- Kept `K` as the only progression source.
- Implemented temporary level-band visualization rules in `hud.gd`:
  - `K 0–999 = LEVEL 1`
  - `K 1000–1999 = LEVEL 2`
- Implemented left-to-right fill behavior for the current level band.
- Implemented bar reset at `K = 1000` so Level 2 fills from zero again.
- Preserved existing top HUD text:
  - live `K`
  - current weapon
  - next unlock / threshold or READY / MAX
  - best K
  - pause button
- Updated docs/status so the new top K bar is part of the current structural state.

**Validation reality:**
- No Godot runtime/editor was available in this environment, so this pass is structurally validated only
- The next step is a focused Godot smoke test of the top progress bar and LEVEL 1 / LEVEL 2 switching

## 2026-04-26 — Session 24: K300~499 Wall Alignment + K500 Overclock Trigger

**Done:**
- Reconfirmed and preserved the runtime K `150–499` Electric Split wall composition as:
  - outer = `Strong`
  - inner = `Armored`
- Updated docs so K `300–499` no longer points at the stale `Strong + Strong` wall-pressure assumption.
- Reused the existing Overclock effect as the first real K `500` attack-speed buff instead of adding a second redundant buff system.
- Moved Overclock truth into `weapon.gd`:
  - unlock gating
  - active duration
  - cooldown timing
- Updated `skill_slot.gd` so the bottom skill slot now reflects and triggers the shared Overclock state instead of maintaining its own duplicate local cooldown model.
- Added placeholder joystick-area buff UI in `aim_joystick.gd`:
  - a horizontal divider above the joystick
  - a placeholder buff button above that divider
  - visibly locked/disabled before K `500`
  - activates shared Overclock when unlocked
- Preserved:
  - center-origin firing
  - joystick aim / last-direction persistence / left-center-right repositioning
  - Arrow / Stone / Split / Electric Split behavior
  - K `500+` siege behavior
  - progression HUD/signaling
  - pause / save / sound / platform scaffolding

**Validation reality:**
- No Godot runtime/editor was available in this environment, so this pass is structurally validated only
- The next step is a focused Godot smoke test at K `300–499` and K `500`

## 2026-04-25 — Session 23: K500+ Five-Shot Siege Override

**Done:**
- Replaced the older K `500–999` single-spear late-game assumption with a real `5`-shot siege volley.
- Updated tier-4 firing in `weapon.gd`:
  - volley angles = `-24° / -12° / 0° / +12° / +24°`
  - center spear = up to `2` pierced collisions + enlarged same-layer explosion radius `2`
  - side spears = `1` pierced collision each + smaller support same-layer explosion radius `1`
- Generalized the existing spear projectile path so a single projectile scene can serve both center and side spears through configurable pierce/explosion settings.
- Generalized ring-side terminal explosion routing so the same-layer neighborhood radius is now parameterized instead of hardcoded.
- Raised K `500+` wall spawning to `5` real concentric layers:
  - K `500–999` = `Strong + Strong + Normal + Strong + Armored`
  - K `1000+` = `Strong + Armored + Strong + Armored + Strong`
- Updated the late-game spec/docs to reflect the override:
  - K `500–999` is now a `Piercing Bomb Siege` 5-shot band
  - K `1000+` Hybrid is now explicitly defined as `5`-shot spear-siege core + electric suppression
- Preserved:
  - Arrow / Stone / Split / Electric Split behavior below K `500`
  - center-origin firing and joystick aim flow
  - generic progression HUD/signaling
  - Toss/platform/pause/save/sound scaffolding

**Validation reality:**
- No Godot runtime/editor was available in this environment, so the K `500+` siege override is structurally validated only
- The next step is a focused Godot smoke test at K `500+`

## 2026-04-25 — Session 22: Late-Game Progression Spec Correction (K300~2000)

**Done:**
- Locked the revised late-game design from K `300` upward in docs only.
- Replaced the older late-game assumptions:
  - old `K 150–499` single Electric Split Arrow band
  - old `K 500–999` 2-layer Piercing Bomb Spear band
  - old vague `K 1000+` Hybrid Siege wording
- Locked the new structure:
  - K `300–499` = `Electric Split Arrow` + `2` layers `Strong + Strong`
  - K `500–699` = `Piercing Bomb Spear` + `3` layers `Strong + Strong + Normal`
  - K `700–999` = `Piercing Bomb Spear` + `3` layers `Strong + Armored + Strong`
  - K `1000–1499` = `Hybrid Siege` + `4` layers `Normal + Strong + Armored + Strong`
  - K `1500–2000` = `Hybrid Siege` + `4` layers `Strong + Armored + Strong + Armored`
- Locked Hybrid meaning explicitly as:
  - center breach spear-like projectile
  - two side electric suppression bolts
- Re-affirmed fixed readability HP:
  - `Normal = 1`
  - `Strong = 2`
  - `Armored = 3`
- Intentionally did **not** change combat code in this pass.
- Intentionally did **not** change `data/progression.json`, because runtime still reads that file and the next narrow implementation passes should realign code/data in order rather than silently shifting runtime behavior during a doc-only turn.

**Validation reality:**
- This was a spec/documentation pass only
- No runtime behavior was claimed or changed
- The next narrow implementation pass should start with K `300–499` Electric Split Arrow wall-pressure alignment

---

## 2026-04-23 — Session 21: Piercing Bomb Spear Implementation

**Done:**
- Turned tier `4` into a real combat state by marking `K 500-999` `Piercing Bomb Spear` as implemented in `data/progression.json`
- Added a dedicated tier-4 projectile path:
  - new `piercing_bomb_spear_projectile.gd`
  - new `piercing_bomb_spear_projectile.tscn`
  - `Weapon` now fires a single spear projectile for tier `4`
  - the spear has `0` bounces
  - the spear counts up to `2` pierced segment collisions
- Extended the real 2-layer wall structure into the K `500-999` band:
  - `RingSpawnPlanner` now keeps K `150-999` on `2` actual layers
  - outer layer = `Strong`
  - inner layer = `Armored`
- Added ring-aware spear routing:
  - `BrickInstance` now forwards direct spear hits and terminal explosion requests back to its owning ring
  - `RingInstance` now applies direct spear-hit damage to a pierced collision target
  - `RingInstance` now applies the fixed terminal explosion neighborhood:
	- same layer center / left / right
	- adjacent outer layer center if present
	- adjacent inner layer center if present
  - destroyed explosion targets are not refilled; the neighborhood remains fixed in this band
- Preserved:
  - Arrow / Stone / Split Arrow / Electric Split behavior below K `500`
  - generic progression HUD / threshold signaling
  - center-origin launch path
  - joystick aiming
  - wall continuity / compaction model
  - pause / save / sound / platform scaffolding

**Validation reality:**
- No Godot runtime/editor was available in this environment, so Piercing Bomb Spear is structurally validated only
- The next step is a focused Godot smoke test of the K `500-999` band before starting the Hybrid Siege pass

---

## 2026-04-22 — Session 20: Electric Split Arrow Implementation

**Done:**
- Turned tier `3` into a real combat state by marking `K 150-499` `Electric Split Arrow` as implemented in `data/progression.json`
- Added a dedicated tier-3 projectile path:
  - new `electric_split_projectile.gd`
  - new `electric_split_projectile.tscn`
  - `Weapon` now fires `3` electric bolts at `-15° / 0° / +15°` for tier `3`
  - each electric bolt has a `1`-bounce budget
- Extended wall spawning for the K `150-499` band:
  - `RingSpawnPlanner` now emits layered wall specs for this band
  - `RingSpawner` now spawns coordinated wall groups with layer metadata
  - outer layer = `Strong`
  - inner layer = `Armored`
  - layer spacing is now configurable through `data/game_config.json`
- Added ring-aware electric hit resolution:
  - `BrickInstance` now forwards electric hits back to its owning ring
  - `RingInstance` now maps a struck segment angle across to the adjacent wall layer
  - direct target preference is the struck layer `{I-1, I, I+1}`
  - electric target preference is the adjacent layer `{I-1, I, I+1}`
  - missing preferred targets are reallocated deterministically instead of shrinking the hit budget
- Preserved:
  - Arrow / Stone / Split Arrow behavior below K `150`
  - generic progression HUD / threshold signaling
  - center-origin launch path
  - joystick aiming
  - wall continuity / compaction model
  - pause / save / sound / platform scaffolding

**Validation reality:**
- No Godot runtime/editor was available in this environment, so Electric Split Arrow is structurally validated only
- The next step is a focused Godot smoke test of the K `150-499` band before starting the Piercing Bomb Spear pass

---

## 2026-04-22 — Session 19: Spec Lock + Generic Tier Signaling / HUD

**Done:**
- Locked the current progression plan in docs and progression data:
  - `0-29` Arrow
  - `30-79` Stone
  - `80-149` Split Arrow
  - `150-499` Electric Split Arrow
  - `500-999` Piercing Bomb Spear
  - `1000+` Hybrid Siege
- Recorded the three newly final spec decisions:
  - Electric fallback must preserve its full intended hit budget by reallocating into other valid targets
  - Piercing Bomb Spear remains a 2-layer band
  - Hybrid Siege defaults to 2 side electric bolts
- Updated `data/progression.json` to carry:
  - locked ranges
  - display names
  - `implemented` flags for honest HUD/signaling
- Generalized progression state handling:
  - `ProgressionService` now exposes display names, next-tier lookup, and implemented-tier lookup
  - `GameState` now tracks configured progression tier separately from currently implemented combat tier
  - added generic `tier_threshold_reached(...)`
  - added generic `progression_display_changed(...)`
  - preserved `stone_unlock_reached(...)` as the first-unlock compatibility hook
- Updated top HUD feedback:
  - `K` remains the single progression source
  - HUD now shows current implemented weapon plus next unlock threshold path, or READY/MAX state
  - added centered `WeaponLabel` under the top `K` label
- Updated project docs/status so the next narrow implementation pass is explicitly `K150-499 Electric Split Arrow`

**Validation reality:**
- No Godot runtime/editor available in this environment, so the new signaling/HUD flow is structurally validated only
- This session intentionally did not implement the late-tier combat behaviors themselves

---

## 2026-04-22 — Session 18: Input System Expansion — Virtual Aim Joystick

**Done:**
- Synced docs first (`00_product_spec.md`, `02_technical_architecture.md`, `03_implementation_plan.md`) so the virtual aiming joystick and its left/center/right placement switching are now part of the written constitution.
- Reworked `InputHandler` into a shared aim-state coordinator:
  - it now accepts explicit normalized aim updates
  - center-origin launch-point wiring remains owned by `Weapon`
  - last valid aim direction remains active unless a new valid direction is supplied
- Added `scripts/ui/aim_joystick.gd`:
  - placeholder virtual joystick UI inside `RootUI/SafeAreaContainer`
  - drag updates `InputHandler.aim_direction`
  - release does not reset aim direction
  - left/right placeholder buttons move the joystick between bottom-left / bottom-center / bottom-right
- Wired the joystick into `scenes/ui/root_ui.tscn` as a safe-area-aware bottom UI control
- Added lightweight joystick anchor persistence:
  - `SaveFileRepository.DEFAULT_DATA` now includes `aim_joystick_position`
  - `SaveManager` now exposes joystick position getter/setter helpers
  - joystick placement is now saved immediately when switched
- Updated `NEXT_STEP`, `STATUS`, and `data/dev_status.json` so the next manual validation is specifically about joystick flow + center-origin non-regression

**Validation reality:**
- No Godot runtime/editor available in this environment, so the joystick flow is structurally validated only
- This session intentionally did not reopen combat, wall, platform, or broad architecture scope

---

## 2026-04-21 — Session 17: Targeted Freeze Fixes Before Architecture Freeze

**Done:**
- Confirmed the last meaningful freeze blocker in code was still real:
  - `DangerManager` was still normalizing ring distance against a stale hardcoded `REFERENCE_RADIUS = 380.0`
  - current wall/play-field radius in `data/game_config.json` is `280`
- Applied the smallest maintainable geometry-source fix:
  - `scripts/autoload/danger_manager.gd` now loads `play_field_radius` from `data/game_config.json`
  - `scripts/application/rings/ring_spawn_planner.gd` now also loads `play_field_radius` from `data/game_config.json`
  - danger normalization and ring spawn geometry now use the same config-backed radius source
- Cleaned stale freeze guidance in:
  - `docs/04_architecture_audit.md`
  - `docs/05_handoff_to_next_agent.md`
  - `docs/06_refactor_validation.md`
  - `docs/NEXT_STEP.md`
  - `docs/STATUS.md`
  - `data/dev_status.json`
- Shifted the project handoff language from "resume gameplay now" to "run one final Godot smoke test, then freeze architecture and move to rules/progression specification"

**Validation reality:**
- No Godot runtime/editor available in this environment, so runtime confirmation is still pending
- This session was intentionally limited to freeze blockers only; no broad refactor or new gameplay work was started

---

## 2026-04-21 — Session 16: Unify Aim-Line Origin and True Firing Origin

**Done:**
- Re-traced the firing path end-to-end after runtime feedback:
  - aim line start point comes from the `Weapon` node origin because `Line2D` point `0` is `Vector2.ZERO` in `weapon.gd`
  - cyan point center comes from the `Core` node origin because the cyan `ColorRect` is centered around local `(0, 0)` in `core.gd`
  - projectile spawn was still using `Weapon.global_position` directly
- Identified the real local-architecture issue:
  - aim line, cyan point, and projectile spawn were only *co-located by scene setup*, not unified through one explicit launch-origin provider
- Applied a narrow firing-path refactor:
  - `Core` now exposes `get_launch_origin_global()`
  - `GameRoot` now sets `Weapon`'s launch-origin provider to `Core`
  - `Weapon` now uses a single `_get_launch_origin()` helper for:
	- `InputHandler.set_aim_origin(...)`
	- projectile spawn position
	- syncing weapon node position to the provider
  - projectile `global_position` is now assigned **after** adding to `ProjectileLayer`, removing ambiguity about pre-parent global placement

**Validation reality:**
- No Godot runtime/editor available in this environment, so this is a structural fix queued for a targeted manual smoke test of true center-origin firing

---

## 2026-04-21 — Session 15: Micro Fix — True Cyan-Point Firing

**Done:**
- Re-audited the full firing path after runtime feedback:
  - core cyan point remains centered at local `(0, 0)`
  - weapon launch origin remains centered at local `(0, 0)`
  - projectile spawn coordinate remains centered
  - projectile-local geometry remains forward-biased from the launch point
- Identified the remaining visible mismatch as launch-point **occlusion**, not a further world-position mismatch:
  - the aim line starts at the same center point
  - the aim line was drawing above the launch point visuals
  - this could visually compete with the first visible projectile pixels at the cyan center
- Applied the smallest possible fix in `weapon.gd`:
  - `Line2D` aim line now renders behind the center launch point via `z_index = -1`

**Validation reality:**
- No Godot runtime/editor available in this environment, so this remains a structural micro-fix queued for live smoke confirmation

---

## 2026-04-21 — Session 14: Exact Launch-Origin + Unlock Readability Correction

**Done:**
- **Docs clarified first** (`00_product_spec.md`, `02_technical_architecture.md`, `03_implementation_plan.md`, `NEXT_STEP.md`, `STATUS.md`, `data/dev_status.json`):
  - exact center of the cyan core point is now explicitly documented as the true projectile launch origin
  - top-of-screen stone unlock readability is now explicitly required
  - future unlock VFX/SFX hook requirement is now explicitly documented
- **Exact visible launch-origin fix** (`arrow_projectile.gd`, `stone_projectile.gd`, `weapon.gd`):
  - confirmed the spawn coordinate was already centered
  - identified the real mismatch as projectile-local visuals/collision being centered on the node origin, which made the body straddle the cyan point
  - shifted projectile-local visuals/collision forward so the launch point reads as the exact center of the cyan core point
  - removed the extra emitter marker from `weapon.gd` so the cyan core point remains the single clear origin indicator
- **Unlock readability + future hook** (`progression_service.gd`, `game_state.gd`, `hud.gd`, `root_ui.tscn`):
  - added tier-threshold lookup in `ProgressionService`
  - added `stone_unlock_threshold`, `unlock_progress_changed`, and `stone_unlock_reached` in `GameState`
  - HUD now reuses `K` as the top-center stone unlock progress display
  - best-K display remains visible and pause button remains intact

**Structural validation:**
- No Godot runtime/editor available in this environment, so no live smoke test was run
- Precision/readability corrections were kept local to projectile presentation, HUD presentation, and progression-state signaling

---

## 2026-04-21 — Session 13: Center-Origin Combat Constitution Correction

**Done:**
- **Docs synced first** (`00_product_spec.md`, `02_technical_architecture.md`, `03_implementation_plan.md`, `NEXT_STEP.md`, `STATUS.md`, `data/dev_status.json`):
  - center-origin firing is now the hard constitutional model again
  - default arrow requires 3 bounces and 3-target spread
  - stone requires 5-target spread
  - stone unlock threshold remains playtest-tunable in data
- **Center-origin firing restored** (`scenes/game/game_root.tscn`, `weapon.gd`, `input_handler.gd`, `game_config.json`):
  - `Weapon` moved from local `(0, 303)` back to local `(0, 0)` so launch origin matches the centered core area
  - `InputHandler` still uses weapon-provided aim origin, which now resolves to the center launch point again
  - weapon visuals were simplified so they no longer imply a bottom launcher
- **Ring-aware spread hits implemented** (`brick_instance.gd`, `ring_instance.gd`):
  - bricks now know their ring + segment index
  - projectiles route impact resolution back up to `RingInstance`
  - `RingInstance.apply_projectile_hit(...)` now applies wrapped neighbor hits against the logical segment array
  - K scoring remains intact because destroyed segments still emit `brick_destroyed`
- **Arrow behavior corrected** (`arrow_projectile.gd`):
  - 3-bounce budget added
  - 3-target spread hit added
  - simple post-hit reflection + pushback added to reduce immediate re-collision
- **Stone behavior corrected** (`stone_projectile.gd`, `data/progression.json`):
  - 5-target spread hit added
  - tier-1 `k_min` remains the tunable stone unlock threshold for playtesting

**Structural validation:**
- Re-checked `project.godot` main scene and autoload paths
- Re-ran repository `res://` audit: 41 refs, 0 missing
- Re-checked internal spread-hit wiring across weapon/projectile/brick/ring path
- Godot runtime/editor still unavailable in this environment, so no live smoke test was performed

---

## 2026-04-21 — Session 12: Shrinking Wall Correction Pass

**Done:**
- **Docs synced to stricter wall constitution first** (`00_product_spec.md`, `02_technical_architecture.md`, `03_implementation_plan.md`, `NEXT_STEP.md`, `STATUS.md`, `data/dev_status.json`): clarified that the continuous radial wall must keep visible brick segmentation while active segment count decreases with radius so overlap does not accumulate and large new gaps do not appear on their own.
- **Segment sizing aligned** (`brick_rules.gd`, `data/game_config.json`): set shared `SEGMENT_SIZE` to `28.0` so wall planning and brick visuals/collision use the same tangential width target.
- **Spawn planner corrected** (`ring_spawn_planner.gd`): wall segment count now derives from `segment_count_for_radius(radius, segment_size)`, and spawn specs pass `segment_size` through explicitly.
- **Spawner wiring updated** (`ring_spawner.gd`): `RingInstance.setup()` now receives `segment_size` alongside radius, speed, count, and brick type.
- **Brick instance updated for compaction-safe rebuilds** (`brick_instance.gd`): collision shape changed to tangential 28×14, and `setup()` now accepts explicit HP/max-HP so a rebuilt ring can preserve strong/armored state instead of resetting it.
- **Shrinking wall compaction implemented** (`ring_instance.gd`):
  - Added logical `_segments` state separate from live brick nodes
  - Rebuilds visible brick nodes from logical segment state
  - On shrink, computes smaller target segment count from current radius
  - Re-tiles old segments into fewer angular buckets
  - Preserves destroyed gaps only when a full merged bucket is already dead
  - Avoids creating new large passable gaps while preventing overlap buildup from a fixed segment count

**Structural validation:**
- Checked touched gameplay files after patching
- `ring.setup(...)` signature change matched by `ring_spawner.gd`
- `brick.setup(...)` remains backward-compatible through optional HP args
- No scene/autoload path changes were introduced in this pass
- Fixed one final structural blocker during the sweep: removed an accidental extra indent before `ring.setup(...)` in `scripts/gameplay/ring_spawner.gd`

**Still not done in this session:**
- No Godot editor/runtime execution was available here
- Wall feel, preserved threat typing, and live scoring/pause/UI behavior still need one runtime smoke test in Godot before Phase 5

---

## 2026-04-21 — Session 11: Gamefeel Correction Pass

**Done:**
- **Core visual** (`core.gd`): replaced invisible 20×20 square with layered visual — 80×80 orange-red kill-zone aura (shows the danger radius), inner dark fill, 18×18 bright cyan core point. Players can now see exactly what they're protecting and when they're about to lose.
- **Weapon marker + aim indicator** (`weapon.gd`): added 20×10 cyan base + 6×14 barrel nub at weapon position (world 195,640). Added `Line2D` aim indicator extending 130px toward `InputHandler.aim_direction`; updates every frame in `_process()`. Bottom-origin position and aim direction are now visually unambiguous.
- **Wall segment visual** (`brick_instance.gd`): changed visual from 24×24 square to 28×14 (28 tangential × 14 radial). Visual is wider than the 23.77px inter-segment arc → 4.23px overlap → gap-free tiling when rotated. Collision shape unchanged (24×24).
- **Tangential brick rotation** (`ring_instance.gd`): added `brick.rotation = angle + PI/2` at spawn. This aligns each segment's wide (28px) face along the ring tangent. Math verified: local X axis after rotation equals tangent direction at all angles. Wall now looks like a continuous tile band, not a loose scatter of squares.
- **Arrow projectile orientation** (`arrow_projectile.gd`): visual changed to 5×16 (thin, elongated). Node rotation set to `direction.angle() - PI/2` in `_ready()` so the arrow visually points in its travel direction. Collision shape updated to 6×14 to match.
- **Stone projectile cleanup** (`stone_projectile.gd`): visual and collision updated to 16×16 (cleaner).

**Validation:**
- Full `res://` path audit: 0 missing references ✓
- Math verified: radius=280, visual_w=28, arc=23.77px → 4.23px overlap per segment, gap-free ✓
- Brick rotation verified at 0°, 90°, 180°, 270°: local X axis = tangent direction ✓
- Bounce/reflection: **not in spec** — not implemented, not deferred as a debt item

---

## 2026-04-21 — Session 10: Phase 4.5 — Gameplay Correction Pass

**Done:**
- **CC-01 resolved — Bottom-origin shooter layout:**
  - `scenes/game/game_root.tscn`: `GameRoot` repositioned from `(195, 422)` to `(195, 337)` (center of play field); `Weapon` given local position `(0, 303)` → world `(195, 640)` (bottom of play field); `Core` stays at local `(0, 0)` = world `(195, 337)` (no change needed)
  - `scripts/gameplay/input_handler.gd`: added `aim_origin` property and `set_aim_origin()` method; `_input()` now uses weapon-relative origin instead of viewport center; default fallback to viewport center if origin not yet set
  - `scripts/gameplay/weapon.gd`: added `InputHandler.set_aim_origin(global_position)` in `_ready()` — called each scene load including restarts

- **CC-02 resolved — Continuous segmented radial wall system:**
  - `scripts/domain/bricks/brick_rules.gd`: added `SEGMENT_SIZE: float = 24.0` (matches `BrickInstance.BRICK_SIZE`)
  - `scripts/application/rings/ring_spawn_planner.gd`: replaced `brick_count_for_k()` with `segment_count_for_radius(radius)` = `ceili(TAU × radius / SEGMENT_SIZE)` — guarantees no passable gaps; `DEFAULT_SPAWN_RADIUS` corrected from `380` to `280` (keeps all ring bricks above weapon at y=640); added slight shrink speed progression
  - `scripts/gameplay/ring_spawner.gd`: passes `segment_count` key (not obsolete `brick_count` key) to `ring.setup()`
  - `data/game_config.json`: added `segment_size`, `play_field_radius`, `core_y`, `weapon_y` layout constants

**Validation:**
- Full `res://` path audit: 0 missing references
- Python math check: radius=280, SEGMENT_SIZE=24 → 74 segments; arc=23.77px < 24px → gap-free wall ✓
- Bottom of ring at spawn: y=617, weapon at y=640 → all bricks spawn above weapon ✓
- Autoload paths unchanged and intact ✓
- No runtime execution available; structural validation only (same constraint as all prior sessions)

**Files modified:** `scenes/game/game_root.tscn`, `scripts/gameplay/input_handler.gd`, `scripts/gameplay/weapon.gd`, `scripts/domain/bricks/brick_rules.gd`, `scripts/application/rings/ring_spawn_planner.gd`, `scripts/gameplay/ring_spawner.gd`, `data/game_config.json`

**Obsolete prototype behavior removed:**
- Center-origin weapon position (GameRoot/Weapon co-located at screen center) → replaced by separated Core/Weapon layout
- Viewport-center aim origin in InputHandler → replaced by weapon-position-relative origin
- Fixed low brick count (10–18 bricks, large gaps) → replaced by circumference-tiled count (~74 at spawn)

---

## 2026-04-21 — Session 09: Constitution Sync (Doc-Only Pass)

**Done:**
- Read all nine constitution source files in full
- Identified two hard conflicts between current implementation and design constitution
- **CC-01** (critical): Weapon fires from center of screen (center-origin). Constitution mandates bottom-origin shooter — weapon at play-field bottom, core at play-field center. Affects `scenes/game/game_root.tscn` and possibly `scripts/gameplay/input_handler.gd`.
- **CC-02** (critical): Ring walls spawn with fixed small brick count (10–18 bricks, large gaps). Constitution mandates continuous segmented radial wall — segment count must derive from circumference so no passable gaps exist at spawn. Affects `ring_spawn_planner.gd`, `brick_rules.gd`, `data/game_config.json`.
- Updated `docs/00_product_spec.md` — rewrote §2.2–§2.5 for bottom-origin layout and continuous wall system; added §10 obsolete-prototype table
- Updated `docs/02_technical_architecture.md` — added constitutional layout table; added §4 continuous wall model; added §10 obsolete notes
- Updated `docs/03_implementation_plan.md` — inserted Phase 4.5 (gameplay correction) as next step; documented exact file-by-file changes; marked phases 3/4 as complete
- Updated `docs/NEXT_STEP.md` — replaced with Phase 4.5 correction instructions
- Updated `docs/STATUS.md` — added constitutional conflict table, current state, corrected risk register
- Updated `data/dev_status.json` — added `constitutional_conflicts_found` array, set phase to 4.5

**No code was changed in this session.**
**Phase 4.5 (gameplay correction) is the mandatory next implementation step.**

---

## 2026-04-21 — Session 08: Phase 3 + 4 — Skill Bar, Overclock, HUD, Platform Compliance

**Phase 4 done (this session):**
- **`scripts/autoload/platform_bridge.gd`** fully wired:
  - `init_platform()` registers `visibilitychange` JS listener → `AudioManager.mute_all()` / `restore_mute_state()` (C-04, C-05)
  - `init_platform()` registers `popstate` JS listener with `history.pushState` seeding (C-16)
  - `_handle_back_gesture()`: back during active play → PauseMenu.show_menu(); back at other states → ConfirmExitDialog.show_dialog() (C-16)
  - `request_close()` calls `TossBridge.close()` on Web, `get_tree().quit()` on native (C-06)
  - `fetch_user_id()` calls `window.TossBridge.getUser()` on init; stores in SaveManager; graceful no-op if bridge absent (C-21)
  - `_ready()` calls `DisplayServer.screen_set_orientation(SCREEN_PORTRAIT)` on non-Web (C-15)
  - JS callbacks held in `_js_callbacks` array to prevent GC
- **`scripts/ui/confirm_exit_dialog.gd`** (new) — centered overlay registered in `exit_dialog` group; Stay/Leave buttons; Leave calls `PlatformBridge.request_close()` (C-20)
- **`scenes/ui/root_ui.tscn`** updated — added `ConfirmExitDialog` node tree with DimOverlay + Panel + MessageLabel + Stay/Leave buttons; load_steps 6→7
- **`docs/01_toss_release_checklist.md`** updated — C-04, C-05, C-06, C-15, C-16, C-20, C-21 now `[~]` with wired-code approach

**Compliance delta after Phase 4:**
- C-04 `[~]` — JS listener wired; runtime test pending
- C-05 `[~]` — JS listener wired; runtime test pending
- C-06 `[~]` — `request_close()` routes to TossBridge or quit; container-close passthrough not blockable
- C-15 `[~]` — orientation call wired; HTML5 export config pending
- C-16 `[~]` — back gesture routing fully coded; runtime test pending
- C-20 `[~]` — ConfirmExitDialog wired; runtime test pending
- C-21 `[~]` — getUser() call wired; Toss bridge availability pending

**Still blocked:**
- C-02 (real audio assets), C-14 (fullscreen export config), C-17/C-18/C-19 (device QA)

---

## 2026-04-21 — Session 08: Phase 3 — Skill Bar + Overclock + HUD Upgrades

**Done:**
- Created `scripts/ui/skill_slot.gd` — OverclockSlot with READY/ACTIVE/COOLDOWN state machine, 3s active duration, 15s cooldown, tap-to-activate via `weapon` group lookup, resets on `game_started`
- Updated `scripts/ui/hud.gd` — added `BestKLabel` (top-right, reads `SaveManager.get_best_k()` on ready and on game start) and `PauseButton` (routes to `pause_menu` group `show_menu()`)
- Updated `scripts/ui/pause_menu.gd` — added `add_to_group("pause_menu")` in `_ready()`; renamed internal `_show()` → public `show_menu()`
- Updated `scripts/ui/game_over_screen.gd` — ScoreLabel now shows `Score: N / Best: N` using `SaveManager.get_best_k()`
- Updated `scenes/ui/root_ui.tscn` — added `BestKLabel` + `PauseButton` to HUD; added `SkillBar` + `OverclockSlot` (with `BG`, `Label`, `CooldownLabel` children) to `SafeAreaContainer`; load_steps 5→6 for `skill_slot.gd`

**Architecture compliance:**
- Skill activation flows: tap → `skill_slot.gd` → `weapon` group → `Weapon.activate_overclock()` — no autoload mutation
- Cooldown state is presentation-local in `skill_slot.gd`, not stored in GameState
- Best K display reads from `SaveManager` (already persisted by `GameState.trigger_game_over`)

**Phase:** 3 — Skill Bar + Overclock complete
**Files touched:** `scripts/ui/skill_slot.gd` (new), `scripts/ui/hud.gd`, `scripts/ui/pause_menu.gd`, `scripts/ui/game_over_screen.gd`, `scenes/ui/root_ui.tscn`

---

## 2026-04-20 — Session 07: Final Validation Mode

**Done:**
- Re-checked `project.godot` main scene and autoload paths
- Confirmed no `godot` / `godot4` CLI was available in PATH
- Searched standard locations and Spotlight for a Godot app/editor; none was found in this environment
- Ran repository-wide static path audit across `project.godot`, `.tscn`, and `.gd` files:
  - **0 missing `res://` references found**
- Ran scene/script consistency audit for attached-script `$NodePath` lookups in the refactored composed scenes:
  - **0 missing node-path bindings found**
- No validation-blocking file/path mismatch was found, so no code fixes were required
- Updated handoff and validation docs to separate:
  - runtime-verified
  - static-structure-verified
  - not verifiable in this environment

**Validation reality:**
- Strongest available validation completed
- Actual Godot runtime/editor execution still not possible on this machine
- Final handoff confidence for this environment: `READY_FOR_GAMEPLAY_RESUME_STRUCTURAL_ONLY`

---

## 2026-04-20 — Session 06: Architecture Review + Layered Refactor

**Done:**
- Added layered folders and extracted non-node responsibilities:
  - `scripts/domain/bricks/brick_rules.gd`
  - `scripts/domain/danger/danger_rules.gd`
  - `scripts/application/progression/progression_service.gd`
  - `scripts/application/rings/ring_spawn_planner.gd`
  - `scripts/infrastructure/config/json_config_loader.gd`
  - `scripts/infrastructure/persistence/save_file_repository.gd`
- Slimmed autoloads without changing their public role in the project:
  - `GameState` now delegates progression lookup and run-result persistence instead of loading/parsing/saving everything inline
  - `SaveManager` now uses `SaveFileRepository`
  - `DangerManager` now delegates threshold math to `DangerRules`
- Moved score/game-over ownership upward:
  - `brick_instance.gd` no longer mutates `GameState` directly; it emits `destroyed`
  - `core.gd` no longer triggers `GameState` directly; it emits `core_breached`
  - `ring_instance.gd` and `ring_spawner.gd` now bubble gameplay events upward
  - `game_root.gd` became the gameplay orchestrator for score and game-over transitions
- Scene composition cleaned up:
  - `main.tscn` now instantiates `scenes/game/game_root.tscn` and `scenes/ui/root_ui.tscn`
  - `scenes/game/core.tscn`, `scenes/game/game_root.tscn`, and `scenes/ui/root_ui.tscn` now contain the real subtrees/scripts instead of placeholder-only definitions
- Added `scripts/ui/root_ui.gd` to apply safe-area offsets centrally
- Updated architecture/status/next-step docs and added `docs/04_architecture_audit.md`

**Validation reality:**
- Static reference/path review completed
- Godot CLI not available on this machine, so no runtime/editor validation was performed in this session

---

## 2026-04-20 — Session 05: Phase 2 — Danger Presentation + Pause/Sound Control

**Done:**
- **Brick type correction**: `brick_instance.gd` now has `BrickType` enum (NORMAL=0, STRONG=1, ARMORED=2). HP derived from type. Normal always 1-hit (amber). Strong = 2 HP (blue→gray). Armored = 3 HP (purple→gray). No generic HP scaling for all bricks.
- **ring_instance.gd**: `brick_hp` replaced with `brick_type`; passes type to brick setup
- **ring_spawner.gd**: `_brick_type()` returns typed const (NORMAL/STRONG/ARMORED) by K threshold; old `_brick_hp()` removed
- **DangerOverlay**: new CanvasLayer (layer=1) in main.tscn with `EdgeTint` ColorRect; subscribes to `DangerManager.danger_level_changed`; level 0=invisible, 1=faint static tint (α=0.07), 2=slow pulse, 3=fast pulse
- **PauseMenu**: new Control (PROCESS_MODE_ALWAYS) in RootUI; triggered by Escape (`ui_cancel`); Resume / Sound:ON/OFF toggle / Restart; `get_tree().paused = true` when shown; no bottom-sheet
- **game_root.gd**: connects `DangerManager.danger_le	vel_changed` → `AudioManager.set_bgm_intensity()`; resets DangerManager on game over
- **audio_manager.gd**: `set_bgm_intensity` now prints level to console (testable without audio assets)
- **main.tscn**: load_steps=9; DangerOverlay added; RootUI layer=2; PauseMenu with DimOverlay + 3 buttons added
- **01_toss_release_checklist.md**: C-03, C-04, C-05, C-07, C-08, C-09, C-10, C-11, C-12 updated to `[~]`

**Phase:** 2 — Danger Presentation + Pause/Sound Control complete
**Compliance delta:** C-03 `[~]` (toggle works, not persisted), C-08/C-09 `[~]` (no bottom-sheet confirmed), C-10 `[~]` (exit path exists via Restart), C-11 `[~]` (verb labels confirmed)

---

## 2026-04-20 — Session 04: Phase 1 — Core Gameplay Loop

**Done:**
- `InputHandler` autoload: mouse/touch position relative to viewport center → `aim_direction` vector, registered in project.godot
- `game_root.gd`: wires Weapon/RingSpawner to their layers, starts game on _ready
- `core.gd`: builds Area2D kill zone (r=40) + ColorRect visual at runtime in _ready; triggers GameState.trigger_game_over on brick contact
- `weapon.gd`: Timer-based auto-fire (0.35s interval), spawns ArrowProjectile into ProjectileLayer
- `arrow_projectile.gd`: Area2D, speed 620px/s, lifetime 1.4s, damages first brick on collision, has yellow ColorRect visual
- `brick_instance.gd`: Area2D, HP-driven color (orange→dark-red), calls GameState.add_k(1) on death
- `ring_instance.gd`: spawns N BrickInstances in circle, shrinks each frame, alive-count tracks full ring destruction, notifies DangerManager
- `ring_spawner.gd`: spawns ring immediately + every 5s; brick count and HP scale with K
- `hud.gd`: Label shows live K score, updates via GameState.k_changed
- `game_over_screen.gd`: hidden until GameState.game_over fires; "Play Again" reloads scene
- `danger_manager.gd`: added `_process` that polls ring radii and emits danger_level_changed (0–3)
- `main.tscn`: expanded to full gameplay tree (GameRoot + Core + BrickLayer + ProjectileLayer + Weapon + RingSpawner + RootUI/HUD/GameOverScreen)
- 3 new gameplay scenes: brick_instance.tscn, ring_instance.tscn, arrow_projectile.tscn
- All 12 preload/ext_resource paths verified OK

**Phase:** 1 — Core Gameplay Loop complete
**Files touched:** See "Files Created/Modified" in session report

---

## 2026-04-20 — Session 03: Phase 0 — Project Scaffold

**Done:**
- Set project.godot: viewport 390×844, stretch `canvas_items`/`keep`, main scene `scenes/main/main.tscn`
- Created 5 autoload stubs and registered in project.godot:
  - `scripts/autoload/game_state.gd` — K counter, session state, signals
  - `scripts/autoload/save_manager.gd` — persistence API stubs (C-03, C-22 hooks)
  - `scripts/autoload/audio_manager.gd` — mute/unmute via AudioServer.set_bus_mute (C-04, C-05)
  - `scripts/autoload/danger_manager.gd` — ring tracking stubs, danger_level_changed signal
  - `scripts/autoload/platform_bridge.gd` — lifecycle/identity stubs (C-06, C-14–C-16, C-20, C-21)
- Created 4 scene files:
  - `scenes/main/main.tscn` — Node root with inline GameRoot (Node2D) + RootUI (CanvasLayer/SafeAreaContainer)
  - `scenes/ui/root_ui.tscn` — standalone CanvasLayer with SafeAreaContainer Control (C-07 hook)
  - `scenes/game/game_root.tscn` — Node2D placeholder
  - `scenes/game/core.tscn` — Node2D placeholder
- Created `icon.svg` placeholder (was missing; would cause Godot warning)
- Created `data/game_config.json` and `data/progression.json` placeholder configs
- Static syntax review passed; Godot CLI not available on this machine

**Compliance hooks created (not yet validated):** C-04, C-05, C-06, C-07, C-14, C-15, C-16, C-20, C-21, C-22

**Phase:** 0 — Scaffold complete
**Files touched:** `project.godot`, `icon.svg`, `scripts/autoload/*.gd` (×5), `scenes/main/main.tscn`, `scenes/ui/root_ui.tscn`, `scenes/game/game_root.tscn`, `scenes/game/core.tscn`, `data/game_config.json`, `data/progression.json`

---

## 2026-04-20 — Session 02: Live-Observability Workflow

**Done:**
- Added `docs/WORKLOG.md` (this file) — append-only engineering log
- Added `docs/NEXT_STEP.md` — single current implementation target with acceptance criteria
- Added `docs/DEV_WATCH.md` — monitoring guide for VS Code + Godot
- Added `data/dev_status.json` — machine-readable progress state
- Updated `docs/STATUS.md` to reference the new observability files

**Phase:** 0 — Scaffold (not yet started in engine)
**Files touched:** `docs/WORKLOG.md`, `docs/NEXT_STEP.md`, `docs/DEV_WATCH.md`, `data/dev_status.json`, `docs/STATUS.md`

---

## 2026-04-20 — Session 01: Source-of-Truth Documentation

**Done:**
- Explored project: fresh Godot 4.6 GL Compatibility scaffold, all asset/scene/script dirs empty
- Created `docs/00_product_spec.md` — full game concept, mechanics, danger system, progression table, art direction
- Created `docs/01_toss_release_checklist.md` — 22 common + feature-specific compliance rows with ID/MVP/approach/validation/status columns
- Created `docs/02_technical_architecture.md` — scene tree, 5 autoload designs (GameState, SaveManager, AudioManager, DangerManager, PlatformBridge), collision layers, directory layout, HTML5 export settings
- Created `docs/03_implementation_plan.md` — 8-phase plan from scaffold to pre-release
- Created `docs/STATUS.md` — current state, next step, 7 risks, assumptions

**Phase:** Pre-Phase 0 (docs only)
**Files touched:** `docs/00_product_spec.md`, `docs/01_toss_release_checklist.md`, `docs/02_technical_architecture.md`, `docs/03_implementation_plan.md`, `docs/STATUS.md`

---
## 2026-05-04 — Phase 4.23 Dual Platform Bridge + Google Play Readiness Audit

- Confirmed the original repo is `/Volumes/junseokism_usb3.0/game/game_junseokism.ver1` and the expected starting branch is `feature/design-rebuild-apply-pass`.
- Verified Git push safety blockers before any branch/push work:
  - `git remote -v` returned no remote.
  - `gh auth status` showed an invalid GitHub token.
  - Result: local work allowed, private push not allowed.
- Re-audited current repo architecture:
  - `PlatformBridge` is still strongly App-in-Toss/Toss-JS specific.
  - UI directly opens rankings via `PlatformBridge.open_leaderboard()`.
  - `GameRoot` owns score-submit timing, which is still the correct owner.
  - gameplay/domain files do not directly call Toss APIs.
- Rechecked current export/build evidence:
  - historical `exports/toss_web_dry_run` exists and measures `36M`
  - largest file is `index.wasm` at roughly `36 MB`
  - no Android/AAB export output exists
- Official-source research performed for Google Play, AdMob, Play Games, and Godot Android export/plugin requirements.
- Created two new docs:
  - `docs/GOOGLE_PLAY_RELEASE_MASTER_CHECKLIST.md`
  - `docs/DUAL_PLATFORM_BRIDGE_AUDIT.md`
- Added minimal no-op architecture skeletons only:
  - `scripts/platform/*`
  - `scripts/platform/ads/*`
  - `scripts/platform/leaderboard/*`
  - `scripts/application/layout/playfield_layout_service.gd`
- Intentionally did not wire the new skeletons into runtime yet.
- Intentionally did not change gameplay math, wall rules, projectile behavior, progression thresholds, TossBridge behavior, or monetization runtime.
## 2026-05-05 — Phase 4.24 Android Debug APK Artifact + Dual Platform Readiness

- Reconfirmed the repo still starts on `feature/design-rebuild-apply-pass`.
- Reconfirmed push is blocked:
  - no `origin` remote exists
  - `gh auth status` is invalid
- Reconfirmed Browser Use was not callable in this VS Code turn, so official-source fallback research was used.
- Used the GitHub plugin to search for an already-installed repo named `game_junseokism.ver1`; none was found.
- Re-audited current platform collision points:
  - `PlatformBridge` remains Toss-specific
  - `MainMenu` and `PauseMenu` call `PlatformBridge.open_leaderboard()`
  - `GameRoot` owns score-submit timing only
- Rechecked platform skeleton state:
  - `scripts/platform/*` exists
  - skeletons are still not wired into runtime
  - `scripts/application/layout/playfield_layout_service.gd` exists and is still skeleton-only
- Rechecked Android readiness:
  - `export_presets.cfg` still contains only the Toss Web preset
  - no Android export preset exists
  - local Godot export templates detect only Web templates, not Android templates
- Added a draft GitHub Actions workflow:
  - `.github/workflows/android-debug-apk.yml`
  - purpose: private debug APK artifact only
  - artifact name: `core-breaker-debug-apk`
  - expected path: `exports/android_debug/core_breaker_debug.apk`
  - intentionally fails early if the Android Debug APK preset is missing
- Added phone artifact instructions:
  - `docs/ANDROID_PHONE_TEST_FROM_GITHUB.md`
- Updated status docs to distinguish:
  - APK artifact testing
  - AAB store submission later
  - Google Play still `NOT READY`

## 2026-05-05 — Phase 4.25 Android Debug APK Pipeline Remediation

- Reconfirmed local push safety blockers:
  - no GitHub remote is configured
  - `gh auth status` is invalid
  - private visibility cannot be verified
  - result: no commit and no push
- Browser Use was callable in this turn; opened the official Godot Android export docs through the in-app browser and used official-source fallback for the broader source list.
- Added `.gitignore` release/secret hygiene for:
  - keystores
  - `google-services.json`
  - service-account JSON
  - local `.env`
  - Android/Gradle local outputs
  - debug APK/AAB export outputs
- Hardened platform skeleton readiness:
  - Android is now only a candidate runtime, not proof of AdMob or Play Games readiness.
  - Web is now only a candidate runtime, not proof of App-in-Toss, Toss Ads, or Game Center readiness.
  - AdMob, Toss Ads, Play Games, and Toss Game Center skeletons return `false` until real SDK/bridge/console/device validation exists.
- Added the first debug-only Android export preset:
  - preset: `Android Debug APK`
  - output: `exports/android_debug/core_breaker_debug.apk`
  - temporary package: `com.junseokism.corebreaker.debug`
  - no production signing, AAB, AdMob, Play Games, or Toss Ads added
- Hardened `.github/workflows/android-debug-apk.yml`:
  - separates GitHub release tag `4.6.2-stable` from Godot template directory `4.6.2.stable`
  - installs/checks Android SDK packages
  - creates a CI-only debug keystore
  - installs export templates into the expected Godot template directory
  - uploads artifact `core-breaker-debug-apk`
- Updated docs/status to reflect that the Android Debug APK preset now exists, while production Google Play readiness remains `NOT READY`.

## 2026-05-05 — Android Debug APK Final Sanity Loop

- Re-ran the private push safety gate:
  - no GitHub remote is configured
  - `gh auth status` is still invalid
  - private visibility cannot be verified
  - result: no commit and no push
- Rechecked actual docs/data/preset/workflow/skeleton files instead of diff previews.
- Confirmed platform skeletons do not claim AdMob, Toss Ads, Play Games, or Toss Game Center readiness from `OS.has_feature(...)`.
- Confirmed the `Android Debug APK` preset is launcher-visible with temporary debug package `com.junseokism.corebreaker.debug`.
- Strengthened the GitHub Actions workflow:
  - renamed the stale draft-warning step to a debug artifact notice
  - aligned CI Android SDK package installation with Godot Android export requirements, including `build-tools;35.0.1`, CMake, NDK, and command-line tools
- Confirmed no gameplay/domain changes were made by this final sanity loop.

## 2026-05-05 — Senior Release Agent Loop Scope Clarification

- Reconfirmed the release-pipeline branch cannot be pushed yet:
  - no GitHub remote is configured
  - `gh auth status` is invalid
- Reconfirmed the worktree is dirty outside this release loop, including gameplay/domain/scene/asset paths from prior work.
- Updated status docs to make the staging rule explicit:
  - do not use `git add .`
  - stage only reviewed release-pipeline/docs/platform-skeleton files once private GitHub safety gates pass
- No gameplay/domain/source-balance files were edited by this clarification loop.
