# Audio Licenses

## Existing audio

Status: PARTIAL

Existing active audio files have repo-local source/license evidence in `assets/audio/LICENSE_MANIFEST.md`, `assets/audio/licenses/kenney/*.txt`, and `docs/audio/phase2-packs.md`. This file consolidates that evidence for release review. Phase 7R.1 added local file size, duration, sample rate, and channel metadata extracted with `ffprobe`/`afinfo`. Some OpenGameArt author names are still not documented locally and remain `UNKNOWN`, so the release status remains `PARTIAL`.

| File | Used by event(s) | Source | License | Author | Commercial use | Verification status | Notes |
|---|---|---|---|---|---|---|---|
| `assets/audio/bgm/core_loop.ogg` | `bgm.core_loop` | `https://opengameart.org/content/flowerbed-fields-loop` | CC0 | Zane Little | Yes | VERIFIED | Manifest lists original `flowerbed_fields.ogg`, source page CC0, SHA256 `99607b996cc43c1891afcbf7c2c8d8aad1009266cea358d4753e3c50b1332d36`. File metadata tags list artist/composer as Zane Little. |
| `assets/audio/sfx/brick/break.ogg` | `brick.break` | `https://kenney.nl/assets/impact-sounds` | CC0 | Kenney Vleugels / Kenney.nl | Yes | VERIFIED | Original `Audio/impactMining_004.ogg`; internal Kenney license text preserved. |
| `assets/audio/sfx/brick/hit.ogg` | `brick.hit` | `https://kenney.nl/assets/impact-sounds` | CC0 | Kenney Vleugels / Kenney.nl | Yes | VERIFIED | Original `Audio/impactMetal_light_004.ogg`; internal Kenney license text preserved. |
| `assets/audio/sfx/progression/game_over.ogg` | `game.over` | `https://kenney.nl/assets/digital-audio` | CC0 | Kenney Vleugels / Kenney.nl | Yes | VERIFIED | Original `Audio/phaserDown3.ogg`; internal Kenney license text preserved. |
| `assets/audio/sfx/progression/max_clear.ogg` | `game.max_clear` | `https://kenney.nl/assets/digital-audio` | CC0 | Kenney Vleugels / Kenney.nl | Yes | VERIFIED | Original `Audio/powerUp11.ogg`; internal Kenney license text preserved. |
| `assets/audio/sfx/progression/weapon_select.ogg` | `weapon.choice.select` | `https://kenney.nl/assets/digital-audio` | CC0 | Kenney Vleugels / Kenney.nl | Yes | VERIFIED | Original `Audio/powerUp8.ogg`; internal Kenney license text preserved. |
| `assets/audio/sfx/ui/button_tap.ogg` | `ui.button_tap` | `https://kenney.nl/assets/interface-sounds` | CC0 | Kenney Vleugels / Kenney.nl | Yes | VERIFIED | Original `Audio/click_001.ogg`; internal Kenney license text preserved. |
| `assets/audio/sfx/ui/confirm.ogg` | `ui.confirm` | `https://kenney.nl/assets/interface-sounds` | CC0 | Kenney Vleugels / Kenney.nl | Yes | VERIFIED | Original `Audio/confirmation_001.ogg`; internal Kenney license text preserved. |
| `assets/audio/sfx/ui/error.ogg` | `ui.error` | `https://kenney.nl/assets/interface-sounds` | CC0 | Kenney Vleugels / Kenney.nl | Yes | VERIFIED | Original `Audio/error_003.ogg`; internal Kenney license text preserved. |
| `assets/audio/sfx/ui/menu_close.ogg` | `ui.menu_close` | `https://kenney.nl/assets/interface-sounds` | CC0 | Kenney Vleugels / Kenney.nl | Yes | VERIFIED | Original `Audio/close_002.ogg`; internal Kenney license text preserved. |
| `assets/audio/sfx/ui/menu_open.ogg` | `ui.menu_open`, `weapon.choice.open` | `https://kenney.nl/assets/interface-sounds` | CC0 | Kenney Vleugels / Kenney.nl | Yes | VERIFIED | Original `Audio/open_002.ogg`; internal Kenney license text preserved. |
| `assets/audio/sfx/ui/switch.ogg` | `ui.switch` | `https://kenney.nl/assets/interface-sounds` | CC0 | Kenney Vleugels / Kenney.nl | Yes | VERIFIED | Original `Audio/switch_002.ogg`; internal Kenney license text preserved. |
| `assets/audio/sfx/weapons/arrow/hit.ogg` | `weapon.hit.arrow` | `https://opengameart.org/content/metal-impact-sounds` | CC0 | UNKNOWN | Yes | PARTIAL | Manifest lists original `clink1_0.wav` trimmed to 0.22s, source page CC0, SHA256 `0d439cd2b1f36f501b94c39661e39f91d160affe25c79f77dff7a2cd0ed7eadd`. Author not recorded in repo manifest. |
| `assets/audio/sfx/weapons/chain_lightning/proc.ogg` | `weapon.hit.chain_lightning`, `weapon.proc.chain_lightning` | `https://opengameart.org/content/electricity-sound-effects-0` | CC0 | UNKNOWN | Yes | PARTIAL | Manifest lists original `continuousspark.wav` trimmed to 0.30s, source page CC0, SHA256 `4ec24045b4fb6a88b958d00f16cc39b8aa992cd6e6a5edb4ecb0f34b36ddb18b`. Author not recorded in repo manifest. |
| `assets/audio/sfx/weapons/meteor_cannon/proc.ogg` | `weapon.hit.meteor_cannon`, `weapon.proc.meteor_cannon` | `https://opengameart.org/content/explosion-8` | CC0 | UNKNOWN | Yes | PARTIAL | Manifest lists original `explosion_1.wav` trimmed to 0.72s, source page CC0, SHA256 `8f91a1e428c5833f1a4881827396dc90725e464b76b402ca1314e8d871a51035`. Author not recorded in repo manifest. |
| `assets/audio/sfx/weapons/prism_lance/proc.ogg` | `weapon.hit.prism_lance`, `weapon.proc.prism_lance` | `https://opengameart.org/content/magic-spell-sfx` | CC0 | UNKNOWN | Yes | PARTIAL | Manifest lists original `magical_7_0.ogg` trimmed to 0.62s, source page CC0, SHA256 `2817da4f5df69ff993baffd6594a2f2a069f85ee2a02019f97db2246e350a76b`. Author not recorded in repo manifest. |
| `assets/audio/sfx/weapons/siege_cannon/hit.ogg` | `weapon.hit.siege_cannon` | `https://opengameart.org/content/cannon-hit-wall` | CC0 | UNKNOWN | Yes | PARTIAL | Manifest lists original `cannon_hit_wall_0.ogg` trimmed to 0.58s, source page CC0, SHA256 `6d15cf2ded4e8b868eefd59f683b788e7a57ef7de68cb448244544083208fa20`. Author not recorded in repo manifest. |
| `assets/audio/sfx/weapons/spark_lance/hit.ogg` | `weapon.hit.spark_lance` | `https://opengameart.org/content/laser` | CC0 | UNKNOWN | Yes | PARTIAL | Manifest lists original `laserthing2.wav` trimmed to 0.38s, source page CC0, SHA256 `922b04169afeefeee3f48b967fe5dbfb00171923f9ba6b336a99fbd6e4d198eb`. Author not recorded in repo manifest. |
| `assets/audio/sfx/weapons/thunder/hit.ogg` | `weapon.hit.thunder` | `https://opengameart.org/content/electricity-sound-effects-0` | CC0 | UNKNOWN | Yes | PARTIAL | Manifest lists original `spark.wav` trimmed to 0.24s, source page CC0, SHA256 `9a3d987bdf7f405570aa015f6da42596ce84c5073c18c0561be7cd3ae401bc97`. Author not recorded in repo manifest. |
| `assets/audio/sfx/weapons/volt_storm/hit.ogg` | `weapon.hit.volt_storm` | `https://opengameart.org/content/electricity-sound-effects-0` | CC0 | UNKNOWN | Yes | PARTIAL | Manifest lists original `continuousspark.wav` trimmed to 0.36s, source page CC0, SHA256 `4ec24045b4fb6a88b958d00f16cc39b8aa992cd6e6a5edb4ecb0f34b36ddb18b`. Author not recorded in repo manifest. |

