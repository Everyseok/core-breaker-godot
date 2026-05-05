# App-in-Toss Monetized Game Release Master Checklist

Date: 2026-05-04  
Repo: `/Volumes/junseokism_usb3.0/game/game_junseokism.ver1`  
Branch: `feature/design-rebuild-apply-pass`  
Scope: documentation-only master checklist pass. No gameplay, UI layout, ads, Game Center implementation, export, or asset changes.

This document is the **master source-of-truth** for App-in-Toss release readiness, monetization readiness, Game Center readiness, and anti-spaghetti release planning. Existing release docs should be treated as condensed summaries of this file.

For a Browser Use re-audit that maps the entire Developer Center first-column category structure, see [`docs/APP_IN_TOSS_DEVCENTER_FULL_AUDIT.md`](APP_IN_TOSS_DEVCENTER_FULL_AUDIT.md).

Status model: `[x]` done · `[~]` partial / structurally done but device or console validation pending · `[ ]` not done · `[?]` unknown / blocked  
Source model: `OFFICIAL_DOC` · `LOCAL_REPO` · `LOCAL_SKILL` · `USER_REQUIREMENT` · `INFERRED` · `UNKNOWN`

## 1. Executive Summary

- **Can submit today?** No.
- **Can launch monetized today?** No.
- **Top blockers:** Toss console registration, QR/device QA, final `.ait` export validation, app name/icon/logo lock, asset/license proof, Toss-shell Game Center validation, and monetization setup.
- **User action required:** final public title, final icon approval, asset/license proof, App-in-Toss console registration, game profile/leaderboard setup, business/settlement registration, Toss Ads setup, QR/device QA.
- **Console dependency:** all console-only items remain `NEEDS_CONSOLE_ACCESS`; they are not treated as code failures.
- **Business dependency:** all monetization implementation remains blocked by `NEEDS_BUSINESS_REGISTRATION` and `NEEDS_OFFICIAL_ADS_SETUP`.
- **Device dependency:** Safe Area, lifecycle, Game Center runtime, and ad behavior remain `NEEDS_DEVICE_QA`.
- **Pass constraint:** documentation-only. No scripts, scenes, assets, or exports changed.

## 2. Product Decision Summary

| Item | Decision | Source | Notes |
|---|---|---|---|
| Final product direction | Eventually monetized App-in-Toss game | USER_REQUIREMENT | Monetization is a target, not current launch reality |
| Persistent top banner | User wants it, but it remains risky now | USER_REQUIREMENT / OFFICIAL_DOC / INFERRED | Keep verdict as `USER_DESIRED_BUT_REQUIRES_LAYOUT_REDESIGN_AND_OFFICIAL_ADS_QA` |
| Death/game-over ad | Consider only post-run interstitial or rewarded continue | USER_REQUIREMENT / OFFICIAL_DOC | Do not implement now |
| Ranking | Update Toss Game Center after run end | USER_REQUIREMENT / OFFICIAL_DOC | No submit on app start |
| Identity | Use Toss Game Center identity, not custom backend unless forced | USER_REQUIREMENT / OFFICIAL_DOC | Current direction stays official bridge first |
| Gameplay ownership | Standalone Godot game remains intact | USER_REQUIREMENT / LOCAL_REPO | No gameplay/domain refactor in this pass |

## 3. Monetization / Ads Checklist

