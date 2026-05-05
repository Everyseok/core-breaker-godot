# App-in-Toss Current Release Feasibility Report

Date: 2026-05-04  
Repo: `/Volumes/junseokism_usb3.0/game/game_junseokism.ver1`  
Branch: `feature/design-rebuild-apply-pass`  
Scope: release/readiness documentation plus safe branding-asset canonicalization only. No gameplay, UI layout, export, ads, or Game Center implementation changed.

## Executive Summary

**Can this game be submitted to App-in-Toss today? No.**

The project is structurally close enough to keep preparing for release, but it is not review-ready because several release gates are still unproven in the real Toss environment. The app is **not registered in the App-in-Toss developer console yet**, so console-dependent items are marked as `NEEDS_CONSOLE_ACCESS` rather than code failures. The biggest blockers are Toss console registration/QR test, final `.ait` export validation, app icon/name/logo consistency, asset/font license proof, visible safe-area/device QA, and Game Center runtime validation inside the Toss shell.

What is already relatively safe:

- The game launches through a `MainMenu` and starts gameplay only after the user taps `게임 시작`.
- The Web export preset has viewport, pinch-zoom, touch-action, and overscroll controls.
- Save/best-record ownership is centralized in `SaveManager.get_best_record_value()`.
- Platform lifecycle scaffolding exists for visibility pause/resume, sound mute/restore, close/back handling, user key, leaderboard submit, and leaderboard open.
- Ads are not implemented and should remain a future integration area until business registration, Toss Ads setup, and official ad-unit configuration are ready. This is not a code failure.
- Current dry-run export evidence shows a historical 36 MB unpacked Web export, below the official 100 MB limit.

What blocks release:

- No App-in-Toss console app registration yet, so review flow, private QR/device test, Game Center profile, ads setup, icon/name/logo registration, and production shell validation are blocked by `NEEDS_CONSOLE_ACCESS`.
- No confirmed Toss QR/private-test run after the latest UI/font/asset changes.
- No current final `.ait` export candidate; the 36 MB dry run predates several root images/font assets.
- App name/icon/logo consistency is unresolved: `project.godot` still uses `game_junseokism.ver1`, while player-facing/title art may use `코어 브레이커` or prior `코어 수호대`. A final exact `600x600` icon candidate now exists, but final console approval is still user-side.
- The root-level duplicated font/image assets can inflate export size or create confusing asset ownership.
- Game Center bridge calls are structurally wired, but official APIs are Promise-based and must be validated/refined in the Toss shell before relying on them.
- Asset/font/background licenses and BGM/SFX license proof are not documented.
- Sentry/monitoring is not integrated.
- Ads/business setup is not ready; banner/interstitial planning should be documented, but no fake ad UI, empty ad slot, IntegratedAd, or Toss Ads Pixel should be added in this audit phase.

## Sources Checked

### Official Docs

Source type: `OFFICIAL_DOC`.

