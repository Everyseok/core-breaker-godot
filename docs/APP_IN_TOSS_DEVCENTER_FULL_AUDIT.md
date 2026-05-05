# App-in-Toss Developer Center Full Coverage Audit

Date: 2026-05-04  
Repo: `/Volumes/junseokism_usb3.0/game/game_junseokism.ver1`  
Branch: `feature/design-rebuild-apply-pass`  
Scope: documentation-only re-audit using Browser Use plus local repo evidence. No scripts, scenes, assets, gameplay, export, ads, or Game Center implementation changed.

This document complements [`docs/APP_IN_TOSS_MONETIZED_RELEASE_MASTER_CHECKLIST.md`](APP_IN_TOSS_MONETIZED_RELEASE_MASTER_CHECKLIST.md). The master checklist stays the release and monetization source-of-truth. This file closes the remaining breadth gap by re-auditing the entire **first-column Developer Center category structure**:

- 시작
- 디자인
- 개발
- 출시
- 마케팅
- 수익화
- API & SDK

## Executive Summary

- **Browser Use worked:** Yes.
- **Can submit today?** No.
- **Can launch monetized today?** No.
- **Broad verdict:** Existing docs were already strong on release, monetization, and Game Center planning, but they were not yet organized against the entire Developer Center category model. This audit fills that gap.
- **Main blockers remain unchanged:** App-in-Toss console registration, QR/device QA, final `.ait` export validation, public branding lock, asset/license proof, Toss-shell Game Center validation, and business/ads setup.
- **Important new audit note:** `scripts/autoload/platform_bridge.gd` relies on `JavaScriptBridge.eval(...)` with static bundled JavaScript strings. This is not the same as executing remote user-provided code, but it is still **review-sensitive** because the official game checklist warns against external code execution patterns such as `eval`.

## Source Rule

Source priority used in this audit:

1. `LOCAL_REPO`
2. current docs in repo
3. `OFFICIAL_DOC` via Browser Use
4. `LOCAL_SKILL` rejection examples
5. `INFERRED` only when evidence exists but official wording does not directly decide the exact implementation detail

## Official Category Coverage Summary

| Category | Browser Use Coverage | Applies Now | Current Verdict | Main Gap |
|---|---|---|---|---|
| 시작 | Sidebar inventory + onboarding/start pages | Yes | Partial | Console and business steps are still external blockers |
| 디자인 | Sidebar inventory + resources/resolution/UX coverage | Yes | Partial | Branding lock, Safe Area device proof, and license proof remain incomplete |
| 개발 | Sidebar inventory + test/integration/debugging coverage | Yes | Partial | Toss app test, sandbox validation, Sentry, and runtime bridge QA remain incomplete |
| 출시 | Game checklist and deploy/test flows | Yes | Partial | Final export, review-ready QA evidence, and branding lock are still missing |
| 마케팅 | Sidebar inventory + Game Center relevance + OG image rule | Partly | Partial | OG image is not prepared; most marketing tools are future-stage |
| 수익화 | Sidebar inventory + ads guidance | Future / strategic | Blocked | Business registration, console setup, and official ad setup are not ready |
| API & SDK | Sidebar inventory + framework/API overview | Partly | Partial | Current repo uses bridge APIs structurally, but server API rules are future-stage |

## 1. 시작

### Sidebar Inventory Checked

- `overview-card.html`
- 이해하기
  - `intro/overview`
  - `intro/onboarding-process`
  - `intro/guide`
  - `intro/caution`
- 시작하기
  - `prepare/console-workspace`
  - `prepare/register-business`
  - `prepare/console-minor`

### Audit

| Guide / Checklist | Status | Source | Repo Evidence | Gap / Risk | Next Action |
|---|---|---|---|---|---|
| App-in-Toss onboarding flow is understood | `[~]` | OFFICIAL_DOC / LOCAL_REPO | Release docs already capture review flow at a high level | Still missing real console execution evidence | Keep documentation; perform console registration later |
| Console workspace preparation is complete | `[?]` | OFFICIAL_DOC / USER_REQUIREMENT | User explicitly says app is not registered yet | Console-only work is still blocked | `NEEDS_CONSOLE_ACCESS` |
| Business registration prerequisites are complete | `[?]` | OFFICIAL_DOC / USER_REQUIREMENT | User explicitly says ads/business setup is not ready | Monetized release cannot proceed | `NEEDS_BUSINESS_REGISTRATION` |
| Minor / caution pages have been considered | `[~]` | OFFICIAL_DOC / INFERRED | No child-targeted special flow is implemented in repo | Policy interpretation still belongs to final review | Keep as policy review item, not code item |