| ID | Requirement | Status | Severity | Source | Evidence | Risk | Required next action | Owner | Blocker label |
|---|---|---:|---|---|---|---|---|---|---|
| TOSS-ADS-01 | Ads remain `NOT_IMPLEMENTED / FUTURE` in the current repo | `[x]` | Medium | LOCAL_REPO / USER_REQUIREMENT | No real Ads SDK, fake UI, placeholder slot, or Pixel code is present | Premature ad UI would create review and UX risk | Keep ad-free implementation state for now | Codex |  |
| TOSS-ADS-02 | Business/settlement registration completed before monetized implementation | `[?]` | High | OFFICIAL_DOC / USER_REQUIREMENT | User explicitly says ads/business setup is not ready | Monetized launch cannot proceed without external setup | Complete business/settlement registration first | User | NEEDS_BUSINESS_REGISTRATION |
| TOSS-ADS-03 | Toss console ads setup and official ad-unit/test-ID flow confirmed | `[?]` | High | OFFICIAL_DOC / USER_REQUIREMENT | User does not yet know exact App-in-Toss Ads setup flow | Blind implementation would likely fail QA | Create a separate Ads Planning prompt after console access exists | User / Toss Console | NEEDS_CONSOLE_ACCESS |
| TOSS-ADS-04 | Toss Ads Pixel requirement is confirmed before any implementation | `[ ]` | Medium | OFFICIAL_DOC / UNKNOWN | No Pixel code exists; requirement not finalized | Unnecessary integration could add churn | Revisit only after monetization plan is approved | Codex / User | NEEDS_OFFICIAL_ADS_SETUP |
| TOSS-ADS-05 | Persistent top banner feasibility is treated as risky for the current 390x844 layout | `[~]` | High | OFFICIAL_DOC / USER_REQUIREMENT / INFERRED | Wide top HUD and bottom controls already use scarce vertical space | HUD readability, Safe Area, and control ergonomics can degrade | Keep banner as deferred design study, not implementation | Codex / User | USER_DESIRED_BUT_REQUIRES_LAYOUT_REDESIGN_AND_OFFICIAL_ADS_QA |
| TOSS-ADS-06 | Persistent top banner is not implemented and no placeholder box is reserved now | `[x]` | High | OFFICIAL_DOC / USER_REQUIREMENT / LOCAL_REPO | No banner UI exists | Fake or empty ad slots can hurt review clarity and gameplay UX | Keep layout unchanged until ad type, height, and real QA are known | Codex | USER_DESIRED_BUT_REQUIRES_LAYOUT_REDESIGN_AND_OFFICIAL_ADS_QA |
| TOSS-ADS-07 | Fake ad UI is forbidden | `[x]` | High | OFFICIAL_DOC | No fake ad frame or disguised ad element exists | Misleading ad UI can trigger rejection | Preserve no-fake-UI rule in future implementation | Codex |  |
| TOSS-ADS-08 | Forbidden ad placements are documented | `[x]` | High | OFFICIAL_DOC | Intro/loading/cutscene/modal/ATF/active gameplay/core HUD overlap are all documented as forbidden or high risk | Incorrect timing is a direct review/UX risk | Keep these prohibited in later Ads Planning docs | Codex |  |
| TOSS-ADS-09 | Safe future candidates are limited to post-run interstitial and rewarded continue | `[~]` | Medium | OFFICIAL_DOC / USER_REQUIREMENT / INFERRED | User wants death ad; docs support transition-point ads more safely than persistent gameplay ads | Wrong format choice could damage retention | Compare post-run interstitial vs rewarded continue after console/business setup | User / Codex | NEEDS_OFFICIAL_ADS_SETUP |
| TOSS-ADS-10 | Banner visibility policy is defined before any UI work | `[ ]` | Medium | OFFICIAL_DOC / INFERRED | No banner exists; no visibility matrix exists yet | Future banner can overlap title, loading, pause, weapon-choice, or modal UI | Draft visibility policy only after banner is still approved by user | Codex | NEEDS_OFFICIAL_ADS_SETUP |
| TOSS-ADS-11 | Ad cooldown, frequency cap, audio pause/resume, background/foreground, and return behavior are QA-gated | `[ ]` | High | OFFICIAL_DOC | Ads QA docs require real device checks | Even correct placement can fail on lifecycle/audio behavior | Add QA checklist after real ad setup exists | Device QA | NEEDS_DEVICE_QA |

## 4. Ranking / Toss Game Center Checklist

