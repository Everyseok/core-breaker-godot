# Phase 1 Audio Event Inventory

Date: 2026-05-06

Scope: Event extraction only. This file documents candidate audio trigger points found in current code. It does not approve mappings, move files, or implement playback.

## Existing Audio Ownership

| Owner | Evidence | Current responsibility |
|---|---:|---|
| `AudioManager` | `scripts/autoload/audio_manager.gd:1` | Sound toggle, background mute, foreground restore, BGM intensity print stub, hook print stub. |
| `PlatformBridge` lifecycle | `scripts/autoload/platform_bridge.gd:64` and `scripts/autoload/platform_bridge.gd:73` | Calls `AudioManager.mute_all()` and `AudioManager.restore_mute_state()` on visibility changes. |
| Gameplay/UI hook callers | `scripts/gameplay/weapon.gd:179`, `scripts/gameplay/ring_instance.gd:716`, `scripts/ui/weapon_choice_panel.gd:316`, `scripts/ui/hud.gd:554` | Existing symbolic hook calls only; no real audio player creation. |

## Candidate Events

| Event ID | 발생 위치(file:line) | Trigger condition | 음향 특성 | Polyphony risk |
|---|---:|---|---|---|
| `game.start` | `scripts/ui/main_menu.gd:111`; `scripts/gameplay/game_root.gd:45`; `scripts/autoload/game_state.gd:58` | Player taps Start; `GameRoot.start_game()` calls `GameState.start_run()` | Short UI confirm + optional BGM start | Low |
| `ui.ranking_open` | `scripts/ui/main_menu.gd:120`; `scripts/ui/pause_menu.gd:67` | Player taps ranking button | Short UI tap | Low |
| `ui.ranking_failed` | `scripts/ui/main_menu.gd:129`; `scripts/ui/pause_menu.gd:115` | Platform leaderboard open fails | Soft negative UI blip | Low |
| `ui.pause_open` | `scripts/ui/hud.gd:405`; `scripts/ui/pause_menu.gd:49` | Pause button pressed or back gesture opens pause menu | Short pause/plate sound | Low |
| `ui.resume` | `scripts/ui/pause_menu.gd:56` | Continue button or cancel while pause menu visible | Short resume sound | Low |
| `ui.sound_toggle` | `scripts/ui/pause_menu.gd:62`; `scripts/autoload/audio_manager.gd:14` | Sound toggle button changes persisted sound state | Toggle click; must still respect muted state | Low |
| `ui.restart` | `scripts/ui/pause_menu.gd:72`; `scripts/ui/game_over_screen.gd:48` | Restart from pause/result screen | Short confirm / run reset | Low |
| `ui.exit_dialog_open` | `scripts/autoload/platform_bridge.gd:112`; `scripts/ui/confirm_exit_dialog.gd:23` | Back gesture outside active play opens exit dialog | Small modal open sound | Low |
| `ui.exit_stay` | `scripts/ui/confirm_exit_dialog.gd:27` | User stays in app | Short confirm/cancel | Low |
| `ui.exit_leave` | `scripts/ui/confirm_exit_dialog.gd:31` | User confirms close | Short confirm; app may close immediately | Low |
| `ui.joystick_drag` | `scripts/ui/aim_joystick.gd:267`; `scripts/ui/aim_joystick.gd:294` | User starts/moves aim stick | Usually no continuous audio recommended; optional tiny start tick | Medium if continuous; should not play on every drag frame |
| `ui.joystick_slot_move` | `scripts/ui/aim_joystick.gd:325`; `scripts/ui/aim_joystick.gd:331` | User moves joystick dock left/right | Short mechanical UI tick | Low |
| `ui.overclock_press` | `scripts/ui/aim_joystick.gd:434`; `scripts/gameplay/weapon.gd:89` | User presses 가속 when available | Start boost sound | Low |
| `weapon.overclock_end` | `scripts/gameplay/weapon.gd:110` | Overclock timer ends and fire interval resets | Short power-down sound | Low |
| `weapon.fire.arrow` | `scripts/gameplay/weapon.gd:117`; `scripts/gameplay/weapon.gd:132` | Auto-fire while playing at tier 0 | Very short one-shot | High during continuous play; 0.35s interval |
| `weapon.fire.thunder` | `scripts/gameplay/weapon.gd:117`; `scripts/gameplay/weapon.gd:138` | Auto-fire at tier 1; 2 projectiles | Electric double-shot; single grouped sound preferred | High if per projectile; group per volley |
| `weapon.fire.spark_lance` | `scripts/gameplay/weapon.gd:117`; `scripts/gameplay/weapon.gd:145` | Auto-fire at tier 2; 3 projectiles | Lance/energy volley | High if per projectile; group per volley |
| `weapon.fire.volt_storm` | `scripts/gameplay/weapon.gd:117`; `scripts/gameplay/weapon.gd:152` | Auto-fire at tier 3; 3 electric split projectiles | Storm volley | High |
| `weapon.fire.siege_cannon` | `scripts/gameplay/weapon.gd:117`; `scripts/gameplay/weapon.gd:159` | Auto-fire at tier 4; 7-piercing volley | Heavy grouped cannon burst | Very high if per projectile; must be one grouped shot event |
| `weapon.fire.prism_side_ray` | `scripts/gameplay/weapon.gd:128`; `scripts/gameplay/weapon.gd:172` | Active `prism_lance` choice every 4 volleys | Bright side-beam proc | Medium |
| `weapon.projectile.hit.arrow` | `scripts/gameplay/arrow_projectile.gd:53` | Arrow projectile hits brick/ring area | Small impact, can bounce | High; hit cooldown `0.04`, `scripts/gameplay/arrow_projectile.gd:14` |
| `weapon.projectile.hit.thunder` | `scripts/gameplay/thunder_bolt_projectile.gd:52` | Thunder bolt hit | Electric crack | High |
| `weapon.projectile.hit.spark_lance` | `scripts/gameplay/spark_lance_projectile.gd:52` | Lance hit | Sharp energy impact | High |
| `weapon.projectile.hit.volt_storm` | `scripts/gameplay/electric_split_projectile.gd:51` | Electric split hit; may route to `RingInstance.apply_electric_hit()` | Multi-target electric impact | Very high; collapse per frame/source |
| `weapon.projectile.hit.siege_cannon` | `scripts/gameplay/piercing_bomb_spear_projectile.gd:50` | Piercing spear hit or terminal collision | Heavy metal/impact | High |
| `weapon.projectile.hit.prism_side_ray` | `scripts/gameplay/prism_side_ray_projectile.gd:43` | Prism side ray hit | Thin beam impact | Medium |
| `weapon.proc.chain_lightning` | `scripts/gameplay/ring_instance.gd:489`; `scripts/gameplay/ring_instance.gd:716` | Chain lightning modifier procs | Electric branch zap | Medium/high; chance-based but can occur during multi-hit |
| `weapon.proc.meteor_cannon` | `scripts/gameplay/ring_instance.gd:509`; `scripts/gameplay/ring_instance.gd:716` | Meteor cannon modifier procs every 5 hits | Heavy explosion | Medium/high; must be capped |
| `weapon.choice.open` | `scripts/autoload/game_state.gd:283`; `scripts/ui/weapon_choice_panel.gd:234`; `scripts/ui/weapon_choice_panel.gd:243` | K crosses weapon-choice threshold and panel opens | Modal open / magical reveal | Low |
| `weapon.choice.select` | `scripts/ui/weapon_choice_panel.gd:280`; `scripts/ui/weapon_choice_panel.gd:286`; `scripts/autoload/game_state.gd:227` | User selects one evolution | Confirm/ equip sound | Low |
| `weapon.tier_up` | `scripts/autoload/game_state.gd:142`; `scripts/ui/hud.gd:360`; `scripts/ui/unlock_announcement.gd:25` | K crosses progression tier threshold | Upgrade fanfare; short | Low |
| `weapon.change_banner` | `scripts/ui/unlock_announcement.gd:35`; `scripts/ui/hud.gd:512` | HUD/banner visual impact for tier or choice equip | Same as tier/choice confirm or a small layer | Low |
| `brick.hit` | `scripts/gameplay/brick_instance.gd:97`; `scripts/gameplay/ring_instance.gd:442` | Damage applied but segment may survive | Small thud/click; should collapse per frame | Very high |
| `brick.break` | `scripts/gameplay/brick_instance.gd:102`; `scripts/gameplay/ring_instance.gd:452`; `scripts/gameplay/ring_instance.gd:273` | Brick/segment HP reaches zero | Pop/break sound | Very high; many bricks can break from AOE |
| `wall.spawn` | `scripts/gameplay/ring_spawner.gd:39` | Ring/wall spawned by timer/start | Low whoosh/arrival; optional | Low/medium |
| `wall.compact` | `scripts/gameplay/ring_instance.gd:60`; `scripts/gameplay/ring_instance.gd:188` | Shrinking wall retile/compaction occurs | Usually no sound; maybe subtle only at danger transitions | High if tied to process; avoid direct sound |
| `wave.clear` | `scripts/gameplay/ring_instance.gd:731` | Ring has no alive segments and queues free | Candidate only; no explicit signal beyond ring free | Medium; currently not exposed upstream |
| `level.transition` | `scripts/autoload/game_state.gd:103`; `scripts/gameplay/game_root.gd:78` | Current level reaches `_level_size_k`, game resets active level state | Level-clear sting | Low |
| `game.max_clear` | `scripts/autoload/game_state.gd:115`; `scripts/ui/game_over_screen.gd:37` | Level 100 reaches max K and run ends | Victory/clear fanfare | Low |
| `game.over` | `scripts/gameplay/core.gd:199`; `scripts/gameplay/game_root.gd:60`; `scripts/autoload/game_state.gd:107`; `scripts/ui/game_over_screen.gd:26` | Any brick enters core kill radius | Failure sting | Low |
| `score.best_updated` | `scripts/autoload/save_manager.gd:45`; `scripts/autoload/save_manager.gd:53`; consumers at `scripts/ui/hud.gd:378` and `scripts/ui/main_menu.gd:107` | Saved best record improves | Cheer/high-score sound | Low; signal also fires on load/save migration, so later hook must detect actual improvement |
| `danger.level_1` | `scripts/autoload/danger_manager.gd:36`; `scripts/domain/danger/danger_rules.gd:14`; `scripts/gameplay/game_root.gd:82` | Nearest ring radius <= 60 percent reference radius | BGM intensity +1 | Low; state transition only |
| `danger.level_2` | `scripts/domain/danger/danger_rules.gd:12`; `scripts/ui/danger_overlay.gd:25` | Nearest ring radius <= 35 percent | BGM intensity +2 + warning pulse/beep candidate | Low/medium; beep must be cooldown based |
| `danger.level_3` | `scripts/domain/danger/danger_rules.gd:10`; `scripts/ui/danger_overlay.gd:28` | Nearest ring radius <= 15 percent | Critical BGM/beep | Low/medium; beep must be cooldown based |
| `audio.lifecycle.mute_background` | `scripts/autoload/platform_bridge.gd:64`; `scripts/autoload/audio_manager.gd:25` | Web visibility hidden | Mute all; no SFX | Low |
| `audio.lifecycle.restore_foreground` | `scripts/autoload/platform_bridge.gd:73`; `scripts/autoload/audio_manager.gd:31` | Web visibility visible | Restore mute state | Low |

