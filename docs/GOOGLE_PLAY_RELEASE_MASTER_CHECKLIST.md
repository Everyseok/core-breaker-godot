# Google Play Release Master Checklist

Date: 2026-05-05
Scope: planning and release-readiness only. No production AdMob IDs, no Play Games SDK integration, no upload in this pass.

## Verdict

- Can upload today: `NO`
- Core reason: the repo now has a debug-only Android APK preset for private phone testing, but there is no production AAB preset, no Android plugin integration path, no production signing/keystore setup, no Play Console app setup, no Data Safety completion, no privacy policy flow, and no Google Play QA yet.
- A hardened GitHub Actions APK artifact workflow now exists, but it is not enough to make Google Play or Android distribution "ready" by itself.

## Official References Checked

- Google Play app setup: [Create and set up your app](https://support.google.com/googleplay/android-developer/answer/9859152?hl=en)
- Google Play target API: [Target API level requirements](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en-EN)
- Play App Signing: [Use Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756?hl=en)
- Data Safety: [Provide information for Google Play's Data safety section](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en-419)
- App content / Contains ads: [Prepare your app for review](https://support.google.com/googleplay/android-developer/answer/9859455?hl=en)
- Ads policy: [Ads policy / disruptive ads](https://support.google.com/googleplay/android-developer/answer/9857753?hl=en)
- AdMob banner: [Banner ads](https://developers.google.com/admob/android/banner)
- AdMob interstitial: [Interstitial ads](https://developers.google.com/admob/android/interstitial)
- AdMob rewarded: [Rewarded ads](https://developers.google.com/admob/android/rewarded)
- AdMob test ads: [Enable test ads](https://developers.google.com/admob/android/test-ads)
- Play Games leaderboards: [Leaderboards](https://developer.android.com/games/pgs/leaderboards)
- Godot Android export: [Exporting for Android](https://docs.godotengine.org/en/latest/getting_started/workflow/export/exporting_for_android.html)
- Godot Android plugins: [Godot Android plugins](https://docs.godotengine.org/en/4.3/tutorials/platform/android/android_plugin.html)

## 1. Can Upload Today?

- `NO`
- Missing for production:
  - production AAB export preset
  - Android package name / application ID lock
  - non-debug signing keystore / upload key
  - Play Console app creation
  - Play App Signing acceptance
  - privacy policy URL
  - Data Safety form
  - content rating / target audience / app content declarations
  - "Contains ads" declaration strategy
  - Android runtime QA
  - Android plugin plan for ads / Play Games

## 2. Android Export Readiness

- Current repo state:
  - `export_presets.cfg` contains the Toss Web preset.
  - `export_presets.cfg` also contains `Android Debug APK` for private sideload testing.
  - Debug APK output path: `exports/android_debug/core_breaker_debug.apk`.
  - Temporary debug package: `com.junseokism.corebreaker.debug`.
  - Debug package is launchable from the Android app drawer for phone QA.
  - `INTERNET` permission remains off for pure debug; ads, Play Games, or Sentry must re-enable it later in a dedicated platform pass.
  - Launcher icon paths are not wired yet; Android may use default project/icon fallback until a later branding/export pass.
  - No production AAB preset exists.
  - No Android plugin folder or Gradle-based Godot Android plugin integration exists.
- Required later:
  - install Android export templates
  - configure Android SDK / JDK 17
  - keep CI Android SDK packages aligned with Godot Android export requirements (`platforms;android-35`, `build-tools;35.0.1`, CMake, NDK, and command-line tools)
  - run the GitHub Actions debug APK workflow on a verified private branch
  - choose final production package name
  - choose production keystore / upload key path
  - add a production AAB preset only after signing and Play Console decisions are locked

## 3. AAB Requirement

- Google Play requires new apps to be published as an Android App Bundle (`.aab`).
- Android APK-first release planning is not sufficient for store submission.
- APK is still useful for direct private phone sideload testing and GitHub Actions artifacts.

## 3A. APK vs AAB

- `APK`
  - direct phone sideload testing
  - GitHub Actions artifact download
  - not a Play Store submission format for new apps
- `AAB`
  - required Play Store submission format later
  - separate from this debug-artifact pass

## 4. Target API Requirement

- As of the currently checked policy, new apps and app updates must target Android 15 / API 35 or higher for Google Play submission.
- This must be rechecked immediately before real submission because Google Play timelines can change.

## 5. Package Name / Application ID

- Required later:
  - choose one final Android package name
  - keep it distinct from any App-in-Toss web identity
  - keep it stable once testing/distribution begins

## 6. Play App Signing / Keystore

- Required later:
  - choose whether Google manages the app signing key through Play App Signing
  - generate and store the upload key safely
  - document keystore ownership / backup responsibility
- Do not lose the upload key.

## 7. Play Console Setup

- Required later:
  - create the app in Play Console
  - choose app/game, free/paid, language, contact email
  - accept Play App Signing terms and declarations

## 8. Store Listing

- Required later:
  - app name
  - icon
  - screenshots
  - feature graphic if required for the chosen surfaces
  - short description
  - full description

## 9. App Content

- Required later:
  - Data Safety
  - Contains ads declaration
  - Content rating
  - Target audience
  - Privacy policy

## 10. AdMob Planning

- Not implemented now.
- Required later:
  - AdMob account setup
  - app setup
  - banner unit
  - interstitial unit
  - rewarded unit only if the product actually uses rewarded continue
  - test ads during development
- Hard rule:
  - never use production ad unit IDs during development or QA setup work

## 11. Google Play Games Planning

- Not implemented now.
- Required later:
  - Games Services project setup
  - player sign-in decision
  - leaderboard creation
  - score submit by `total_progress`
  - open leaderboard flow
- Score model should stay aligned with the shared core:
  - `total_progress = (current_level - 1) * 1000 + current_level_k`

## 12. Release Tracks

- Required later:
  - internal testing
  - closed/open testing if needed
  - production

## 13. Review Blockers

- No verified private GitHub remote / auth path for pushing the workflow yet
- Android Debug APK preset still needs CI validation
- No production AAB export preset
- No Android plugin plan wired
- No Play Console app setup
- No signing setup
- No Data Safety completion
- No privacy policy URL
- No "Contains ads" declaration decision executed
- No Android device QA

## 14. User-Action Checklist

- Create/verify private Google Play developer account / console access
- Approve package name
- Approve store branding and listing text
- Provide privacy policy destination
- Decide whether Google Play build uses Play Games leaderboards
- Decide whether Google Play build uses ads at all

## 15. Codex-Action Checklist

- Keep `.github/workflows/android-debug-apk.yml` as a debug-artifact-only workflow.
- Keep `docs/ANDROID_PHONE_TEST_FROM_GITHUB.md` aligned with private-repo artifact download behavior.
- Validate the Android Debug APK preset through GitHub Actions
- Add production AAB export preset later
- Add platform-neutral bridge wiring later
- Add Android plugin integration plan later
- Add Play Games bridge later if approved
- Add AdMob bridge later if approved
- Run Android device QA later