| ID | Requirement | Status | Severity | Source | Evidence | Risk | Required next action | Owner | Blocker label |
|---|---|---:|---|---|---|---|---|---|---|
| TOSS-GC-01 | App-in-Toss app registration exists | `[?]` | Critical | USER_REQUIREMENT / OFFICIAL_DOC | User says app is not registered yet | No console-backed validation can happen | Register app in App-in-Toss console | User / Toss Console | NEEDS_CONSOLE_ACCESS |
| TOSS-GC-02 | Game category/profile is configured | `[?]` | Critical | OFFICIAL_DOC / USER_REQUIREMENT | `getUserKeyForGame` is game-category-only | `INVALID_CATEGORY` risk remains until setup exists | Configure game profile in console | User / Toss Console | NEEDS_CONSOLE_ACCESS |
| TOSS-GC-03 | Leaderboard is configured in console | `[?]` | Critical | OFFICIAL_DOC / USER_REQUIREMENT | No console evidence yet | Submit/open may fail even if code path exists | Create leaderboard in console | User / Toss Console | NEEDS_CONSOLE_ACCESS |
| TOSS-GC-04 | `PlatformBridge` is the single owner for Toss/Game Center calls | `[x]` | Medium | LOCAL_REPO | Current bridge owns user key, submit, open, lifecycle hooks | Ownership drift would create spaghetti | Preserve bridge-only ownership | Codex |  |
| TOSS-GC-05 | `SaveManager` is the owner of `game_user_key` and best score | `[x]` | Medium | LOCAL_REPO | `SaveManager.get_best_record_value()` and local storage exist | Multiple score owners would create drift | Preserve single source of truth | Codex |  |
| TOSS-GC-06 | `GameRoot` is the only score-submit trigger owner | `[~]` | High | LOCAL_REPO | Submit is triggered on game over / max clear only | Needs runtime proof in Toss shell | Validate trigger timing on device | Codex / Device QA | NEEDS_DEVICE_QA |
| TOSS-GC-07 | UI opens leaderboard but never submits scores directly | `[~]` | Medium | LOCAL_REPO / INFERRED | MainMenu/PauseMenu open ranking via bridge; no UI submit path found | Later UI patches could violate boundary | Keep open-only UI ownership documented | Codex |  |
| TOSS-GC-08 | `getUserKeyForGame` minimum Toss version handling is verified | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | Bridge constants exist, but runtime validation is pending | Unsupported-version behavior may be wrong | Validate unsupported-version fallback in Toss shell | Codex / Device QA | NEEDS_DEVICE_QA |
| TOSS-GC-09 | `submitGameCenterLeaderBoardScore` minimum Toss version handling is verified | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | Structurally wired; runtime validation missing | Score submit could silently fail | Validate submit path in Toss shell | Codex / Device QA | NEEDS_DEVICE_QA |
| TOSS-GC-10 | Duplicate submit prevention works | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | `_score_submitted_this_run` exists | Double-submit still unproven on device | Test repeated end-state triggers | Device QA | NEEDS_DEVICE_QA |
| TOSS-GC-11 | Score submits only after game over / max clear, never on app start | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | Current repo wiring appears correct | Mistimed submit is a release risk | Keep structural rule and validate in device logs | Codex / Device QA | NEEDS_DEVICE_QA |
| TOSS-GC-12 | QR/device Toss-shell validation is complete | `[ ]` | Critical | OFFICIAL_DOC / USER_REQUIREMENT | No device proof exists | Structurally partial cannot be upgraded to done | Run real Toss-shell QA after console setup | User / Device QA | NEEDS_DEVICE_QA |

**Verdict:** Ranking/Game Center stays **structurally partial** until console registration and device QA exist. No related row should be promoted to `[x]` based only on local structure.

## 5. App-in-Toss Release Checklist

