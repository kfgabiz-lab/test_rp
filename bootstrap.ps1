# bootstrap.ps1
# Run as Administrator (first time only)
# Usage: .\bootstrap.ps1
#        .\bootstrap.ps1 -InstallDir "D:\firewall-test"

param(
    [string]$InstallDir = "C:\firewall-test",
    [string]$RepoUrl   = "https://github.com/kfgabiz-lab/test_rp.git"
)

# Check admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) {
    Write-Host "[ERROR] Please run as Administrator." -ForegroundColor Red
    exit 1
}

function Refresh-Path {
    $env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

$total = 6

Write-Host ""
Write-Host "[1/$total] Chocolatey" -ForegroundColor Cyan
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol =
        [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString(
        'https://community.chocolatey.org/install.ps1'))
    Refresh-Path
    Write-Host "  Installed" -ForegroundColor Green
} else {
    Write-Host "  Already installed: $(choco --version)" -ForegroundColor Green
}

Write-Host "[2/$total] Git" -ForegroundColor Cyan
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    choco install git -y --no-progress
    Refresh-Path
    Write-Host "  Installed" -ForegroundColor Green
} else {
    Write-Host "  Already installed: $(git --version)" -ForegroundColor Green
}

Write-Host "[3/$total] Java 17" -ForegroundColor Cyan
if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    choco install temurin17 -y --no-progress
    Refresh-Path
    Write-Host "  Installed" -ForegroundColor Green
} else {
    Write-Host "  Already installed" -ForegroundColor Green
}

Write-Host "[4/$total] Maven" -ForegroundColor Cyan
if (-not (Get-Command mvn -ErrorAction SilentlyContinue)) {
    choco install maven -y --no-progress
    Refresh-Path
    Write-Host "  Installed" -ForegroundColor Green
} else {
    Write-Host "  Already installed" -ForegroundColor Green
}

Write-Host "[5/$total] Node.js" -ForegroundColor Cyan
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    choco install nodejs-lts -y --no-progress
    Refresh-Path
    Write-Host "  Installed" -ForegroundColor Green
} else {
    Write-Host "  Already installed: $(node --version)" -ForegroundColor Green
}

Write-Host "[6/$total] Clone repo + npm install" -ForegroundColor Cyan
if (Test-Path $InstallDir) {
    Write-Host "  Directory exists: $InstallDir - running git pull"
    Set-Location $InstallDir
    git pull
} else {
    Write-Host "  Cloning: $RepoUrl -> $InstallDir"
    git clone $RepoUrl $InstallDir
    Set-Location $InstallDir
}

Write-Host "  npm install (frontend-3001)..."
Set-Location "$InstallDir\frontend-3001"
npm install --silent

Write-Host "  npm install (frontend-3002)..."
Set-Location "$InstallDir\frontend-3002"
npm install --silent

Write-Host ""
Write-Host "=======================================" -ForegroundColor Green
Write-Host "  Setup complete!" -ForegroundColor Green
Write-Host "  Install path: $InstallDir"
Write-Host ""
Write-Host "  Run:"
Write-Host "    cd $InstallDir"
Write-Host "    .\start-all.ps1"
Write-Host "=======================================" -ForegroundColor Green
