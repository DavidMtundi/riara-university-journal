# OJS Riara — run full automated test suite
# Usage: .\run-tests.ps1 [-SkipWorkflow] [-Playwright]

param(
    [switch]$Playwright,
    [switch]$SkipWorkflow
)

$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot

$projectName = "ojs-riara"
$envFile = Join-Path $ProjectRoot ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*COMPOSE_PROJECT_NAME\s*=\s*"?([^"#]+)"?') {
            $projectName = $Matches[1].Trim()
        }
    }
}

$Container = "pkp_app_$projectName"
$Scripts = "$ProjectRoot\volumes\scripts"

Write-Host "`n=== OJS Riara Test Runner ===" -ForegroundColor Cyan
Write-Host "Container: $Container" -ForegroundColor Gray

$httpPort = "8888"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*HTTP_PORT\s*=\s*"?([^"#]+)"?') {
            $httpPort = $Matches[1].Trim()
        }
    }
}
$journalUrl = "http://127.0.0.1:$httpPort/index.php/riara/"

function Test-JournalHttp {
    param([string]$Url, [int]$TimeoutSec = 20)
    try {
        $resp = Invoke-WebRequest -Uri $Url -TimeoutSec $TimeoutSec -UseBasicParsing
        return $resp.StatusCode -eq 200
    } catch {
        return $false
    }
}

if (-not (Test-JournalHttp -Url $journalUrl)) {
    Write-Host "Journal not responding at $journalUrl (timed out or non-200)." -ForegroundColor Red
    Write-Host "Try: docker compose restart app" -ForegroundColor Yellow
    Write-Host "Or:  docker compose down && docker compose up -d --wait" -ForegroundColor Yellow
    Write-Host "Then confirm: curl.exe -I $journalUrl" -ForegroundColor Yellow
    exit 1
}
Write-Host "Journal HTTP OK: $journalUrl" -ForegroundColor Gray

$configPath = Join-Path $ProjectRoot "volumes\config\pkp.config.inc.php"
if (-not (Test-Path $configPath)) {
    Write-Host "Rendering OJS config from .env ..." -ForegroundColor Gray
    php (Join-Path $Scripts "render-config.php") --force
}

# Ensure stack is up
$running = docker ps --filter "name=$Container" --format "{{.Names}}" 2>$null
if (-not $running) {
    Write-Host "Starting Docker stack..." -ForegroundColor Yellow
    Set-Location $ProjectRoot
    docker compose up -d --no-build
    Start-Sleep -Seconds 5
}

# Sync scripts into container
Write-Host "Syncing test scripts..." -ForegroundColor Gray
docker cp "$Scripts\test-config.php" "${Container}:/tmp/test-config.php"
docker cp "$Scripts\test-lib.php" "${Container}:/tmp/test-lib.php"
docker cp "$Scripts\riara-ojs-lib.php" "${Container}:/tmp/riara-ojs-lib.php"
docker cp "$Scripts\script-db.php" "${Container}:/tmp/script-db.php"
docker cp "$Scripts\riara-env.php" "${Container}:/tmp/riara-env.php"
docker cp "$Scripts\backup.sh" "${Container}:/tmp/backup.sh"
docker cp "$Scripts\workflow-runner.php" "${Container}:/tmp/workflow-runner.php"
docker cp "$Scripts\create-test-users.php" "${Container}:/tmp/create-test-users.php"
docker cp "$Scripts\bootstrap-theme.php" "${Container}:/tmp/bootstrap-theme.php"
docker cp "$Scripts\bootstrap-journal-services.php" "${Container}:/tmp/bootstrap-journal-services.php"
docker cp "$Scripts\bootstrap-email-notifications.php" "${Container}:/tmp/bootstrap-email-notifications.php"
docker cp "$Scripts\bootstrap-google-oauth.php" "${Container}:/tmp/bootstrap-google-oauth.php"
docker cp "$Scripts\bootstrap-faculty-journals.php" "${Container}:/tmp/bootstrap-faculty-journals.php"

docker cp "$Scripts\get-published-article-id.php" "${Container}:/tmp/get-published-article-id.php"

docker cp "$Scripts\run-all-tests.php" "${Container}:/tmp/run-all-tests.php"

# Bootstrap test environment
Write-Host "Bootstrapping test users and theme..." -ForegroundColor Gray
docker exec $Container php /tmp/create-test-users.php
docker exec $Container php /tmp/bootstrap-theme.php
docker exec $Container php /tmp/bootstrap-journal-services.php
docker exec $Container php /tmp/bootstrap-email-notifications.php
docker exec -e OJS_GOOGLE_TEST_CREDENTIALS=1 $Container php /tmp/bootstrap-google-oauth.php
docker exec -e OJS_FACULTY_JOURNALS="law:Riara Law Journal|engineering:School of Engineering Journal" $Container php /tmp/bootstrap-faculty-journals.php
docker exec $Container sh -c "apachectl graceful 2>/dev/null || kill -USR1 1 || true"
docker exec $Container rm -rf /var/www/html/cache
# Warm homepage cache with the public URL so web_cache stores correct asset hosts.
curl.exe -s -o NUL "http://127.0.0.1:8888/index.php/riara/" 2>$null
curl.exe -s -o NUL "http://127.0.0.1:8888/index.php/index/" 2>$null
curl.exe -s -o NUL "http://127.0.0.1:8888/index.php/law/" 2>$null
curl.exe -s -o NUL "http://127.0.0.1:8888/index.php/engineering/" 2>$null

# Run PHP test suite inside container
Write-Host "`nRunning PHP test suite in container..." -ForegroundColor Cyan
$execArgs = @("exec", $Container, "php", "/tmp/run-all-tests.php")
if ($SkipWorkflow) {
    $execArgs = @("exec", "-e", "OJS_SKIP_WORKFLOW=1", "-e", "OJS_FACULTY_JOURNALS=law:Riara Law Journal|engineering:School of Engineering Journal", $Container, "php", "/tmp/run-all-tests.php")
} else {
    $execArgs = @("exec", "-e", "OJS_FACULTY_JOURNALS=law:Riara Law Journal|engineering:School of Engineering Journal", $Container, "php", "/tmp/run-all-tests.php")
}
docker @execArgs
$phpExit = $LASTEXITCODE

if ($Playwright) {
    Write-Host "`nRunning Playwright browser tests..." -ForegroundColor Cyan
    Set-Location $ProjectRoot
    if (-not (Test-Path "node_modules\@playwright\test")) {
        npm install
        npx playwright install chromium
    }
    $env:OJS_BASE_URL = "http://127.0.0.1:8888"
    $articleId = (docker exec $Container php /tmp/get-published-article-id.php).Trim()
    if (-not $articleId) {
        throw "Could not resolve a published article id for Playwright"
    }
    $env:OJS_TEST_ARTICLE_ID = $articleId
    Write-Host "Playwright article id: $articleId" -ForegroundColor Gray
    npx playwright test
    $pwExit = $LASTEXITCODE
} else {
    $pwExit = 0
}

if ($phpExit -ne 0 -or $pwExit -ne 0) {
    Write-Host "`nTESTS FAILED" -ForegroundColor Red
    exit 1
}

Write-Host "`nALL TESTS PASSED" -ForegroundColor Green
exit 0