| ID | Requirement | Status | Severity | Source | Evidence | Risk | Required next action | Owner | Blocker label |
|---|---|---:|---|---|---|---|---|---|---|
| TOSS-MUST-01 | First screen appears within 10 seconds | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | MainMenu-first flow exists | No physical launch timing proof yet | Time QR/device launch | Device QA | NEEDS_DEVICE_QA |
| TOSS-MUST-02 | Start flow is user initiated | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | Start button begins gameplay | Needs Toss-shell flow proof | Validate on device | Device QA | NEEDS_DEVICE_QA |
| TOSS-MUST-03 | Sound toggle exists and persists | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | AudioManager + SaveManager ownership exists | Not yet validated in Toss shell | Run toggle/relaunch QA | Device QA | NEEDS_DEVICE_QA |
| TOSS-MUST-04 | Pause/resume works | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | PauseMenu/HUD pause paths exist | Requires gameplay-device confirmation | Test during live run | Device QA | NEEDS_DEVICE_QA |
| TOSS-MUST-05 | Close path and exit confirmation work | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | Close/back bridge and exit dialog exist | Shell-specific behavior unproven | Validate back/close on device | Device QA | NEEDS_DEVICE_QA |
| TOSS-MUST-06 | Safe Area / Dynamic Island are respected | `[~]` | Critical | OFFICIAL_DOC / LOCAL_REPO | Safe-area structure exists | Device-specific layout can still break | Capture iOS/Android screenshots | Device QA | NEEDS_DEVICE_QA |
| TOSS-MUST-07 | App name, icon, and logo match public registration | `[~]` | Critical | OFFICIAL_DOC / LOCAL_REPO / USER_REQUIREMENT | `app_icon_600.png` exists, but title/logo/console lock is pending | Branding mismatch can block release | Lock public title and approve final icon | User / Toss Console | USER_ACTION |
| TOSS-MUST-08 | Viewport, pinch zoom, touch-action, and overscroll are controlled | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | Export preset injects required meta/CSS | Still needs Toss WebView validation | Run gesture QA on QR build | Device QA | NEEDS_DEVICE_QA |
| TOSS-MUST-09 | Local save persistence works across relaunch | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | Save path and best-score source exist | Relaunch persistence not proven in Toss shell | Perform save/relaunch QA | Device QA | NEEDS_DEVICE_QA |
| TOSS-MUST-10 | QR private test and review flow are completed | `[ ]` | Critical | OFFICIAL_DOC / USER_REQUIREMENT | No current QR proof exists | Cannot claim review readiness | Produce export and run private test | User / Toss Console / Device QA | NEEDS_CONSOLE_ACCESS |
| TOSS-MUST-11 | No forced external migration / trapped flow exists | `[~]` | Medium | OFFICIAL_DOC / LOCAL_REPO | No forced install or external dependency found | Needs manual flow review | Confirm in final QA | Device QA | NEEDS_DEVICE_QA |

## 6. Asset / License / Branding Checklist

| ID | Requirement | Status | Severity | Source | Evidence | Risk | Required next action | Owner | Blocker label |
|---|---|---:|---|---|---|---|---|---|---|
| TOSS-ASSET-01 | Final public game title is locked | `[?]` | Critical | USER_REQUIREMENT / LOCAL_REPO | Project/internal/player-facing names can drift | Name mismatch can block review | Decide one final public title | User | USER_ACTION |
| TOSS-ASSET-02 | Canonical source logo path is fixed | `[x]` | Medium | LOCAL_REPO | `res://assets/branding/app_logo.png` exists | None if retained as canonical source | Keep this path as branding source | Codex |  |
| TOSS-ASSET-03 | Final exact `600x600` console icon candidate exists | `[x]` | Medium | LOCAL_REPO | `res://assets/branding/app_icon_600.png` exists | Console approval still pending | Use as console-ready candidate pending approval | User / Codex | USER_ACTION |
| TOSS-ASSET-04 | Final icon approval is complete | `[?]` | High | USER_REQUIREMENT | User approval still pending | Unapproved icon cannot be treated as final public icon | Approve or replace `app_icon_600.png` | User | USER_ACTION |
| TOSS-ASSET-05 | `title_logo.png` decision is explicit | `[ ]` | Medium | USER_REQUIREMENT / LOCAL_REPO | No final title-logo asset is locked | Title screen and app icon can diverge | Decide whether a dedicated title logo is needed | User / Codex | USER_ACTION |
| TOSS-ASSET-06 | Background/font/audio/icon license proof exists | `[?]` | Critical | UNKNOWN / LOCAL_REPO | No complete license manifest exists | Release risk remains until ownership is documented | Create asset license manifest | User / Codex | USER_ACTION |
| TOSS-ASSET-07 | Root duplicate cleanup is tracked as future hygiene only | `[x]` | Low | LOCAL_REPO / USER_REQUIREMENT | Root duplicates remain intentionally; no deletions in this pass | Premature cleanup could break imports | Audit duplicates later with evidence and approval | Codex |  |
| TOSS-ASSET-08 | Final export resource ownership is documented | `[ ]` | Medium | LOCAL_REPO / INFERRED | No complete ownership manifest exists | Hard to audit final pack contents | Add ownership manifest before final export | Codex / User |  |

## 7. Export / Bundle / Traffic Checklist

