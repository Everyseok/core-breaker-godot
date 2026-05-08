# App-in-Toss Legal URLs - 2026-05-08

## Status

| Item | Value |
|---|---|
| App public title | `코어브레이커` |
| Console/service name | `코어 브레이커` |
| Legal URL status | `VERIFIED_200` |
| Public HTTPS 200 OK | `DONE` |
| Final legal PASS | `READY_FOR_CONSOLE_ENTRY` |
| Legal placeholders | `RESOLVED_NO_TODO` |
| Legal copy status | `PRODUCTION_COPY_READY` |

## Business / Operator Info

| Item | Value |
|---|---|
| Operator | 엔드포인트 |
| Representative | 김준석 |
| Contact email | junseok3055@gmail.com |
| Business registration number | 711-34-01671 |
| Business address | 사업장 주소: 운영자 문의처를 통해 안내 |
| Effective date | 2026년 5월 6일 |

## Candidate URLs

Preferred default deployment path: GitHub Pages for `Everyseok/core-breaker-godot`, serving the `/docs` folder.

| Page | Candidate URL | Local file | Status |
|---|---|---|---|
| Terms | `https://everyseok.github.io/core-breaker-godot/legal/terms.html` | `docs/legal/terms.html` | `VERIFIED_200` |
| Privacy | `https://everyseok.github.io/core-breaker-godot/legal/privacy.html` | `docs/legal/privacy.html` | `VERIFIED_200` |
| Legal index | `https://everyseok.github.io/core-breaker-godot/legal/` | `docs/legal/index.html` | `PAGES_DEPLOYED` |

## GitHub Pages Setup

Current setup:

- Repository: `Everyseok/core-breaker-godot`
- Pages source branch: `feature/android-debug-apk-artifact`
- Pages source folder: `/docs`
- Pages root: `https://everyseok.github.io/core-breaker-godot/`

Verification command:

```sh
tools/verify_legal_urls.sh
```

Custom URL verification:

```sh
TERMS_URL="https://example.com/legal/terms.html" PRIVACY_URL="https://example.com/legal/privacy.html" tools/verify_legal_urls.sh
```

## Local Page Notes

- Pages are static HTML only.
- No external JavaScript, analytics, trackers, ads scripts, or remote CSS are included.
- Current MVP states no Toss Login, OAuth, IAP, TossPay, location permission, or camera permission.
- Privacy page includes minimal App-in-Toss/Toss Ads SDK and Game Center processing language.
- Operator/business placeholders are resolved in canonical `terms.html` and `privacy.html`.
- Business address is not invented; pages state that the business address is provided through the operator contact channel.

## Blockers

| Gate | Evidence |
|---|---|
| `LEGAL_URLS_VERIFIED_200` | `tools/verify_legal_urls.sh` returns `LEGAL URLS VERIFIED` |
| `PAGES_SOURCE` | GitHub Pages is configured to deploy `feature/android-debug-apk-artifact` `/docs` |

Legal URLs are ready to enter in App-in-Toss Console.
