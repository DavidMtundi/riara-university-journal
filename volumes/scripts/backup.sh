#!/usr/bin/env bash
# Backup OJS Riara database and file volumes.
#
# Optional .env variables:
#   BACKUP_REMOTE_DIR  — copy each backup stamp to this directory (NAS, mounted share, etc.)
#
# Schedule with host cron or docker compose -f docker-compose.backup.yml up -d
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PROJECT_NAME="ojs-riara"
if [[ -f "$ROOT/.env" ]]; then
  val=$(grep -E '^\s*COMPOSE_PROJECT_NAME\s*=' "$ROOT/.env" | head -1 | cut -d= -f2 | tr -d ' "' || true)
  [[ -n "$val" ]] && PROJECT_NAME="$val"
  # shellcheck disable=SC1091
  set -a
  source <(grep -E '^(DB_PASS|MYSQL_PASSWORD|BACKUP_REMOTE_DIR)=' "$ROOT/.env" | sed 's/^/export /')
  set +a
fi

DB_CONTAINER="pkp_db_${PROJECT_NAME}"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT_DIR="$ROOT/backups/$STAMP"
mkdir -p "$OUT_DIR"

DB_PASS="${MYSQL_PASSWORD:-${DB_PASS:-changeMePlease}}"
DB_USER="${MYSQL_USER:-pkp}"
DB_NAME="${MYSQL_DATABASE:-pkp}"

echo "Backing up database to $OUT_DIR/db.sql.gz ..."
docker exec "$DB_CONTAINER" mariadb-dump -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" \
  | gzip -9 > "$OUT_DIR/db.sql.gz"

if [[ -d "$ROOT/volumes/private" ]]; then
  echo "Archiving private files (submissions, usage stats) ..."
  tar -czf "$OUT_DIR/private-files.tar.gz" -C "$ROOT/volumes" private
fi

if [[ -d "$ROOT/volumes/public" ]]; then
  echo "Archiving public files ..."
  tar -czf "$OUT_DIR/public-files.tar.gz" -C "$ROOT/volumes" public
fi

if [[ -n "${BACKUP_REMOTE_DIR:-}" ]]; then
  REMOTE_TARGET="${BACKUP_REMOTE_DIR%/}/$STAMP"
  echo "Copying backup to remote: $REMOTE_TARGET ..."
  mkdir -p "$REMOTE_TARGET"
  cp -a "$OUT_DIR/." "$REMOTE_TARGET/"
fi

echo "Backup complete: $OUT_DIR"
if [[ -n "${BACKUP_REMOTE_DIR:-}" ]]; then
  echo "Remote copy: ${BACKUP_REMOTE_DIR%/}/$STAMP"
fi
