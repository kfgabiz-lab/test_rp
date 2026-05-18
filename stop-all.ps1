# stop-all.ps1
# Kill processes on ports 8080, 3001, 3002

$ports = @(8080, 3001, 3002)
$killed = 0

Write-Host ""
Write-Host "Stopping services..." -ForegroundColor White

foreach ($port in $ports) {
    $conn = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    if ($conn) {
        $pid = $conn.OwningProcess
        $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
        $procName = if ($proc) { $proc.Name } else { "unknown" }
        Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
        Write-Host "  [STOPPED] port $port  (PID: $pid / $procName)" -ForegroundColor Yellow
        $killed++
    } else {
        Write-Host "  [SKIP]    port $port  not running" -ForegroundColor Gray
    }
}

Write-Host ""
if ($killed -gt 0) {
    Write-Host "  $killed service(s) stopped." -ForegroundColor Green
} else {
    Write-Host "  No services were running." -ForegroundColor Gray
}
Write-Host ""
