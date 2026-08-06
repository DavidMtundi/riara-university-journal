#!/usr/bin/env bash
# OJS Riara — cross-platform test runner (Linux/macOS/CI)
set -euo pipefail

PLAYWRIGHT=0
SKIP_WORKFLOW=0

for arg in "$@"; do
  case "$arg" in
    --playwright|-Playwright) PLAYWRIGHT=1 ;;
    --skip-workflow|-SkipWorkflow) SKIP_WORKFLOW=1 ;;
  esac
done

ROOT="$(cd "$(dirname "$0")" && pwd)"
PROJECT_NAME="ojs-riara"

if [[ -f "$ROOT/.env" ]]; then
  val=$(grep -E '^\s*COMPOSE_PROJECT_NAME\s*=' "$ROOT/.env" | head -1 | cut -d= -f2 | tr -d ' "' || true)
  [[ -n "$val" ]] && PROJECT_NAME="$val"
fi

CONTAINER="pkp_app_${PROJECT_NAME}"
SCRIPTS="$ROOT/volumes/scripts"

echo ""
echo "=== OJS Riara Test Runner ==="
echo "Container: $CONTAINER"

if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER"; then
  echo "Starting Docker stack..."
  (cd "$ROOT" && docker compose up -d --no-build)
  sleep 8
fi

if [[ ! -f "$ROOT/volumes/config/pkp.config.inc.php" ]]; then
  echo "Rendering OJS config from .env ..."
  php "$SCRIPTS/render-config.php" --force
fi

echo "Syncing test scripts..."
for f in test-config.php test-lib.php riara-ojs-lib.php riara-env.php script-db.php workflow-runner.php backup.sh create-test-users.php bootstrap-theme.php bootstrap-journal-services.php bootstrap-email-notifications.php bootstrap-google-oauth.php bootstrap-faculty-journals.php run-all-tests.php get-published-article-id.php; do
  docker cp "$SCRIPTS/$f" "${CONTAINER}:/tmp/$f"
done

echo "Bootstrapping test users and theme..."
docker exec "$CONTAINER" php /tmp/create-test-users.php
docker exec "$CONTAINER" php /tmp/bootstrap-theme.php
docker exec "$CONTAINER" php /tmp/bootstrap-journal-services.php
docker exec "$CONTAINER" php /tmp/bootstrap-email-notifications.php
docker exec -e OJS_GOOGLE_TEST_CREDENTIALS=1 "$CONTAINER" php /tmp/bootstrap-google-oauth.php
docker exec -e OJS_FACULTY_JOURNALS="law:Riara Law Journal|engineering:School of Engineering Journal" "$CONTAINER" php /tmp/bootstrap-faculty-journals.php
docker exec "$CONTAINER" sh -c "apachectl graceful 2>/dev/null || kill -USR1 1 || true"
docker exec "$CONTAINER" rm -rf /var/www/html/cache
curl -sf -o /dev/null "http://127.0.0.1:8888/index.php/riara/" || true
curl -sf -o /dev/null "http://127.0.0.1:8888/index.php/index/" || true
curl -sf -o /dev/null "http://127.0.0.1:8888/index.php/law/" || true
curl -sf -o /dev/null "http://127.0.0.1:8888/index.php/engineering/" || true

echo ""
echo "Running PHP test suite..."
if [[ "$SKIP_WORKFLOW" -eq 1 ]]; then
  docker exec -e OJS_SKIP_WORKFLOW=1 -e OJS_FACULTY_JOURNALS="law:Riara Law Journal|engineering:School of Engineering Journal" "$CONTAINER" php /tmp/run-all-tests.php
else
  docker exec -e OJS_FACULTY_JOURNALS="law:Riara Law Journal|engineering:School of Engineering Journal" "$CONTAINER" php /tmp/run-all-tests.php
fi

if [[ "$PLAYWRIGHT" -eq 1 ]]; then
  echo ""
  echo "Running Playwright browser tests..."
  cd "$ROOT"
  export OJS_BASE_URL="http://127.0.0.1:8888"
  ARTICLE_ID=$(docker exec "$CONTAINER" php /tmp/get-published-article-id.php | tr -d '\r')
  export OJS_TEST_ARTICLE_ID="$ARTICLE_ID"
  echo "Playwright article id: $ARTICLE_ID"
  npx playwright test
fi

echo ""
echo "ALL TESTS PASSED"