## Missing Or Non-Explicit Events

| Requested concept | Current evidence | Phase 1 decision |
|---|---|---|
| Core HP hit / low-HP enter / low-HP exit | Core has no HP model. Death is a kill-radius breach, `scripts/gameplay/core.gd:199`. Danger state is wall proximity, not core HP. | Do not invent `core_low_hp_*`; map tension to `danger.level_*` later unless game design changes. |
| Countdown tick | `rg` found no countdown implementation in `scripts/`. | Leave unmapped until a real countdown exists. |
| Explicit line-clear / wave-clear signal | Ring cleanup exists at `scripts/gameplay/ring_instance.gd:731`, but no upstream `wave_clear` signal is emitted. | Candidate only; requires a later narrow hook if desired. |
| Real BGM playback | `AudioManager.set_bgm_intensity()` is a print stub, `scripts/autoload/audio_manager.gd:37`. | Phase 5 BGM sourcing/system pass required. |

## AudioManager Direction Gate

Phase 1 found a small number of existing symbolic audio calls, but no real playback players. Choose one before Phase 2/implementation planning:

| Option | Description | Pros | Risk |
|---|---|---|---|
| A | Keep `AudioManager` as lifecycle/mute owner. Add `AudioEvents` as the new gameplay-facing facade later. Existing `AudioManager.play_hook()`/`play_weapon_change()` stubs delegate to `AudioEvents` during migration. | Lowest churn; preserves current sound toggle/background behavior; best anti-spaghetti bridge. | Requires temporary compatibility delegation. |
| B | Let `AudioEvents` absorb everything and deprecate `AudioManager`; migrate all callers. | Clean final naming. | Higher churn because platform lifecycle and sound toggle currently depend on `AudioManager`. |

Recommendation: Option A.
