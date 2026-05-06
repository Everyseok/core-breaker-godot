# Master Release Checklist

Date: 2026-05-06
Repo: `/Volumes/JUNSEOKISM_USB3.0/game/game_junseokism.ver1`
Branch inspected: `feature/android-debug-apk-artifact`

This Phase 2 document merges the repo's existing App-in-Toss checklist docs with the current official-doc pass. The existing monetized master checklist remains the broad product source-of-truth; this file is the execution-facing checklist for this gated pass.

Status: `✅` done with local evidence, `⚠️` structurally partial or blocked by external validation, `❌` missing, `⛔` blocked before implementation.

## Release Gates

| ID | Status | Requirement | Evidence | Blocker / Next Action |
|---|---|---|---|---|
| REL-01 | ⛔ | App must be registered in App-in-Toss console before console-backed validation. | User context and existing docs say app is not registered. | `NEEDS_CONSOLE_ACCESS`; user/Toss console action. |
| REL-02 | ⚠️ | First screen must load quickly and start flow should be user-initiated. | `MainMenu` is app entry and `GameRoot.start_game()` is button-driven. | Measure launch in QR/device test. |
| REL-03 | ⚠️ | Sound toggle, pause/resume, close/exit, and foreground/background behavior must work in Toss shell. | `AudioManager`, `PauseMenu`, `PlatformBridge.visibilitychange`, `popstate` handling exist. | Device QA required. |
| REL-04 | ⚠️ | Safe area and fullscreen WebView behavior must be validated. | `project.godot` fixed `390x844`; export preset injects viewport/touch controls. | iOS/Android screenshot QA required. |
| REL-05 | ❌ | Final `.ait` export must exist and unpacked bundle must be `<= 100MB`. | Historical dry run exists in docs; no current final `.ait`. | Dedicated export pass. |
| REL-06 | ⛔ | Public title, icon, logo, and console metadata must be locked. | `assets/branding/app_icon_600.png` exists; final title/logo approval pending. | User action. |
| REL-07 | ⛔ | Asset/font/background/audio license proof must exist. | No complete license manifest found. | Create asset license manifest with user proof. |

## Game Center / Ranking

| ID | Status | Requirement | Evidence | Blocker / Next Action |
|---|---|---|---|---|
| GC-01 | ⚠️ | Use Toss game identity API, not device ID/ad ID/custom UUID. | `SaveManager.set_game_user_key()` exists; official `getUserKeyForGame()` documented. | Promise bridge validation required. |
| GC-02 | ⚠️ | Submit score only after game completion/max clear. | `scripts/gameplay/game_root.gd:64-75`. | Toss shell logs required. |
| GC-03 | ⚠️ | Prevent duplicate score submit in the same play. | `_score_submitted_this_run` in `PlatformBridge`. | Device/runtime duplicate-trigger test required. |
| GC-04 | ⛔ | Game profile and leaderboard must exist in console. | No console evidence; official docs warn `LeaderBoard not found` / `INVALID_CATEGORY`. | User/Toss console action. |
| GC-05 | ⛔ | Promise-based official APIs must be awaited/bridged correctly. | Current bridge stores `var r = window.TossBridge.getUserKeyForGame()` and `submitGameCenterLeaderBoardScore(...)` inside synchronous `JavaScriptBridge.eval()`. | Dedicated platform bridge refactor/validation before done status. |
| GC-06 | ⚠️ | Leaderboard open must be user-triggered and return safely. | MainMenu/PauseMenu call `PlatformBridge.open_leaderboard()`; visibility pause exists. | Toss shell device QA. |

## Monetization / Ads

| ID | Status | Requirement | Evidence | Blocker / Next Action |
|---|---|---|---|---|
| AD-01 | ✅ | No fake ad UI, placeholder ad boxes, or real ad SDK implementation now. | `toss_ads_bridge.gd` returns false; no placeholder slot found. | Preserve until ads setup exists. |
| AD-02 | ⛔ | Business/settlement and Toss Ads console setup required before real ads. | User stated ads/business setup is not ready. | `NEEDS_BUSINESS_REGISTRATION`, `NEEDS_OFFICIAL_ADS_SETUP`. |
| AD-03 | ⛔ | Persistent top banner remains user-desired but risky. | Official banner recommends fixed `96px` container; current game has tight `390x844` HUD/control layout. | Verdict: `USER_DESIRED_BUT_REQUIRES_LAYOUT_REDESIGN_AND_OFFICIAL_ADS_QA`. |
| AD-04 | ⚠️ | Death/game-over ad may be post-run interstitial or rewarded continue only. | Official fullscreen/reward API supports transition-point use after `load -> show`. | Decide format after console/business setup. |
| AD-05 | ⛔ | Reward is granted only on `userEarnedReward`. | Official `IntegratedAd` event model. | No rewarded code until official setup exists. |
| AD-06 | ⚠️ | Audio/background/cooldown/frequency must be QA-gated. | Official Ads QA checklist. | Real ad device QA later. |

## Web / Export / Bundle

| ID | Status | Requirement | Evidence | Blocker / Next Action |
|---|---|---|---|---|
| WEB-01 | ⚠️ | WebView pinch zoom and overscroll controls must be enforced. | `export_presets.cfg` head include has `user-scalable=no`, `touch-action:none`, `overscroll-behavior:none`. | Validate in Toss WebView. |
| WEB-02 | ⚠️ | Current project is Godot Web, not standard Apps-in-Toss Web Framework. | No `package.json` or `granite.config.ts` found. | Treat `project-validator` findings as mapping guidance, not direct blocker. |
| WEB-03 | ❌ | Final export and `.ait` packaging must be produced. | No current final `.ait`. | Dedicated export pass after branding/license checks. |
| WEB-04 | ⚠️ | Root duplicate assets should not bloat final bundle. | Existing docs track root duplicates. | Audit before export; do not delete without approval. |

## Architecture / Anti-Spaghetti

| ID | Status | Requirement | Evidence | Blocker / Next Action |
|---|---|---|---|---|
| ARCH-01 | ✅ | Platform bridge owns Toss/Game Center/Ads wrappers. | `scripts/autoload/platform_bridge.gd`, `scripts/platform/*`. | Preserve ownership. |
| ARCH-02 | ✅ | SaveManager owns best score and game user key. | `scripts/autoload/save_manager.gd`. | Preserve ownership. |
| ARCH-03 | ⚠️ | UI opens leaderboard but must not submit scores. | MainMenu/PauseMenu call open; GameRoot submits. | Keep boundary in platform pass. |
| ARCH-04 | ⛔ | Ads must not live in gameplay/domain files. | No ad code in gameplay/domain. | Preserve in all future prompts. |
| ARCH-05 | ⚠️ | Runtime UI builders are maintainability risks only. | Existing docs classify GameOver/WeaponChoice builders. | Do not refactor before release unless bug-driven. |
| ARCH-06 | ⛔ | Do not broad-refactor combat/domain/progression for release platform work. | User guardrails. | Keep untouched. |

## Phase 2 Decision

The repo has release-planning documents, so Phase 2 does not stop for missing checklist files.

However, the checklist is not 100% complete. It contains external blockers and one code-architecture blocker:

- external: console, game profile, leaderboard, business/ads setup, QR/device QA, branding/license proof.
- code/bridge: official Game Center APIs are Promise-based, while the current Godot bridge does not await Promises.
