# App-in-Toss Legal URLs - 2026-05-08

## Status

| Item | Value |
|---|---|
| App public title | `코어브레이커` |
| Console/service name | `코어 브레이커` |
| Legal URL status | `BLOCKED_BY_LEGAL_URLS` |
| Public HTTPS 200 OK | `NOT_DONE` |
| Final legal PASS | `NO` |
| Legal placeholders | `RESOLVED_NO_TODO` |

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
| Terms | `https://everyseok.github.io/core-breaker-godot/legal/terms.html` | `docs/legal/terms.html` | `PENDING_DEPLOYMENT_NOT_VERIFIED` |
| Privacy | `https://everyseok.github.io/core-breaker-godot/legal/privacy.html` | `docs/legal/privacy.html` | `PENDING_DEPLOYMENT_NOT_VERIFIED` |
| Legal index | `https://everyseok.github.io/core-breaker-godot/legal/` | `docs/legal/index.html` | `PENDING_DEPLOYMENT_NOT_VERIFIED` |

## GitHub Pages Setup

1. Open GitHub repo `Everyseok/core-breaker-godot`.
2. Open **Settings**.
3. Open **Pages**.
4. Set **Build and deployment** to **Deploy from a branch**.
5. Select the branch that will host legal pages.
   - If Pages is configured for `main`, these legal files must be pushed to `main`.
   - If Pages can serve `feature/android-debug-apk-artifact`, confirm that branch is intended for public legal URL hosting.
6. Set folder to `/docs`.
7. Save.
8. Wait for Pages deployment.
9. Run:

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

| Blocker | Required unblock evidence |
|---|---|
| `BLOCKED_BY_LEGAL_URLS` | Terms and Privacy URLs return HTTP 200 via `curl -I -L --max-time 10` |
| `PAGES_DEPLOYMENT_PENDING` | GitHub Pages source branch is selected and `/docs` deployment finishes |
| `PAGES_BRANCH_UNCONFIRMED` | User confirms GitHub Pages source branch and `/docs` folder |

Do not mark legal URLs as PASS until both public URLs return HTTP 200.
