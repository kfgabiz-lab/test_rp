# start-all.ps1
# Start all 3 services in separate PowerShell windows

$root = Split-Path -Parent $MyInvocation.MyCommand.Definition

function Start-Service([string]$name, [string]$dir, [string]$cmd) {
    $fullCmd = "Set-Location '$dir'; `$host.UI.RawUI.WindowTitle = '$name'; $cmd; Read-Host"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $fullCmd
}

Write-Host ""
Write-Host "Starting services..." -ForegroundColor White

Start-Service "Backend :8080"    "$root\backend"       ".\gradlew.bat bootRun"
Write-Host "  [OK] Backend    :8080" -ForegroundColor Green
Start-Sleep -Seconds 3

Start-Service "Frontend-A :3001" "$root\frontend-3001" "npm run dev"
Write-Host "  [OK] Frontend A :3001" -ForegroundColor Cyan
Start-Sleep -Seconds 1

Start-Service "Frontend-B :3002" "$root\frontend-3002" "npm run dev"
Write-Host "  [OK] Frontend B :3002" -ForegroundColor Magenta

Write-Host ""
Write-Host "=======================================" -ForegroundColor White
Write-Host "  Backend    : http://localhost:8080/api/ping" -ForegroundColor Green
Write-Host "  Frontend A : http://localhost:3001"          -ForegroundColor Cyan
Write-Host "  Frontend B : http://localhost:3002"          -ForegroundColor Magenta
Write-Host "=======================================" -ForegroundColor White
Write-Host "  Stop: .\stop-all.ps1" -ForegroundColor Gray
Write-Host ""
