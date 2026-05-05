# Android Phone Test From GitHub

Date: 2026-05-05
Scope: private GitHub debug APK artifact testing only.

## What This Is

- `APK` is for direct phone sideload testing.
- `AAB` is for Google Play submission later.
- The debug APK artifact in this flow is **not** a production release and **not** a Play Store submission package.

## Before You Start

- The repository must be private.
- You must have GitHub login access to the private repository.
- The workflow must have completed successfully.
- The repo must contain the `Android Debug APK` export preset in `export_presets.cfg`.
- The debug APK is configured as a launcher app so it should appear in the phone app drawer after install.

## Download Steps

1. Open the private GitHub repository.
2. Go to the **Actions** tab.
3. Select the workflow named **Android Debug APK**.
4. Open the latest successful run.
5. Scroll to the **Artifacts** section.
6. Download the artifact named `core-breaker-debug-apk`.
7. Unzip it if GitHub downloads it as a zip archive.
8. Inside, find:
   - `exports/android_debug/core_breaker_debug.apk`

## Install On Phone

1. Transfer the APK to the Android phone if you downloaded it on desktop.
2. Open the APK on the phone.
3. If Android blocks installation, allow **Install unknown apps / unknown sources** for the app you used to open the APK.
4. Continue the installation.
5. Launch the game and test runtime behavior.

If the app icon/title looks temporary, that is expected. Final launcher icon wiring is a later branding/export pass.

## Private Repo Access Note

- If the repo is private, the phone user must still have GitHub read access to download artifacts directly from GitHub.
- If the phone browser/session is not logged in to GitHub, the artifact download will fail.

## Artifact Retention

- GitHub Actions artifacts expire after the configured retention period.
- The current workflow is set to keep the APK artifact for `14` days.

## APK vs AAB

- `APK`: direct phone sideload / GitHub artifact testing
- `AAB`: Google Play submission format later

Do not treat the debug APK as a production release candidate.
