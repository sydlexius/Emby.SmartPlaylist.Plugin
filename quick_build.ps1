# Quick build script for SmartPlaylist plugin
# Builds both frontend and backend

param(
    [Parameter(Mandatory=$false)]
    [string]$Configuration = "Release"
)

Write-Host "`nBuilding SmartPlaylist Plugin ($Configuration)..." -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Build frontend
Write-Host "`n[1/2] Building frontend..." -ForegroundColor Yellow
Push-Location ".\frontend"
npm run build
$frontendSuccess = $LASTEXITCODE -eq 0
Pop-Location

if (-not $frontendSuccess) {
    Write-Host "`n✗ Frontend build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Frontend build successful" -ForegroundColor Green

# Build backend
Write-Host "`n[2/2] Building backend..." -ForegroundColor Yellow
Push-Location ".\backend"
dotnet build --configuration $Configuration
$backendSuccess = $LASTEXITCODE -eq 0
Pop-Location

if (-not $backendSuccess) {
    Write-Host "`n✗ Backend build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Backend build successful" -ForegroundColor Green

# Show output location
$dllPath = ".\backend\SmartPlaylist\bin\$Configuration\netstandard2.0\SmartPlaylist.dll"
if (Test-Path $dllPath) {
    $fileSize = (Get-Item $dllPath).Length / 1MB
    Write-Host "`n✓ Plugin DLL ready: $dllPath" -ForegroundColor Green
    Write-Host "  Size: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Gray
}

Write-Host "`n✓ Build completed successfully!" -ForegroundColor Green