| ID | Requirement | Status | Severity | Source | Evidence | Risk | Required next action | Owner | Blocker label |
|---|---|---:|---|---|---|---|---|---|---|
| TOSS-WEB-01 | Godot version and web export preset are known | `[x]` | Medium | LOCAL_REPO | `project.godot`, `export_presets.cfg`, prior docs | None | Keep export config documented | Codex |  |
| TOSS-WEB-02 | Final `.ait` export exists | `[ ]` | Critical | OFFICIAL_DOC / LOCAL_REPO | No current final `.ait` | Cannot submit without current export artifact | Generate export only in a dedicated export pass | Codex / User |  |
| TOSS-WEB-03 | Unpacked bundle is remeasured against 100 MB | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | Historical dry run was under 100 MB | Current duplicate assets may change outcome | Re-export and measure current bundle | Codex |  |
| TOSS-WEB-04 | Root duplicate risk is accounted for before final export | `[~]` | Medium | LOCAL_REPO | Root font/image duplicates still exist | Bundle can include unnecessary assets | Audit duplicates before final export | Codex |  |
| TOSS-WEB-05 | No unnecessary gameplay network traffic exists | `[~]` | Medium | LOCAL_REPO | No gameplay HTTP code found | Future SDK/analytics/CDN can change this | Preserve local-only gameplay asset path for now | Codex |  |
| TOSS-WEB-06 | Future HTTPS/CORS/origin/CDN implications are documented | `[~]` | Medium | OFFICIAL_DOC / INFERRED | Current game is mostly local-only | Future external services may fail in live environment | Document allowed-origin work later if external traffic is added | Codex |  |
| TOSS-WEB-07 | WebView debugging plan exists | `[ ]` | Low | OFFICIAL_DOC | No current QA/debugging playbook exists | Slower diagnosis in live shell | Add small debugging playbook later | Codex |  |

## 8. Sentry / Monitoring Checklist

| ID | Requirement | Status | Severity | Source | Evidence | Risk | Required next action | Owner | Blocker label |
|---|---|---:|---|---|---|---|---|---|---|
| TOSS-OBS-01 | JS/WebView monitoring decision is documented | `[~]` | Medium | OFFICIAL_DOC / LOCAL_REPO | Sentry is not integrated | Shipping blind increases post-launch risk | Decide whether MVP can ship without monitoring | User / Codex |  |
| TOSS-OBS-02 | Sentry or equivalent monitoring is integrated | `[ ]` | Medium | OFFICIAL_DOC / LOCAL_REPO | No runtime monitoring code exists | Errors may be hard to diagnose after launch | Plan later monitoring pass | Codex |  |
| TOSS-OBS-03 | Native tracking stays disabled if Sentry is later used | `[~]` | Low | OFFICIAL_DOC | Requirement is documented, not yet implemented | Misconfiguration risk later | Preserve as implementation rule | Codex |  |

## 9. Anti-Spaghetti Refactor Checklist

| ID | Requirement | Status | Severity | Source | Evidence | Risk | Required next action | Owner | Blocker label |
|---|---|---:|---|---|---|---|---|---|---|
| ARCH-01 | `PlatformBridge` owns Toss/Game Center/Ads wrappers | `[x]` | Medium | LOCAL_REPO / INFERRED | Current bridge already owns user key, submit/open, lifecycle, ad stub | Ownership drift would spread platform logic | Preserve single owner | Codex |  |
| ARCH-02 | `SaveManager` owns best score and `game_user_key` | `[x]` | Medium | LOCAL_REPO | Single score source exists | Duplicate state would create bugs | Preserve single owner | Codex |  |
| ARCH-03 | `GameRoot` owns score-submit timing only | `[~]` | Medium | LOCAL_REPO | Structural timing is correct | Runtime proof still pending | Validate, then leave ownership unchanged | Codex / Device QA | NEEDS_DEVICE_QA |
| ARCH-04 | UI scripts own display and buttons only | `[~]` | Medium | LOCAL_REPO / INFERRED | MainMenu/PauseMenu/HUD are mostly display-level | Future patches could leak business logic | Preserve UI boundary in later prompts | Codex |  |
| ARCH-05 | No fake ad UI or hidden placeholder ad boxes are introduced | `[x]` | High | USER_REQUIREMENT / OFFICIAL_DOC | Current repo has none | Placeholder UI would create UX and review debt | Keep strict no-placeholder rule | Codex |  |
| ARCH-06 | Ads do not live in gameplay/domain files | `[x]` | High | LOCAL_REPO / INFERRED | No gameplay/domain ad logic exists | Wrong owner would create hard-to-test coupling | Keep ads under future bridge/controller only | Codex |  |
| ARCH-07 | No custom ranking DB is introduced unless officially forced | `[x]` | Medium | USER_REQUIREMENT / OFFICIAL_DOC | Current direction is official Game Center first | Custom backend would expand scope and risk | Preserve official-bridge-first strategy | Codex |  |
| ARCH-08 | Broad combat/domain refactor remains out of scope before release | `[x]` | High | USER_REQUIREMENT | This pass is documentation-only | Release planning can be derailed by broad refactor | Keep gameplay/domain untouched | Codex |  |
| ARCH-09 | Remaining runtime UI builders are classified, not refactored | `[~]` | Low | LOCAL_REPO | GameOver/WeaponChoice runtime builder patterns remain | Maintainability risk exists, but not a release blocker | Defer to post-release or bug-driven cleanup | Codex |  |
| ARCH-10 | Root duplicate asset cleanup is a later hygiene plan | `[x]` | Low | LOCAL_REPO / USER_REQUIREMENT | Duplicates remain intentionally | Premature deletion can break imports | Keep cleanup in later asset/export pass | Codex |  |
| ARCH-11 | `dev_status.json` duplicate-key cleanup is enforced | `[x]` | Medium | USER_REQUIREMENT | This pass will keep unique keys only | Duplicate keys can break tooling and status trust | Keep JSON normalized | Codex |  |
| ARCH-12 | Checklist/status doc duplicate-row cleanup is enforced | `[x]` | Medium | USER_REQUIREMENT | This pass will keep unique IDs/rows only | Duplicates create conflicting guidance | Keep docs normalized | Codex |  |

