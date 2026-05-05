# Refactor / Release Architecture Audit

Date: 2026-05-05  
Master source-of-truth: [`docs/APP_IN_TOSS_MONETIZED_RELEASE_MASTER_CHECKLIST.md`](APP_IN_TOSS_MONETIZED_RELEASE_MASTER_CHECKLIST.md)

Scope: release-readiness and monetization-readiness architecture audit only. No implementation performed.

## Current Architecture Map

| Layer | Current Owner | Release-Relevant Notes |
|---|---|---|
| Domain rules | `scripts/domain/*` | Gameplay math, HP, damage, progression thresholds, wall rules. Out of scope for release docs and future ads/Game Center planning. |
| Application services | `scripts/application/*` | Progression/ring planning. Already dirty from earlier work; do not broaden scope here. |
| Gameplay | `scripts/gameplay/*` | Run orchestration and score/end-state timing. `GameRoot` should remain the only score-submit trigger owner. |
| Platform | `scripts/autoload/platform_bridge.gd`, `scripts/platform/*` | `PlatformBridge` is still the live Toss owner today; new no-op platform skeletons now reserve clean adapter boundaries for Google Play, ads, leaderboards, and editor fallback without touching gameplay. |
| Save | `scripts/autoload/save_manager.gd`, `scripts/infrastructure/persistence/save_file_repository.gd` | Owns local save, best record, sound flag, and `game_user_key`. |
| UI | `scripts/ui/*`, `scenes/ui/root_ui.tscn` | MainMenu/PauseMenu/HUD are single active systems; UI should only display state and route button actions. |
| Visual/VFX | `scripts/visual/*`, `scenes/vfx/*` | Visual-only ownership. Must not absorb ranking, ads, or progression logic. |
| Export/assets | `export_presets.cfg`, root assets, `assets/fonts`, `assets/branding` | Final export hygiene and branding/license proof remain external blockers. |
| CI artifact pipeline | `.github/workflows/android-debug-apk.yml` | Debug-only APK artifact workflow; not a production release path and not yet end-to-end validated. |

## Release-Critical Blockers

| ID | Problem | Evidence | Severity | Safest Fix Strategy | Timing |
|---|---|---|---|---|---|
| REL-BLOCK-01 | No Toss console registration | User context | Critical | Treat as `NEEDS_CONSOLE_ACCESS`; do not misclassify as code failure | Before release |
| REL-BLOCK-02 | No current final `.ait` export candidate | Export docs only; no current export artifact | Critical | Dedicated export prompt after asset hygiene | Before release |
| REL-BLOCK-03 | Branding is not fully locked | Public title/logo/console metadata are still unsettled | Critical | User locks title, icon, and title-logo direction | Before release |
| REL-BLOCK-04 | Asset/license proof is incomplete | No full license manifest exists | Critical | Create docs-only asset license manifest | Before release |
| REL-BLOCK-05 | Game Center is only structurally partial | Platform wrappers exist, but Toss-shell validation is missing | High | Dedicated Promise/runtime validation prompt after console setup | Before Game Center release |
| REL-BLOCK-06 | QR/device QA proof does not exist | No current device evidence in docs | Critical | Produce export then run QR/device QA | Before release |
| REL-BLOCK-07 | Android debug APK workflow is not yet CI-validated | `export_presets.cfg` now contains a debug-only Android preset, but no private push/workflow run has occurred | High | Fix private remote/auth, push feature branch, run workflow, download artifact | Before phone testing via GitHub |

## Monetization-Specific Risks

| ID | Risk | Evidence | Severity | Strategy |
|---|---|---|---|---|
| MON-RISK-01 | Persistent top banner can damage HUD readability and controls | 390x844 portrait, top HUD, bottom controls | High | Keep verdict `USER_DESIRED_BUT_REQUIRES_LAYOUT_REDESIGN_AND_OFFICIAL_ADS_QA`; no implementation now |
| MON-RISK-02 | Wrong ad timing can violate official guidance | Official docs prohibit intro/loading/cutscene/modal/ATF misuse | High | Prefer post-run interstitial or rewarded continue candidates only |
| MON-RISK-03 | Ads setup is externally blocked | User says business and console ads setup are not ready | Medium | Keep ads as `NOT_IMPLEMENTED / FUTURE` |
| MON-RISK-04 | Placeholder ad boxes and fake ad UI would create review debt | User explicitly forbids them and repo currently has none | High | Preserve no-placeholder/no-fake-UI rule |

## Maintainability Hotspots

| Hotspot | Evidence | Risk | Recommendation |
|---|---|---|---|
| Runtime UI builders | `GameOverScreen`, `WeaponChoicePanel`, `AimJoystick` still use `Panel.new/Button.new/Label.new` patterns | Medium maintainability, low immediate release risk | Classify only. Do not refactor in release planning pass. |
| `PlatformBridge` inline JS / Promise handling | Official APIs are Promise-based while current bridge validation is partial | High platform risk | Use a future dedicated platform pass, not an unrelated UI or gameplay pass. |
| `JavaScriptBridge.eval(...)` review sensitivity | Official game checklist flags external code execution patterns such as `eval`, while `PlatformBridge` currently uses static bundled JS strings via `JavaScriptBridge.eval(...)` | High review/policy risk, even if current usage is not remote-code execution | Keep all bridge JS isolated in `PlatformBridge`, avoid dynamic/user-provided code paths, and validate acceptability explicitly in a dedicated platform review pass. |
| Root duplicate assets | Root font/image copies remain | Medium export risk | Keep as later asset/export hygiene work only. |
| Branding drift | Public title and title art are not locked | Critical release risk | Brand decision before export/review. |
| Status/doc drift | Checklist IDs and JSON keys can diverge | Medium planning risk | Keep master checklist as source-of-truth and dedupe summary docs each pass. |

## Anti-Spaghetti Rules For Later Implementation

- `PlatformBridge` remains the live Toss owner today, but future platform-specific API calls should migrate behind `scripts/platform/*` adapters instead of being mixed into gameplay/UI code.
- `SaveManager` is the single owner for best score and `game_user_key`.
- `GameRoot` owns score-submit timing only.
- UI owns buttons, labels, and fallback copy only; UI must not submit scores directly.
- Ads must not live in gameplay or domain files.
- Game Center logic must not be duplicated across MainMenu, PauseMenu, and HUD.
- Banner-safe playfield scaling must come from one centralized layout owner, not scattered offsets in HUD, joystick, core, rings, or projectiles.
- Do not add fake ad UI or hidden placeholder ad boxes.
- Do not introduce a custom ranking backend unless official constraints force it later.
- Do not broad-refactor combat, domain, progression, or weapon balance before release.

## Recommended Refactor / Remediation Order

1. Brand/title/icon decision and license manifest.
2. Asset/export hygiene and fresh bundle measurement.
3. Toss console registration and Game Center console setup.
4. Promise-aware `PlatformBridge` validation in Toss shell.
5. QR/device QA for safe area, lifecycle, ranking, and persistence.
6. Ads planning only after business/console readiness exists.
7. Monitoring/Sentry planning.
8. Post-release maintainability cleanup for runtime UI builders and duplicate assets.

## Do Not Refactor Before Release Unless Blocking

- Damage values, BrickRules HP, progression thresholds, wall rules, projectile mechanics.
- Current HUD/MainMenu/PauseMenu layout just to make ad space.
- Active gameplay visuals just to prepare monetization.
- Asset deletions without evidence and user approval.
