# Project Status

**Date:** 2026-05-05
**Phase:** 4.25 — Android Debug APK Pipeline Remediation
**Master source-of-truth:** [`docs/APP_IN_TOSS_MONETIZED_RELEASE_MASTER_CHECKLIST.md`](APP_IN_TOSS_MONETIZED_RELEASE_MASTER_CHECKLIST.md)
**Breadth audit:** [`docs/APP_IN_TOSS_DEVCENTER_FULL_AUDIT.md`](APP_IN_TOSS_DEVCENTER_FULL_AUDIT.md)
**Dual-platform audit:** [`docs/DUAL_PLATFORM_BRIDGE_AUDIT.md`](DUAL_PLATFORM_BRIDGE_AUDIT.md)
**Google Play checklist:** [`docs/GOOGLE_PLAY_RELEASE_MASTER_CHECKLIST.md`](GOOGLE_PLAY_RELEASE_MASTER_CHECKLIST.md)
**Phone artifact guide:** [`docs/ANDROID_PHONE_TEST_FROM_GITHUB.md`](ANDROID_PHONE_TEST_FROM_GITHUB.md)

## Current Verdicts

| Area | Verdict |
|---|---|
| Can submit App-in-Toss today? | **No** |
| Can submit Google Play today? | **No** |
| Can push this pass to GitHub? | **No — no remote configured, `gh` auth invalid** |
| Can build Android debug APK artifact today? | **Closer — debug preset and workflow exist; private GitHub push/run is still blocked** |
| Top banner | `USER_DESIRED_BUT_REQUIRES_LAYOUT_REDESIGN_AND_OFFICIAL_ADS_QA` |
| Death/game-over ad | Post-run interstitial or rewarded continue candidates only; do not implement now |
| Ranking / Game Center | Structurally partial on App-in-Toss; future Google Play Games path not implemented |

## Current State Summary

| Area | Current State |
|---|---|
| Branch | `feature/design-rebuild-apply-pass` |
| Main flow | MainMenu starts the app; gameplay starts only on user action |
| Save source of truth | `SaveManager.get_best_record_value()` |
| Platform owner today | `PlatformBridge` owns Toss lifecycle, user key, leaderboard submit/open, and future ad wrapper concerns |
| Platform direction | shared core + platform adapters; no runtime wiring yet |
| Export state | Historical dry run exists; no current final `.ait` |
| Google Play export state | Debug-only APK preset exists; no production AAB, signing, or Play Console setup |
| GitHub APK artifact state | Hardened workflow exists at `.github/workflows/android-debug-apk.yml`; it installs Godot 4.6.2 export templates and Android SDK packages for a real debug APK attempt, but still needs private push and first CI run |
| Android debug APK launch state | Debug APK uses temporary package `com.junseokism.corebreaker.debug` and is configured as launcher-visible |
| Worktree hygiene | Dirty worktree includes pre-existing gameplay/domain/scene/asset changes outside this release-pipeline loop; do not stage with `git add .` |
| Branding | `res://assets/branding/app_logo.png` is canonical source, `res://assets/branding/app_icon_600.png` is the exact `600x600` candidate pending approval |
| Console state | App is not registered yet; console-dependent work stays `NEEDS_CONSOLE_ACCESS` |
| Ads state | `NOT_IMPLEMENTED / FUTURE`; no placeholder slots, no fake ad UI |
| Developer Center breadth | All first-column categories are now mapped; many marketing/API/revenue items are future-stage rather than current blockers |
| GitHub push safety | Blocked until private remote exists and `gh` auth is healthy |
| Buff System MVP | Implemented and manually smoke-tested |

## Highest-Priority Blockers

1. There is no verified private GitHub remote and `gh` auth is invalid, so this pass cannot be pushed safely.
2. Toss console registration and QR/device validation are not complete.
3. Google Play has no production AAB preset, signing path, or Play Console setup.
4. Public title/icon/logo are not fully locked for store registration.
5. Asset/license proof is still incomplete.
6. Ranking/Game Center is only structurally partial and still needs Toss-shell validation.
7. `JavaScriptBridge.eval(...)` in `PlatformBridge` is a review-sensitive implementation detail that needs careful later validation.

## What Was Not Changed By This Release-Pipeline Loop

- No gameplay math, `DamageRules`, `BrickRules`, progression thresholds, wall rules, projectile mechanics, or weapon balance were intentionally changed by the APK/dual-platform release loop.
- The current worktree still contains pre-existing gameplay/domain/scene/asset changes from other passes, so final staging must be path-specific and must not use `git add .`.
- Platform scripts added in this phase are no-op skeletons only and are not wired into live runtime.
- `exports/` was not modified and no `.ait`, APK, or AAB export was generated.
- No ad SDK integration, leaderboard SDK integration, ads, placeholder ad boxes, Toss Ads Pixel, production signing, production ad IDs, or Play Games SDK integration were added.