## 10. One-by-One Execution Plan

| ID | Goal | Likely Files | What Not To Touch | Validation | Status | Owner | Blocker label |
|---|---|---|---|---|---|---|---|
| STEP-01 | Documentation/status cleanup | `docs/*`, `data/dev_status.json` | `scripts/`, `scenes/`, `assets/`, `exports/` | `git diff --check`, `jq . data/dev_status.json` | DONE | Codex |  |
| STEP-02 | Brand lock and title decision | `docs/STATUS.md`, future metadata docs | Gameplay/UI layout | Brand review | TODO | User / Codex | USER_ACTION |
| STEP-03 | Asset license manifest | new docs-only legal manifest | Gameplay/UI/runtime code | Manual proof review | TODO | User / Codex | USER_ACTION |
| STEP-04 | Title logo creation/integration plan | branding docs, later UI pass | Gameplay rules | Asset path review | TODO | User / Codex | USER_ACTION |
| STEP-05 | Asset/export hygiene | export docs, later cleanup plan | Gameplay/domain | Asset inventory + export audit | TODO | Codex |  |
| STEP-06 | Fresh export size check | export docs, later export artifacts | UI/gameplay implementation | Bundle size audit | TODO | Codex / User |  |
| STEP-07 | Toss console registration checklist | docs only | Runtime code | Console field checklist | TODO | User / Toss Console | NEEDS_CONSOLE_ACCESS |
| STEP-08 | Game Center bridge Promise validation | `PlatformBridge` later | Unrelated UI/gameplay | Toss-shell logs | TODO | Codex | NEEDS_CONSOLE_ACCESS |
| STEP-09 | Ranking QR/device QA | QA docs/checklists | Gameplay math | Device recordings | TODO | User / Device QA | NEEDS_DEVICE_QA |
| STEP-10 | Ads planning with official docs | new ads planning doc later | Ad UI implementation | Official doc review | TODO | Codex | NEEDS_OFFICIAL_ADS_SETUP |
| STEP-11 | Ads architecture skeleton only if approved | later bridge/ads owner files | Gameplay/domain/HUD layout | Static owner review | TODO | Codex | NEEDS_OFFICIAL_ADS_SETUP |
| STEP-12 | Top banner feasibility prototype only if officially allowed and user approves tradeoff | later UI prototype files | Current production HUD/layout | Device UX review | TODO | Codex / User | USER_DESIRED_BUT_REQUIRES_LAYOUT_REDESIGN_AND_OFFICIAL_ADS_QA |
| STEP-13 | Death/game-over interstitial or rewarded implementation only after business/console setup | later bridge/UI result flow | Active gameplay loop math | Device ad QA | TODO | Codex / User | NEEDS_BUSINESS_REGISTRATION |
| STEP-14 | Sentry/monitoring plan | docs and later web shell | Gameplay/domain | Error capture smoke test | TODO | Codex |  |
| STEP-15 | Full device QA matrix | QA docs/checklists | Gameplay logic | QR/device evidence | TODO | User / Device QA | NEEDS_DEVICE_QA |
| STEP-16 | Final release signoff | release docs/checklists | Broad refactors | Checklist review | TODO | User / Codex |  |

