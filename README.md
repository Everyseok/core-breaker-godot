# Core Breaker Debug

Core Breaker Debug is a portrait mobile radial survival game built with Godot.  
You defend the center core, break shrinking concentric walls, and survive as long as possible.

Korean version: [README.ko.md](README.ko.md)

[![Private Repo](https://img.shields.io/badge/PRIVATE-REPO-2f3640?style=for-the-badge&logo=github)](https://github.com/Everyseok/core-breaker-godot)
[![Download APK](https://img.shields.io/badge/DOWNLOAD-APK-e67e22?style=for-the-badge&logo=android)](https://github.com/Everyseok/core-breaker-godot/releases/download/android-debug-latest/core-breaker-debug.apk)
[![Latest Release](https://img.shields.io/badge/LATEST-DEBUG%20RELEASE-1f6feb?style=for-the-badge&logo=github)](https://github.com/Everyseok/core-breaker-godot/releases/tag/android-debug-latest)
[![Phone Guide](https://img.shields.io/badge/PHONE-INSTALL%20GUIDE-2980b9?style=for-the-badge&logo=readthedocs)](docs/ANDROID_PHONE_TEST_FROM_GITHUB.md)
[![AAB Later](https://img.shields.io/badge/GOOGLE%20PLAY-AAB%20LATER-4b5563?style=for-the-badge&logo=googleplay)](docs/GOOGLE_PLAY_RELEASE_MASTER_CHECKLIST.md)

## Quick Links

- [Direct APK download](https://github.com/Everyseok/core-breaker-godot/releases/download/android-debug-latest/core-breaker-debug.apk)
- [Open the latest debug release page](https://github.com/Everyseok/core-breaker-godot/releases/tag/android-debug-latest)
- [Open the Android Debug APK workflow](https://github.com/Everyseok/core-breaker-godot/actions/workflows/android-debug-apk.yml)
- [Open the private repository](https://github.com/Everyseok/core-breaker-godot)
- [Open the phone install guide](docs/ANDROID_PHONE_TEST_FROM_GITHUB.md)
- [Open the Google Play release checklist](docs/GOOGLE_PLAY_RELEASE_MASTER_CHECKLIST.md)

## Download APK

The current Android package is distributed through a **private GitHub Release asset** backed by the Android Debug APK workflow.

Primary direct download link:

- [Download core-breaker-debug.apk](https://github.com/Everyseok/core-breaker-godot/releases/download/android-debug-latest/core-breaker-debug.apk)

Fallback path if the direct link is not ready yet:

1. Open the workflow page:
   [Android Debug APK](https://github.com/Everyseok/core-breaker-godot/actions/workflows/android-debug-apk.yml)
2. Open the latest **successful** run.
3. In **Artifacts**, download:
   `core-breaker-debug-apk`
4. Unzip the downloaded archive.
5. Inside the archive, install:
   `exports/android_debug/core_breaker_debug.apk`

## Install On Android

- Download the artifact on your phone or transfer the APK from desktop.
- Open `core_breaker_debug.apk`.
- If Android blocks installation, allow **Install unknown apps** for your browser or file manager.
- Launch **Core Breaker Debug** from the app drawer after installation.

## Current Build Status

- APK output path:
  `exports/android_debug/core_breaker_debug.apk`
- Workflow file:
  `.github/workflows/android-debug-apk.yml`
- Godot export preset:
  `Android Debug APK`
- Artifact name:
  `core-breaker-debug-apk`

## Important Notes

- This is a **private testing APK**, not a production release.
- The repository is **private**, so GitHub login with repo access is required.
- The direct APK link depends on at least one successful workflow publication to the `android-debug-latest` release tag.
- The APK artifact can expire after the configured GitHub Actions retention window.
- Google Play `AAB` packaging is a later release path and is not the current download format.

## Game Overview

- Portrait mobile-first play field
- Center-core defense loop
- Auto-fire weapon system with joystick aiming
- Multi-tier weapon progression
- Local save / score tracking
- Private APK artifact flow for direct phone testing

## Documentation

- [App-in-Toss master checklist](docs/APP_IN_TOSS_MONETIZED_RELEASE_MASTER_CHECKLIST.md)
- [Developer Center full audit](docs/APP_IN_TOSS_DEVCENTER_FULL_AUDIT.md)
- [Dual-platform bridge audit](docs/DUAL_PLATFORM_BRIDGE_AUDIT.md)
- [Google Play release checklist](docs/GOOGLE_PLAY_RELEASE_MASTER_CHECKLIST.md)
- [Android phone test from GitHub](docs/ANDROID_PHONE_TEST_FROM_GITHUB.md)
