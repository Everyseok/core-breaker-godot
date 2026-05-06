# Toss Apps-in-Toss Official Spec Mapping

Date: 2026-05-06
Repo: `/Volumes/JUNSEOKISM_USB3.0/game/game_junseokism.ver1`
Branch inspected: `feature/android-debug-apk-artifact`

This document is the Phase 1 output for the Apps-in-Toss registration pass. It uses the installed Toss `ax` MCP documentation tools, the local Apps-in-Toss Codex skills, and official Developer Center content.

## Source Inventory

| Source | Evidence | Use |
|---|---|---|
| Toss MCP via `ax mcp start` | `docs/toss-mcp-skills-inventory.md` | Official docs search/retrieval, not runtime SDK execution |
| `docs-search` skill | `/Users/junseokism/.codex/skills/docs-search/SKILL.md` | Runs `ax` against Apps-in-Toss docs |
| `project-validator` skill | `/Users/junseokism/.codex/skills/project-validator/SKILL.md` | Web/RN/Unity-style validation references; Godot must be mapped carefully |
| Official aggregated docs | `https://developers-apps-in-toss.toss.im/development/llms.html` and `llms-full.txt` | Broad Developer Center content |
| Official game checklist | `https://developers-apps-in-toss.toss.im/checklist/app-game.html` | Release gate source |
| Official deploy docs | `https://developers-apps-in-toss.toss.im/development/deploy.html` | Review, bundle, test, rollback flow |
| Official Game Center docs | `https://developers-apps-in-toss.toss.im/game-center/develop.html`, `https://developers-apps-in-toss.toss.im/game-center/qa.html` | Ranking and QA rules |
| Official game user key API | `https://developers-apps-in-toss.toss.im/bedrock/reference/framework/게임/getUserKeyForGame.html` | Ranking identity source |
| Official leaderboard API | `https://developers-apps-in-toss.toss.im/bedrock/reference/framework/게임/submitGameCenterLeaderBoardScore.html` | Score submission source |
| Official ad docs | `https://developers-apps-in-toss.toss.im/ads/develop.html`, `https://developers-apps-in-toss.toss.im/ads/qa.html`, `BannerAd`, `IntegratedAd` references | Monetization constraints |
| Official WebView/safe-area docs | `https://developers-apps-in-toss.toss.im/bedrock/reference/framework/속성`, `SafeAreaInsets` docs | Viewport, pinch zoom, safe area |

## Official Requirements That Directly Affect This Godot Game

