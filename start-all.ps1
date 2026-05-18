# start-all.ps1
# 3개 서비스를 각각 별도 PowerShell 창으로 실행

$root = Split-Path -Parent $MyInvocation.MyCommand.Definition

function Start-Service([string]$name, [string]$dir, [string]$cmd, [string]$color) {
    $title = "[$name]"
    $fullCmd = "Set-Location '$dir'; `$host.UI.RawUI.WindowTitle = '$title'; $cmd; Read-Host"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $fullCmd
    Write-Host "  ✓ $name 시작" -ForegroundColor $color
}

Write-Host "`n서비스 시작 중..." -ForegroundColor White

Start-Service "Backend   :8080" "$root\backend"       "mvn spring-boot:run"  "Green"
Start-Sleep -Seconds 3
Start-Service "Frontend A :3001" "$root\frontend-3001" "npm run dev"          "Cyan"
Start-Sleep -Seconds 1
Start-Service "Frontend B :3002" "$root\frontend-3002" "npm run dev"          "Magenta"

Write-Host ""
Write-Host "========================================" -ForegroundColor White
Write-Host "  Backend    : http://localhost:8080/api/ping" -ForegroundColor Green
Write-Host "  Frontend A : http://localhost:3001"          -ForegroundColor Cyan
Write-Host "  Frontend B : http://localhost:3002"          -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor White
Write-Host ""
Write-Host "종료: .\stop-all.ps1" -ForegroundColor Gray
