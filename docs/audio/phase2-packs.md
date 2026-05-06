# Phase 2 Kenney CC0 Audio Pack Intake

Date: 2026-05-06
Download timestamp: 2026-05-06T07:42:00Z

Scope: Download and preserve requested Kenney audio packs after direct CC0 verification. No event mapping, renaming, conversion, code wiring, scene changes, or gameplay changes were made.

## Summary

| Result | Count |
|---|---:|
| Requested packs | 5 |
| Downloaded packs | 5 |
| Skipped packs | 0 |
| Packs with official page CC0 text | 5 |
| Packs with internal `License.txt` CC0 text | 5 |
| Extracted `.ogg` files | 418 |
| Extracted `.wav` files | 0 |
| Extracted `.mp3` files | 0 |
| Raw intake size | 19 MB |

All five requested packs were accepted because the fetched Kenney asset pages and internal license files explicitly state Creative Commons Zero / CC0.

## Pack Manifest

| Pack | Page URL | Zip direct URL | License evidence | Version / creation date evidence | SHA256 | Downloaded zip | Extracted path | Official asset count | Extracted `.ogg` count |
|---|---|---|---|---|---|---|---|---:|---:|
| Sci-fi Sounds | `https://kenney.nl/assets/sci-fi-sounds` | `https://kenney.nl/media/pages/assets/sci-fi-sounds/e3af5f7ed7-1677589334/kenney_sci-fi-sounds.zip` | Page: `Creative Commons CC0`; internal `License.txt`: `License: (Creative Commons Zero, CC0)` | Internal `License.txt`: `Sci-Fi Sounds (1.0)`, creation date `11-10-2020` | `119340f351a5098ad814f78719438c0da355a9ce8a4c8a3af6a8d48aa3d49e04` | `assets/audio/_kenney_raw/sci-fi-sounds.zip` | `assets/audio/_kenney_raw/sci-fi-sounds/` | 70 | 73 |
| Impact Sounds | `https://kenney.nl/assets/impact-sounds` | `https://kenney.nl/media/pages/assets/impact-sounds/8aa7b545c9-1677589768/kenney_impact-sounds.zip` | Page: `Creative Commons CC0`; internal `License.txt`: `License: (Creative Commons Zero, CC0)` | Internal `License.txt`: `Impact Sounds (1.0)`, creation date `19-12-2019` | `029d734af1582474edf3a694d1b0cebc97c1c152f2f39fa34d4c2bafc5de77f8` | `assets/audio/_kenney_raw/impact-sounds.zip` | `assets/audio/_kenney_raw/impact-sounds/` | 130 | 130 |
| Interface Sounds | `https://kenney.nl/assets/interface-sounds` | `https://kenney.nl/media/pages/assets/interface-sounds/d23a84242e-1677589452/kenney_interface-sounds.zip` | Page: `Creative Commons CC0`; internal `License.txt`: `License: (Creative Commons Zero, CC0)` | Internal `License.txt`: `Interface Sounds (1.0)`, creation date `11-02-2020` | `f2193d072726d6758a5f7871b2dcc54dcce0d5c35c6f0a62f92549b327c81232` | `assets/audio/_kenney_raw/interface-sounds.zip` | `assets/audio/_kenney_raw/interface-sounds/` | 100 | 100 |
| UI Audio | `https://kenney.nl/assets/ui-audio` | `https://kenney.nl/media/pages/assets/ui-audio/e19c9b1814-1677590494/kenney_ui-audio.zip` | Page: `Creative Commons CC0`; internal `License.txt`: `License (Creative Commons Zero, CC0)` | Internal `License.txt`: `UI SFX Set`; no version/date found in fetched page/license | `946fc23a63d535d693eb31b2eabb80c8c28d6351e2186b344ceb71b2cb1d5eb6` | `assets/audio/_kenney_raw/ui-audio.zip` | `assets/audio/_kenney_raw/ui-audio/` | 50 | 52 |
| Digital Audio | `https://kenney.nl/assets/digital-audio` | `https://kenney.nl/media/pages/assets/digital-audio/7492b26e77-1677590265/kenney_digital-audio.zip` | Page: `Creative Commons CC0`; internal `License.txt`: `License (Creative Commons Zero, CC0)` | Internal `License.txt`: `Digital Audio`; no version/date found in fetched page/license | `24e6ce28b76a6d8c89cff4d331e0965ff5c3de8a73c612028e9d363cc64e4f06` | `assets/audio/_kenney_raw/digital-audio.zip` | `assets/audio/_kenney_raw/digital-audio/` | 60 | 63 |

## Internal License Files Preserved

| Pack | Internal license path |
|---|---|
| Sci-fi Sounds | `assets/audio/_kenney_raw/sci-fi-sounds/License.txt` |
| Impact Sounds | `assets/audio/_kenney_raw/impact-sounds/License.txt` |
| Interface Sounds | `assets/audio/_kenney_raw/interface-sounds/License.txt` |
| UI Audio | `assets/audio/_kenney_raw/ui-audio/License.txt` |
| Digital Audio | `assets/audio/_kenney_raw/digital-audio/License.txt` |

## Notes For Phase 3

- The raw packs include more `.ogg` files than the official page asset counts for Sci-fi Sounds, UI Audio, and Digital Audio because extracted folders include preview/support files in addition to the primary asset count.
- Do not map all 418 files. Phase 3 should choose a small, curated subset based on `docs/audio/event-inventory.md`.
- Do not move files out of `_kenney_raw` until Phase 3 mapping is approved.
- Do not wire audio code until mapping is approved.
- Do not add BGM yet. These packs are SFX-oriented and do not solve looped gameplay music by themselves.

## Commands Used

```bash
curl -L --fail --retry 3 -sS 'https://kenney.nl/assets/<pack-slug>'
curl -L --fail --retry 3 -o assets/audio/_kenney_raw/<pack-slug>.zip '<direct-zip-url>'
shasum -a 256 assets/audio/_kenney_raw/<pack-slug>.zip
unzip -oq assets/audio/_kenney_raw/<pack-slug>.zip -d assets/audio/_kenney_raw/<pack-slug>/
find assets/audio/_kenney_raw/<pack-slug> -maxdepth 3 -type f \( -iname '*license*' -o -iname '*readme*' \)
```
