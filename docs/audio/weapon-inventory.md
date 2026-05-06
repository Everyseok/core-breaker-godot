# Phase 1 Weapon Inventory

Date: 2026-05-06

Scope: Read-only inventory for the future Kenney CC0 audio pass. No code, scene, asset, or gameplay-rule changes were made.

## Source Map

| Source | Evidence | Notes |
|---|---:|---|
| Weapon runtime owner | `scripts/gameplay/weapon.gd:1` | There is no `scripts/weapons/` directory. The runtime weapon node lives in gameplay. |
| Progression tier data | `data/progression.json:2` | K is the internal progression counter; player-facing wording is broken bricks. |
| Progression resolver | `scripts/application/progression/progression_service.gd:14` | Resolves tier from K and calculates loop length. |
| Evolution choice rules | `scripts/domain/combat/weapon_choice_rules.gd:4` | Defines chain/prism/meteor choices and proc cadence. |
| Weapon visual identity | `scripts/visual/weapon_profile.gd:9` | Central profile map includes display names, styles, recoil, and planned shot hook names. |
| Projectile hit entry points | `scripts/gameplay/*projectile.gd` | Projectile scripts own hit callbacks and delegate damage to bricks/rings. |

## Primary Weapon Tiers

| weapon_id | Display name | Archetype | Tier structure | Fire entry | Projectile / hit route | Visual effect summary | Audio implication |
|---|---|---|---|---|---|---|---|
| `arrow` | 화살 | Straight single projectile / bounce | Tier 0, K `0-29`, `data/progression.json:4`; resolved by `ProgressionService.tier_for_k()`, `scripts/application/progression/progression_service.gd:14` | `scripts/gameplay/weapon.gd:132` `_fire_arrow()` from `_fire()` at `scripts/gameplay/weapon.gd:117` | `scripts/gameplay/arrow_projectile.gd:53` `_on_area_entered()` calls `resolve_projectile_hit()` / `take_damage()` | Yellow bow/arrow profile, `scripts/visual/weapon_profile.gd:10`; muzzle flash/recoil from `Core.play_fire_feedback()`, `scripts/gameplay/core.gd:168` | Short crisp shot, frequent one-shot; impact may happen multiple times because bounce count is 3. |
| `thunder` | 번개 | Two-shot electric fork / small spread | Tier 1, K `30-79`, `data/progression.json:5`; threshold emitted by `GameState._refresh_unlock_progress()`, `scripts/autoload/game_state.gd:142` | `scripts/gameplay/weapon.gd:138` `_fire_thunder()` fires `[-8, 8]` degrees | `scripts/gameplay/thunder_bolt_projectile.gd:52` delegates hit to standard spread route | Yellow electric fork, `scripts/visual/weapon_profile.gd:31`; planned hook `electric_shot`, `scripts/visual/weapon_profile.gd:50` | Bright electric double-shot; moderate polyphony. |
| `spark_lance` | 스파크 랜스 | Three-shot lance spread | Tier 2, K `80-149`, `data/progression.json:6` | `scripts/gameplay/weapon.gd:145` `_fire_spark_lances()` fires `[-15, 0, 15]` degrees | `scripts/gameplay/spark_lance_projectile.gd:52` standard spread hit route | Blue lance profile, `scripts/visual/weapon_profile.gd:52`; planned hook `energy_shot`, `scripts/visual/weapon_profile.gd:71` | Sharper energy lance sound; high but controlled shot polyphony. |
| `volt_storm` | 볼트 스톰 | Three-shot storm / electric multi-hit | Tier 3, K `150-499`, `data/progression.json:7` | `scripts/gameplay/weapon.gd:152` `_fire_volt_storm()` fires `[-15, 0, 15]` degrees | `scripts/gameplay/electric_split_projectile.gd:51` calls `resolve_electric_projectile_hit()` and may affect up to six targets via `RingInstance.apply_electric_hit()`, `scripts/gameplay/ring_instance.gd:298` | Purple/cyan storm profile, `scripts/visual/weapon_profile.gd:73`; planned hook `storm_shot`, `scripts/visual/weapon_profile.gd:92` | Needs cooldown/grouping for hits; electric impact can multiply across rings. |
| `siege_cannon` | 시즈 캐논 | Seven-shot piercing / AOE terminal explosion | Tier 4, K `500-2999`, `data/progression.json:8` | `scripts/gameplay/weapon.gd:159` `_fire_siege_cannon()` uses `SIEGE_VOLLEY_ANGLES`, `scripts/gameplay/weapon.gd:20` | `scripts/gameplay/piercing_bomb_spear_projectile.gd:50` handles pierce; terminal explosion via `trigger_terminal_explosion()`, `scripts/gameplay/piercing_bomb_spear_projectile.gd:74` and `RingInstance.apply_terminal_explosion()`, `scripts/gameplay/ring_instance.gd:385` | Orange cannon profile, `scripts/visual/weapon_profile.gd:94`; planned hook `cannon_shot`, `scripts/visual/weapon_profile.gd:113` | Heavy cannon + delayed/explosion layer; highest shot burst polyphony. |
| `hybrid_siege` | 하이브리드 | Future disabled tier | Tier 5, K `3000+`, disabled and not implemented, `data/progression.json:9` | No matching `_fire_*` implementation; `_fire()` fallback goes to arrow for unknown tiers, `scripts/gameplay/weapon.gd:126` | None active | No active profile found in `TIER_PROFILES` | Do not map production SFX yet. |

