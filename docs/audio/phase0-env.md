# Phase 0 - Audio Environment Audit

Date: 2026-05-06
Repo: `/Volumes/JUNSEOKISM_USB3.0/game/game_junseokism.ver1`
Branch: `feature/android-debug-apk-artifact`
Scope: inspection only. No scripts, scenes, assets, data catalog, or audio files changed.

## Tool Availability

| Tool / Permission | Result | Evidence |
|---|---|---|
| Filesystem | Available | Read/write inspection succeeded in repo |
| Computer Use | Available | `mcp__computer_use__.list_apps` returned running apps, including Chrome, Godot, Codex |
| GitHub CLI | Available and authenticated | `gh auth status` reports account `Everyseok`, scopes include `repo`, `workflow` |
| Browser Use | Blocked in this session | Browser Use requires Node REPL browser runtime; `mcp__node_repl__js` is not callable in this request |
| Godot | Available | `/Users/junseokism/Downloads/Godot 2.app/Contents/MacOS/Godot` |
| `ffmpeg` | Missing | `command -v ffmpeg` produced no path |
| `ffprobe` | Missing | `command -v ffprobe` produced no path |
| `sips` | Available | `/usr/bin/sips` |
| `file` | Available | `/usr/bin/file` |
| `unzip` | Available | `/usr/bin/unzip` |
| `curl` | Available | `/usr/bin/curl` |

## Project Configuration

| Check | Result | Evidence |
|---|---|---|
| Godot project found | Yes | `project.godot` exists |
| Godot version feature | `4.6` | `config/features=PackedStringArray("4.6", "GL Compatibility")` |
| Main scene | `res://scenes/main/main.tscn` | `project.godot` |
| Mobile viewport | `390x844` | `project.godot` display width/height |
| Existing audio assets | None found | no `.ogg`, `.wav`, `.mp3`, `.flac`, `.aiff` under `assets/` |

## Intended Audio Work Directories

| Directory | Current State |
|---|---|
| `assets/audio/` | Missing |
| `scripts/audio/` | Missing |
| `data/audio/` | Missing |
| `docs/audio/` | Created for audit output only |

No runtime audio directories were created in this phase because Phase 3 mapping approval has not happened yet.

## Existing Audio Code Inventory

| File | Match | Interpretation |
|---|---|---|
| `scripts/autoload/audio_manager.gd:63` | `AudioServer.set_bus_mute(...)` | Existing lifecycle/sound-toggle mute owner. Not a playback system. |
| `scripts/autoload/audio_manager.gd` | `set_bgm_intensity`, `play_hook`, `play_ui_impact`, `play_weapon_change`, `play_weapon_proc` | Stub/log hooks only; no `AudioStreamPlayer`, no file paths, no real playback. |

Search command:

```bash
rg -n "AudioStreamPlayer|AudioServer|AudioStream|AudioBus|\\.ogg|\\.wav|\\.mp3|play\\(" scripts scenes data project.godot export_presets.cfg --glob '!*.import'
```

## Conflict Assessment

No direct scattered playback system was found.

Existing `AudioManager` is not a conflict if the future audio pass preserves it as the sound-toggle/lifecycle owner or folds it narrowly into the new audio facade. The anti-spaghetti rule should still make `AudioEvents` the only gameplay-facing playback API.

## Phase 0 Blockers

| Blocker | Severity | Why It Blocks |
|---|---|---|
| `ffmpeg` missing | Critical for Phase 4 | Required for `.ogg` conversion from downloaded Kenney source files |
| Browser Use runtime unavailable | Critical for Phase 2 as written | Kenney pack inspection/download via Browser Use cannot be completed in this session unless the browser runtime is re-enabled |

## Phase 0 Decision

Phase 0 is partially complete but the full pipeline must stop before Kenney download/conversion.

Next safe action, if the user approves proceeding despite Browser Use blockage, is Phase 1 event inventory extraction because it only reads repo code and does not need `ffmpeg` or browser downloads.
