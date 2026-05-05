# Dual Platform Bridge Audit

Date: 2026-05-05
Scope: App-in-Toss + future Google Play coexistence audit for the shared Godot game core.

## Verdict

- Can App-in-Toss and Google Play coexist on one shared core: `YES`
- Condition: platform-specific APIs must move behind platform-neutral adapters and the gameplay core must consume generic bridge contracts only.

## What Must Be Abstracted

1. Platform runtime detection
2. User identity / game-specific user key
3. Leaderboard submit/open
4. Ad show/hide hooks
5. Banner-safe playfield reservation data
6. Background/foreground pause-resume behavior if platform-specific

## Current Collision Risks

1. `scripts/autoload/platform_bridge.gd` currently mixes generic lifecycle ownership with Toss-specific JS bridge calls.
2. `scripts/ui/main_menu.gd` and `scripts/ui/pause_menu.gd` call `PlatformBridge.open_leaderboard()` directly.
3. `scripts/gameplay/game_root.gd` submits score through `PlatformBridge.submit_leaderboard_score(...)`.
4. Future Google Play code would become spaghetti if it is added directly into the same Toss-oriented functions without platform guards or adapters.
5. Top banner layout cannot be solved by scattering offsets into HUD, joystick, core, rings, and projectiles independently.
6. Candidate runtimes must not be treated as feature-ready runtimes. Android does not imply AdMob or Play Games setup; Web does not imply App-in-Toss, Toss Ads, or Game Center setup.

## Build / Export Target Selection

- App-in-Toss build:
  - web export
  - Toss bridge available
  - Toss Game Center / Toss Ads are future platform adapters
- Google Play build:
  - Android export
  - Android plugin path required
  - Play Games / AdMob are future platform adapters
- Editor/debug:
  - use no-op fallback stubs

## What Must Stay Platform-Neutral

- `scripts/domain/*`
- `scripts/application/rings/*`
- `scripts/gameplay/core.gd`
- projectile behavior
- damage rules
- progression thresholds
- weapon balance
- wall math
- save file repository internals

## What Is Platform-Specific

- Toss JS bridge / `JavaScriptBridge.eval(...)`
- Play Games Services client calls
- AdMob / Toss Ads SDK hooks
- store-specific identity / leaderboard transport
- app-exit / shell-close behavior

## Editor / Debug Environment

- Use editor fallback stubs only.
- No Toss API should run in editor-only or non-web contexts.
- No Google Play / AdMob API should run without Android runtime and plugin availability.

## How To Prevent Wrong Runtime Calls

- App-in-Toss prevention:
  - keep Toss bridge calls behind an App-in-Toss adapter
  - load or execute them only on the web/Toss runtime path
  - require actual Toss shell/console validation before any adapter reports ads or Game Center as ready
- Google Play prevention:
  - keep Android plugin / Play Games / AdMob calls behind Android adapters
  - load or execute them only on the Android runtime path
  - require actual SDK/plugin and Play Console setup before any adapter reports AdMob or Play Games as ready

## Suggested Ownership Model

- `PlatformBridge` or future runtime facade:
  - selects the active adapter
  - owns platform detection and external bridge routing
- `GameRoot`:
  - owns run-complete score submission timing only
- `UI`:
  - owns buttons and feedback only
- `SaveManager`:
  - owns local persistence only
- `scripts/application/layout/playfield_layout_service.gd`:
  - computes one centralized gameplay playfield rect for future banner-safe scaling

## Minimal Skeleton Added In This Pass

- `scripts/platform/platform_runtime.gd`
- `scripts/platform/platform_capabilities.gd`
- `scripts/platform/app_in_toss_bridge.gd`
- `scripts/platform/google_play_bridge.gd`
- `scripts/platform/editor_fallback_bridge.gd`
- `scripts/platform/ads/*`
- `scripts/platform/leaderboard/*`
- `scripts/application/layout/playfield_layout_service.gd`

These are contract/skeleton files only. They are not wired into runtime yet.

## Skeleton Safety Hardening

- `OS.has_feature("android")` is allowed to mark Android as a candidate runtime only.
- `OS.has_feature("web")` is allowed to mark Web/App-in-Toss as a candidate runtime only.
- AdMob, Toss Ads, Play Games, and Toss Game Center skeletons must return `false` for feature readiness until their real SDK/bridge/console/device validation is complete.

## Top Banner Safe-Layout Decision

- Verdict: `NEEDS_LAYOUT_PROTOTYPE`
- Hard rule:
  - top UI and bottom controls stay readable and usable
  - gameplay playfield scales/repositions from one centralized layout owner
  - do not scatter ad offsets into ring spawning, projectile logic, or joystick math
- Current best owner:
  - `scripts/application/layout/playfield_layout_service.gd`

## What Should Be Pushed Now

- Docs
- no-op platform skeletons
- no-op layout skeleton
- hardened GitHub Actions APK artifact workflow only after private remote/auth are repaired

## What Remains Blocked

- real private GitHub push, because this repo currently has no remote and `gh` auth is invalid
- successful GitHub APK artifact builds, because the workflow has not been pushed to a verified private repo and run in CI yet
- production Android release work, because there is no production AAB preset, signing setup, or Play Console setup yet
- real Play Games / AdMob implementation, because the platform pass is not approved for SDK integration yet
- real Toss Ads / Game Center runtime proof, because console/device QA is still pending
