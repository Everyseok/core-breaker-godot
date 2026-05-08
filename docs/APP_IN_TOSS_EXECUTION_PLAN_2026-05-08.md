# App-in-Toss Execution Plan - 2026-05-08

## Phase 0 - Audit Snapshot

### Baseline

Commands executed:

```sh
pwd
git status --short
git branch --show-current
git log --oneline -5
git diff --stat
find . -maxdepth 3 -type f | sort | sed -n '1,200p'
rg -n "TossBridge|TossAds|loadFullScreenAd|showFullScreenAd|submitGameCenterLeaderBoardScore|openGameCenterLeaderboard|getUserKeyForGame|rewarded|revive|leaderboard|ranking|ait-top-banner|CORE_BREAKER_TOSS_BANNER_SLOT_ID|JavaScriptBridge.eval|rewarded_revive_ad_group_id|adGroupId|banner" .
git diff --check
```

Observed state:

| Item | Result |
|---|---|
| Workspace | `/Volumes/JUNSEOKISM_USB3.0/game/game_junseokism.ver1` |
| Branch | `feature/android-debug-apk-artifact` |
| HEAD | `cc06f33 feat: add passive attack telegraph vfx` |
| Recent commits | `cc06f33`, `1d41a46`, `bd9f899`, `a8ff309`, `b9f338a` |
| Working tree | Dirty from earlier pre-bundle / wrapper work and Godot editor cache |
| `git diff --check` before this snapshot | Passed |

Dirty working tree classification:

| Category | Files / paths | Action |
|---|---|---|
| Godot cache/editor output | `.godot/**` | Do not stage; not release source |
| Prior pre-bundle code work | `scripts/autoload/platform_bridge.gd`, `scripts/ui/root_ui.gd`, `project.godot` | Existing dirty work; not modified in Phase 0 |
| Prior checklist/status docs | `docs/01_toss_release_checklist.md`, `docs/APP_IN_TOSS_MONETIZED_RELEASE_MASTER_CHECKLIST.md`, `docs/NEXT_STEP.md`, `docs/STATUS.md`, new Toss docs | Existing dirty work; Phase 0 only adds this snapshot |
| Dry-run export output | `exports/prebundle_dry_run/` | Do not stage unless a later explicit packaging policy says otherwise |
| Vite bridge/wrapper prototype | `web/` | Existing dirty/untracked prototype; not modified in Phase 0 |
| Editor-normalized scene | `scenes/ui/skill_select_panel.tscn` | Existing dirty file; not touched in Phase 0 |
| Unrelated UID sidecars | `*.gd.uid` under scripts | Do not stage unless explicitly required by the changed source |

### Files Read

- `docs/01_toss_release_checklist.md`
- `docs/APP_IN_TOSS_MONETIZED_RELEASE_MASTER_CHECKLIST.md`
- `docs/APP_IN_TOSS_DEVCENTER_FULL_AUDIT.md`
- `scripts/autoload/platform_bridge.gd`
- `export_presets.cfg`

### Audit Findings

| Question | Phase 0 verdict | Evidence |
|---|---|---|
| Do ad docs and actual code state match? | Updated in Phase 3.5 plus user input update | Checklist/status docs now use `STRUCTURALLY_WIRED_BUILD_VALIDATED` for Ads and Game Center. Game Center console setup is `USER_REPORTED_DONE`; release is still blocked by adGroupId, settlement review, legal URLs, QR/device QA, and final `.ait`. |
| Does a top banner DOM slot exist? | Yes | `export_presets.cfg` injects `#ait-top-banner-slot`, `--ait-banner-height:96px`, and `window.CORE_BREAKER_TOSS_BANNER_SLOT_ID='ait-top-banner-slot'`. |
| Does real `TossAds.initialize` / `TossAds.attachBanner` exist? | Structurally yes in the web bridge prototype; not QR/device proven | `web/toss_bridge/src/core_breaker_toss_platform_bridge.ts` imports `TossAds` from `@apps-in-toss/web-framework` and calls `TossAds.initialize()` and `TossAds.attachBanner()`. `PlatformBridge` calls `window.CoreBreakerToss.ads.init()` and `attachTopBanner()`. Production wrapper inclusion and Toss runtime QA remain blocked. |
| Is rewarded revive structurally wired? | Structurally wired, not release-verified | `PlatformBridge.request_rewarded_revive_ad()` calls `window.CoreBreakerToss.ads.showRewardedRevive(adGroupId)`. `_on_rewarded_revive_ad_result()` grants success only for `USER_EARNED_REWARD`. Missing ad group ID / QR runtime still block release. |
| Is Game Center submit/open/user key structurally viable? | Structurally viable, QR/device blocked | `fetch_game_user_key()`, `submit_leaderboard_score()`, and `open_leaderboard()` use `window.CoreBreakerToss.game` first and historical `window.TossBridge` fallback only for Game Center/user-key paths. Async handling uses `JavaScriptBridge.create_callback` instead of assuming Promise results are synchronous. Console profile/leaderboard setup and Toss app QA remain required. |
| Is there a Promise/async mismatch risk? | Reduced, not fully eliminated until QR/device | Current `PlatformBridge` uses `_call_core_breaker_toss_async()` callback handling. The remaining risk is real Toss WebView/runtime behavior, not local static structure. |
| Is final `.ait` created? | No | No final `.ait` artifact is recorded. `exports/prebundle_dry_run/` exists only as dry-run output. |
| Is QR/device QA evidence present? | No | Docs consistently show QR/device QA as not run / blocked by console, ID, legal URL, or final export. |

