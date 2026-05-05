# Core Breaker Debug

Portrait mobile radial survival game built with Godot.

## What This Game Is

- You defend the core at the center of the screen.
- Concentric brick walls shrink inward.
- You aim with the bottom joystick and auto-fire outward.
- Break as many walls as possible before anything reaches the core.

## Quick Links

- Private GitHub repo: [Everyseok/core-breaker-godot](https://github.com/Everyseok/core-breaker-godot)
- Android APK workflow: [Actions / Android Debug APK](https://github.com/Everyseok/core-breaker-godot/actions/workflows/android-debug-apk.yml)
- Phone install guide: [docs/ANDROID_PHONE_TEST_FROM_GITHUB.md](docs/ANDROID_PHONE_TEST_FROM_GITHUB.md)

## Download The Android APK

The APK is distributed through GitHub Actions artifacts.

1. Open the workflow page:
   [Android Debug APK](https://github.com/Everyseok/core-breaker-godot/actions/workflows/android-debug-apk.yml)
2. Open the latest **successful** run.
3. In **Artifacts**, download:
   `core-breaker-debug-apk`
4. Unzip the downloaded artifact.
5. Inside the archive, install:
   `exports/android_debug/core_breaker_debug.apk`

## Important Notes

- This is a **private testing APK**, not a production store build.
- The workflow artifact is expected to be named:
  `core-breaker-debug-apk`
- The APK may be blocked by Android until you allow install from unknown apps in your browser or file manager.

## Current Build Status

- Debug APK target path:
  `exports/android_debug/core_breaker_debug.apk`
- GitHub Actions workflow file:
  `.github/workflows/android-debug-apk.yml`
- Export preset:
  `Android Debug APK`

## Documentation

- App-in-Toss master checklist:
  [docs/APP_IN_TOSS_MONETIZED_RELEASE_MASTER_CHECKLIST.md](docs/APP_IN_TOSS_MONETIZED_RELEASE_MASTER_CHECKLIST.md)
- Developer Center full audit:
  [docs/APP_IN_TOSS_DEVCENTER_FULL_AUDIT.md](docs/APP_IN_TOSS_DEVCENTER_FULL_AUDIT.md)
- Google Play release checklist:
  [docs/GOOGLE_PLAY_RELEASE_MASTER_CHECKLIST.md](docs/GOOGLE_PLAY_RELEASE_MASTER_CHECKLIST.md)
