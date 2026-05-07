# Audio License Audit

## Summary

- Audit date: 2026-05-08
- Repository: Everyseok/core-breaker-godot
- Current audio architecture:
  AudioEvents -> data/audio/sound_catalog.json -> AudioRouter
- Existing audio file count: 20 active `.ogg` media files under `assets/audio`
- Existing catalog event count: 24
- Missing catalog files: 0
- Unreferenced audio files: 0
- Existing license documentation found: Yes. Current evidence is in `assets/audio/LICENSE_MANIFEST.md`, `assets/audio/licenses/kenney/*.txt`, and `docs/audio/phase2-packs.md`.
- Overall status: PARTIAL

Notes:
- Existing active audio has repo-local source/license evidence, mostly CC0 records from Kenney and OpenGameArt.
- The standard `docs/AUDIO_LICENSES.md` file did not exist before this audit, so this pass creates it.
- Some older release docs still mention audio-license gaps from before audio import; this audit supersedes that older status for current active audio inventory.
- Passive SFX source site remains `PENDING_USER_PROVIDED_SITE`; no passive-specific SFX generation/download site was confirmed locally.

## Existing audio catalog inventory

| Event ID | File path | Exists? | Source/license status | Notes |
|---|---|---:|---|---|
| `bgm.core_loop` | `assets/audio/bgm/core_loop.ogg` | Yes | VERIFIED | Listed in `assets/audio/LICENSE_MANIFEST.md` as OpenGameArt Flowerbed Fields [Loop], CC0 on source page. |
| `brick.break` | `assets/audio/sfx/brick/break.ogg` | Yes | VERIFIED | Listed as Kenney Impact Sounds, CC0 license file preserved. |
| `brick.hit` | `assets/audio/sfx/brick/hit.ogg` | Yes | VERIFIED | Listed as Kenney Impact Sounds, CC0 license file preserved. |
| `game.max_clear` | `assets/audio/sfx/progression/max_clear.ogg` | Yes | VERIFIED | Listed as Kenney Digital Audio, CC0 license file preserved. |
| `game.over` | `assets/audio/sfx/progression/game_over.ogg` | Yes | VERIFIED | Listed as Kenney Digital Audio, CC0 license file preserved. |
| `ui.button_tap` | `assets/audio/sfx/ui/button_tap.ogg` | Yes | VERIFIED | Listed as Kenney Interface Sounds, CC0 license file preserved. |
| `ui.confirm` | `assets/audio/sfx/ui/confirm.ogg` | Yes | VERIFIED | Listed as Kenney Interface Sounds, CC0 license file preserved. |
| `ui.error` | `assets/audio/sfx/ui/error.ogg` | Yes | VERIFIED | Listed as Kenney Interface Sounds, CC0 license file preserved. |
| `ui.menu_close` | `assets/audio/sfx/ui/menu_close.ogg` | Yes | VERIFIED | Listed as Kenney Interface Sounds, CC0 license file preserved. |
| `ui.menu_open` | `assets/audio/sfx/ui/menu_open.ogg` | Yes | VERIFIED | Listed as Kenney Interface Sounds, CC0 license file preserved. |
| `ui.switch` | `assets/audio/sfx/ui/switch.ogg` | Yes | VERIFIED | Listed as Kenney Interface Sounds, CC0 license file preserved. |
| `weapon.choice.open` | `assets/audio/sfx/ui/menu_open.ogg` | Yes | VERIFIED | Reuses `ui.menu_open`; same Kenney Interface Sounds evidence. |
| `weapon.choice.select` | `assets/audio/sfx/progression/weapon_select.ogg` | Yes | VERIFIED | Listed as Kenney Digital Audio, CC0 license file preserved. |
| `weapon.hit.arrow` | `assets/audio/sfx/weapons/arrow/hit.ogg` | Yes | VERIFIED | Listed as OpenGameArt Metal Impact Sounds, CC0 on source page. |
| `weapon.hit.chain_lightning` | `assets/audio/sfx/weapons/chain_lightning/proc.ogg` | Yes | VERIFIED | Listed as OpenGameArt Electricity Sound Effects, CC0 on source page. |
| `weapon.hit.meteor_cannon` | `assets/audio/sfx/weapons/meteor_cannon/proc.ogg` | Yes | VERIFIED | Listed as OpenGameArt Explosion, CC0 on source page. |
| `weapon.hit.prism_lance` | `assets/audio/sfx/weapons/prism_lance/proc.ogg` | Yes | VERIFIED | Listed as OpenGameArt Magic Spell SFX, CC0 on source page. |
| `weapon.hit.siege_cannon` | `assets/audio/sfx/weapons/siege_cannon/hit.ogg` | Yes | VERIFIED | Listed as OpenGameArt Cannon hit wall, CC0 on source page. |
| `weapon.hit.spark_lance` | `assets/audio/sfx/weapons/spark_lance/hit.ogg` | Yes | VERIFIED | Listed as OpenGameArt Laser, CC0 on source page. |
| `weapon.hit.thunder` | `assets/audio/sfx/weapons/thunder/hit.ogg` | Yes | VERIFIED | Listed as OpenGameArt Electricity Sound Effects, CC0 on source page. |
| `weapon.hit.volt_storm` | `assets/audio/sfx/weapons/volt_storm/hit.ogg` | Yes | VERIFIED | Listed as OpenGameArt Electricity Sound Effects, CC0 on source page. |
| `weapon.proc.chain_lightning` | `assets/audio/sfx/weapons/chain_lightning/proc.ogg` | Yes | VERIFIED | Reuses chain lightning proc file; same OpenGameArt evidence. |
| `weapon.proc.meteor_cannon` | `assets/audio/sfx/weapons/meteor_cannon/proc.ogg` | Yes | VERIFIED | Reuses meteor cannon proc file; same OpenGameArt evidence. |
| `weapon.proc.prism_lance` | `assets/audio/sfx/weapons/prism_lance/proc.ogg` | Yes | VERIFIED | Reuses prism lance proc file; same OpenGameArt evidence. |

