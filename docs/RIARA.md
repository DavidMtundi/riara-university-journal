# Riara University — OJS Journal Platform

Dockerized [Open Journal Systems](https://pkp.sfu.ca/ojs/) 3.5.0.4 for **Riara University**, with a custom `riarauniversity` theme and automated test suite.

## Quick start

```bash
git clone <repo-url> ojs-riara
cd ojs-riara
cp .env.example .env          # edit DB_PASS and ports if needed
php volumes/scripts/render-config.php --force
docker compose up -d
```

On first enable of file volume mounts, sync existing submission files from the container:

```bash
./volumes/scripts/init-file-volumes.sh
docker compose up -d
```

| Service | URL |
|---------|-----|
| Journal | http://127.0.0.1:8888/index.php/riara |
| Admin login | http://127.0.0.1:8888/index.php/index/en/login |

### Default accounts (local / seed)

| Role | Username | Password |
|------|----------|----------|
| Site admin | `root` | `root` |
| Test author | `author` | `test123` |
| Test reviewer | `reviewer` | `test123` |

## Theme

Active theme: `volumes/plugins/themes/riarauniversity/`

Themed public pages include homepage, article, issue, search, about, auth (login/register/lost password), announcements, editorial masthead/history, contact, privacy, and error/message screens. A custom `header.tpl` renders the Riara brand bar on every page.

After editing theme files (templates, LESS, JS, locale):

```bash
docker exec pkp_app_ojs-riara sh -c "apachectl graceful; rm -rf /var/www/html/cache"
```

## Running tests

**Windows (PowerShell):**

```powershell
.\run-tests.ps1 -Playwright              # full suite incl. editorial workflow
.\run-tests.ps1 -Playwright -SkipWorkflow  # skip author→reviewer→publish pipeline
```

**Linux / macOS / CI:**

```bash
./run-tests.sh --playwright
./run-tests.sh --playwright --skip-workflow
```

### What the suite covers

- Infrastructure (DB, writable dirs, OJS installed)
- Theme registration and file mounts
- HTTP smoke tests for all public journal pages
- Riara branding (no OJS/PKP footer on public pages)
- Editorial workflow automation (`workflow-runner.php`)
- OAI and RSS endpoints
- Playwright browser tests (homepage, inner pages, auth, responsive)

## CI database seed

GitHub Actions imports `volumes/db-import/seed.sql.gz` on fresh installs via `ci-bootstrap.sh`.

**Re-export after journal/content changes:**

```bash
# Bash (Git Bash / Linux / macOS)
./volumes/scripts/export-db-seed.sh

# Or manually:
docker exec pkp_db_ojs-riara sh -c "mariadb-dump -upkp -p'<DB_PASS>' pkp | gzip -9 > /tmp/seed.sql.gz"
docker cp pkp_db_ojs-riara:/tmp/seed.sql.gz volumes/db-import/seed.sql.gz
```

Commit the updated seed so CI stays in sync.

> **Important:** Run `php volumes/scripts/render-config.php` after changing `.env` secrets. The rendered `pkp.config.inc.php` is gitignored; use `pkp.config.inc.php.example` as the template.

## Production checklist

Before go-live (see also `.env.example` and `docs/AUDIT.md`):

1. Set `OJS_ENV=production`, strong `DB_PASS`, and rotate `OJS_APP_KEY` / `OJS_SALT` in `.env`
2. Run `php volumes/scripts/render-config.php --force --strict`
3. Set `OJS_BASE_URL` to your public HTTPS URL and re-render config
4. Add production domain(s) to `allowed_hosts` in the config template
5. Enable `force_ssl = On` and captcha in `[security]`
6. Enable scheduled backups (see [Backups](#backups) below)
7. Export and commit an updated CI seed after final content setup
8. Run `.\run-tests.ps1 -Playwright` with zero failures

## Backups

Manual backup (database + `volumes/private` + `volumes/public`):

```bash
./volumes/scripts/backup.sh
```

Restore:

```bash
./volumes/scripts/restore.sh backups/20260101-120000
```

**Scheduled backups (Linux server):**

```bash
docker compose -f docker-compose.yml -f docker-compose.backup.yml --profile backup up -d
```

Set `BACKUP_CRON_SCHEDULE` (default `0 2 * * *`) and optional `BACKUP_REMOTE_DIR` in `.env` to copy each stamp to a NAS or secondary disk.

**Windows:** register `volumes/scripts/scheduled-backup.ps1` in Task Scheduler (requires Git Bash).

See `docs/AUDIT.md` for the full security/ops audit and remaining production gaps.

## Project layout

```
volumes/
  plugins/themes/riarauniversity/   # Custom theme (mounted into container)
  scripts/                          # Test runners, bootstrap, workflow automation
  db-import/seed.sql.gz             # CI database seed
  config/pkp.config.inc.php.example   # OJS config template (render with render-config.php)
  private/                            # Persisted submission files (mounted)
  public/                             # Public journal files (mounted)
  logs/app/                           # Apache logs (mounted)
tests/e2e/                          # Playwright specs
.github/workflows/docker-image.yml  # CI pipeline
```

## Editorial workflow test

The PHP workflow test creates a submission end-to-end:

1. Author submits manuscript
2. Editor sends to reviewer
3. Reviewer completes review
4. Editor accepts and publishes

Run manually inside the container:

```bash
docker exec pkp_app_ojs-riara php /tmp/workflow-runner.php
```

## Project status

| Area | Status |
|------|--------|
| Custom `riarauniversity` theme (28+ templates) | Complete |
| Riara University public branding | Complete |
| Self-hosted fonts (no Google CDN) | Complete |
| Editorial workflow automation | Complete |
| CI seed + GitHub Actions pipeline | Complete |
| PHP + Playwright test suite | 55+ PHP + 26 Playwright tests |
| File volume persistence | `volumes/private`, `volumes/public`, `volumes/logs/app` |
| Config template + render script | `render-config.php` |
| Backup / restore scripts | `backup.sh`, `restore.sh`, `docker-compose.backup.yml` |
| Security / ops audit | `docs/AUDIT.md` |
| Editorial playbook + upgrade runbook | `docs/EDITORIAL-PLAYBOOK.md`, `docs/OJS-UPGRADE.md` |

See also: `docs/AUDIT.md`, `docs/EDITORIAL-PLAYBOOK.md`, `docs/OJS-UPGRADE.md`, `docs/REVIEW-VIEWER-PLUGIN.md`.

### Remaining before production go-live

These are operational tasks (not code):

1. Upload journal logo and favicon in OJS admin
2. Replace placeholder about/contact/privacy copy with official university text
3. Set production `base_url`, HTTPS, and rotate secrets (see checklist above)
4. Re-export and commit `volumes/db-import/seed.sql.gz` after content is final

### Recently completed UX enhancements

- Custom `galley_link.tpl` download/view pills
- Article hero, citation block, and related-articles section
- Issue page magazine-style hero with current/archive kicker
- Announcement card redesign (homepage + list page)
- Register page auth feature parity with login
- Message page polish matching error page treatment
- `bootstrap-theme.php` sets `currentIssueId` for `/issue/current`

### University journal services (`bootstrap-journal-services.php`)

Run automatically via `run-tests.ps1` / `run-tests.sh`, or manually:

```bash
docker exec pkp_app_ojs-riara php /tmp/bootstrap-journal-services.php
```

| Feature | Status |
|---------|--------|
| Citation Style Language (APA, BibTeX, RIS, etc.) | Enabled + themed on article page |
| recommendByAuthor / recommendBySimilarity | Enabled + themed footer blocks |
| Static policy pages (ethics, peer review, copyright, preservation, indexing) | Created at `/about/policies`, etc. |
| Public journal metrics page | `/about/metrics` |
| DOI prefix + local DOI minting for published articles | `OJS_DOI_PREFIX` in `.env` |
| Crossref plugin (test mode) | Configured; add credentials for live deposit |
| CRediT + Publications Facts Label | Plugins enabled |
| ORCID | Enabled when `OJS_ORCID_CLIENT_ID` + secret set in `.env` |
| Google Analytics | Enabled when `OJS_GOOGLE_ANALYTICS_ID` set |
| Legacy `riara` theme | Disabled |
| Riara author guidelines & submission checklist | `bootstrap-journal-services.php` |
| XML sitemap documented on indexing page | `/about/indexing` |
| SMTP via `.env` + `render-config.php` | Optional `OJS_SMTP_*` vars |
| Workflow email notifications (submission ack + auto decision emails) | `bootstrap-email-notifications.php` + `riaraworkflownotifications` plugin |
| Google Sign-In (domain-based Student/Staff groups) | `bootstrap-google-oauth.php` + `googleOAuth` plugin |

### Google Sign-In (`bootstrap-google-oauth.php`)

```bash
docker exec pkp_app_ojs-riara php /tmp/bootstrap-google-oauth.php
```

Registers the `googleOAuth` plugin, creates **Student** and **Staff** reader groups per journal, and optionally applies credentials from `.env`:

- `OJS_GOOGLE_CLIENT_ID` / `OJS_GOOGLE_CLIENT_SECRET` — production OAuth client
- `OJS_GOOGLE_TEST_CREDENTIALS=1` — installs placeholder credentials for local smoke tests (no real Google login)

**Google Cloud console:** add this redirect URI per journal:

`http://127.0.0.1:8888/index.php/{journalPath}/googleoauth/callback`

Start URL (Sign in with Google button): `/index.php/{journalPath}/googleoauth/connect`

Domain mapping: `@stu.riarauniversity.ac.ke` → Student, `@riarauniversity.ac.ke` → Staff, all others → default Reader.

### Faculty journals (`bootstrap-faculty-journals.php`)

Optional. Set `OJS_FACULTY_JOURNALS` in `.env` (pipe-separated `path:Name` pairs) to clone additional journals from the primary journal shell, then re-run `bootstrap-google-oauth.php` for OAuth on all journals.

The site index at `/index.php/index` uses the Riara multi-journal hub (`indexSite.tpl`) to list all enabled journals.

### Email notifications (`bootstrap-email-notifications.php`)

```bash
docker exec pkp_app_ojs-riara php /tmp/bootstrap-email-notifications.php
```

Enables the Riara workflow notifications plugin, registers it in `versions`, and sets journal email defaults (submission acknowledgement to all authors, editor alerts on new submissions).

**CI seed:** Re-export after bootstrap changes, then commit `volumes/db-import/seed.sql.gz`:

```bash
./volumes/scripts/export-db-seed.sh
```

### Optional future enhancements

- Playwright UI test for full author→reviewer browser flow
- Admin dashboard rebrand (public site is already Riara-branded)
- Custom review viewer plugin (see `docs/REVIEW-VIEWER-PLUGIN.md`)
