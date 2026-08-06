# Restart OJS Riara when the site hangs (port open but pages timeout).
# Usage: .\volumes\scripts\restart-stack.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Set-Location $Root

Write-Host "Stopping stack..." -ForegroundColor Yellow
docker compose down --timeout 30

Write-Host "Starting stack..." -ForegroundColor Yellow
docker compose up -d --wait

Write-Host "Clearing OJS cache..." -ForegroundColor Gray
$projectName = "ojs-riara"
if (Test-Path ".env") {
    Get-Content ".env" | ForEach-Object {
        if ($_ -match '^\s*COMPOSE_PROJECT_NAME\s*=\s*"?([^"#]+)"?') {
            $projectName = $Matches[1].Trim()
        }
    }
}
$container = "pkp_app_$projectName"
docker exec $container rm -rf /var/www/html/cache
docker exec $container apachectl graceful 2>$null

$url = "http://127.0.0.1:8888/index.php/riara/"
Write-Host "Probing $url ..." -ForegroundColor Gray
try {
    $code = (Invoke-WebRequest -Uri $url -TimeoutSec 20 -UseBasicParsing).StatusCode
    Write-Host "OK HTTP $code - open $url" -ForegroundColor Green
} catch {
    Write-Host "Still not responding: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Restart Docker Desktop, then run this script again." -ForegroundColor Yellow
    exit 1
}