## Existing audio files not referenced by catalog

None. All 20 active `.ogg` media files under `assets/audio` are referenced by `data/audio/sound_catalog.json`.

Note: `.ogg.import` files and license text files are not gameplay media and are intentionally excluded from this active media count.

## Catalog paths missing on disk

None. All catalog paths exist on disk.

## Phase 7R.1 Metadata Hardening

- `b9f338a docs: audit audio license status` push result: succeeded. `origin/feature/android-debug-apk-artifact` now points to `b9f338a`.
- Metadata extraction tools: `ffprobe` available at `/opt/homebrew/bin/ffprobe`; `afinfo` available at `/usr/bin/afinfo`.
- Files with file size recorded: 20 / 20 active `.ogg` media files.
- Files with duration recorded: 20 / 20 active `.ogg` media files.
- Files with sample rate/channel recorded: 20 / 20 active `.ogg` media files.
- Current technical metadata: every active audio file is Ogg Vorbis at 44100 Hz; files are a mix of mono and stereo.
- Remaining metadata gaps: OpenGameArt author names are still not documented locally for 8 weapon SFX files, except `assets/audio/bgm/core_loop.ogg`, whose file tags list Zane Little as artist/composer.
- Current release-readiness status: PARTIAL.

The release-readiness status remains `PARTIAL` because a `COMPLETE` status requires every active audio file to have source, license, author, commercial use, duration, sample rate, channel, file size, and processing notes fully recorded.

## Phase 8 Passive SFX Addendum

- Passive SFX files added: 6
- Passive SFX source family: OpenGameArt CC0 source pages
- Passive SFX total size: 65,692 B
- Passive SFX format: Ogg Vorbis, 44100 Hz stereo
- Missing catalog files after integration: expected 0
- Unreferenced passive media after integration: expected 0
- Passive SFX status: VERIFIED

| Passive event | Final file | Source page | Original file | License | Author | Size | Duration | Notes |
|---|---|---|---|---|---|---:|---:|---|
| `passive.stone_throw.launch` | `assets/audio/sfx/passives/stone_throw/launch.ogg` | `https://opengameart.org/content/various-sound-effects-0` | `snd_throw1.wav` | CC0 | Spring Spring | 14,910 B | 0.380s | Catapult/throw launch for stone passive. |
| `passive.stone_throw.impact` | `assets/audio/sfx/passives/stone_throw/impact.ogg` | `https://opengameart.org/content/various-sound-effects-0` | `small_rock_impact.wav` | CC0 | Spring Spring | 15,927 B | 0.531s | Small stone impact on brick. |
| `passive.meteor.launch` | `assets/audio/sfx/passives/meteor/launch.ogg` | `https://opengameart.org/content/25-cc0-bang-firework-sfx` | `cannon_03.ogg` | CC0 | rubberduck | 11,529 B | 0.601s | Meteor cannon launch; not sky-falling meteor audio. |
| `passive.meteor.impact` | `assets/audio/sfx/passives/meteor/impact.ogg` | `https://opengameart.org/content/various-sound-effects-0` | `cannonball_tap.wav` | CC0 | Spring Spring | 8,076 B | 0.491s | Cannonball collision / impact, intentionally different from existing `cannon_hit_wall_0.ogg`. |
| `passive.machine_gun.burst` | `assets/audio/sfx/passives/machine_gun/burst.ogg` | `https://opengameart.org/content/laser-weapon-burst-fire` | `burst fire.mp3` | CC0 | celestialghost8 | 9,407 B | 0.451s | Arcade "다다다다다" burst fire, not realistic firearm. |
| `passive.machine_gun.hit` | `assets/audio/sfx/passives/machine_gun/hit.ogg` | `https://opengameart.org/content/various-sound-effects-0` | `tick.wav` | CC0 | Spring Spring | 5,843 B | 0.057s | Tiny tick/ping hit spark. |

## Passive SFX Phase 8 requirement

Before adding passive SFX, each new file must have:

- source site URL
- exact generation prompt or search phrase
- license
- author if known
- commercial use allowed yes/no
- generated/downloaded date
- file size
- duration
- sample rate
- mono/stereo
- processing/compression notes

## Decision

Existing active audio has usable repo-local source/license evidence, but the project did not have a consolidated `docs/AUDIO_LICENSES.md` table before this pass. Overall status is therefore `PARTIAL`, not `COMPLETE`.

If existing audio licenses are not documented in enough detail for a store/review packet:
- Do not claim the release packet is fully cleared.
- Keep the remaining metadata gaps marked as needing verification.
- New passive SFX must not repeat this gap.
- Phase 8 may proceed only for new files if their license is explicit and recorded.
