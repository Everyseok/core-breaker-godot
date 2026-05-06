# Apps-in-Toss Gap Analysis

Date: 2026-05-06
Repo: `/Volumes/JUNSEOKISM_USB3.0/game/game_junseokism.ver1`
Branch inspected: `feature/android-debug-apk-artifact`

This is the Phase 3 gap analysis. It compares official Apps-in-Toss requirements and the merged release checklist against the current Godot repo.

## Executive Verdict

The game is not App-in-Toss submit-ready today and not monetized-launch-ready today.

Implementation must stop before Phase 4 because official docs create hard gates that cannot be safely bypassed:

- Toss console app registration is not complete.
- Game profile and leaderboard setup are not complete.
- Ads business/settlement and Toss Ads setup are not complete.
- QR/device QA evidence is missing.
- Game Center APIs are Promise-based, but the current Godot bridge treats them as synchronous `JavaScriptBridge.eval()` return values.
- Persistent top banner remains risky for the current `390x844` gameplay layout.

## Critical Gaps

| Gap | Type | Evidence | Risk | Safest Fix Strategy | Do Now? |
|---|---|---|---|---|---|
| No Toss console registration | External blocker | User context, existing docs | Cannot validate Game Center, app metadata, QR test, or review flow | User registers app; Codex prepares checklist only | No code |
| No game profile / leaderboard | External blocker | Official `getUserKeyForGame` game-category rule; leaderboard docs | `INVALID_CATEGORY`, `LeaderBoard not found`, false success assumptions | Configure console first; then QR test | No code |
| Promise bridge mismatch | Code architecture blocker | Official APIs return Promises; `PlatformBridge` uses immediate `JavaScriptBridge.eval()` at lines 140, 205, 255 | User key and submit can silently parse Promise objects incorrectly | Dedicated platform bridge pass: callback/Promise bridge, no gameplay changes | Yes, later dedicated pass |
| Ads setup missing | External blocker | User says business/ads setup not ready; official ads require adGroupId and QA | Real ads cannot be validated; fake UI would be review risk | Write Ads Planning doc, wait for business/console setup | No implementation |
| Persistent top banner risk | Product/layout blocker | Official banner fixed container recommendation `96px`; current game uses tight portrait layout | Banner may overlap HUD/safe area/playfield/control ergonomics | Separate prototype only after official setup and user accepts layout tradeoff | No |
| No QR/device proof | QA blocker | Official Game Center/Ads/release docs require real device checks | Structural rows cannot become done | Produce export and run device matrix after console setup | Later |
| Branding/license incomplete | Release blocker | Existing docs; `app_icon_600.png` exists but public title/license proof pending | Review/legal risk | User locks title/icon; Codex creates license manifest | Docs only now |

## High / Medium Gaps

| Gap | Type | Evidence | Risk | Safest Fix Strategy | Do Now? |
|---|---|---|---|---|---|
| Web framework config absent | Project-shape gap | No `package.json`/`granite.config.ts` found | Apps-in-Toss web-framework docs do not map 1:1 to Godot export | Treat Godot as WebView game export; use export preset/shell validation | No |
| `JavaScriptBridge.eval(...)` review sensitivity | Review-sensitive implementation | Current bridge uses static JS strings | Official game checklist is sensitive to eval-like code execution; reviewer may require explanation | Keep isolated; avoid dynamic/user-provided eval; document rationale | Later |
| Sentry not integrated | Observability gap | No Sentry code found | Production crashes harder to diagnose | Decide MVP-without-monitoring risk or add JS/WebView monitoring later | Later |
| Runtime UI builders | Maintainability gap | Existing docs classify GameOver/WeaponChoice runtime UI builders | Not immediate release blocker, but future UI changes can tangle | Defer until bug-driven or post-release cleanup | No |
| Export size not fresh | Release artifact gap | Historical dry run only | Current dirty assets may change bundle | Dedicated fresh export/size pass | Later |

## What Is Already Structurally Good

| Area | Evidence | Current Status |
|---|---|---|
| App starts from title screen | MainMenu-first flow in current docs/code | Structurally partial |
| Gameplay starts by user action | `GameRoot.start_game()` called by UI flow | Structurally partial |
| Score submit timing owner | `scripts/gameplay/game_root.gd:64-75` | Good owner, needs runtime proof |
| Duplicate submit guard | `PlatformBridge._score_submitted_this_run` | Good structure, needs stress test |
| Best score source | `SaveManager.get_best_record_value()` | Good structure |
| Ads are not prematurely implemented | `scripts/platform/ads/toss_ads_bridge.gd` returns false | Correct |
| No fake ad UI | Search found no fake ad slot | Correct |
| Viewport protections | `export_presets.cfg` head include | Structurally partial |

## Phase 4 Entry Decision

Phase 4 cannot start in this cycle.

The first implementation task should be a dedicated, narrow platform bridge pass, not ads:

1. Keep gameplay/domain untouched.
2. Replace synchronous Promise assumptions in `PlatformBridge` with an explicit async JS callback bridge for `getUserKeyForGame`, `submitGameCenterLeaderBoardScore`, and `openGameCenterLeaderboard`.
3. Preserve current score timing: only `GameRoot` triggers submit after game over/max clear.
4. Keep ads unimplemented until business/console setup exists.
5. Run static validation and later Toss-shell device QA.

## Recommended Next Prompts

1. `PLATFORMBRIDGE PROMISE-SAFE GAME CENTER PASS` — fix only `PlatformBridge` async Promise handling for user key, score submit, leaderboard open; no ads, no gameplay math.
2. `APP-IN-TOSS CONSOLE REGISTRATION CHECKLIST PASS` — list exact console fields for app name, icon, game category, leaderboard, QR test.
3. `ASSET LICENSE MANIFEST PASS` — create a license/source proof document for icon, backgrounds, font, and any audio.
4. `FRESH TOSS WEB EXPORT SIZE PASS` — export `.ait` candidate and measure unpacked size, no code changes unless export-only config bug.
5. `ADS PLANNING ONLY PASS` — after business/console info exists, choose banner/interstitial/rewarded strategy without UI implementation.

## Stop Conditions Preserved

- Do not implement banner ads now.
- Do not add placeholder ad boxes.
- Do not implement Toss Ads Pixel now.
- Do not implement custom ranking backend now.
- Do not touch gameplay math, DamageRules, BrickRules, progression thresholds, wall rules, projectile behavior, or weapon balance.
- Do not mark Game Center done before Toss console and device QA evidence.
