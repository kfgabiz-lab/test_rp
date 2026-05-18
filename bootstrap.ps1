# bootstrap.ps1
# 새 Windows Server에서 최초 1회 실행 (관리자 권한 필요)
# 사용법: .\bootstrap.ps1
#         .\bootstrap.ps1 -InstallDir "D:\firewall-test"

param(
    [string]$InstallDir = "C:\firewall-test",
    [string]$RepoUrl   = "https://github.com/kfgabiz-lab/test_rp.git"
)

# ── 관리자 권한 확인 ─────────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) {
    Write-Host "[ERROR] 관리자 권한으로 실행해주세요." -ForegroundColor Red
    Write-Host "  PowerShell을 우클릭 → '관리자 권한으로 실행' 후 다시 시도하세요."
    exit 1
}

function Refresh-Path {
    $env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

function Step([int]$n, [int]$total, [string]$msg) {
    Write-Host "`n[$n/$total] $msg" -ForegroundColor Cyan
}

$total = 6

# ── 1. Chocolatey ────────────────────────────────────────────
Step 1 $total "Chocolatey 확인"
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol =
        [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString(
        'https://community.chocolatey.org/install.ps1'))
    Refresh-Path
    Write-Host "  Chocolatey 설치 완료" -ForegroundColor Green
} else {
    Write-Host "  이미 설치됨: $(choco --version)" -ForegroundColor Green
}

# ── 2. Git ───────────────────────────────────────────────────
Step 2 $total "Git 확인"
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    choco install git -y --no-progress
    Refresh-Path
    Write-Host "  Git 설치 완료" -ForegroundColor Green
} else {
    Write-Host "  이미 설치됨: $(git --version)" -ForegroundColor Green
}

# ── 3. Java 17 ───────────────────────────────────────────────
Step 3 $total "Java 17 확인"
if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    choco install temurin17 -y --no-progress
    Refresh-Path
    Write-Host "  Java 17 설치 완료" -ForegroundColor Green
} else {
    $jv = java -version 2>&1 | Select-Object -First 1
    Write-Host "  이미 설치됨: $jv" -ForegroundColor Green
}

# ── 4. Maven ─────────────────────────────────────────────────
Step 4 $total "Maven 확인"
if (-not (Get-Command mvn -ErrorAction SilentlyContinue)) {
    choco install maven -y --no-progress
    Refresh-Path
    Write-Host "  Maven 설치 완료" -ForegroundColor Green
} else {
    Write-Host "  이미 설치됨: $(mvn -version 2>&1 | Select-Object -First 1)" -ForegroundColor Green
}

# ── 5. Node.js ───────────────────────────────────────────────
Step 5 $total "Node.js 확인"
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    choco install nodejs-lts -y --no-progress
    Refresh-Path
    Write-Host "  Node.js 설치 완료" -ForegroundColor Green
} else {
    Write-Host "  이미 설치됨: $(node --version)" -ForegroundColor Green
}

# ── 6. 레포 클론 + npm install ───────────────────────────────
Step 6 $total "레포 클론 및 의존성 설치"

if (Test-Path $InstallDir) {
    Write-Host "  디렉토리가 이미 존재합니다: $InstallDir" -ForegroundColor Yellow
    Write-Host "  git pull로 최신화합니다..."
    Set-Location $InstallDir
    git pull
} else {
    Write-Host "  클론 중: $RepoUrl → $InstallDir"
    git clone $RepoUrl $InstallDir
    Set-Location $InstallDir
}

Write-Host "  npm install (frontend-3001)..."
Set-Location "$InstallDir\frontend-3001"
npm install --silent

Write-Host "  npm install (frontend-3002)..."
Set-Location "$InstallDir\frontend-3002"
npm install --silent

# ── 완료 ─────────────────────────────────────────────────────
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  설치 완료!" -ForegroundColor Green
Write-Host "  설치 경로: $InstallDir"
Write-Host ""
Write-Host "  실행 방법:"
Write-Host "    cd $InstallDir"
Write-Host "    .\start-all.ps1"
Write-Host "========================================" -ForegroundColor Green