## Evolution / Choice Weapons

| choice_id | Display name | Trigger / cadence | Runtime entry | Visual effect summary | Audio implication |
|---|---|---|---|---|---|
| `chain_lightning` | 연쇄 번개 | Player choice at K `2000`, `scripts/domain/combat/weapon_choice_rules.gd:9`; proc chance `0.35`, `scripts/domain/combat/weapon_choice_rules.gd:10` | `RingInstance._apply_active_weapon_choice_for_hit()`, `scripts/gameplay/ring_instance.gd:472`; chain logic at `scripts/gameplay/ring_instance.gd:489` | Chain profile, `scripts/visual/weapon_profile.gd:117`; VFX requested at `scripts/gameplay/ring_instance.gd:499` | Short electric proc layered over existing hit; needs per-frame collapse to avoid spam. |
| `prism_lance` | 프리즘 랜스 | Player choice at K `2000`; every 4 volleys via `PRISM_VOLLEY_INTERVAL`, `scripts/domain/combat/weapon_choice_rules.gd:12` | `GameState.consume_prism_volley_trigger()`, `scripts/autoload/game_state.gd:237`; `Weapon._fire_prism_side_rays()`, `scripts/gameplay/weapon.gd:172` | Prism profile, `scripts/visual/weapon_profile.gd:137`; side ray projectile, `scripts/gameplay/prism_side_ray_projectile.gd:43` | Clean shimmer/beam proc; lower frequency than base fire. |
| `meteor_cannon` | 메테오 캐논 | Player choice at K `2000`; every 5 hits via `METEOR_HIT_INTERVAL`, `scripts/domain/combat/weapon_choice_rules.gd:14` | `GameState.consume_meteor_trigger()`, `scripts/autoload/game_state.gd:250`; `RingInstance._apply_meteor_cannon_modifier()`, `scripts/gameplay/ring_instance.gd:509` | Meteor profile, `scripts/visual/weapon_profile.gd:156`; VFX requested at `scripts/gameplay/ring_instance.gd:511` | Low, heavy explosion proc; must be rate-limited by catalog/router. |

## Existing Audio Hook Names

These are already present as symbolic hook ideas, but they do not currently play real audio.

| Hook | Evidence | Current behavior |
|---|---:|---|
| `arrow_shot` | `scripts/visual/weapon_profile.gd:29` | Data-only; not called by playback yet. |
| `electric_shot` | `scripts/visual/weapon_profile.gd:50` and `scripts/visual/weapon_profile.gd:135` | Data-only; not called by playback yet. |
| `energy_shot` | `scripts/visual/weapon_profile.gd:71` and `scripts/visual/weapon_profile.gd:154` | Data-only; not called by playback yet. |
| `storm_shot` | `scripts/visual/weapon_profile.gd:92` | Data-only; not called by playback yet. |
| `cannon_shot` | `scripts/visual/weapon_profile.gd:113` | Data-only; not called by playback yet. |
| `explosion_shot` | `scripts/visual/weapon_profile.gd:173` | Data-only; not called by playback yet. |
| `weapon_choice_open` | `scripts/domain/combat/weapon_choice_rules.gd:17`; used at `scripts/ui/weapon_choice_panel.gd:243` | Routed to `AudioManager.play_hook()` print stub. |
| `weapon_choice_select` | `scripts/domain/combat/weapon_choice_rules.gd:18`; used at `scripts/ui/weapon_choice_panel.gd:286` | Routed to `AudioManager.play_hook()` print stub. |
| `weapon_choice_proc` | `scripts/domain/combat/weapon_choice_rules.gd:19`; used at `scripts/gameplay/ring_instance.gd:716` | Routed to `AudioManager.play_hook()` print stub. |
| `meteor_cannon_proc` | `scripts/domain/combat/weapon_choice_rules.gd:44`; used through `proc_audio_hook_for_id()`, `scripts/domain/combat/weapon_choice_rules.gd:83` | Routed to `AudioManager.play_hook()` print stub. |
| `weapon_change` | `scripts/ui/hud.gd:554` through `AudioManager.play_weapon_change()` | Routed to `AudioManager.play_hook()` print stub. |

## Phase 1 Notes

- No direct `AudioStreamPlayer` gameplay playback exists.
- Existing audio calls are symbolic and sparse, but they are already split across `weapon.gd`, `ring_instance.gd`, `weapon_choice_panel.gd`, and `hud.gd`.
- Later implementation should not add direct playback here. It should migrate these symbolic calls to `AudioEvents` or have `AudioManager` delegate to `AudioEvents`.
- Automatic fire interval is `0.35` seconds, and Overclock reduces it by `1/3`, `scripts/gameplay/weapon.gd:16-19`, so the audio router must enforce cooldown/polyphony limits.
