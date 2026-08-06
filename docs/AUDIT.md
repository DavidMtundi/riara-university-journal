# OJS Riara — Security & Operations Audit

Last reviewed: July 2026. Use this document when onboarding reviewers, preparing production go-live, or answering “is this safe to deploy?”

## Executive summary

| Area | Status | Notes |
|------|--------|-------|
| Theme / core isolation | OK | Custom code only under `volumes/plugins/` |
| Secrets in git | Fixed (ongoing vigilance) | `.env` gitignored; history may contain old `.env` — rotate if repo was ever public |
| Config rendering | Fixed | `render-config.php --strict` + `OJS_ENV=production` rejects placeholders |
| Google Sign-In | OK (additive) | Local login remains; OAuth optional |
| DOI / Crossref | Dev/test only | Prefix `10.55555`, `testMode=1` — not production registration |
| Backups | Improved | Manual + optional cron sidecar + `BACKUP_REMOTE_DIR` |
| Multi-journal routing | OK | Standard OJS path routing |
| Test suite | Good (custom) | Does not run upstream OJS PHPUnit |
| Container security | OK for dev | DB not exposed; admin login public (standard OJS) |
| Documentation | OK | This file + `RIARA.md`, `OJS-UPGRADE.md` |

---

## 1. Theme isolation

**Verdict: OK**

Customizations are mounted only as OJS plugins/themes:

```yaml
# docker-compose.yml (app volumes)
- ./volumes/plugins/themes/riarauniversity:...
- ./volumes/plugins/generic/riaraworkflownotifications:...
- ./volumes/plugins/generic/googleOAuth:...
```

Core OJS ships inside the Docker image (PKP tarball in `Dockerfile`). There is no `lib/pkp` tree in this repository.

Theme template overrides (e.g. `registrationForm.tpl`, `citationblock.tpl`) live under the theme path — the supported OJS override mechanism, not core edits.

---

## 2. Secrets and `.env` hygiene

**Verdict: Fixed with checklist**

| Check | Evidence |
|-------|----------|
| `.env` gitignored | `.gitignore` line 6 |
| `.env.example` placeholders only | `OJS_APP_KEY=base64:REPLACE_ME_GENERATE_A_NEW_KEY` |
| Rendered config gitignored | `volumes/config/pkp.config.inc.php` in `.gitignore` |

### Historical risk

`git log --all --full-history -- .env` shows `.env` existed in early commits. **Rotate all secrets** if the repository was ever shared publicly.

### Removed hardcoded install passwords

- `volumes/scripts/install-ojs.sh` — now requires `OJS_INSTALL_ADMIN_PASS` and `OJS_INSTALL_DB_PASS` env vars
- `volumes/scripts/update-admin.php` — now requires `OJS_ADMIN_PASS` env var

### Production config rendering

```bash
# Set in .env before go-live:
OJS_ENV=production
DB_PASS=<strong-password>
OJS_APP_KEY=<generate new — see .env.example>
OJS_SALT=<random string>
OJS_BASE_URL=https://journals.riarauniversity.ac.ke

php volumes/scripts/render-config.php --force --strict
```

`--strict` or `OJS_ENV=production` runs validation in `volumes/scripts/riara-env.php` and **exits non-zero** on placeholder values.

---

## 3. Google Sign-In

**Verdict: OK — optional, with local fallback**

| Item | Detail |
|------|--------|
| Plugin | `volumes/plugins/generic/googleOAuth/` |
| Scopes | `openid email profile` (`GoogleOAuthService.php`) |
| Bootstrap | `bootstrap-google-oauth.php` reads `OJS_GOOGLE_CLIENT_ID` / `OJS_GOOGLE_CLIENT_SECRET` |
| UI | Button on login/register only when `isConfigured()` (client id + secret set) |
| Failure | Redirect to login with error message (`GoogleOAuthHandler.php`) |
| New users | Auto-created; assigned **Reader** (Student/Staff groups by email domain) |
| Existing users | Matched by email, groups updated |

Local username/password login is unchanged when OAuth is disabled or misconfigured.

---

## 4. DOI / Crossref

**Verdict: Not production-ready without manual steps**

Bootstrap (`bootstrap-journal-services.php`) enables:

- Local DOI minting: `{OJS_DOI_PREFIX}/article.{submission_id}`
- Default prefix: `10.55555` (Crossref **test** prefix)
- Crossref plugin: `testMode=1` by default
- **No** Crossref API username/password in bootstrap

**Before go-live:**

