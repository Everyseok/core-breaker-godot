# Next Step

**Phase:** Pre-Bundle Readiness Gate
**Date:** 2026-05-08
**Current verdict:** Final `.ait` export is not allowed. `PlatformBridge` is structurally wired/build validated through `window.CoreBreakerToss`, packaging policy is locked to Vite wrapper, Game Center console setup is user-reported done, legal URLs are verified 200, but adGroupIds, settlement review, QR/device QA, and final export validation are still blocked.

Master source-of-truth: [`docs/APP_IN_TOSS_MONETIZED_RELEASE_MASTER_CHECKLIST.md`](APP_IN_TOSS_MONETIZED_RELEASE_MASTER_CHECKLIST.md)
Breadth audit: [`docs/APP_IN_TOSS_DEVCENTER_FULL_AUDIT.md`](APP_IN_TOSS_DEVCENTER_FULL_AUDIT.md)
Dual-platform audit: [`docs/DUAL_PLATFORM_BRIDGE_AUDIT.md`](DUAL_PLATFORM_BRIDGE_AUDIT.md)
Google Play checklist: [`docs/GOOGLE_PLAY_RELEASE_MASTER_CHECKLIST.md`](GOOGLE_PLAY_RELEASE_MASTER_CHECKLIST.md)
Phone artifact guide: [`docs/ANDROID_PHONE_TEST_FROM_GITHUB.md`](ANDROID_PHONE_TEST_FROM_GITHUB.md)

## Next 10 Execution Tasks

1. **Rejection Checklist Integrated**
   - `docs/APP_IN_TOSS_REJECTION_CASE_AUDIT.md` is now the rejection-case mapping source.
   - Keep `TOSS-NAV-01`, `TOSS-SCHEME-01`, `TOSS-UX-01`, `TOSS-UX-02`, `TOSS-ADS-EVENT-01`, `TOSS-EXTERNAL-01`, `TOSS-BRAND-01`, `TOSS-PERM-01`, `TOSS-MOTION-01`, and `TOSS-COMPLETE-01` as QR/device QA gates.

2. **PlatformBridge Wiring to `window.CoreBreakerToss`**
   - Structurally wired/build validated.
   - Keep `window.CoreBreakerToss` as the primary path.
   - Do not use guessed globals such as `window.TossAds`, `window.loadFullScreenAd`, or `window.showFullScreenAd`.
   - Do not mark QR/device runtime as passed until tested in Toss.

3. **Provide Console IDs and Legal URLs**
   - Final public title is `코어브레이커`; Toss Console service name is `코어 브레이커`.
   - User/Toss Console must provide banner ad group ID and rewarded revive ad group ID after review approval.
   - Keep production IDs out of commit until sensitivity policy is confirmed.
   - Legal URLs are verified 200 and can be entered in App-in-Toss Console.
   - Terms: `https://everyseok.github.io/core-breaker-godot/legal/terms.html`
   - Privacy: `https://everyseok.github.io/core-breaker-godot/legal/privacy.html`
   - Legal placeholders are resolved with operator `엔드포인트`, representative `김준석`, contact `junseok3055@gmail.com`, business registration number `711-34-01671`, and effective date `2026년 5월 6일`.
   - Legal copy status is `PRODUCTION_COPY_READY`; no draft or public-HTTPS-pending warning remains in the production pages.

4. **Configure Game Center**
   - Game profile and leaderboard are `USER_REPORTED_DONE`.
   - Leaderboard name is `기본단위`.
   - Keep score model as `total_progress`, higher-is-better, unless the console display unit requires a later doc/config adjustment.
   - Do not mark runtime verification done until QR/private Toss App device QA passes.

5. **Run QR/Device QA**
   - Use `docs/TOSS_QR_DEVICE_QA_PLAN.md`.
   - Rejection checklist inventory is integrated into the QR/device plan: 33 total rejection cases, 16 remaining-before-review gates, 7 code-fix-only-if-QA-fails areas.
   - Community audit additions are included: verify full ad failure matrix, submit only low QR test scores, and confirm no destructive/high-score leaderboard record remains before review.
   - Verify banner visibility, rewarded completion/skip/fail, ranking submit/open, safe area, background/foreground, audio restore, legal links, common navigation, and external-link policy.
   - Do not mark ads, rewarded revive, or Game Center as final PASS from Godot local/headless; those require App-in-Toss console + QR/private Toss App + physical device evidence.

6. **Use Wrapper Packaging Policy**
   - Packaging policy is `PACKAGING_POLICY_LOCKED_WRAPPER`.
   - Future final source directory candidate is `web/toss_wrapper/dist`.
   - Current wrapper dry-run size is `55M`; final size must be remeasured after the final Godot export.
   - Do not stage `exports/prebundle_dry_run/`, `web/toss_wrapper/dist/`, `web/toss_wrapper/public/godot/`, or `web/toss_wrapper/public/toss/`.

