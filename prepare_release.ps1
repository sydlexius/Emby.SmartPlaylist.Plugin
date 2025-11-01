# Complete workflow: increment version, build, and show next steps
# This is your one-stop script for preparing a new plugin version

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "SmartPlaylist Plugin - Version & Build" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Step 1: Increment version
Write-Host "[Step 1/2] Incrementing version..." -ForegroundColor Yellow
& ".\increment_version.ps1"

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n✗ Version update failed or was cancelled!" -ForegroundColor Red
    exit 1
}

# Step 2: Build
Write-Host "`n[Step 2/2] Building plugin..." -ForegroundColor Yellow
& ".\quick_build.ps1" -Configuration "Release"

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n✗ Build failed!" -ForegroundColor Red
    exit 1
}

# Show deployment instructions
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Ready to Deploy!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nDLL Location:" -ForegroundColor Yellow
Write-Host "  .\backend\SmartPlaylist\bin\Release\netstandard2.0\SmartPlaylist.dll" -ForegroundColor White
Write-Host "`nTo deploy:" -ForegroundColor Yellow
Write-Host "  1. Copy the DLL to your Emby server's plugins folder" -ForegroundColor White
Write-Host "  2. Restart Emby Server" -ForegroundColor White
Write-Host "  3. Clear browser cache (Ctrl+Shift+Delete)" -ForegroundColor White
Write-Host "  4. Test the plugin" -ForegroundColor White
Write-Host ""
