# CI database seed



`seed.sql.gz` is imported by `volumes/scripts/ci-bootstrap.sh` when the stack starts with an empty database.



**Commit this file to git** so CI matches your local journal setup (theme, plugins, static pages, DOIs).



Re-export after install, bootstrap, or content changes:



```bash

./volumes/scripts/export-db-seed.sh

```



Bootstrap scripts run automatically via `run-tests.ps1` / `run-tests.sh`. For a manual refresh:



```bash

docker exec pkp_app_ojs-riara php /tmp/bootstrap-theme.php

docker exec pkp_app_ojs-riara php /tmp/bootstrap-journal-services.php
docker exec -e OJS_GOOGLE_TEST_CREDENTIALS=1 pkp_app_ojs-riara php /tmp/bootstrap-google-oauth.php
docker exec pkp_app_ojs-riara php /tmp/bootstrap-faculty-journals.php

./volumes/scripts/export-db-seed.sh

```



See [docs/RIARA.md](../../docs/RIARA.md) for full setup and testing instructions.