## 2. 디자인

### Sidebar Inventory Checked

- `design/overview.html`
- UI/UX 가이드
  - `design/miniapp-branding-guide`
  - `design/consumer-ux-guide`
  - `design/ux-writing`
  - `design/resources`
  - `design/resolution`
- 디자인 준비하기
  - `design/prepare/design`
  - `design/prepare/deus`
- `design/components`
- `design/prepare/figma-ui-license`

### Audit

| Guide / Checklist | Status | Source | Repo Evidence | Gap / Risk | Next Action |
|---|---|---|---|---|---|
| Portrait fullscreen design matches current game direction | `[~]` | OFFICIAL_DOC / LOCAL_REPO | `project.godot` is fixed at `390x844` portrait | Real device safe-area proof is still missing | QR/device screenshot QA |
| Safe Area / Dynamic Island handling is structurally present | `[~]` | OFFICIAL_DOC / LOCAL_REPO | Existing UI docs already track safe-area handling as partial | Not yet proven in Toss shell on physical devices | Keep `[~]` until device proof exists |
| Toss graphic resources are treated as optional references, not mandatory app branding | `[x]` | OFFICIAL_DOC / LOCAL_REPO | Branding currently uses project-owned assets, not Toss graphic resources as icon | Still need final approval and license proof | Keep custom art path; finish proof/approval |
| App icon/logo usage follows branding separation | `[~]` | OFFICIAL_DOC / LOCAL_REPO | `res://assets/branding/app_logo.png` and `app_icon_600.png` exist | Final title/logo/icon lock is incomplete | User must finalize public branding |
| Design resources / file requirements are documented | `[~]` | OFFICIAL_DOC / LOCAL_REPO | `app_icon_600.png` exists, but no OG image or license manifest yet | Some file-format requirements remain future or missing | Add OG/license tasks to backlog |
| UX writing quality is tracked | `[~]` | OFFICIAL_DOC / LOCAL_REPO | Korean UI copy exists and docs already track title/icon consistency | Final public naming still drifts between internal/project identifiers | Lock one final public title |
| TDS/Figma/AppBuilder resources are required for this Godot game | `[x]` | OFFICIAL_DOC / INFERRED | Repo is a Godot game, not a TDS component implementation | Misclassifying optional design systems as blockers would waste effort | Treat as optional references only |

## 3. 개발

### Sidebar Inventory Checked

- `development/overview.html`
- 시작하기
  - `tutorials/webview`
  - `tutorials/react-native`
  - `development/llms`
- 디버깅하기
  - `learn-more/debugging-webview`
  - `learn-more/debugging`
- 테스트하기
  - `development/client/android`
  - `development/client/ios`
  - `development/test/sandbox`
  - `development/test/toss`
- 연동 & 운영
  - `development/integration-process`
  - `firebase/intro`
  - `learn-more/sentry-monitoring`
- 토스 로그인
  - `login/intro`
  - `login/console`
  - `login/develop`
  - `login/qa`
- 유저 식별키 발급
  - `user-hash-key/intro`
  - `user-hash-key/develop`
  - `user-hash-key/migration`
- 토스 인증
  - `tossauth/contract`
  - `tossauth/test`
  - `tossauth/develop`
- 토스애즈 픽셀 연동
  - `tosspixel/console`
  - `tosspixel/develop`

### Audit