| Area | Official Requirement | Mapping To Current Game |
|---|---|---|
| Release/test | Review request should happen after at least one test. Bundle upload has an unpacked `100MB` limit; large resources should be separated or lazy-loaded if needed. | Current historical Web dry run was under the limit, but there is no current final `.ait`; QR/device test is still missing. |
| First screen / flow | Game release checklist includes first-screen, sound, navigation, close/exit, safe-area, persistence, and no trapped flow checks. | MainMenu-first flow exists structurally, but no current Toss-shell timing evidence exists. |
| WebView gestures | Pinch zoom should be disabled except special cases; viewport meta and WebView props must avoid scroll/zoom regressions. | `export_presets.cfg` injects viewport/touch/overscroll controls, but QR/device validation is still required. |
| Safe Area | Safe Area insets exist to keep content clear of notch/home-indicator/system UI. | Current Godot canvas is `390x844`; actual safe-area correctness needs physical iOS/Android screenshots. |
| Game identity | `getUserKeyForGame()` is game-category-only, requires Toss app `5.232.0+`, returns a Promise of `{ type: 'HASH', hash }`, `'INVALID_CATEGORY'`, `'ERROR'`, or `undefined`. | `SaveManager` can persist `game_user_key`; `PlatformBridge` has a wrapper, but current code must not be considered validated until Promise handling and Toss shell QA are proven. |
| Score submission | `submitGameCenterLeaderBoardScore({ score })` is Promise-based, requires Toss app `5.221.0+`, and should be called after play completion, not on entry. | `GameRoot` triggers submit on game over / max clear only; duplicate guard exists in `PlatformBridge`; runtime Promise behavior is not validated. |
| Leaderboard open | `openGameCenterLeaderboard()` is user-triggered, version-gated, and can background the miniapp; state should survive foreground return. | MainMenu/PauseMenu open ranking via `PlatformBridge`; lifecycle pause/restore exists structurally; Toss shell QA remains required. |
| Banner ads | WebView `TossAds.initialize()` then `TossAds.attachBanner()`; Toss app `5.241.0+`; fixed list/banner container recommends `height: 96px`, `width: 100%`, empty container, cleanup via `destroy()`. | Persistent top banner is user-desired but risky with current HUD/gameplay layout; do not add fake slot or placeholder now. |
| Fullscreen/reward ads | `loadFullScreenAd()` then `showFullScreenAd()`; show only after loaded event; Toss app `5.247.0+` for Ads 2.0 ver2, `5.227.0+` for older fallback; reward is valid only on `userEarnedReward`. | Death/game-over ad can only be a future post-run interstitial or rewarded continue candidate after business/console setup. |
| Ads policy | No misleading ad UI, no SDK event mutation, no forced redirects/dead-end structures, no hidden/overlapped ads, no first-screen surprise ads. | Current repo correctly has no ads, no fake ad UI, and no placeholder ad box. |
| Ads QA | Real-device QA should verify load/show, return to miniapp, audio pause/resume, dismiss path, cooldown/frequency, reward-only-on-complete, and logs/settlement identifiers. | No ads can be marked done before business setup, console ad units, and device QA exist. |
| Sentry / monitoring | Official monitoring guidance recommends WebView/JS error visibility before launch. | Sentry is not integrated; this is a release risk but not a gameplay implementation requirement. |

## Current Repo Mapping

| Component | Evidence | Spec Alignment |
|---|---|---|
| Godot project | `project.godot` uses Godot `4.6`, GL Compatibility, `390x844`, main scene `scenes/main/main.tscn`. | Acceptable as a custom game WebView target, but not a standard `@apps-in-toss/web-framework` project. |
| Web export | `export_presets.cfg` has `Toss Web` preset with viewport/touch/overscroll injection. | Structural partial; final `.ait` and QR validation missing. |
| Platform bridge | `scripts/autoload/platform_bridge.gd` owns visibility, close/back, user key, leaderboard submit/open. | Correct ownership, but Promise-based official APIs are currently called through synchronous `JavaScriptBridge.eval()` strings. |
| Score trigger | `scripts/gameplay/game_root.gd:64-75` submits only on game over or max clear. | Correct trigger timing structurally. |
| Save ownership | `scripts/autoload/save_manager.gd` owns best score and `game_user_key`. | Correct persistence owner structurally. |
| Ads adapters | `scripts/platform/ads/toss_ads_bridge.gd` returns false for all readiness. | Correct conservative posture; not implemented. |
| Leaderboard adapters | `scripts/platform/leaderboard/toss_game_center_bridge.gd` returns false for readiness. | Correct conservative posture outside live `PlatformBridge`. |

## Implementation Gate Decision

Phase 1 passes as documentation/spec collection.

Phase 4 implementation must not start yet because:

- App-in-Toss console app registration is not done.
- Game profile and leaderboard are not configured.
- Ads business/settlement and official ad unit setup are not done.
- Browser Use IAB automation failed in this Codex session; official docs were checked through `ax`/official text instead.
- Current Game Center bridge uses synchronous `JavaScriptBridge.eval()` for Promise-returning official APIs, so it needs a dedicated bridge validation/refactor pass before any checklist row can be marked complete.
- A persistent top banner can collide with the current `390x844` HUD/gameplay/safe-area constraints and remains `USER_DESIRED_BUT_REQUIRES_LAYOUT_REDESIGN_AND_OFFICIAL_ADS_QA`.
