# App-in-Toss Console Inputs

## 1. App 기본 정보

| Item | Value | Status | Notes |
|---|---|---|---|
| Final public app title | 코어브레이커 | USER_REPORTED_DONE | 최종 공개 앱 이름 |
| Console app/service name | 코어 브레이커 | USER_REPORTED_DONE | Toss console 등록명 |
| App category is Game | 게임 > 액션, 게임 > 클래식 | USER_REPORTED_DONE | Game Center 사용 조건 |
| Console app id / URL |  | MISSING | 있으면 기록, 없으면 비움 |
| Terms URL | https://everyseok.github.io/core-breaker-godot/legal/terms.html | PENDING_DEPLOYMENT_NOT_VERIFIED | GitHub Pages `/docs` 배포와 HTTPS 200 필요 |
| Privacy URL | https://everyseok.github.io/core-breaker-godot/legal/privacy.html | PENDING_DEPLOYMENT_NOT_VERIFIED | GitHub Pages `/docs` 배포와 HTTPS 200 필요 |
| Legal placeholders | RESOLVED_NO_TODO | USER_REPORTED_DONE | 운영자명/대표자/이메일/사업자등록번호/시행일 반영; 주소는 운영자 문의처 안내 |

## 2. Game Center / Ranking

| Item | Value | Status | Notes |
|---|---|---|---|
| Game profile created | yes | USER_REPORTED_DONE | Toss console setup reported by user; runtime verification remains QR/device blocked |
| Leaderboard created | yes | USER_REPORTED_DONE | Toss console setup reported by user; runtime verification remains QR/device blocked |
| Leaderboard name | 기본단위 | USER_REPORTED_DONE | Toss console |
| Score policy | total_progress | USER_CONFIRMED | Console display unit may still require adjustment |
| Score direction | higher is better | USER_CONFIRMED | 더 높은 진행도가 좋음 |
| Submit timing | game over / max clear only | LOCKED | app start submit 금지 |
| Open leaderboard trigger | user button only | LOCKED | 자동 open 금지 |

## 3. Ads

| Item | Value | Status | Notes |
|---|---|---|---|
| Business registration done | yes | USER_REPORTED_DONE | Toss console / business |
| Settlement review done | PENDING_REVIEW | BLOCKED_BY_BUSINESS_SETTLEMENT | Toss console |
| Banner ad group created | PENDING_REVIEW / NOT_AVAILABLE_YET | BLOCKED_BY_AD_GROUP_ID | Toss ads console |
| Banner adGroupId | PENDING_REVIEW / NOT_AVAILABLE_YET | BLOCKED_BY_AD_GROUP_ID | real ID는 코드에 직접 hardcode 금지 |
| Rewarded revive ad group created | PENDING_REVIEW / NOT_AVAILABLE_YET | BLOCKED_BY_AD_GROUP_ID | Toss ads console |
| Rewarded revive adGroupId | PENDING_REVIEW / NOT_AVAILABLE_YET | BLOCKED_BY_AD_GROUP_ID | real ID는 코드에 직접 hardcode 금지 |
| Reward name | 부활 | USER_REPORTED_DONE | Rewarded revive reward |
| Reward quantity | 1 | USER_REPORTED_DONE | Rewarded revive reward |
| Development banner test ID | ait-ad-test-banner-id | KNOWN_TEST_ID | dev only |
| Development rewarded test ID | ait-ad-test-rewarded-id | KNOWN_TEST_ID | dev only |
| Production IDs available | no | PENDING_REVIEW / NOT_AVAILABLE_YET | production IDs must not be invented |

## 4. Layout / UX

| Item | Value | Status | Notes |
|---|---|---|---|
| Top 96px banner area permanently reserved | YES_IF_BANNER_ENABLED | USER_CONFIRMED | gameplay overlap is not allowed |
| Banner appears during active gameplay | YES_IF_BANNER_ENABLED | USER_CONFIRMED | 허용 시 safe-area/HUD 검증 필요; gameplay overlap allowed: NO |
| Banner hidden screens |  | MISSING | 예: loading, modal, result 등 |
| Revive ad entry screen |  | MISSING | GameOver/Revive UI 위치 확인 |

## 5. QA / Bundle

| Item | Value | Status | Notes |
|---|---|---|---|
| QR Toss app test done | no | BLOCKED | console/app bundle 필요 |
| Android device tested | no | BLOCKED | QR 이후 |
| iOS device tested | no | BLOCKED | QR 이후 |
| Final .ait path |  | MISSING | 아직 생성 금지 |
| Unpacked bundle size |  | MISSING | final export 이후 측정 |
| Bundle generation command |  | MISSING | wrapper/Godot packaging policy 확정 필요 |
| Package excludes | .godot, node_modules, dist, dry-run exports | LOCKED | scope lock 기준 |

## 6. Hard Rules

- 실제 production adGroupId는 source code에 hardcode하지 않는다.
- fake ad UI / placeholder ad UI를 만들지 않는다.
- rewarded revive는 USER_EARNED_REWARD 이벤트에서만 부활 처리한다.
- Game Center score submit은 game over / max clear 후 1회만 수행한다.
- Leaderboard open은 user button action에서만 수행한다.
- console/QR/device 검증 전에는 광고/랭킹을 DONE으로 표기하지 않는다.

## 7. Remaining User Input Request

아래 값이 아직 필요합니다. 모르면 '아직 없음'이라고 답하세요.

1) 배너 광고 adGroupId
2) 부활 리워드 광고 adGroupId
3) 정산 심사 완료 여부
4) GitHub Pages source branch: main인지, feature/android-debug-apk-artifact인지, 또는 별도 Pages branch인지
5) public HTTPS 200 OK 검증 결과
6) App-in-Toss QR/private test URL 또는 실행 가능 여부
7) iOS/Android 실기기 QA 가능 기기/OS/Toss 앱 버전