| Guide / Checklist | Status | Source | Repo Evidence | Gap / Risk | Next Action |
|---|---|---|---|---|---|
| WebView-oriented miniapp path is the correct technical target | `[x]` | OFFICIAL_DOC / LOCAL_REPO | `export_presets.cfg` targets web export; `project.godot` is Godot web-compatible | None at strategy level | Keep WebView-first target |
| Sandbox / Toss app testing has been completed | `[ ]` | OFFICIAL_DOC / USER_REQUIREMENT | No current QR/device proof exists | Release readiness remains unproven | Run sandbox and Toss tests later |
| WebView debugging guidance is reflected in workflow | `[~]` | OFFICIAL_DOC / LOCAL_REPO | Debugging doc was inspected and release docs reference device validation | No current captured debug session evidence | Keep as QA workflow item |
| Sentry monitoring guidance is reflected | `[~]` | OFFICIAL_DOC / LOCAL_REPO | Monitoring is documented as pending | Launch would still be possible without it, but with lower observability | Decide whether MVP ships without monitoring |
| Toss Login is implemented | `[ ]` | OFFICIAL_DOC / LOCAL_REPO | No Toss Login integration found | Not a current blocker for this standalone game | Keep as out-of-scope unless product changes |
| User hash key issuance flow is implemented through its own product docs | `[ ]` | OFFICIAL_DOC / LOCAL_REPO | No separate user-hash-key product integration found | Current plan uses Game Center user identity instead | Treat as not in scope unless product expands |
| Toss Auth is implemented | `[ ]` | OFFICIAL_DOC / LOCAL_REPO | No Toss Auth integration found | Not relevant unless authentication flow changes | Keep out-of-scope |
| Toss Ads Pixel integration is implemented | `[ ]` | OFFICIAL_DOC / LOCAL_REPO / USER_REQUIREMENT | User explicitly said not to implement Pixel yet | Premature integration would add churn | Keep future-only |
| `PlatformBridge` runtime bridge handling is fully validated | `[~]` | LOCAL_REPO / OFFICIAL_DOC | Bridge wrappers exist for lifecycle, user key, submit, and leaderboard open | Promise/runtime behavior still needs Toss-shell proof | Dedicated bridge validation pass later |

## 4. 출시

### Official Pages Checked

- `checklist/app-game.html`
- `development/deploy.html`
- `development/test/toss.html`
- `development/test/sandbox.html`

### Audit

| Guide / Checklist | Status | Source | Repo Evidence | Gap / Risk | Next Action |
|---|---|---|---|---|---|
| First screen under 10 seconds | `[~]` | OFFICIAL_DOC / LOCAL_REPO | MainMenu-first flow exists | No measured QR/device evidence | Time launch later |
| Close/exit path and no trapped flow | `[~]` | OFFICIAL_DOC / LOCAL_REPO | `PlatformBridge` + exit dialog exist | Needs Toss-shell validation | Validate back/close in QR build |
| Sound toggle and pause/resume | `[~]` | OFFICIAL_DOC / LOCAL_REPO | AudioManager + PauseMenu/HUD exist | Needs lifecycle QA on device | Device QA |
| Safe Area and fullscreen/no-gap behavior | `[~]` | OFFICIAL_DOC / LOCAL_REPO | Structural viewport and UI approach exist | Physical device proof missing | Device QA |
| Viewport / pinch zoom / touch-action / overscroll controls | `[~]` | OFFICIAL_DOC / LOCAL_REPO | `export_presets.cfg` injects `user-scalable=no`, `touch-action:none`, `overscroll-behavior:none` | Needs Toss WebView validation | QR/device QA |
| No forced bottom sheet / no forced external migration | `[~]` | OFFICIAL_DOC / LOCAL_REPO | No such flows found in repo | Final QA still needed | Keep in final QA checklist |
| Save persistence and play record retention | `[~]` | OFFICIAL_DOC / LOCAL_REPO | SaveManager is source-of-truth | Needs relaunch proof | Persistence QA |
| Final deploy/review flow is complete | `[ ]` | OFFICIAL_DOC / LOCAL_REPO | No current final `.ait` candidate or review submission evidence | Cannot request review yet | Export pass first |

## 5. 마케팅

### Sidebar Inventory Checked

- `marketing/overview.html`
- 세그먼트
  - `segment/intro`
  - `segment/console`
- 스마트 발송
  - `smart-message/intro`
  - `smart-message/console`
  - `smart-message/develop`
  - `smart-message/qa`
- 프로모션
  - `promotion/intro`
  - `promotion/console`
  - `promotion/develop`
  - `promotion/qa`
