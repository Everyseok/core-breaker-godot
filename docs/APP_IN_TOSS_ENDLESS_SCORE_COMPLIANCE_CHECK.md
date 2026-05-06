# App-in-Toss Endless Score Compliance Check

Date: 2026-05-06

Scope:
- Latest gameplay change: endless score model, best-record gauge, repeated weapon choice at `2000 + 1000n`.
- This is a documentation/audit pass only. No gameplay code was changed in this pass.

## Verdict

The endless score model itself is not blocked by the official App-in-Toss Developer Center documents checked in this pass.

Current verdict:
- Endless score: OK by policy, if score calculation is stable and saved/submitted only after final game completion.
- Best-record gauge: OK by policy, because it is local gameplay UI and does not fake ranking data.
- Repeated weapon-choice panel: OK by policy, if it remains responsive, non-misleading, and does not trap the user.
- Release-ready today: No. Console, QR/device QA, final `.ait` export, Game Center shell validation, and review-sensitive bridge implementation remain blockers.

## Official Sources Checked

Primary official sources:
- `https://developers-apps-in-toss.toss.im/development/llms.html`
- `https://developers-apps-in-toss.toss.im/llms.txt`
- `https://developers-apps-in-toss.toss.im/llms-full.txt`
- `https://developers-apps-in-toss.toss.im/checklist/app-game.html`
- `https://developers-apps-in-toss.toss.im/design/resolution.html`
- `https://developers-apps-in-toss.toss.im/game-center/develop.html`
- `https://developers-apps-in-toss.toss.im/bedrock/reference/framework/게임/submitGameCenterLeaderBoardScore.html`
- `https://developers-apps-in-toss.toss.im/bedrock/reference/framework/게임/getUserKeyForGame.html`
- `https://developers-apps-in-toss.toss.im/development/deploy.html`
- `https://developers-apps-in-toss.toss.im/development/test/toss.html`
- `https://developers-apps-in-toss.toss.im/development/test/sandbox.html`
- `https://developers-apps-in-toss.toss.im/ads/develop.html`
- `https://developers-apps-in-toss.toss.im/ads/qa.html`

Tools used:
- Browser Use opened `development/llms.html` and `checklist/app-game.html`.
- `docs-search` found the official Game Center leaderboard and user-key docs.
- Direct official docs browsing checked game checklist, resolution, deploy, test, sandbox, ads, and Game Center pages.

## Current Repo Evidence

Latest implementation evidence:
- `scripts/autoload/game_state.gd`
  - `DEFAULT_SCORE_GAUGE_MAX = 2000`
  - `FIRST_REPEATED_WEAPON_CHOICE_SCORE = 2000`
  - `WEAPON_CHOICE_REPEAT_SCORE = 1000`
  - `add_k()` increments `current_level_k` continuously and does not emit `level_transitioned`.
  - `_sync_progress_values()` sets `total_progress = current_level_k`.
  - `_finalize_game_over()` is the score-save path and emits `game_over`.
- `scripts/ui/hud.gd`
  - HUD gauge text displays `current_score/gauge_max`.
  - `gauge_max` is from `GameState.get_score_gauge_max()`.
- `scripts/gameplay/game_root.gd`
  - Brick destruction calls `GameState.add_k(1)`.
  - Final game-over path submits `SaveManager.get_best_record_value()` through `PlatformBridge`.
- `scripts/autoload/platform_bridge.gd`
  - Duplicate leaderboard submission is gated by `_score_submitted_this_run`.
  - Toss/Game Center calls are centralized in `PlatformBridge`.

## Compliance Matrix