## 11. User-Action Checklist

- Register the app in the App-in-Toss developer console.
- Decide the final public title.
- Approve `res://assets/branding/app_icon_600.png` as the final App-in-Toss icon or request a replacement.
- Create or provide `title_logo.png` if a dedicated title logo is required.
- Provide asset/license proof for icon, background, font, and any future audio.
- Configure game category/profile and leaderboard in Toss console.
- Decide the monetization strategy for launch vs post-launch.
- Complete business/settlement registration before ads.
- Set Toss Ads/ad unit/test ID information after official setup becomes available.
- Run QR private test.
- Run iOS and Android physical QA.
- Decide whether the top-banner layout tradeoff is acceptable later.
- Decide whether death ad should be interstitial or rewarded continue if monetization proceeds.

## 12. Codex-Action Checklist

- Keep release docs and `data/dev_status.json` deduplicated and internally consistent.
- Lock brand metadata only after the user finalizes public naming.
- Create an asset license manifest template.
- Integrate `title_logo` only after the user provides or approves the asset.
- Audit root duplicate assets before final export.
- Prepare a fresh export and size report when explicitly requested.
- Harden `PlatformBridge` Promise/error handling in a later dedicated platform pass.
- Add Game Center runtime fallback handling only after console/device validation needs are clear.
- Prepare a separate Ads Planning doc before any ads implementation.
- Keep anti-spaghetti ownership boundaries intact in all later prompts.

## 13. Rejection-Case Checklist

| ID | Requirement | Status | Severity | Source | Evidence | Risk | Required next action | Owner | Blocker label |
|---|---|---:|---|---|---|---|---|---|---|
| REJECT-01 | No pinch zoom / unintended page gesture regression | `[~]` | High | OFFICIAL_DOC / LOCAL_SKILL / LOCAL_REPO | Structural viewport controls exist | Needs real WebView QA | Run gesture QA | Device QA | NEEDS_DEVICE_QA |
| REJECT-02 | No unsafe area overlap | `[~]` | High | OFFICIAL_DOC / LOCAL_SKILL / LOCAL_REPO | Safe-area structure exists | Still unproven on device | Capture screenshots on device | Device QA | NEEDS_DEVICE_QA |
| REJECT-03 | No trapped back/exit flow | `[~]` | High | OFFICIAL_DOC / LOCAL_SKILL / LOCAL_REPO | Exit/close structure exists | Needs Toss-shell validation | Test back/close on QR build | Device QA | NEEDS_DEVICE_QA |
| REJECT-04 | No misleading CTA or fake ad surface | `[x]` | High | OFFICIAL_DOC / LOCAL_SKILL / LOCAL_REPO | No fake ad UI or fake ranking UI found | Future patches can violate this | Preserve explicit prohibition | Codex |  |
| REJECT-05 | No ad on intro/loading/cutscene/modal/ATF | `[x]` | High | OFFICIAL_DOC | Current repo has no ads | Future wrong placement would be high risk | Keep as hard rule | Codex |  |
| REJECT-06 | No Game Center submit at wrong time | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | Structural trigger timing is correct | Needs runtime logs | Validate after console setup | Device QA | NEEDS_DEVICE_QA |
| REJECT-07 | No missing persistence or lost best score | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | Save ownership is centralized | Needs relaunch proof | Run persistence QA | Device QA | NEEDS_DEVICE_QA |
| REJECT-08 | No title/icon/name mismatch | `[?]` | Critical | OFFICIAL_DOC / LOCAL_SKILL / LOCAL_REPO | Branding is still not locked | Review can fail on inconsistent branding | Finalize public branding | User | USER_ACTION |
| REJECT-09 | No unsupported asset/license ambiguity | `[?]` | Critical | LOCAL_SKILL / UNKNOWN | License proof is incomplete | Legal/ownership issues can block launch | Create license manifest | User / Codex | USER_ACTION |
