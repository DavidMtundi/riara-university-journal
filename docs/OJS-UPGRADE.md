# OJS upgrade runbook — Riara University

## Before upgrading

1. **Backup** — run `./volumes/scripts/backup.sh` and verify archives
2. **Export CI seed** — `./volumes/scripts/export-db-seed.sh` after verifying the site
3. **Note versions** — record current `PKP_VERSION` in `.env` and OJS version in admin
4. **Theme diff** — compare `volumes/plugins/themes/riarauniversity/` against PKP default theme for the target version

## Upgrade steps

1. Update `PKP_VERSION` in `.env` to the target release (e.g. `3_5_0-5`)
2. Rebuild the app image: `docker compose build app`
3. Stop stack: `docker compose down`
4. Restore is optional if upgrade fails; otherwise keep DB and `volumes/private`
5. Start stack: `docker compose up -d`
6. Run OJS upgrade via CLI inside the container:
   ```bash
   docker exec pkp_app_ojs-riara php tools/upgrade.php upgrade
   ```
7. Clear cache: `docker exec pkp_app_ojs-riara rm -rf /var/www/html/cache`
8. Run full test suite: `./run-tests.sh --playwright`

## After upgrading

1. Smoke-test homepage, article view, login, and editorial dashboard
2. Re-export `volumes/db-import/seed.sql.gz` for CI
3. Update `docs/RIARA.md` project status if templates or plugins changed

## Rollback

1. Restore `.env` `PKP_VERSION` to the previous value
2. `docker compose build app && docker compose up -d`
3. Restore database from backup: `./volumes/scripts/restore.sh backups/<stamp>`