### Phase 0 Release Gate Labels

| Gate | Status | Blocker label | Unblock condition |
|---|---|---|---|
| Ads runtime | Partial | `BLOCKED_BY_AD_GROUP_ID` / `BLOCKED_BY_QR_DEVICE_QA` | User provides banner/rewarded ad group IDs; wrapper is included in production export; Toss QR/private test proves banner and rewarded event matrix. |
| Game Center runtime | Partial | `USER_REPORTED_DONE / BLOCKED_BY_QR_DEVICE_QA` | Game profile and leaderboard are user-reported created; QR/device test must verify `getUserKeyForGame`, submit, and open behavior. |
| Legal/console | Blocked | `BLOCKED_USER_OR_TOSS_CONSOLE` | Public HTTPS terms/privacy URLs return 200; console registration, business, settlement, ad groups, and Game Center are confirmed. |
| Export packaging | Blocked | `BLOCKED_EXPORT_PACKAGING` | Final wrapper/Godot package policy is locked, size is measured, secrets/cache are excluded, then final `.ait` is generated in a later pass. |
| Code integrity | Structurally ready, not QR validated | `STRUCTURALLY_READY_NOT_QR_VALIDATED` | Keep `PlatformBridge` ownership, no guessed globals, no fake ad success, no UI score submit, then validate in Toss runtime. |

### Scope Boundary

Phase 0 changed only this audit snapshot document. No code, scenes, web prototype, `project.godot`, `export_presets.cfg`, gameplay, domain, progression, weapon, wall, projectile, asset, or final bundle files were modified in this phase.

## Phase 3 - Packaging Policy

- Packaging policy document: `docs/APP_IN_TOSS_PACKAGING_POLICY_2026-05-08.md`
- Selected strategy: `PACKAGING POLICY LOCKED: WRAPPER`
- Final bundle source directory candidate: `web/toss_wrapper/dist`
- Final `.ait` status: not created
- QR/device status: not run

## Phase 3.5 - Docs/Status Consistency Cleanup

- Current platform wording: `STRUCTURALLY_WIRED_BUILD_VALIDATED`, not done.
- Current packaging wording: `PACKAGING_POLICY_LOCKED_WRAPPER`.
- Required blocker labels: `BLOCKED_BY_AD_GROUP_ID`, `BLOCKED_BY_TOSS_CONSOLE_GAME_CENTER`, `BLOCKED_BY_LEGAL_URLS`, `BLOCKED_BY_BUSINESS_SETTLEMENT`, `BLOCKED_BY_QR_DEVICE_QA`, `BLOCKED_BY_FINAL_AIT_EXPORT`.
- Source-of-truth docs: `docs/APP_IN_TOSS_PLATFORM_BRIDGE_VALIDATION_2026-05-08.md`, `docs/APP_IN_TOSS_REWARDED_AD_GUARD_PATCH_2026-05-08.md`, `docs/APP_IN_TOSS_PACKAGING_POLICY_2026-05-08.md`, `docs/APP_IN_TOSS_CONSOLE_INPUTS.md`.
- Final `.ait` status: not created.

## Phase 4D/4E - Export Filter and Claude Warning Hardening

- Applied a Toss Web generated-path `exclude_filter`, pinned Vite/TypeScript/App-in-Toss bridge dependencies to installed versions, added release guardrail comments to future `scripts/platform` skeleton adapters, and documented wrapper-vs-Godot-direct banner slot ownership. Final `.ait` remains not created.

## Phase 3.9B - Rejection Checklist QA Docs Integration

- Integrated the uploaded 33 App-in-Toss rejection cases into `docs/TOSS_QR_DEVICE_QA_PLAN.md`: 12 already covered, 14 new QA required, 13 console/device required, 11 not applicable, 7 code-fix-only-if-QA-fails, and 16 remaining-before-review gates.
- New code work now: none. Runtime code should only be patched if QR/device QA produces a failing evidence item.
- Ads, rewarded revive, and Game Center remain App-in-Toss console + QR/private Toss App + physical-device validation items, not Godot local/headless final PASS items.

## Phase 5A - Legal URLs First

- Created static legal pages at `docs/legal/terms.html`, `docs/legal/privacy.html`, and `docs/legal/index.html`.
- Candidate GitHub Pages URLs are `https://everyseok.github.io/core-breaker-godot/legal/terms.html` and `https://everyseok.github.io/core-breaker-godot/legal/privacy.html`.
- Verification script: `tools/verify_legal_urls.sh`.
- Legal placeholders are `RESOLVED_NO_TODO`: operator `엔드포인트`, representative `김준석`, contact `junseok3055@gmail.com`, business registration number `711-34-01671`, effective date `2026년 5월 6일`; business address is listed as available through the operator contact channel.
- Current legal URL status remains `BLOCKED_BY_LEGAL_URLS` until GitHub Pages is enabled for `/docs` and both URLs return HTTP 200.
