#!/usr/bin/env bash
# CI bootstrap: verify OJS is installed; import seed if provided.
set -euo pipefail

CONTAINER="${1:-pkp_app_ojs-riara}"
DB_CONTAINER="${2:-pkp_db_ojs-riara}"
SEED="/tmp/db-import/seed.sql.gz"
SEED_SQL="/tmp/db-import/seed.sql"

installed() {
  docker exec "$CONTAINER" php -r '
    require "/tmp/test-config.php";
    $c = require "/tmp/test-config.php";
    try {
      $pdo = new PDO("mysql:host={$c["db"]["host"]};dbname={$c["db"]["name"]}", $c["db"]["user"], $c["db"]["pass"]);
      echo (int) $pdo->query("SELECT COUNT(*) FROM journals")->fetchColumn();
    } catch (Throwable $e) {
      echo 0;
    }
  ' 2>/dev/null || echo 0
}

count="$(installed)"
if [[ "$count" -ge 1 ]]; then
  echo "OJS already installed ($count journal(s))"
  exit 0
fi

echo "OJS not installed — attempting seed import if available ..."

if docker exec "$DB_CONTAINER" test -f "$SEED"; then
  echo "Importing compressed seed ..."
  docker exec "$DB_CONTAINER" sh -c "gunzip -c '$SEED' | mariadb -u\"\$MYSQL_USER\" -p\"\$MYSQL_PASSWORD\" \"\$MYSQL_DATABASE\""
  count="$(installed)"
  if [[ "$count" -ge 1 ]]; then
    echo "Seed import complete ($count journal(s))"
    exit 0
  fi
  echo "Seed import finished but no journals found"
  exit 1
fi

if docker exec "$DB_CONTAINER" test -f "$SEED_SQL"; then
  echo "Importing seed.sql ..."
  docker exec "$DB_CONTAINER" sh -c "mariadb -u\"\$MYSQL_USER\" -p\"\$MYSQL_PASSWORD\" \"\$MYSQL_DATABASE\" < '$SEED_SQL'"
  count="$(installed)"
  if [[ "$count" -ge 1 ]]; then
    echo "Seed import complete ($count journal(s))"
    exit 0
  fi
fi

echo "No seed found and OJS is not installed."
echo "Export locally: ./volumes/scripts/export-db-seed.sh"
exit 1
