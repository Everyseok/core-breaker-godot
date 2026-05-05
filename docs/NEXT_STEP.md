# Next Step

**Phase:** 4.25 — Android Debug APK Pipeline Remediation
**Date:** 2026-05-05
**Current verdict:** Shared core can support App-in-Toss and Google Play, the Android Debug APK preset now exists, and the GitHub Actions workflow is hardened for a real debug APK attempt; private push is still blocked by missing remote and invalid `gh` auth.

Master source-of-truth: [`docs/APP_IN_TOSS_MONETIZED_RELEASE_MASTER_CHECKLIST.md`](APP_IN_TOSS_MONETIZED_RELEASE_MASTER_CHECKLIST.md)
Breadth audit: [`docs/APP_IN_TOSS_DEVCENTER_FULL_AUDIT.md`](APP_IN_TOSS_DEVCENTER_FULL_AUDIT.md)
Dual-platform audit: [`docs/DUAL_PLATFORM_BRIDGE_AUDIT.md`](DUAL_PLATFORM_BRIDGE_AUDIT.md)
Google Play checklist: [`docs/GOOGLE_PLAY_RELEASE_MASTER_CHECKLIST.md`](GOOGLE_PLAY_RELEASE_MASTER_CHECKLIST.md)
Phone artifact guide: [`docs/ANDROID_PHONE_TEST_FROM_GITHUB.md`](ANDROID_PHONE_TEST_FROM_GITHUB.md)

## Next 10 Execution Tasks

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
- Final public title decision.
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
