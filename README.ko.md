# 코어 브레이커 디버그

코어 브레이커 디버그는 Godot로 만든 세로형 모바일 방어 서바이벌 게임입니다.  
화면 중앙의 코어를 지키면서 안쪽으로 줄어드는 원형 벽돌 벽을 부수고 오래 버티는 것이 목표입니다.

English version: [README.md](README.md)

[![비공개 저장소](https://img.shields.io/badge/PRIVATE-REPO-2f3640?style=for-the-badge&logo=github)](https://github.com/Everyseok/core-breaker-godot)
[![APK 다운로드](https://img.shields.io/badge/DOWNLOAD-APK-e67e22?style=for-the-badge&logo=android)](https://github.com/Everyseok/core-breaker-godot/actions/workflows/android-debug-apk.yml)
[![폰 설치 가이드](https://img.shields.io/badge/PHONE-INSTALL%20GUIDE-2980b9?style=for-the-badge&logo=readthedocs)](docs/ANDROID_PHONE_TEST_FROM_GITHUB.md)
[![AAB 나중에](https://img.shields.io/badge/GOOGLE%20PLAY-AAB%20LATER-4b5563?style=for-the-badge&logo=googleplay)](docs/GOOGLE_PLAY_RELEASE_MASTER_CHECKLIST.md)

## 빠른 링크

- [Android Debug APK 워크플로 열기](https://github.com/Everyseok/core-breaker-godot/actions/workflows/android-debug-apk.yml)
- [비공개 저장소 열기](https://github.com/Everyseok/core-breaker-godot)
- [휴대폰 설치 가이드 열기](docs/ANDROID_PHONE_TEST_FROM_GITHUB.md)
- [Google Play 릴리즈 체크리스트 열기](docs/GOOGLE_PLAY_RELEASE_MASTER_CHECKLIST.md)

## APK 다운로드

현재 안드로이드 패키지는 **비공개 GitHub Actions artifact**로 배포됩니다.  
Google Play에서 받는 구조가 아닙니다.

1. 아래 워크플로 페이지를 엽니다.  
   [Android Debug APK](https://github.com/Everyseok/core-breaker-godot/actions/workflows/android-debug-apk.yml)
2. 가장 최근의 **성공한 run**을 엽니다.
3. **Artifacts** 섹션에서 아래 이름을 다운로드합니다.  
   `core-breaker-debug-apk`
4. 다운로드한 zip 파일을 풉니다.
5. 압축을 푼 뒤 아래 APK를 설치합니다.  
   `exports/android_debug/core_breaker_debug.apk`

## 안드로이드 설치 방법

- 휴대폰에서 바로 다운로드하거나, PC에서 받아 휴대폰으로 옮깁니다.
- `core_breaker_debug.apk` 파일을 엽니다.
- 설치 차단이 뜨면 브라우저 또는 파일 관리자에 대해 **출처를 알 수 없는 앱 설치 허용**을 켭니다.
- 설치 후 앱 서랍에서 **Core Breaker Debug**를 실행합니다.

## 현재 빌드 상태

- APK 출력 경로:
  `exports/android_debug/core_breaker_debug.apk`
- 워크플로 파일:
  `.github/workflows/android-debug-apk.yml`
- Godot export preset:
  `Android Debug APK`
- artifact 이름:
  `core-breaker-debug-apk`

## 참고 사항

- 이 APK는 **비공개 테스트용 디버그 빌드**입니다.
- 저장소가 **private** 이므로 GitHub 로그인과 저장소 접근 권한이 필요합니다.
- GitHub Actions artifact는 보관 기간이 지나면 만료될 수 있습니다.
- Google Play 제출용 `AAB`는 나중 단계이며, 현재 다운로드 형식은 아닙니다.

## 게임 개요

- 세로형 모바일 기준 플레이
- 중앙 코어 방어
- 조이스틱 에임 + 자동 발사
- 무기 단계 진화
- 로컬 저장 / 점수 기록
- 휴대폰 직접 테스트용 private APK artifact 흐름

## 문서

- [App-in-Toss 마스터 체크리스트](docs/APP_IN_TOSS_MONETIZED_RELEASE_MASTER_CHECKLIST.md)
- [Developer Center 전체 감사 문서](docs/APP_IN_TOSS_DEVCENTER_FULL_AUDIT.md)
- [듀얼 플랫폼 브리지 감사](docs/DUAL_PLATFORM_BRIDGE_AUDIT.md)
- [Google Play 릴리즈 체크리스트](docs/GOOGLE_PLAY_RELEASE_MASTER_CHECKLIST.md)
- [GitHub에서 안드로이드 폰 테스트 가이드](docs/ANDROID_PHONE_TEST_FROM_GITHUB.md)
