# Project Status

**Date:** 2026-05-08
**Phase:** Pre-Bundle Readiness — App-in-Toss Ads / Game Center / Legal Gate
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
| Can push this pass to GitHub? | **Yes — private remote is configured; use path-specific staging only** |
| Can build Android debug APK artifact today? | **Closer — debug preset and workflow exist; private GitHub push/run is still blocked** |
| Top banner | `STRUCTURALLY_WIRED_NOT_QR_VALIDATED` |
| Rewarded revive ad | `STRUCTURALLY_WIRED_NOT_QR_VALIDATED`; success only on `USER_EARNED_REWARD` |
| Ranking / Game Center | `STRUCTURALLY_WIRED_NOT_QR_VALIDATED`; future Google Play Games path not implemented |
| App-in-Toss official docs | Rechecked by curl/Markdown fetch in `docs/PRE_BUNDLE_OFFICIAL_AUDIT.md` |
| Ads bridge | `STRUCTURALLY_WIRED_BUILD_VALIDATED` — blocked by ad group IDs, Toss Console, QR/device QA, and final wrapper packaging validation |
| Packaging policy | `PACKAGING_POLICY_LOCKED_WRAPPER`; final source candidate is `web/toss_wrapper/dist`; final size must be remeasured |
| Legal URLs | Static pages prepared, placeholders resolved, GitHub Pages deployed, public HTTPS 200 verified |
| Dry-run Web export | Passed to `exports/prebundle_dry_run/`, size `55M`; generated output must not be staged |
| Rejection-case checklist | Integrated into `docs/TOSS_QR_DEVICE_QA_PLAN.md`; 33 cases mapped, 16 remaining-before-review gates, community ad/leaderboard risk rows added, QR/device validation pending |
| Final `.ait` | Not created |

## Current State Summary

| Area | Current State |
|---|---|
| Branch | `feature/android-debug-apk-artifact` |
| Main flow | MainMenu starts the app; gameplay starts only on user action |
| Save source of truth | `SaveManager.get_best_record_value()` |
| Platform owner today | `PlatformBridge` owns Toss lifecycle, user key, leaderboard submit/open, and future ad wrapper concerns |
| Platform direction | App-in-Toss runtime now uses `window.CoreBreakerToss` structurally; QR/device proof is still missing |
| Export state | Historical dry run exists; no current final `.ait` |
| Google Play export state | Debug-only APK preset exists; no production AAB, signing, or Play Console setup |
| GitHub APK artifact state | Hardened workflow exists at `.github/workflows/android-debug-apk.yml`; it installs Godot 4.6.2 export templates and Android SDK packages for a real debug APK attempt, but still needs private push and first CI run |
| Android debug APK launch state | Debug APK uses temporary package `com.junseokism.corebreaker.debug` and is configured as launcher-visible |
| Worktree hygiene | Dirty worktree includes pre-existing gameplay/domain/scene/asset changes outside this release-pipeline loop; do not stage with `git add .` |
| Branding | `res://assets/branding/app_logo.png` is canonical source, `res://assets/branding/app_icon_600.png` is the exact `600x600` candidate pending approval |
| Console state | App title/categories and Game Center profile/leaderboard are user-reported; adGroupIds, settlement review, public legal URLs, and QR/device validation remain blocked |
| Ads state | `STRUCTURALLY_WIRED_BUILD_VALIDATED`; no fake ad UI; `BLOCKED_BY_AD_GROUP_ID` and `BLOCKED_BY_QR_DEVICE_QA` |
| Developer Center breadth | All first-column categories are now mapped; many marketing/API/revenue items are future-stage rather than current blockers |
| GitHub push safety | Private remote is configured; keep using path-specific staging and do not stage `.godot` cache files |
| Buff System MVP | Timed cooldown pass implemented: projectile x2 and damage x1.5 now expire after 10 seconds, then enter 30-second cooldown |
| Endless score model | Pass 1 implemented: score no longer resets by level; HUD gauge uses `max(best, 2000)`; weapon choice repeats at `2000 + 1000n` |
| Stabilization refactor | Pass 1 extracted pure endless-score gauge rules and repeated weapon-choice schedule rules without gameplay balance changes |
| Late-game pattern | Pass 5A implemented: K 2000~2999 alternating wall rotation, K 2000+ buff cooldown 10s, max wall remains 8 layers |
| Late-game pattern Pass 5B | Jumping monster pattern implemented and manually QA-verified |

## Highest-Priority Blockers

1. Rejection-case checklist is integrated into `docs/TOSS_QR_DEVICE_QA_PLAN.md`; 16 remaining-before-review gates still need Toss QR/device QA evidence.
2. PlatformBridge is structurally wired to `window.CoreBreakerToss`; bridge/wrapper builds pass, but Toss QR/device runtime validation is not complete.
3. Packaging policy is locked to Vite wrapper, but final wrapper output has not been rebuilt from the final export or converted to `.ait`.
4. Banner and rewarded ad group IDs are not configured and must not be invented.
5. Business registration is user-reported done; settlement review remains `PENDING_REVIEW`.
6. Toss Game Center profile/leaderboard setup is `USER_REPORTED_DONE`, but QR/device runtime verification is not complete.
7. Toss QR/device QA for navigation, schemes, external links, ads, ranking, low-score leaderboard validation, safe area, lifecycle, and audio is not complete.
8. Selected `Toss Web` export completeness audit passed, but final wrapper output still must be refreshed from the final export and remeasured before `.ait`.
9. Final `.ait` export has not been created.

## Release STOP GATES

| Gate | Status |
|---|---|
| Console / Legal | `PARTIAL`: legal URLs verified; adGroupIds and settlement review still blocked |
| QR / Device QA | `BLOCKED` |
| Export / Packaging | `BLOCKED` |
| Code Integrity | `STRUCTURALLY_READY_NOT_QR_VALIDATED` |
| Submit ready | `false` |
| Final `.ait` allowed | `false` |

## What Was Not Changed By This Release-Pipeline Loop

- No gameplay math, `DamageRules`, `BrickRules`, progression thresholds, wall rules, projectile mechanics, or weapon balance were intentionally changed by the APK/dual-platform release loop.
- The current worktree still contains pre-existing gameplay/domain/scene/asset changes from other passes, so final staging must be path-specific and must not use `git add .`.
- PlatformBridge changes in the pre-bundle worktree are structurally wired to `window.CoreBreakerToss`, but release remains QR/device and console blocked.
- `exports/prebundle_dry_run/` was generated for a dry-run Web export and must not be staged; no final `.ait`, APK, or AAB export was generated.
- No fake ad UI, placeholder ad box, Toss Ads Pixel, production signing, production ad IDs, or Play Games SDK integration were added. App-in-Toss Ads/Game Center paths are structural only until QR/device validation.
