#!/bin/sh
# One-time OJS web installer (fresh empty database only).
# Credentials come from environment — never hardcode secrets in this file.
#
# Example:
#   OJS_INSTALL_ADMIN_USER=admin \
#   OJS_INSTALL_ADMIN_PASS='your-strong-password' \
#   OJS_INSTALL_ADMIN_EMAIL=admin@example.com \
#   OJS_INSTALL_DB_PASS='your-db-password' \
#   ./volumes/scripts/install-ojs.sh

set -eu

ADMIN_USER="${OJS_INSTALL_ADMIN_USER:-admin}"
ADMIN_PASS="${OJS_INSTALL_ADMIN_PASS:-}"
ADMIN_EMAIL="${OJS_INSTALL_ADMIN_EMAIL:-admin@example.com}"
DB_USER="${OJS_INSTALL_DB_USER:-pkp}"
DB_PASS="${OJS_INSTALL_DB_PASS:-}"
DB_NAME="${OJS_INSTALL_DB_NAME:-pkp}"
DB_HOST="${OJS_INSTALL_DB_HOST:-db}"
BASE_URL="${OJS_INSTALL_BASE_URL:-http://127.0.0.1/index}"

if [ -z "$ADMIN_PASS" ] || [ -z "$DB_PASS" ]; then
  echo "ERROR: Set OJS_INSTALL_ADMIN_PASS and OJS_INSTALL_DB_PASS before running." >&2
  exit 1
fi

curl -sL "${BASE_URL}/install/install" -X POST \
  --data-urlencode "installing=0" \
  --data-urlencode "installLanguage=en" \
  --data-urlencode "locale=en" \
  --data-urlencode "adminUsername=${ADMIN_USER}" \
  --data-urlencode "adminPassword=${ADMIN_PASS}" \
  --data-urlencode "adminPassword2=${ADMIN_PASS}" \
  --data-urlencode "adminEmail=${ADMIN_EMAIL}" \
  --data-urlencode "clientCharset=utf-8" \
  --data-urlencode "connectionCharset=utf8" \
  --data-urlencode "databaseCharset=utf8" \
  --data-urlencode "filesDir=/var/www/files" \
  --data-urlencode "databaseDriver=mysqli" \
  --data-urlencode "databaseHost=${DB_HOST}" \
  --data-urlencode "databaseUsername=${DB_USER}" \
  --data-urlencode "databasePassword=${DB_PASS}" \
  --data-urlencode "databaseName=${DB_NAME}" \
  --data-urlencode "oaiRepositoryId=ojs-riara" \
  --data-urlencode "enableBeacon=0" \
  -o /tmp/install-result.html

if grep -q "notifyError" /tmp/install-result.html; then
  echo "INSTALL_FAILED"
  grep "description" /tmp/install-result.html | head -5
  exit 1
fi

echo "INSTALL_SUCCESS"
grep -i "complete\|installed\|success" /tmp/install-result.html | head -5
