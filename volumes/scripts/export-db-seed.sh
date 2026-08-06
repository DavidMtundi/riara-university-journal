#!/usr/bin/env bash
# Export a CI-ready database seed from the running OJS stack.
# Run locally after install + journal setup: ./volumes/scripts/export-db-seed.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PROJECT_NAME="ojs-riara"
if [[ -f "$ROOT/.env" ]]; then
  val=$(grep -E '^\s*COMPOSE_PROJECT_NAME\s*=' "$ROOT/.env" | head -1 | cut -d= -f2 | tr -d ' "' || true)
  [[ -n "$val" ]] && PROJECT_NAME="$val"
fi

DB_CONTAINER="pkp_db_${PROJECT_NAME}"
OUT_DIR="$ROOT/volumes/db-import"
OUT_FILE="$OUT_DIR/seed.sql.gz"

mkdir -p "$OUT_DIR"

DB_PASS="${MYSQL_PASSWORD:-changeMePlease}"
DB_USER="${MYSQL_USER:-pkp}"
DB_NAME="${MYSQL_DATABASE:-pkp}"

echo "Exporting database from $DB_CONTAINER to $OUT_FILE ..."
docker exec "$DB_CONTAINER" mariadb-dump -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" \
  | gzip -9 > "$OUT_FILE"

echo "Seed exported ($(du -h "$OUT_FILE" | cut -f1)). Commit for CI or keep local."