- [llms.txt](https://developers-apps-in-toss.toss.im/llms.txt)
- [Game release checklist](https://developers-apps-in-toss.toss.im/checklist/app-game.html)
- [Non-game release checklist](https://developers-apps-in-toss.toss.im/checklist/app-nongame.html)
- [Deploy/review](https://developers-apps-in-toss.toss.im/development/deploy.html)
- [Toss app test](https://developers-apps-in-toss.toss.im/development/test/toss.html)
- [Sandbox test](https://developers-apps-in-toss.toss.im/development/test/sandbox.html)
- [Resolution](https://developers-apps-in-toss.toss.im/design/resolution.html)
- [Graphics/resources](https://developers-apps-in-toss.toss.im/design/resources.html)
- [UX writing](https://developers-apps-in-toss.toss.im/design/ux-writing.html)
- [Game Center intro](https://developers-apps-in-toss.toss.im/game-center/intro.html)
- [Game Center develop](https://developers-apps-in-toss.toss.im/game-center/develop.html)
- [Game Center QA](https://developers-apps-in-toss.toss.im/game-center/qa.html)
- [getUserKeyForGame](https://developers-apps-in-toss.toss.im/bedrock/reference/framework/%EA%B2%8C%EC%9E%84/getUserKeyForGame.html)
- [submitGameCenterLeaderBoardScore](https://developers-apps-in-toss.toss.im/bedrock/reference/framework/%EA%B2%8C%EC%9E%84/submitGameCenterLeaderBoardScore.html)
- [Ads intro](https://developers-apps-in-toss.toss.im/ads/intro.html)
- [Ads develop](https://developers-apps-in-toss.toss.im/ads/develop.html)
- [Ads QA](https://developers-apps-in-toss.toss.im/ads/qa.html)
- [Sentry monitoring](https://developers-apps-in-toss.toss.im/learn-more/sentry-monitoring.html)
- [WebView debugging](https://developers-apps-in-toss.toss.im/learn-more/debugging-webview.html)
- [Sensitive content caution](https://developers-apps-in-toss.toss.im/intro/_caution-sensitive.html)
- [AI chat caution](https://developers-apps-in-toss.toss.im/intro/_caution-aichat.html)
- [Politics caution](https://developers-apps-in-toss.toss.im/intro/_caution-politics.html)

Official requirements summarized:

- Game guide: first screen within 10 seconds, user-controlled sound, close/exit path, Safe Area including Dynamic Island, no forced entry bottom sheet, persisted play records, exit confirmation, no ads on intro/loading/cutscene/popup modal, and correct game score/stage flows.
- Deploy/test: review is available only after at least one test; unpacked bundle must be 100 MB or less; large image/audio/video resources should be separated, CDN-hosted, or lazy-loaded if needed.
- Resolution: game miniapps must be fullscreen, avoid WebView gaps/letterboxing, and handle notch/Dynamic Island with Safe Area.
- Game Center: score submission should happen after game completion, not app entry; duplicate submit must be prevented; game profile readiness matters; Toss app 5.221.0+ is required for leaderboard APIs; `getUserKeyForGame` is game-category-only, returns a game-specific hash, and requires Toss app 5.232.0+.
- Ads: do not modify/mislead ad UI, do not mutate SDK click/impression logic, do not force redirect/dead-end flows, do not place ATF first-screen ads, avoid temporary screens such as tutorial/loading/cutscene/system popup/permission modal, keep ads away from primary interactive UI, and real-device QA must check audio/background/cooldown. The docs describe banner ads as fixed or inline areas and interstitial/rewarded ads as preloaded then shown at appropriate transition points.
- Sentry: JavaScript/WebView error monitoring is recommended; native tracking is not supported in App-in-Toss and must be disabled if using the documented React Native setup.

### Local Skill / Rejection Cases

Source type: `LOCAL_SKILL / experience-based`.

Found:

- `/Users/junseokism/.claude/skills/appsintoss-nongame-launch-checklist-by-robin/SKILL.md`
- `/Users/junseokism/.claude/skills/appsintoss-nongame-launch-checklist-by-robin/references/rejection-cases.md`
- `/Users/junseokism/.claude/skills/appsintoss-nongame-launch-checklist-by-robin/references/external-link-rules.md`

Important limitation: the skill is for non-game Web/React Native miniapps. Use it only as rejection-case support, not as the source of truth for this Godot game.

Experience-based items relevant to this game:

- App name/logo must be consistent with console registration.
- Back/exit behavior must not trap the user.
- Pinch zoom and unintended horizontal scroll are common rejection risks.
- External app install or external-link dependency is risky.
- TDS/custom Toss resources are recommended for consistency but not proven mandatory for a custom Godot game.

## Current Compliance Matrix

| Category | Status | Severity | Source | Evidence | Missing / Risk | Next Action | Owner |
|---|---:|---|---|---|---|---|---|
| Toss console dependency | `[?]` | Critical | LOCAL_REPO / USER_CONTEXT | User says app is not registered in console yet | Console-only setup cannot be validated locally | Register app before marking console rows done | User / Toss Console |
| Release review flow | `[?]` | Critical | OFFICIAL_DOC | Deploy docs require test before review | `NEEDS_CONSOLE_ACCESS`; no proof of Toss console test completion or review-ready version | Run sandbox + Toss QR private test before review | User / Toss Console / Device QA |
| `.ait` final export | `[ ]` | Critical | OFFICIAL_DOC / LOCAL_REPO | `export_presets.cfg`, old `exports/toss_web_dry_run` | No current `.ait`; old dry run predates new root assets | Produce fresh export only when explicitly requested, then decompress/measure | Codex / User |
| 100 MB bundle policy | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | Old dry run `36M`; assets `5.3M`; `.godot/imported` `7.0M` | Current root image/font duplicates likely change final export size | Re-export and measure after asset cleanup/license pass | Codex |
| Root duplicate assets | `[~]` | Medium | LOCAL_REPO | `game_ui_kr.ttf` and `assets/fonts/game_ui_kr.ttf`; root `A.png` | Duplicate font and possibly unused `A.png` can inflate export and confuse ownership | Audit references and remove only in a later asset-cleanup prompt | Codex |
| Traffic / CORS | `[~]` | Medium | LOCAL_REPO / OFFICIAL_DOC | No app HTTP code found; TossBridge calls only | Future CDN/API/ads/Game Center still need Toss-shell/live-domain validation | Keep assets local for MVP; document allowed origins if CDN/API added | Codex / Toss Console |
| App name/logo consistency | `[?]` | Critical | OFFICIAL_DOC / LOCAL_SKILL / LOCAL_REPO | `project.godot` name `game_junseokism.ver1`; UI/title art naming conflict risk | `NEEDS_CONSOLE_ACCESS`; console name/icon/logo unknown; current title art may say `코어 브레이커` | Lock one public title and 600x600 icon before submission | User |
| Toss design resources | `[?]` | Medium | OFFICIAL_DOC / LOCAL_SKILL | Graphics docs allow direct icon creation guidance; local skill says TDS recommended | Not proven mandatory for custom game art, but resource/license rules apply | Use custom game art with documented ownership/license | User / Codex |
| Safe area / viewport | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | `root_ui.gd`, `project.godot`, `export_presets.cfg` | Needs real device/Dynamic Island validation | QR/device safe-area test on iOS/Android | Device QA |
| Pinch zoom / touch behavior | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | `user-scalable=no`, `touch-action:none`, `overscroll-behavior:none` | Structural only; no Toss WebView validation | Test pinch/scroll on QR build | Device QA |
| Main flow | `[~]` | High | LOCAL_REPO | `MainMenu.start_game()`, `GameRoot.start_game()` | Visible screenshot/device flow still pending | Run launch -> start -> game over smoke test | Device QA |
| Pause / sound / restart | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | `PauseMenu`, `AudioManager`, `PlatformBridge.visibilitychange` | No physical device/background validation | Test pause/sound/restart/background/foreground | Device QA |
| Save/best score | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | `SaveManager.get_best_record_value()`, `user://save.json` | Persistence after relaunch in Toss shell not proven | Test save/relaunch in QR build | Device QA |
| Game Center user key | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | `PlatformBridge.fetch_game_user_key()` | `NEEDS_CONSOLE_ACCESS`; official API is Promise-based; current sync bridge path may not await correctly | Validate/refactor async bridge in a dedicated platform prompt after console setup exists | Codex / Toss Console |
| Leaderboard submit | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | `game_root.gd` submits only on game over/max clear | Toss shell not validated; async Promise handling risk | Dedicated Game Center runtime QA/refactor prompt | Codex / Device QA |
| Leaderboard open | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | MainMenu ranking button calls `PlatformBridge.open_leaderboard()` | `NEEDS_CONSOLE_ACCESS`; game profile dependency unknown | Test only after console profile/leaderboard setup | User / Toss Console |
| Ads / monetization | `[ ]` | Medium | OFFICIAL_DOC / LOCAL_REPO / USER_CONTEXT | `PlatformBridge.show_ad()` stub only | `NOT_IMPLEMENTED / FUTURE`; `NEEDS_BUSINESS_REGISTRATION`, `NEEDS_CONSOLE_ACCESS`, `NEEDS_OFFICIAL_ADS_SETUP` | Document safe/forbidden timings now; do not add fake UI or slots | User / Business Registration |
| Sentry / monitoring | `[ ]` | Medium | OFFICIAL_DOC / LOCAL_REPO | No Sentry references in runtime scripts | No JS/WebView error monitoring | Add later in export shell or hosting wrapper | Codex |
| Asset/license proof | `[?]` | Critical | LOCAL_REPO / UNKNOWN | `mainbackground.png`, `basicbackground.png`, `game_ui_kr.ttf` | No license/ownership docs found | Create `docs/legal/asset_licenses.md` with source/proof | User |
| BGM/SFX license | `[?]` | Medium | LOCAL_REPO / UNKNOWN | No `.wav`, `.mp3`, `.ogg` files found | No production audio shipped yet; future audio needs proof | Keep no-audio MVP or document audio licenses before import | User |
| Architecture cleanliness | `[~]` | Medium | LOCAL_REPO | Single MainMenu/PauseMenu/HUD scene tree found | Runtime UI builders remain in GameOver/WeaponChoice; not release blocker | Defer cleanup unless visual bugs appear | Codex |
| Domain/gameplay stability | `[~]` | High | LOCAL_REPO | Domain files already dirty from prior passes | This audit should not change gameplay/domain | Keep documentation-only boundary | Codex |
| Device QA | `[ ]` | Critical | OFFICIAL_DOC / LOCAL_REPO | `docs/NEXT_STEP.md` says visible QA pending | No current real device/Toss QR signoff | Run documented QA matrix | User / Device QA |

## Bundle / Resource Report

Current measured sizes:

| Path | Size | Notes |
|---|---:|---|
| `exports/toss_web_dry_run` | `36M` | Historical dry run; not final current export |
| `exports/toss_web_dry_run/index.wasm` | `36M` | Godot Web engine baseline |
| `exports/toss_web_dry_run/index.pck` | `110K` | Old packed game resources from dry run |
| `assets` | `8.0M` | Includes canonical font, app-logo source copy, and final `600x600` icon candidate |
| `.godot/imported` | `7.0M` | Editor/import cache, not directly shipped as-is |
| `assets/fonts/game_ui_kr.ttf` | `5.3M` | Canonical UI font path |
| `assets/branding/app_logo.png` | `2.1M` | Canonical source logo path; source image is `1254x1254` |
| `assets/branding/app_icon_600.png` | `639K` | Final exact `600x600` console-ready candidate, pending user approval |
| `game_ui_kr.ttf` | `5.3M` | Root duplicate of font |
| `app_logo.png` | `2.1M` | Root source copy retained intentionally; existing root `.import` still points here |
| `mainbackground.png` | `2.1M` | Title screen background |
| `basicbackground.png` | `1.7M` | Gameplay background |
| `A.png` | `1.9M` | Root image; current active use not proven |

Practical risk:

- The official limit is 100 MB unpacked. The previous dry run has large headroom, but it was produced before the new root images/font imports.
- `export_filter="all_resources"` can include imported root resources, so duplicate root assets should be cleaned before a final `.ait`.
- No CDN/lazy loading is needed yet if the fresh export stays under 100 MB, but this must be rechecked after final art/audio.

## Traffic / Network / CORS Report

Current runtime network posture:

- No gameplay HTTP/fetch/API code was found in local scripts.
- Current app traffic risk is low because assets appear local and Game Center calls use Toss shell bridge wrappers.
- CORS/origin risk becomes relevant if future CDN assets, custom backend leaderboard, Sentry, or ads/pixel/network APIs are added.
- Sandbox docs note that HTTP may work in sandbox but live supports HTTPS only; future external calls must be HTTPS and console/live-origin validated.

## Design / Resource Report

Toss design resources are **not proven mandatory** for this custom game. Official graphics docs describe Toss-provided resource usage rules and direct icon creation guidance, while the local non-game skill says TDS is recommended but not directly mandatory. For this Godot game, the practical release requirement is consistency and safety:

- Lock one public game name.
- Use `res://assets/branding/app_logo.png` as the canonical source logo path.
- Use `res://assets/branding/app_icon_600.png` as the final exact `600x600` App-in-Toss console icon candidate.
- The source `app_logo.png` remains a valid `1254x1254` PNG and is preserved as the higher-resolution branding source.
- Keep the root `res://app_logo.png` copy for now because the root `.import` exists and deletion was not approved in this pass.
- Final user approval is still required before treating `app_icon_600.png` as the locked console icon.
- Ensure title-screen image, project config, metadata, and visible UI do not conflict.
- Document ownership/license for `app_logo.png`, `app_icon_600.png`, `mainbackground.png`, `basicbackground.png`, `A.png`, and `game_ui_kr.ttf`.
- Keep gameplay art custom and clearly not using restricted Toss graphics outside allowed contexts.

Current naming risk:

- `project.godot` uses `game_junseokism.ver1`.
- Earlier UI/title work referenced `코어 수호대`.
- User-reported title-screen background may contain `코어 브레이커`.
- This must be resolved before review.

## Toss Console Dependency

Current status:

- App registration status: not done. Source: `USER_CONTEXT`.
- Game profile status: not done. Source: `USER_CONTEXT / OFFICIAL_DOC`.
- Leaderboard console dependency: required before reliable Game Center validation. `PlatformBridge` can keep its wrapper code, but real profile/leaderboard IDs and Toss-shell behavior cannot be proven locally.
- Ads console/business dependency: required before real ad implementation. Do not implement `IntegratedAd`, Toss Ads Pixel, production ad IDs, or ad UI placement before business registration and official setup are clear.
- App icon/name/logo registration dependency: required before review. The repo can prepare assets and metadata docs, but final console values are user/Toss-console work.
- QR/device test dependency: required before marking review-flow, WebView, safe-area, Game Center, and lifecycle rows complete.

What Codex can do now:

- Prepare checklists, metadata templates, asset-license manifests, export hygiene audits, and a future Ads Planning prompt.
- Keep PlatformBridge wrappers isolated and ready for a later Toss-shell validation pass.
- Document allowed/forbidden ad timings without adding UI slots or SDK calls.

What the user must do later:

- Register the app in the App-in-Toss console.
- Create/confirm game category/profile and leaderboard setup.
- Complete business/settlement/Toss Ads setup if monetization is desired.
- Provide final app name, app icon/logo, and license proof.
- Run real Toss QR/device QA after an export candidate exists.

## Toss Console Registration Next Step

This is the immediate next release step after the current ranking UX shell work.

- App registration in the App-in-Toss developer console is required.
- The app must be registered with the correct game category/profile before Game Center can be validated reliably.
- Leaderboard / Game Center setup is required before real leaderboard open, score submit, and user-key validation can be trusted.
- A Toss QR private test is required before review readiness can be claimed.
- `getUserKeyForGame()` and leaderboard submit/open cannot be fully validated before console registration and profile setup exist.
- Missing console registration is `NEEDS_CONSOLE_ACCESS`, not a code failure.

## Game Center Report

Current implementation:

- `PlatformBridge.fetch_game_user_key()` calls `window.TossBridge.getUserKeyForGame()`.
- `PlatformBridge.submit_leaderboard_score()` is called only from `GameRoot._on_game_over()` and `_on_max_level_cleared()`.
- Duplicate submit is blocked by `_score_submitted_this_run`, reset on `GameState.game_started`.
- `PlatformBridge.open_leaderboard()` is user-triggered from MainMenu ranking and PauseMenu ranking only.
- When the Toss bridge or Game Center open path is unavailable, `PlatformBridge` emits a Korean fallback message and both MainMenu and PauseMenu show it in their local status labels instead of silently failing.
- `SaveManager` stores `game_user_key` and best record data locally.
- Return safety is structurally staged: `PlatformBridge` mutes audio on background, restores it on foreground, and only auto-unpauses if it was the system that paused the tree. That means opening leaderboard from PauseMenu keeps gameplay paused on return.

Release risks:

- Official docs show Game Center APIs as Promise-returning framework calls. Current Godot bridge code uses synchronous `JavaScriptBridge.eval()` and does not explicitly await Promises.
- Toss console game category/profile/leaderboard setup is not locally verifiable.
- `getUserKeyForGame` can return `INVALID_CATEGORY` until the app is registered as a game category.
- Leaderboard may fail before game profile/miniapp approval.

Conclusion: structurally partial, not release-validated.

Current staging status:

- Ranking UX shell: `PARTIAL` — user action only, Korean fallback copy present in MainMenu/PauseMenu, no fake local leaderboard.
- PauseMenu ranking button: `STRUCTURALLY_DONE`.
- Leaderboard return/back handling: `STAGED`; real Toss close/back behavior is still `NEEDS_DEVICE_QA`.
- Real leaderboard-open validation: `NEEDS_CONSOLE_ACCESS` and `NEEDS_DEVICE_QA`.
- Real `getUserKeyForGame()` and `submitGameCenterLeaderBoardScore()` behavior: `NEEDS_CONSOLE_ACCESS` and `NEEDS_DEVICE_QA`.

## Ads / Monetization Readiness

Current implementation status:

- Status: `NOT_IMPLEMENTED / FUTURE`.
- Severity: Medium by default. Raise to High only if monetization is required before launch.
- Blocker type: `NEEDS_BUSINESS_REGISTRATION`, `NEEDS_CONSOLE_ACCESS`, `NEEDS_OFFICIAL_ADS_SETUP`.
- Current code: `PlatformBridge.show_ad(_ad_unit)` is a stub.
- Toss Ads Pixel: not implemented and intentionally deferred.

Official-doc requirements to preserve:

- Ads must remain clearly identifiable as ads; do not disguise ad UI or arbitrarily modify labels, CTA, color, size, SDK click/impression behavior, refresh, or redirect behavior.
- The game checklist says in-app ads are not shown on intro/loading/cutscene/popup modal temporary screens.
- The ads development guide warns against ATF first-screen ads, dead-end/back-button blocking flows, forced redirects, hidden/overlapped ad DOM, and core-flow interruption.
- Banner ads use fixed or inline areas and must not overlap primary interactive UI. The docs describe recommended banner heights for list/feed types, but this game has no safe gameplay spare area today.
- Interstitial/rewarded ads are loaded ahead of time and shown at appropriate transition points; QA must confirm return-to-miniapp, audio pause/resume, close behavior, cooldown/frequency limits, and background/foreground behavior on real devices.

Forbidden placements for this game:

- App intro/title loading or first-screen ATF placement.
- Active gameplay field, joystick/control dock, HUD, weapon choice modal, pause modal content, forced modal, cutscene/loading/permission/system popup.
- Any ad surface that changes or blocks gameplay interaction, disguises ads as game rewards, or forces external redirects.

Safe candidate placements for later:

- Between-run transition after game over or max-clear result.
- Optional post-run/retry moment where the user has completed a play session.
- Pause or resume transition only if it does not cover controls misleadingly, does not trap the user, and passes real-device QA.
- Rewarded continue only if the user explicitly chooses it and reward handling follows official rewarded-ad completion rules.

Should placeholder ad zones be added now?

- Recommendation: **No.**
- Empty ad slots or fake ad boxes can hurt gameplay UX, consume scarce 390x844 portrait space, confuse review, and create the appearance of hidden/placeholder advertising before official setup exists.
- Banner ads need real fixed/inline layout constraints. This game currently relies on a compact top HUD and lowered control dock; reserving large permanent ad space now would likely reduce readability or control ergonomics without monetization benefit.
- Prepare architecture hooks only: keep a single future `PlatformBridge` ad owner, document allowed timings, and create a separate Ads Planning prompt after console/business setup.

Required user actions before implementation:

- Complete Toss business/settlement registration if ads are desired.
- Register/configure ads in the App-in-Toss/Toss Ads console and confirm official ad-unit/setup flow.
- Decide whether banner, interstitial/fullscreen, rewarded, or ad-free MVP is the intended launch strategy.
- Provide permission to implement real SDK/API integration after official credentials/test IDs and policy decisions exist.

## Ad Slot Decision

Current decision:

- Ads remain `NOT_IMPLEMENTED / FUTURE`.
- Placeholder ad boxes should not be added now.
- Permanent top-banner space should not be reserved now.
- A persistent top fixed banner is **not recommended now** for this game.

Why the top persistent banner is deferred:

- Officially, fixed top/bottom banner placement can be possible only if it does not overlap or degrade primary interactive UI.
- This game uses a tight `390x844` portrait layout with a top HUD and bottom controls already occupying the critical play envelope.
- A fixed banner around `96px` high would likely reduce readability at the top and harm control/gameplay ergonomics at the bottom.
- The project should not reserve empty ad space before real ad type, official test IDs, business setup, and real-device QA exist.

Safer future ad candidates:

- game-over result
- max-clear result
- between-run transition
- explicit rewarded continue chosen by the user

## Monitoring Report

Current status:

- No Sentry integration found.
- No production crash/error monitoring plan is wired into the exported shell.

Recommendation:

- Add JavaScript/WebView monitoring before production launch if the release schedule allows it.
- If Sentry is used, follow official guidance to avoid unsupported native tracking and handle sourcemap upload manually where needed.

## Refactor / Spaghetti Report

Current clean ownership:

- `MainMenu`, `PauseMenu`, and `HUD` each have one active scene-owned system.
- `ui_style.gd` owns the UI font path.
- `SaveManager` owns best-record source of truth.
- `PlatformBridge` owns Toss/platform wrappers.
- `WeaponProfile` and visual factories centralize weapon identity/visuals.
- Domain/combat rules remain separate from UI and VFX ownership.

Release-risk hotspots:

- Game Center bridge Promise handling is the most important platform risk.
- `GameOverScreen` still builds a card at runtime; `WeaponChoicePanel` builds UI nodes at runtime. These are maintainability issues, not immediate release blockers.
- Root duplicate assets and `export_filter="all_resources"` can ship unused/imported resources.
- Title/name/icon consistency is unresolved.
- Device QA is still the largest release gate.

What should not be refactored before release:

- Damage/HP/progression/wall/projectile mechanics.
- Weapon VFX/guardian/HUD layout unless visible QA finds a blocking issue.
- Broad UI architecture; focus only on release gates.

## Next Action Plan

1. **Toss title/icon/name lock prompt**: choose one public title, update metadata docs, define required 600x600 icon deliverable.
2. **Asset/license manifest prompt**: create `docs/legal/asset_licenses.md` for backgrounds, font, icon, and future audio.
3. **Export hygiene prompt**: audit root duplicate assets and export filters; remove only proven-unused duplicates after user approval.
4. **Fresh Web export prompt**: produce a current Web export and unpacked-size report; do not upload.
5. **Game Center async bridge prompt**: inspect official Promise API shape and refactor PlatformBridge wrappers to await correctly if needed.
6. **Toss console checklist prompt**: list exact console setup values needed for game category, leaderboard, icon, name, and QR test.
7. **Device QA script prompt**: create a step-by-step manual QA sheet for iOS/Android/Toss QR.
8. **Safe-area/viewport validation prompt**: verify 390x844, Dynamic Island, bottom gesture bar, pinch zoom, overscroll, and touch ergonomics.
9. **Sentry planning prompt**: design minimal WebView JS error monitoring for Godot Web export without implementing until approved.
10. **Ads planning prompt**: document banner/interstitial/rewarded options, forbidden placements, cooldown/audio/background QA, and console/business requirements without adding fake UI, Pixel, or real ads.
11. **Final release checklist signoff prompt**: re-run matrix after QR/device/export/license evidence exists.

## What Was Not Changed

- No code changed.
- No gameplay math changed.
- No UI layout changed.
- No assets moved/deleted.
- No `.ait` export produced.
- No ads, Toss Ads Pixel, Game Center refactor, Sentry integration, or Toss console work implemented.
