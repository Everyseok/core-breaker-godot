# Next Step

**Phase:** 4.21 — Ads Implementation Pass (BLOCKED — awaiting console/business/settlement setup)
**Context:** Phase 4.20 ads planning complete (Session 42). Official APIs confirmed. Placement policy locked. Prerequisites documented. No code implemented.

---

## Phase 4.20 — Done (Session 42)

### Ads Plan — Locked Decisions

**Official APIs (confirmed from App-in-Toss Developer Center):**

| Format | API | Min Toss Version |
|--------|-----|-----------------|
| Full-screen interstitial | `loadFullScreenAd()` → `showFullScreenAd()` (IntegratedAd v2) | v5.247.0 (v2); v5.227.0 (AdMob fallback) |
| Reward | Same IntegratedAd v2, `userEarnedReward` event | v5.247.0 / v5.227.0 |
| Banner | `TossAds.initialize()` → `TossAds.attachBanner()` | v5.241.0 |

**Banner dimensions (official):** width 100% screen; height 96px (fixed/list) or 410px (feed/native).
**All calls via `JavaScriptBridge` in PlatformBridge — no binary SDK added to Godot bundle.**

**Locked interstitial trigger points:**
- `GameState.game_over` → preload + show on game-over screen
- `GameState.max_level_cleared` → preload + show on max-clear screen
- Between-run on restart tap (after current run ends)
- Frequency limit + cooldown required (official QA requirement)

**Locked interstitial exclusions (official `ads/develop.md` prohibited placements):**
- Active gameplay — PROHIBITED
- Loading / intro screens — PROHIBITED
- Modal dialogs (PauseMenu is a modal overlay) — PROHIBITED; **pause-screen ad is explicitly excluded**
- Game UI overlap (joystick, skill bar, HUD) — PROHIBITED

**Banner placement candidate:**
- Bottom: below joystick / skill bar, above safe-area bottom inset (96px height)
- Requires device QA to confirm no overlap with gameplay controls
- Fallback: top banner below HUD K-progress bar (requires HUD layout adjustment)

**Audio behavior (official QA requirement):**
- `AudioManager.mute_all()` before `showFullScreenAd()`
- `AudioManager.restore_mute_state()` on `dismissed` or `failedToShow`
- Banner: no audio pause required

**Ad failure behavior (non-blocking rule):**
- Any ad failure → proceed normally; never block restart or game-over screen

---

## Phase 4.21 Prerequisites (BLOCKED)

Before any ad code is written, the following must be complete:

1. **Business registration** in Toss console (required first)
2. **Terms agreement** in Toss console
3. **Settlement information** (banking; ~2–3 business day review)
4. **Ad group creation** in console (format + placement; IDs take ~2h to register with Google)
5. **Test ad IDs available** after ad group setup:
   - `ait-ad-test-interstitial-id`
   - `ait-ad-test-banner-id`
   - `ait-ad-test-rewarded-id`

**Current status of prerequisites:** NOT STARTED — same person/org doing Toss console registration (C-25/C-28) should handle this at the same time.

---

## High-Priority Gates (Pre-Submission)

- [ ] **C-25/C-28: Toss console registration** — app name, icon (600×600px), scheme URL. **Primary blocker for QR test.**
- [ ] **TQA-01: Toss QR/device test** — official gate; min 1 test required before review request button activates.
- [ ] **Phase 4.21 Ads implementation** — blocked on console/business/settlement setup above.

---

## Still-Open Interactive Confirmation

- [ ] Confirm walls rotate smoothly without jitter (Phase 4.17 fix)
- [ ] Confirm 7-shot siege and K1000 level transition feel correct on screen
- [ ] Confirm MAX LEVEL CLEAR result screen displays correctly on device

---

## Guardrails

- Do not implement Hybrid combat
- Do not change combat balance, walls, or K-loop
- Do not auto-open leaderboard (must be user-triggered)
- Do not implement ads before console/business/settlement setup is complete
- Do not show ads during pause (PauseMenu = modal = prohibited placement per official docs)
- Do not show ads during active gameplay, loading, or intro

---

## Definition of Done

Phase 4.20 is done: official ad APIs confirmed, placement policy locked, prerequisites documented. Phase 4.21 (ads implementation) is blocked on Toss console prerequisites. Toss-shell runtime confirmation (TQA-01) is the next hard gate before submission.