## Existing active audio technical metadata

Extracted locally on 2026-05-08 with `ffprobe` and cross-checked with `afinfo`.

| File | File size | Duration | Sample rate | Channels | Processing / original-file notes |
|---|---:|---:|---:|---|---|
| `assets/audio/bgm/core_loop.ogg` | 1,759,940 B | 105.932s | 44100 Hz | stereo | Original `flowerbed_fields.ogg`; source page CC0; no trim note in manifest. |
| `assets/audio/sfx/brick/break.ogg` | 11,668 B | 0.830s | 44100 Hz | stereo | Original `Audio/impactMining_004.ogg`; Kenney internal license preserved. |
| `assets/audio/sfx/brick/hit.ogg` | 6,675 B | 0.213s | 44100 Hz | stereo | Original `Audio/impactMetal_light_004.ogg`; Kenney internal license preserved. |
| `assets/audio/sfx/progression/game_over.ogg` | 7,329 B | 0.496s | 44100 Hz | stereo | Original `Audio/phaserDown3.ogg`; Kenney internal license preserved. |
| `assets/audio/sfx/progression/max_clear.ogg` | 6,495 B | 0.679s | 44100 Hz | mono | Original `Audio/powerUp11.ogg`; Kenney internal license preserved. |
| `assets/audio/sfx/progression/weapon_select.ogg` | 6,363 B | 0.575s | 44100 Hz | mono | Original `Audio/powerUp8.ogg`; Kenney internal license preserved. |
| `assets/audio/sfx/ui/button_tap.ogg` | 4,876 B | 0.100s | 44100 Hz | mono | Original `Audio/click_001.ogg`; Kenney internal license preserved. |
| `assets/audio/sfx/ui/confirm.ogg` | 8,968 B | 0.290s | 44100 Hz | mono | Original `Audio/confirmation_001.ogg`; Kenney internal license preserved. |
| `assets/audio/sfx/ui/error.ogg` | 12,256 B | 0.533s | 44100 Hz | stereo | Original `Audio/error_003.ogg`; Kenney internal license preserved. |
| `assets/audio/sfx/ui/menu_close.ogg` | 14,752 B | 0.314s | 44100 Hz | mono | Original `Audio/close_002.ogg`; Kenney internal license preserved. |
| `assets/audio/sfx/ui/menu_open.ogg` | 14,975 B | 0.314s | 44100 Hz | mono | Original `Audio/open_002.ogg`; reused by `weapon.choice.open`. |
| `assets/audio/sfx/ui/switch.ogg` | 7,097 B | 0.611s | 44100 Hz | stereo | Original `Audio/switch_002.ogg`; Kenney internal license preserved. |
| `assets/audio/sfx/weapons/arrow/hit.ogg` | 7,574 B | 0.221s | 44100 Hz | stereo | Original `clink1_0.wav`; trimmed to 0.22s. |
| `assets/audio/sfx/weapons/chain_lightning/proc.ogg` | 11,078 B | 0.218s | 44100 Hz | stereo | Original `continuousspark.wav`; trimmed to 0.30s per manifest, exported file duration is 0.218s. |
| `assets/audio/sfx/weapons/meteor_cannon/proc.ogg` | 11,043 B | 0.721s | 44100 Hz | stereo | Original `explosion_1.wav`; trimmed to 0.72s. |
| `assets/audio/sfx/weapons/prism_lance/proc.ogg` | 20,293 B | 0.621s | 44100 Hz | stereo | Original `magical_7_0.ogg`; trimmed to 0.62s. |
| `assets/audio/sfx/weapons/siege_cannon/hit.ogg` | 14,537 B | 0.578s | 44100 Hz | stereo | Original `cannon_hit_wall_0.ogg`; trimmed to 0.58s. |
| `assets/audio/sfx/weapons/spark_lance/hit.ogg` | 9,603 B | 0.311s | 44100 Hz | stereo | Original `laserthing2.wav`; trimmed to 0.38s per manifest, exported file duration is 0.311s. |
| `assets/audio/sfx/weapons/thunder/hit.ogg` | 9,988 B | 0.241s | 44100 Hz | stereo | Original `spark.wav`; trimmed to 0.24s. |
| `assets/audio/sfx/weapons/volt_storm/hit.ogg` | 9,992 B | 0.218s | 44100 Hz | stereo | Original `continuousspark.wav`; trimmed to 0.36s per manifest, exported file duration is 0.218s. |

## Passive SFX to be added later

Do not add passive SFX license rows yet unless files already exist and source/license is known.

Required fields for future passive SFX:
- final filename
- source site URL
- exact prompt/search phrase
- license
- author if known
- generation/download date
- commercial use allowed
- duration
- sample rate
- mono/stereo
- file size
- processing notes