- 게임 프로필 & 리더보드
  - `game-center/intro`
  - `game-center/develop`
  - `game-center/qa`
- 공유 리워드
  - `reward/intro`
  - `reward/console`
  - `reward/develop`
  - `reward/qa`
- OG 이미지
  - `marketing/open-graph`
- 분석하기
  - `analytics/dashboard`
  - `analytics/logging`
  - `analytics/conversion-metrics`
- 성장 가이드
  - `growth/intro`
  - `growth/traffic`
  - `growth/retention`
  - `growth/share`
  - `growth/insight`

### Audit

| Guide / Checklist | Status | Source | Repo Evidence | Gap / Risk | Next Action |
|---|---|---|---|---|---|
| Game profile / leaderboard marketing path is structurally relevant | `[~]` | OFFICIAL_DOC / LOCAL_REPO | Game Center bridge is documented as structurally partial | No console setup or QR/device proof yet | Keep Game Center as partial |
| OG image requirement is prepared | `[ ]` | OFFICIAL_DOC / LOCAL_REPO | No `1200x600` OG image asset is documented | Share surfaces may be underprepared later | Add OG image task when sharing scope matters |
| Segment / Smart Message / Promotion / Reward flows are implemented | `[ ]` | OFFICIAL_DOC / LOCAL_REPO | No such integrations found | Not current blockers for the standalone game MVP | Keep out-of-scope until growth work begins |
| Analytics / growth tooling is formally planned | `[ ]` | OFFICIAL_DOC / LOCAL_REPO | No analytics/growth implementation found | Post-launch marketing will be blind | Treat as post-MVP planning area |

## 6. 수익화

### Sidebar Inventory Checked

- `revenue/overview.html`
- 인앱 광고
  - `ads/intro`
  - `ads/console`
  - `ads/develop`
  - `ads/qa`
- 인앱 결제
  - `iap/intro`
  - `iap/console`
  - `iap/develop`
  - `iap/qa`
- 토스 페이
  - `tosspay/intro`
  - `tosspay/console`
  - `tosspay/develop`
  - `tosspay/qa`
- 정산
  - `settlement/intro`

### Audit

| Guide / Checklist | Status | Source | Repo Evidence | Gap / Risk | Next Action |
|---|---|---|---|---|---|
| Ads are planned but not implemented | `[x]` | OFFICIAL_DOC / USER_REQUIREMENT / LOCAL_REPO | Docs explicitly keep ads as `NOT_IMPLEMENTED / FUTURE` | None if kept deferred | Preserve current state |
| Persistent top banner is approved for implementation | `[ ]` | USER_REQUIREMENT / OFFICIAL_DOC / INFERRED | Current official and layout audit says it is risky | High HUD/safe-area/gameplay UX risk | Keep deferred verdict |
| Death/game-over ad is narrowed to safe future candidates | `[~]` | USER_REQUIREMENT / OFFICIAL_DOC | Docs already restrict it to post-run interstitial or rewarded continue | Still blocked by business/console setup | Revisit later |
| Ads business/settlement is complete | `[?]` | OFFICIAL_DOC / USER_REQUIREMENT | User says not ready | Monetized launch blocked | `NEEDS_BUSINESS_REGISTRATION` |
| IAP / TossPay are current blockers | `[x]` | OFFICIAL_DOC / LOCAL_REPO / INFERRED | No IAP or TossPay product requirement exists for current scope | Misclassifying them as required would expand scope wrongly | Keep out-of-scope for current release |

## 7. API & SDK

### Sidebar Inventory Checked

- `api/overview.html`
- Login, Promotion, TossPay, IAP, Push APIs
- Bedrock framework SDK reference categories

### Audit

