#!/usr/bin/env bash
# Restore OJS Riara from a backup directory created by backup.sh.
# Usage: ./volumes/scripts/restore.sh backups/20260101-120000
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <backup-directory>" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BACKUP_DIR="$(cd "$1" && pwd)"
PROJECT_NAME="ojs-riara"
if [[ -f "$ROOT/.env" ]]; then
  val=$(grep -E '^\s*COMPOSE_PROJECT_NAME\s*=' "$ROOT/.env" | head -1 | cut -d= -f2 | tr -d ' "' || true)
  [[ -n "$val" ]] && PROJECT_NAME="$val"
fi

DB_CONTAINER="pkp_db_${PROJECT_NAME}"
DB_PASS="${MYSQL_PASSWORD:-changeMePlease}"
DB_USER="${MYSQL_USER:-pkp}"
DB_NAME="${MYSQL_DATABASE:-pkp}"

if [[ ! -f "$BACKUP_DIR/db.sql.gz" ]]; then
  echo "Missing $BACKUP_DIR/db.sql.gz" >&2
  exit 1
fi

echo "Restoring database ..."
gunzip -c "$BACKUP_DIR/db.sql.gz" | docker exec -i "$DB_CONTAINER" \
  mariadb -u"$DB_USER" -p"$DB_PASS" "$DB_NAME"

if [[ -f "$BACKUP_DIR/private-files.tar.gz" ]]; then
  echo "Restoring private files ..."
  tar -xzf "$BACKUP_DIR/private-files.tar.gz" -C "$ROOT/volumes"
fi

if [[ -f "$BACKUP_DIR/public-files.tar.gz" ]]; then
  echo "Restoring public files ..."
  tar -xzf "$BACKUP_DIR/public-files.tar.gz" -C "$ROOT/volumes"
fi

echo "Restore complete. Restart app container and clear cache."
