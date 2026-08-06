#!/usr/bin/env bash
# Copy submission files from a running container into volumes/private on first mount.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PROJECT_NAME="ojs-riara"
if [[ -f "$ROOT/.env" ]]; then
  val=$(grep -E '^\s*COMPOSE_PROJECT_NAME\s*=' "$ROOT/.env" | head -1 | cut -d= -f2 | tr -d ' "' || true)
  [[ -n "$val" ]] && PROJECT_NAME="$val"
fi

APP_CONTAINER="pkp_app_${PROJECT_NAME}"
PRIVATE="$ROOT/volumes/private"

if [[ -n "$(ls -A "$PRIVATE" 2>/dev/null || true)" ]]; then
  echo "volumes/private already has content — skipping sync"
  exit 0
fi

if ! docker ps --format '{{.Names}}' | grep -qx "$APP_CONTAINER"; then
  echo "Container $APP_CONTAINER not running — start stack first or copy files manually" >&2
  exit 1
fi

echo "Copying /var/www/files from $APP_CONTAINER to $PRIVATE ..."
docker cp "$APP_CONTAINER:/var/www/files/." "$PRIVATE/"
echo "File volume sync complete"
