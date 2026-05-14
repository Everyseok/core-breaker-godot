<p align="center">
  <img src="docs/assets/readme/core-breaker-banner.png" alt="Core Breaker Banner" width="100%" />
</p>

<!-- Add core-breaker-banner.png under docs/assets/readme/ when available. -->

<p align="center">
  <img src="docs/assets/readme/core-breaker-icon.png" alt="Core Breaker Icon" width="96" />
</p>

<!-- Add core-breaker-icon.png under docs/assets/readme/ when available. -->

<h1 align="center">Core Breaker</h1>

<p align="center">
  <strong>A portrait mobile radial-defense arcade game built with Godot.</strong>
</p>

<p align="center">
  Defend the central core, break shrinking circular brick walls, and survive through escalating weapon progression.
</p>

<p align="center">
  <a href="https://github.com/Everyseok/core-breaker-godot/releases/download/android-debug-latest/core-breaker-debug.apk">
    <img src="https://img.shields.io/badge/Download-Android%20APK-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Download Android APK" />
  </a>
  <a href="https://github.com/Everyseok/core-breaker-godot/actions/workflows/android-debug-apk.yml">
    <img src="https://img.shields.io/badge/Build-GitHub%20Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white" alt="GitHub Actions" />
  </a>
  <img src="https://img.shields.io/badge/Engine-Godot-478CBF?style=for-the-badge&logo=godotengine&logoColor=white" alt="Godot" />
  <img src="https://img.shields.io/badge/Platform-Mobile%20Portrait-7C3AED?style=for-the-badge" alt="Mobile Portrait" />
  <img src="https://img.shields.io/badge/Status-Private%20Testing-2F3640?style=for-the-badge&logo=github" alt="Private Testing" />
</p>

---

## What is Core Breaker?

**Core Breaker** is a mobile-first arcade defense game where the battlefield is built around a single central core.

You aim from the center, fire into shrinking radial brick walls, destroy segments before they reach the core, and survive as the pressure accelerates. The design goal is simple: make a fast, readable, one-hand mobile game with satisfying brick destruction and escalating weapon progression.

---

## Gameplay Preview

<p align="center">
  <img src="docs/assets/readme/gameplay-preview.gif" alt="Core Breaker Gameplay Preview" width="72%" />
</p>

<!-- Add gameplay-preview.gif under docs/assets/readme/ when available. -->

<p align="center">
  <img src="docs/assets/readme/screenshot-gameplay-01.png" alt="Gameplay Screenshot 1" width="31%" />
  <img src="docs/assets/readme/screenshot-gameplay-02.png" alt="Gameplay Screenshot 2" width="31%" />
  <img src="docs/assets/readme/screenshot-gameplay-03.png" alt="Gameplay Screenshot 3" width="31%" />
</p>

<!-- Add screenshots under docs/assets/readme/ when available. -->

---

## Core Gameplay

| System | Description |
|---|---|
| **Central Core Defense** | The player protects a fixed core at the center of the arena. |
| **Radial Brick Walls** | Segmented circular walls shrink inward and create constant spatial pressure. |
| **Directional Aiming** | A mobile joystick controls the firing angle from the central core. |
| **Brick Destruction** | Projectiles break wall segments and open survival paths. |
| **Weapon Progression** | Weapons evolve as the player destroys more bricks and survives longer. |
| **Portrait Mobile Design** | Built for 9:16 mobile play with fast readability and one-hand interaction. |

---

## Download Android APK

The current Android build is distributed as a **private/debug testing APK** through GitHub Releases.

<p align="center">
  <a href="https://github.com/Everyseok/core-breaker-godot/releases/download/android-debug-latest/core-breaker-debug.apk">
    <strong>Download core-breaker-debug.apk</strong>
  </a>
</p>

Additional links:

- [Latest debug release](https://github.com/Everyseok/core-breaker-godot/releases/tag/android-debug-latest)
- [Android Debug APK workflow](https://github.com/Everyseok/core-breaker-godot/actions/workflows/android-debug-apk.yml)
- [Android phone install guide](docs/ANDROID_PHONE_TEST_FROM_GITHUB.md)

> This is a debug/private testing build, not a final production store release.

---

## Install on Android

1. Download `core-breaker-debug.apk`.
2. Open the APK on your Android device.
3. If Android blocks installation, allow **Install unknown apps** for your browser or file manager.
4. Launch **Core Breaker Debug** from the app drawer.

For detailed steps, see:

[Android phone test from GitHub](docs/ANDROID_PHONE_TEST_FROM_GITHUB.md)

---

## Tech Stack

| Area | Stack |
|---|---|
| Game Engine | Godot |
| Scripting | GDScript |
| Target Device | Android / Mobile portrait |
| Build Output | Debug APK |
| CI / Build Pipeline | GitHub Actions |
| Release Preparation | Google Play / App-in-Toss |
| Documentation | Markdown-based release and audit docs |

---

## Project Status

Core Breaker is currently in **private testing and release preparation**.

Current focus:

- Android APK validation
- Mobile input and layout stability
- Gameplay readability
- Weapon progression balancing
- Store/App-in-Toss release preparation
- Leaderboard and monetization workflow preparation

---

## Roadmap

- [x] Core radial-defense gameplay loop
- [x] Central-core projectile combat
- [x] Shrinking radial wall system
- [x] Android debug APK workflow
- [x] Phone installation guide
- [ ] Final mobile QA pass
- [ ] Leaderboard integration
- [ ] Ad integration
- [ ] Store/App-in-Toss release packaging
- [ ] Public production release

---

## Documentation

- [Korean README](README.ko.md)
- [App-in-Toss monetized release checklist](docs/APP_IN_TOSS_MONETIZED_RELEASE_MASTER_CHECKLIST.md)
- [App-in-Toss Developer Center full audit](docs/APP_IN_TOSS_DEVCENTER_FULL_AUDIT.md)
- [Dual-platform bridge audit](docs/DUAL_PLATFORM_BRIDGE_AUDIT.md)
- [Google Play release checklist](docs/GOOGLE_PLAY_RELEASE_MASTER_CHECKLIST.md)
- [Android phone test from GitHub](docs/ANDROID_PHONE_TEST_FROM_GITHUB.md)

---

## Repository Notes

This repository is currently used for private development, Android debug testing, and release preparation.

The direct APK link depends on a successful GitHub Actions build and publication to the `android-debug-latest` release tag. If the release asset is unavailable, use the latest successful workflow artifact from the Android Debug APK workflow.

---

## Author

**Jun Seok Kim**<br />
Independent Researcher & AI Builder<br />
GitHub: [@Everyseok](https://github.com/Everyseok)

---

<p align="center">
  <strong>Break the walls. Defend the core.</strong>
</p>
