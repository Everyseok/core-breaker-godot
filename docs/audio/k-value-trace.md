# Phase 1 K-Value And BGM Trigger Trace

Date: 2026-05-06

Scope: Direct code trace for K/progression and current BGM intensity ownership. No gameplay math or progression thresholds were changed.

## K Definition

| Concept | Evidence | Meaning |
|---|---:|---|
| K is internal progression counter | `data/progression.json:2` | Player-facing UI should describe it as broken bricks. |
| Current level K | `scripts/autoload/game_state.gd:34` | `current_level_k` is the active level progress counter. |
| Legacy/current alias | `scripts/autoload/game_state.gd:32` and `scripts/autoload/game_state.gd:257` | `k` is synced to `current_level_k`. |
| Ranking / total score | `scripts/autoload/game_state.gd:35` and `scripts/autoload/game_state.gd:259` | `total_progress = ((current_level - 1) * _level_size_k) + current_level_k`. |
| Level size | `scripts/autoload/game_state.gd:42`; configured by `ProgressionService.loop_length()`, `scripts/application/progression/progression_service.gd:91` | Current enabled progression data resolves `_level_size_k` to `3000`, because `siege_cannon` ends at K `2999`. |
| K increment source | `scripts/gameplay/game_root.gd:56`; `scripts/autoload/game_state.gd:76` | Destroyed bricks emit upward and add exactly 1 K each. |

## Progression Thresholds

| Tier | ID | Display | K range | Evidence | Active implementation |
|---:|---|---|---|---:|---|
| 0 | `arrow` | 화살 | `0-29` | `data/progression.json:4` | Yes |
| 1 | `thunder` | 번개 | `30-79` | `data/progression.json:5` | Yes |
| 2 | `spark_lance` | 스파크 랜스 | `80-149` | `data/progression.json:6` | Yes |
| 3 | `volt_storm` | 볼트 스톰 | `150-499` | `data/progression.json:7` | Yes |
| 4 | `siege_cannon` | 시즈 캐논 | `500-2999` | `data/progression.json:8` | Yes |
| 5 | `hybrid_siege` | 하이브리드 | `3000+` | `data/progression.json:9` | Disabled and not implemented |

## K Flow

| Step | Evidence | Description |
|---|---:|---|
| Run starts | `scripts/gameplay/game_root.gd:45`; `scripts/autoload/game_state.gd:58` | `start_game()` resets runtime layers, resets danger, starts a run, and starts ring spawning. |
| Brick destroyed | `scripts/gameplay/ring_instance.gd:458`; `scripts/gameplay/ring_spawner.gd:85`; `scripts/gameplay/game_root.gd:56` | Brick destruction bubbles from ring to spawner to root. |
| K added | `scripts/autoload/game_state.gd:76` | `GameState.add_k(1)` increments `current_level_k` while playing. |
| Tier recalculated | `scripts/autoload/game_state.gd:98`; `scripts/application/progression/progression_service.gd:14`; `scripts/application/progression/progression_service.gd:26` | Current progression tier and implemented projectile tier are resolved from K. |
| Tier threshold event | `scripts/autoload/game_state.gd:142` | Emits `tier_threshold_reached` for each crossed threshold. |
| Weapon choice threshold | `scripts/domain/combat/weapon_choice_rules.gd:9`; `scripts/autoload/game_state.gd:276`; `scripts/autoload/game_state.gd:283` | K `2000` opens weapon choice once per level. |
| Level transition | `scripts/autoload/game_state.gd:85`; `scripts/autoload/game_state.gd:103`; `scripts/gameplay/game_root.gd:78` | At `_level_size_k`, current level resets active runtime state and advances level unless max level is reached. |
| Max level clear | `scripts/autoload/game_state.gd:86`; `scripts/autoload/game_state.gd:115` | Level 100 at `_level_size_k` ends the run and emits `max_level_cleared`. |
| Result persistence | `scripts/autoload/game_state.gd:111`; `scripts/autoload/game_state.gd:119`; `scripts/autoload/save_manager.gd:32` | Game over and max clear both record `total_progress`, `level`, and `level_k`. |

## Current BGM Intensity Driver

| Concept | Evidence | Meaning |
|---|---:|---|
| BGM intensity method | `scripts/autoload/audio_manager.gd:37` | Stub only: prints intensity level. No real stream switching yet. |
| Current caller | `scripts/gameplay/game_root.gd:82` | `GameRoot._on_danger_level(level)` calls `AudioManager.set_bgm_intensity(level)`. |
| Danger source | `scripts/autoload/danger_manager.gd:36` | Every frame, `DangerManager` tracks nearest active ring radius. |
| Danger math | `scripts/domain/danger/danger_rules.gd:9` | Converts `radius / reference_radius` to level 0-3. |
| Level 1 threshold | `scripts/domain/danger/danger_rules.gd:14` | Radius ratio <= `0.60`. |
| Level 2 threshold | `scripts/domain/danger/danger_rules.gd:12` | Radius ratio <= `0.35`. |
| Level 3 threshold | `scripts/domain/danger/danger_rules.gd:10` | Radius ratio <= `0.15`. |
| Visual listener | `scripts/ui/danger_overlay.gd:14` | Danger overlay already reacts to the same level. |

Conclusion: the current code does not define a BGM K-value state machine. It defines K for progression and score, while the active BGM-intensity hook is driven by wall proximity danger level.

## Documentation Conflicts To Resolve Later

| File | Evidence | Conflict |
|---|---:|---|
| `docs/02_technical_architecture.md` | `docs/02_technical_architecture.md:289` through `docs/02_technical_architecture.md:292` | Mentions K `1000` loop behavior, but current code and `data/progression.json` use `_level_size_k = 3000`. |
| `docs/00_product_spec.md` | `docs/00_product_spec.md:233` and `docs/00_product_spec.md:240` | Some older text mentions 1000-based score/level loops while nearby newer text says K `3000`. |

These documentation conflicts were not edited in Phase 1 because the user asked for audio event inventory first and no gameplay/progression changes.

## BGM Mapping Implication

Future `AudioEvents.bgm_set_state(state, k_value)` should probably accept both:

| Input | Source | Use |
|---|---|---|
| `current_level_k` / `total_progress` | `GameState` | Long-form progression / level-band music changes. |
| `danger_level` | `DangerManager` | Intensity layer, filter, warning pulse, or one-shot danger beep. |

Do not force K and danger into one variable. They represent different game axes.