| Guide / Checklist | Status | Source | Repo Evidence | Gap / Risk | Next Action |
|---|---|---|---|---|---|
| Current game depends primarily on client bridge APIs, not partner server APIs | `[x]` | OFFICIAL_DOC / LOCAL_REPO | No custom backend/server API usage found | None today | Keep backend out of scope unless officially required later |
| Game Center bridge methods are structurally present | `[~]` | OFFICIAL_DOC / LOCAL_REPO | `PlatformBridge` wraps user key, submit, and leaderboard open | Runtime validation still missing | Toss-shell validation later |
| Server-side API constraints such as mTLS, firewall allowlist, JSON response format, and QPM are currently active blockers | `[x]` | OFFICIAL_DOC / LOCAL_REPO / INFERRED | No server API integration found | Future backend work would need these constraints | Track as future-only |
| `JavaScriptBridge.eval(...)` use is review-safe by default | `[?]` | OFFICIAL_DOC / LOCAL_REPO / INFERRED | Static bundled JS strings are used, but official checklist flags `eval`-style external code execution as sensitive | Review misunderstanding risk exists | Add explicit review note and keep bridge logic isolated |
| iframe restrictions are relevant to current app | `[x]` | OFFICIAL_DOC / LOCAL_REPO | No iframe usage found | None | Keep no-iframe stance |

## File Formats And Resource Requirements Found

| Artifact / Format | Official Source | Current Repo State | Verdict | Next Action |
|---|---|---|---|---|
| App icon PNG `600x600` | 디자인 / 브랜딩-related guidance + current release planning | `res://assets/branding/app_icon_600.png` exists | Partial | User must approve final icon for console |
| Canonical high-res logo PNG | LOCAL_REPO branding convention | `res://assets/branding/app_logo.png` exists | Good | Keep as source asset |
| Final `.ait` export | 출시 / 배포 flow | Not produced in this pass | Missing | Dedicated export pass later |
| Unpacked bundle `<= 100MB` | 공식 배포 docs | Historical dry run was under limit | Partial | Re-export and remeasure later |
| OG image `1200x600` | 마케팅 `open-graph` docs | Not prepared | Missing | Create if/when share surface becomes active |
| Web viewport meta + gesture controls | 출시 / 디자인 / 개발 docs | `export_presets.cfg` injects viewport + CSS controls | Partial | Validate in Toss WebView |
| API JSON response shape `resultType/success/error` | API overview | No server API integration in current repo | Future-only | Track only if backend is added |
| mTLS cert / HTTPS 443 / firewall allowlist | API overview | No server API integration in current repo | Future-only | Track only if backend is added |

## Important Re-Audit Findings

1. The repo is **much closer to release documentation completeness than to full Developer Center breadth completeness**. The missing breadth is mostly in future-stage categories, not hidden code failure.
2. The most relevant categories right now remain **출시**, **디자인**, **개발**, and **게임 프로필 & 리더보드** within **마케팅**.
3. `Toss Login`, `Toss Auth`, `Firebase`, `Segment`, `Smart Message`, `Promotion`, `Reward`, `IAP`, and `TossPay` are **not current MVP blockers** for this standalone Godot game.
4. The **top banner ad remains intentionally unapproved**. Official ads guidance plus the current `390x844` layout make it too risky to pre-approve now.
5. The **death/game-over ad path is still plausible**, but only as a later official-doc-compliant transition ad after console/business setup.
6. `JavaScriptBridge.eval(...)` is the clearest new **review-sensitive implementation detail** found in this breadth audit. It should stay isolated in `PlatformBridge` and be justified carefully during any later production validation.

## Recommended Follow-Up Order

1. Lock final public title, title art direction, and icon approval.
2. Create asset/license manifest.
3. Run asset/export hygiene and generate a fresh export size audit.
4. Register the app in App-in-Toss console and configure game profile/leaderboard.
5. Validate `PlatformBridge` runtime behavior in Toss shell, especially user key and leaderboard submit/open.
6. Run QR/device QA for launch time, safe area, lifecycle, and ranking.
7. Revisit ads only after business registration and official ad setup exist.
8. Decide whether OG image, analytics, and growth tooling enter the MVP or post-launch scope.

## Final Verdict

- **Can submit today?** No.
- **Can launch monetized today?** No.
- **Top banner verdict:** `USER_DESIRED_BUT_REQUIRES_LAYOUT_REDESIGN_AND_OFFICIAL_ADS_QA`
- **Death/game-over ad verdict:** post-run interstitial or rewarded continue candidates only; do not implement now
- **Ranking / Game Center verdict:** structurally partial
- **Developer Center breadth verdict:** official categories are now mapped, but several categories remain future-stage or externally blocked rather than code-complete
