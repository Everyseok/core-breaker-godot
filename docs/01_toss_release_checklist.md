# App-in-Toss Release Checklist Matrix

Date: 2026-05-04
Master source-of-truth: [`docs/APP_IN_TOSS_MONETIZED_RELEASE_MASTER_CHECKLIST.md`](APP_IN_TOSS_MONETIZED_RELEASE_MASTER_CHECKLIST.md)
Full Developer Center category audit: [`docs/APP_IN_TOSS_DEVCENTER_FULL_AUDIT.md`](APP_IN_TOSS_DEVCENTER_FULL_AUDIT.md)

This file is the condensed release matrix. Monetization, Game Center nuance, refactor ownership, and rejection-case detail are maintained in the master checklist above.

Status model: `[x]` done · `[~]` partial / structurally done but console or device validation pending · `[ ]` not done · `[?]` unknown / blocked

## Condensed Matrix

| ID | Requirement | Status | Severity | Source | Evidence | Next Action |
|---|---|---:|---|---|---|---|
| TOSS-MUST-01 | Review/test flow is understood and backed by at least one Toss test before review | `[?]` | Critical | OFFICIAL_DOC / USER_REQUIREMENT | App is not registered in console yet | `NEEDS_CONSOLE_ACCESS`; register app and complete test flow |
| TOSS-MUST-02 | First screen loads within 10 seconds | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | MainMenu-first flow exists | Time launch in QR/device build |
| TOSS-MUST-03 | Close/exit path works and does not trap the user | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | Close/back bridge and exit dialog exist | Validate in Toss shell |
| TOSS-MUST-04 | Safe Area / Dynamic Island are respected | `[~]` | Critical | OFFICIAL_DOC / LOCAL_REPO | Safe-area structure exists | Run iOS/Android screenshot QA |
| TOSS-MUST-05 | Local save persistence works across relaunch | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | SaveManager + local repository exist | Run save/relaunch QA |
| TOSS-MUST-06 | Sound toggle and pause/resume work | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | AudioManager + PauseMenu/HUD exist | Validate on device |
| TOSS-MUST-07 | App name, icon, and logo are locked and match registration | `[~]` | Critical | OFFICIAL_DOC / LOCAL_REPO / USER_REQUIREMENT | `app_icon_600.png` exists but final title/logo/console values are not locked | Approve final title and icon |
| TOSS-MUST-08 | No forced external migration or trapped flow exists | `[~]` | Medium | OFFICIAL_DOC / LOCAL_REPO | No forced install or external dependency found | Confirm in final QA |
| TOSS-WEB-01 | Web export preset exists and viewport protections are configured | `[~]` | High | LOCAL_REPO / OFFICIAL_DOC | `export_presets.cfg` injects viewport/touch/overscroll controls | Validate in Toss WebView |
| TOSS-WEB-02 | Final `.ait` export exists and is remeasured | `[ ]` | Critical | OFFICIAL_DOC / LOCAL_REPO | No final export candidate yet | Generate export in dedicated export pass |
| TOSS-WEB-03 | Unpacked bundle remains <= 100 MB | `[~]` | High | OFFICIAL_DOC / LOCAL_REPO | Historical dry run was under limit | Re-export and remeasure after asset hygiene |
| TOSS-GC-01 | Game Center is structurally wired but not overclaimed | `[~]` | High | LOCAL_REPO / OFFICIAL_DOC | Bridge, save, and trigger owners exist | Keep verdict as structurally partial until console/device QA |
| TOSS-GC-02 | Score submits only after run completion and duplicate prevention exists | `[~]` | High | LOCAL_REPO / OFFICIAL_DOC | Submit timing and duplicate guard exist structurally | Validate in Toss shell |
| TOSS-GC-03 | Leaderboard opens only by user action | `[~]` | Medium | LOCAL_REPO / OFFICIAL_DOC | Ranking buttons exist in menu flows | Validate title/pause ranking UX in Toss shell |
| TOSS-GC-04 | Console app, game profile, and leaderboard setup exist | `[?]` | Critical | USER_REQUIREMENT / OFFICIAL_DOC | Console setup is not done | `NEEDS_CONSOLE_ACCESS`; configure app/game/leaderboard |
| TOSS-ADS-01 | Current ads status remains `NOT_IMPLEMENTED / FUTURE` | `[x]` | Medium | LOCAL_REPO / USER_REQUIREMENT | No ad SDK/UI/Pixel is implemented | Keep ads deferred |
| TOSS-ADS-02 | Persistent top banner remains deferred and unimplemented | `[x]` | High | USER_REQUIREMENT / OFFICIAL_DOC / INFERRED | Current layout has top HUD and bottom controls | Preserve verdict `USER_DESIRED_BUT_REQUIRES_LAYOUT_REDESIGN_AND_OFFICIAL_ADS_QA` |
| TOSS-ADS-03 | Death/game-over ads are documented only as post-run interstitial or rewarded continue candidates | `[~]` | Medium | USER_REQUIREMENT / OFFICIAL_DOC | Safe future candidates are documented | Revisit only after business/console setup |
| TOSS-ADS-04 | No placeholder ad box or fake ad UI is introduced | `[x]` | High | OFFICIAL_DOC / USER_REQUIREMENT | Current repo contains no placeholder/fake ad UI | Preserve no-placeholder rule |
| TOSS-OBS-01 | Monitoring/Sentry is still pending | `[ ]` | Medium | OFFICIAL_DOC / LOCAL_REPO | No monitoring code exists | Add later monitoring plan |
| TOSS-ASSET-01 | Root duplicate assets are tracked as export hygiene risk | `[~]` | Medium | LOCAL_REPO | Root font/image duplicates remain | Audit before final export |
| TOSS-ASSET-02 | Canonical app logo path exists | `[x]` | Medium | LOCAL_REPO | `res://assets/branding/app_logo.png` exists | Keep canonical branding source |
| TOSS-ASSET-03 | Exact `600x600` app icon candidate exists | `[x]` | Medium | LOCAL_REPO | `res://assets/branding/app_icon_600.png` exists | Treat as console-ready candidate pending approval |
| TOSS-ASSET-04 | License/ownership proof exists for shipped branding/font/background assets | `[?]` | Critical | UNKNOWN / LOCAL_REPO | No full license manifest exists | Create asset license manifest |
| TOSS-QA-01 | Toss QR private test is complete | `[ ]` | Critical | OFFICIAL_DOC / USER_REQUIREMENT | No current QR proof exists | Run QR/device test after export |
| TOSS-QA-02 | Visible iOS/Android device QA is complete | `[ ]` | Critical | OFFICIAL_DOC / LOCAL_REPO | No current physical QA evidence exists | Run safe-area, lifecycle, and control QA |
| ARCH-01 | Platform/UI/save ownership stays clean for release work | `[~]` | Medium | LOCAL_REPO / INFERRED | Ownership is mostly clean, but runtime builders remain | Preserve boundaries; no broad refactor now |

## Sign-Off Rule

Do not request Toss review until Critical rows are either `[x]` with evidence or explicitly accepted by the user as deferred risk. Ranking/Game Center must stay structurally partial until console-backed device QA exists.
