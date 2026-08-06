# OJS Riara scheduled backup (Windows Task Scheduler)
# Usage:
#   Register a daily task pointing at this script, or run manually:
#   .\volumes\scripts\scheduled-backup.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$backupSh = Join-Path $Root "volumes\scripts\backup.sh"
if (-not (Test-Path $backupSh)) {
    throw "backup.sh not found at $backupSh"
}

# Git Bash or WSL required for backup.sh (bash + docker)
$bash = Get-Command bash -ErrorAction SilentlyContinue
if (-not $bash) {
    throw "bash not found. Install Git for Windows or run backup.sh from WSL."
}

Write-Host "Running backup via bash ..."
& bash $backupSh
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host "Backup finished."
