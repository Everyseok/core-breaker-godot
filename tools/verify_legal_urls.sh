#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TERMS_URL="${TERMS_URL:-https://everyseok.github.io/core-breaker-godot/legal/terms.html}"
PRIVACY_URL="${PRIVACY_URL:-https://everyseok.github.io/core-breaker-godot/legal/privacy.html}"

TERMS_FILE="${ROOT_DIR}/docs/legal/terms.html"
PRIVACY_FILE="${ROOT_DIR}/docs/legal/privacy.html"

check_status() {
  local label="$1"
  local url="$2"
  local status

  status="$(curl -I -L --max-time 10 -o /dev/null -s -w "%{http_code}" "$url" || true)"
  printf '%s %s -> HTTP %s\n' "$label" "$url" "$status"

  if [[ "$status" == "200" ]]; then
    return 0
  fi
  return 1
}

placeholder_status=0
if grep -Rni "TODO:" "$TERMS_FILE" "$PRIVACY_FILE" >/tmp/core_breaker_legal_todo_check.log; then
  echo "LOCAL PLACEHOLDER CHECK -> TODO placeholders remain:"
  cat /tmp/core_breaker_legal_todo_check.log
  placeholder_status=1
else
  echo "LOCAL PLACEHOLDER CHECK -> no TODO placeholders found"
fi

url_status=0
check_status "TERMS" "$TERMS_URL" || url_status=1
check_status "PRIVACY" "$PRIVACY_URL" || url_status=1

if [[ "$placeholder_status" -eq 0 && "$url_status" -eq 0 ]]; then
  echo "LEGAL URLS VERIFIED"
  exit 0
fi

echo "LEGAL URLS BLOCKED"
if [[ "$placeholder_status" -ne 0 ]]; then
  echo "Required before final PASS: replace or approve TODO legal placeholders."
fi
if [[ "$url_status" -ne 0 ]]; then
  echo "Required before final PASS: deploy legal pages and verify both public HTTPS URLs return HTTP 200."
fi
exit 1
