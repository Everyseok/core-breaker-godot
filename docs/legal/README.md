# Core Breaker Legal Pages

This directory contains static legal pages for App-in-Toss console registration.

Canonical candidate URLs:

- Terms: `https://everyseok.github.io/core-breaker-godot/legal/terms.html`
- Privacy: `https://everyseok.github.io/core-breaker-godot/legal/privacy.html`

## GitHub Pages Setup

1. Open the GitHub repository: `Everyseok/core-breaker-godot`.
2. Go to **Settings**.
3. Go to **Pages**.
4. Set **Build and deployment** to **Deploy from a branch**.
5. Choose the branch that will host the legal pages.
   - If GitHub Pages is configured for `main`, these files must also be present on `main`.
   - If Pages can serve `feature/android-debug-apk-artifact`, use that branch only if it is the intended public deployment source.
6. Set folder to `/docs`.
7. Save.
8. Wait a few minutes, then run:

```sh
tools/verify_legal_urls.sh
```

Custom URL verification:

```sh
TERMS_URL="https://example.com/legal/terms.html" PRIVACY_URL="https://example.com/legal/privacy.html" tools/verify_legal_urls.sh
```

## Release Status

- Public HTTPS deployment: `VERIFIED`
- HTTP 200 verification: `VERIFIED_200`
- Operator/business placeholders: `RESOLVED_NO_TODO`
- Final legal PASS: ready for App-in-Toss console URL entry.

Verified URLs:

- Terms: `https://everyseok.github.io/core-breaker-godot/legal/terms.html`
- Privacy: `https://everyseok.github.io/core-breaker-godot/legal/privacy.html`