| Item | Status | Source | Evidence | Risk | Required next action |
|---|---|---|---|---|---|
| Score can continue endlessly in one run | OK | LOCAL_REPO / INFERRED | `GameState.add_k()` no longer resets score | Low | Device QA after export |
| Best-record gauge uses saved best or `2000` fallback | OK | LOCAL_REPO | `GameState.get_score_gauge_max()` | Low | Test with saved best under/over 2000 |
| Game score flow must not be broken | PARTIAL | OFFICIAL_DOC / LOCAL_REPO | Game checklist requires score/stage flow to work; code now saves on finalization | Medium | Long-run smoke test beyond 2000, 3000, 4000 |
| Play records must persist | PARTIAL | OFFICIAL_DOC / LOCAL_REPO | `SaveManager.record_run_result()` still runs in `_finalize_game_over()` | Medium | QR/Toss shell persistence test |
| Leaderboard submit timing | OK structurally | OFFICIAL_DOC / LOCAL_REPO | Game Center docs say submit after game completion; `GameRoot._on_game_over()` submits after final game-over | Medium | Toss console profile and QR test |
| No leaderboard submit on app entry | OK structurally | OFFICIAL_DOC / LOCAL_REPO | No submit call in `start_game()` or `add_k()` | Low | Runtime log check in Toss shell |
| Duplicate leaderboard submit prevention | OK structurally | OFFICIAL_DOC / LOCAL_REPO | `_score_submitted_this_run` gate in `PlatformBridge` | Medium | Validate across revive/decline/restart |
| `submitGameCenterLeaderBoardScore` score type | OK structurally | OFFICIAL_DOC / LOCAL_REPO | Docs require score as numeric string; code converts integer best to string | Low | Validate actual TossBridge return |
| Game user key handling | PARTIAL | OFFICIAL_DOC / LOCAL_REPO | `getUserKeyForGame` handled in `PlatformBridge`, saved through `SaveManager` | Medium | Console game category and Toss app 5.232.0+ validation |
| Fullscreen / Safe Area / no gaps | PARTIAL | OFFICIAL_DOC / LOCAL_REPO | `project.godot` 390x844, stretch canvas; recent phone screenshots showed background/safe-area issues | High | Real device QR test and background fix validation |
| Touch interactions under 2 seconds | UNKNOWN | OFFICIAL_DOC / USER_QA | User reported joystick direction issues on phone earlier | High | Physical phone touch QA after latest build |
| Ads placement | NOT IN THIS CHANGE | OFFICIAL_DOC / LOCAL_REPO | Banner slot exists in Web export head include, but no real ad integration here | Medium | Ensure real ad SDK only; no fake ad UI; top/bottom only |
| App bundle size | PARTIAL | OFFICIAL_DOC / LOCAL_REPO | Current assets about 13M, historical exports 36M; final `.ait` not generated | Medium | Fresh `.ait` export and unpacked size check under 100MB |
| Review-sensitive `eval` usage | RISK | OFFICIAL_DOC / LOCAL_REPO | Game checklist forbids executing externally delivered code such as `eval`; `PlatformBridge` uses Godot `JavaScriptBridge.eval` for static bridge calls | High | Replace or justify with official Godot Web bridge strategy before submission |

## Important Official Findings Applied

Game release checklist:
- First screen should open normally within the required launch-time window.
- Sound and background/foreground audio behavior must be correct.
- Safe Area, exit path, CTA clarity, UI responsiveness, persistence, and score/stage flow must work.
- External code execution such as `eval` is listed as prohibited, so current `JavaScriptBridge.eval` usage is review-sensitive even though the project uses static strings.

Resolution:
- Game miniapps must be fullscreen.
- No WebView gaps or letterboxing.
- Notch, camera hole, and Dynamic Island must be handled with Safe Area.
- One logical resolution should be used instead of per-device layout forks.

Game Center:
- Score submission is for game completion.
- Do not submit immediately on game entry.
- Game profile must exist before score submission.
- Toss app minimum version applies.
- Sandbox scores do not reflect live service leaderboard.

Deploy/test:
- `.ait` upload requires unpacked bundle size under 100MB.
- At least one Toss app test is required before review request.
- QR/private and live environments can differ, especially CORS/network/resource behavior.

Ads:
- Banner ads must not overlap major interactive UI.
- Game ads can be top or bottom, not center.
- Rewarded/fullscreen ads must be user-understandable, preloaded, and QA-tested on real devices.
- This pass did not implement ads.

## Does The Latest Endless Score Change Violate App-in-Toss?

No direct violation found.

Reasoning:
- App-in-Toss docs do not require games to have finite levels.
- A continuous score is acceptable if the game score measurement flow is correct.
- Leaderboard docs accept a numeric score string and do not require a level number.
- The current implementation still saves only at final game-over and submits only after finalization.

## Remaining Release Risks

1. `JavaScriptBridge.eval` usage in `PlatformBridge` is the largest policy-sensitive code risk.
2. Real Toss shell QR/device QA is still required before any compliance item can be marked fully done.
3. The phone screenshots previously showed device-only issues: missing/incorrect background and joystick direction behavior. Those must be rechecked after fresh APK/Web export.
4. Final `.ait` export has not been generated for this exact commit, so the 100MB unpacked bundle rule is not proven for this version.
5. Game Center remains structurally partial until console game profile and device validation are complete.

## Recommended Next Fix Order

1. Fresh Android APK/Web smoke test for current commit `d57a2f5` or later.
2. Confirm phone background asset and joystick direction issue are fixed in the actual installed build.
3. Build a fresh Toss Web export and measure unpacked bundle size.
4. Replace or isolate `JavaScriptBridge.eval` bridge calls before App-in-Toss submission review.
5. Register App-in-Toss console app, game category/profile, and leaderboard.
6. Run QR private Toss app test and verify save/score/leaderboard behavior.