7. **Reconcile Asset License Gaps**
   - Confirm app icon/logo/thumbnail/font sources.

8. **Update Readiness JSON**
   - Keep `submit_ready=false` and `final_ait_allowed=false` until console/legal, QR/device QA, and export packaging gates are resolved.

## Release Gate Validation Commands

Run before final export:

```sh
git diff --check
python3 -m json.tool data/pre_bundle_readiness.json > /tmp/pre_bundle_readiness_check.json
rg -n "window.TossAds|window.loadFullScreenAd|window.showFullScreenAd|iframe" web scripts export_presets.cfg
rg -n "submit_leaderboard_score" scripts
rg -n "USER_EARNED_REWARD|rewarded_revive_ad_completed|revive_after_reward" scripts web
```

9. **Final `.ait` Export Pass**
   - Only after the above blockers are resolved or explicitly accepted.
   - Re-run dry export after export filter cleanup before creating final `.ait`.

10. **Submission Review**
   - Confirm console screenshots, legal URLs, bundle size, and device QA evidence.

## Historical APK Tasks

1. **Private GitHub Remote / Auth Prompt**
   - Add a verified private GitHub remote.
   - Repair `gh` authentication.
   - Only then create and push `feature/android-debug-apk-artifact`.

2. **Private Branch Push Prompt**
   - Create or switch to `feature/android-debug-apk-artifact` only after private remote/auth verification passes.
   - Commit only the intended APK pipeline, docs, and skeleton-hardening files.
   - Do not push to `main` or `master`.

3. **GitHub Actions APK Artifact Prompt**
   - Run the hardened workflow after remote/auth are fixed.
   - Verify artifact output path `exports/android_debug/core_breaker_debug.apk`.

4. **Visible Interactive Godot QA Prompt**
   - Run a visible Godot session.
   - Confirm current layout feel before any ad-safe playfield prototype.

5. **Platform Runtime Wiring Prompt**
   - Decide whether to start migrating `PlatformBridge` callers to platform-neutral adapters.
   - Keep gameplay/domain files untouched.

6. **Google Play Package / Keystore Prompt**
   - Lock package name and signing strategy.
   - Decide Play App Signing ownership.

7. **Ad-Safe Playfield Prototype Prompt**
   - Wire a centralized playfield layout owner.
   - Reserve top-banner height without shrinking HUD/joystick randomly.

8. **Google Play Services Decision Prompt**
   - Decide whether the Google Play build uses Play Games leaderboards.
   - Keep `total_progress` as the only score model.

9. **Ads Integration Planning Prompt**
   - Keep production ads disabled.
   - Use test-only planning for banner/interstitial/rewarded.

10. **App-in-Toss Console + Device QA Prompt**
   - Continue Toss console registration and QR/device QA separately.

## Newly Clarified From Full Developer Center Audit

- App-in-Toss and Google Play can share the same game core if platform APIs are moved behind adapters.
- `JavaScriptBridge.eval(...)` remains isolated to Toss-only bridge ownership and must not leak into Android/Google Play code.
- A top banner requires a centralized playfield layout owner before any SDK integration.
- APK is now explicitly treated as private phone sideload / GitHub artifact testing only.
- `Android Debug APK` exists as a debug-only export preset with temporary package `com.junseokism.corebreaker.debug`.
- AAB remains the later Google Play submission format.

## User-Action Blockers

- Add a private GitHub remote and restore `gh` auth if you want Codex to push this pass.
- Validate the Android Debug APK export preset in GitHub Actions.
- Keep staging path-specific because the current worktree contains pre-existing gameplay/domain/scene/asset changes outside the APK pipeline scope.
- Final public title is user-reported as `코어브레이커`; audit all title/legal/icon surfaces before review.
- Final approval of `app_icon_600.png`.
- Asset/license proof.
- Toss console registration and QR/device QA.
- Future Google Play Console access, package-name decision, privacy policy URL, and signing ownership.

## Guardrails

- Do not change gameplay math, balance, or progression in platform-readiness prompts.
- Do not implement production ads or SDK IDs in readiness/audit passes.
- Do not mix Toss-only and Google Play-only API calls inside the same unguarded function.
- Do not scatter banner offsets across HUD, joystick, ring spawner, core, or projectile files.
- Do not push until remote privacy is verified and GitHub auth is healthy.
- Do not use `git add .` for this branch; stage only release-pipeline/docs/platform-skeleton files after reviewing the dirty worktree.
