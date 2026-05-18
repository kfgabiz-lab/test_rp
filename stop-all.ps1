# stop-all.ps1
# 8080, 3001, 3002 포트를 사용하는 프로세스 종료

$ports = @(8080, 3001, 3002)
$killed = 0

Write-Host "`n서비스 종료 중..." -ForegroundColor White

foreach ($port in $ports) {
    $conn = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    if ($conn) {
        $pid = $conn.OwningProcess
        $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
        $procName = if ($proc) { $proc.Name } else { "unknown" }
        Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
        Write-Host "  ✓ 포트 $port 종료  (PID: $pid / $procName)" -ForegroundColor Yellow
        $killed++
    } else {
        Write-Host "  - 포트 $port 실행 중 아님" -ForegroundColor Gray
    }
}

Write-Host ""
if ($killed -gt 0) {
    Write-Host "  $killed 개 서비스 종료됨" -ForegroundColor Green
} else {
    Write-Host "  실행 중인 서비스가 없습니다" -ForegroundColor Gray
}
Write-Host ""