1. Register a real DOI prefix with Crossref
2. Set `OJS_DOI_PREFIX` and `OJS_CROSSREF_TEST_MODE=0` in `.env`
3. Enter Crossref depositor credentials in OJS admin
4. Verify a test deposit in the Crossref dashboard

---

## 5. Backups

**Verdict: Improved — enable scheduling for production**

### What is backed up

`volumes/scripts/backup.sh` archives:

| Artifact | Contents |
|----------|----------|
| `db.sql.gz` | Full MariaDB dump |
| `private-files.tar.gz` | Submissions, usage stats (`volumes/private`) |
| `public-files.tar.gz` | Public journal files (`volumes/public`) |

### Restore

```bash
./volumes/scripts/restore.sh backups/YYYYMMDD-HHMMSS
```

### Scheduled backups

**Linux (Docker sidecar):**

```bash
docker compose -f docker-compose.yml -f docker-compose.backup.yml --profile backup up -d
```

Set in `.env`:

```env
BACKUP_CRON_SCHEDULE="0 2 * * *"
BACKUP_REMOTE_DIR="/mnt/nas/ojs-riara-backups"
```

`BACKUP_REMOTE_DIR` copies each stamp off the primary disk after the local archive.

**Windows:** register `volumes/scripts/scheduled-backup.ps1` in Task Scheduler (requires Git Bash).

### Remaining gap

No cloud off-site backup (S3, etc.) is built in — use `BACKUP_REMOTE_DIR` to a NAS mount or extend `backup.sh` for your storage provider.

---

## 6. Multi-journal routing

**Verdict: OK**

OJS routes by journal path (`/index.php/riara`, `/index.php/law`, etc.). Apache rewrites all requests to `index.php` (`volumes/config/apache.pkp.conf`). No per-journal vhost required.

**Production:** set `OJS_BASE_URL`, enable HTTPS, `force_ssl = On` in config template, extend `allowed_hosts`.

---

## 7. Bootstrap scripts

**Verdict: Mostly idempotent**

Bootstrap scripts use `ON DUPLICATE KEY UPDATE` and existence checks. Safe to re-run in dev/CI; re-running in production **overwrites** plugin/journal settings by design.

`render-config.php` without `--strict` still allows dev defaults when `.env` is missing (warns to stderr).

---

## 8. Test suite coverage

**Verdict: Good for Riara customizations**

| Layer | Location | Count |
|-------|----------|-------|
| PHP integration | `volumes/scripts/run-all-tests.php` | ~63 tests |
| Playwright E2E | `tests/e2e/*.spec.ts` | ~29 tests |

Does **not** run OJS upstream PHPUnit.

### Recently added tests

- `render-config strict mode rejects placeholder secrets`
- `render-config allows local dev without strict flag`
- `Backup script archives DB and file volumes`

### Remaining gaps

| Component | Coverage |
|-----------|----------|
| `restore.sh` end-to-end | Manual only |
| Crossref live deposit | Not tested |
| SMTP delivery | Email log only in workflow test |
| SSL / `force_ssl` | Not tested |

---

## 9. Container security

| Check | Status |
|-------|--------|
| MariaDB port exposed | **No** — `db` service has no `ports:` mapping; internal network only |
| App port | `8888:80` — expected for dev; use firewall/reverse proxy in prod |
| Admin dashboard | OJS login required; no IP restriction (add at reverse proxy if needed) |

---

## 10. Documentation map

| Document | Purpose |
|----------|---------|
| `docs/RIARA.md` | Setup, testing, integrations, production checklist |
| `docs/AUDIT.md` | This file — security/ops audit |
| `docs/OJS-UPGRADE.md` | Version upgrades + rollback |
| `docs/EDITORIAL-PLAYBOOK.md` | Editorial workflow, email, Google Sign-In |
| `.env.example` | All configurable variables with comments |
| `volumes/scripts/restore.sh` | Disaster recovery procedure |

---

## Pre-production checklist (copy for reviewers)

- [ ] Rotate secrets (assume old `.env` may be in git history)
- [ ] `OJS_ENV=production` + `render-config.php --force --strict`
- [ ] HTTPS + `force_ssl = On` + production `allowed_hosts`
- [ ] Real DOI prefix + Crossref credentials + `testMode=0`
- [ ] Google OAuth production client + redirect URIs registered
- [ ] SMTP configured (`OJS_SMTP_*` in `.env`)
- [ ] Scheduled backups enabled + `BACKUP_REMOTE_DIR` tested
- [ ] Restore drill: `restore.sh` on a staging host
- [ ] `.\run-tests.ps1 -Playwright` passes with zero failures
- [ ] Change default accounts (`root`, `author`, `reviewer`)
