# Enhanced version update script for SmartPlaylist plugin
# Updates version in all necessary files: csproj, HTML, webpack config, and Plugin.cs

param(
    [Parameter(Mandatory=$false)]
    [string]$NewVersion
)

function Get-CurrentVersion {
    $csprojPath = ".\backend\SmartPlaylist\SmartPlaylist.csproj"
    [xml]$csproj = Get-Content $csprojPath
    return $csproj.Project.PropertyGroup.Version
}

function Update-CsprojVersion($version) {
    $csprojPath = ".\backend\SmartPlaylist\SmartPlaylist.csproj"
    $content = Get-Content $csprojPath -Raw
    
    # Update version numbers
    $content = $content -replace '<Version>[\d\.]+</Version>', "<Version>$version</Version>"
    $content = $content -replace '<FileVersion>[\d\.]+</FileVersion>', "<FileVersion>$version</FileVersion>"
    
    # Update embedded resource references
    $content = $content -replace 'smartplaylist\.[\d\.]+\.html', "smartplaylist.$version.html"
    $content = $content -replace 'smartplaylist\.[\d\.]+\.js', "smartplaylist.$version.js"
    
    Set-Content $csprojPath $content -NoNewline
    Write-Host "✓ Updated SmartPlaylist.csproj to version $version" -ForegroundColor Green
}

function Update-PluginCs($oldVersion, $newVersion) {
    $pluginPath = ".\backend\SmartPlaylist\Plugin.cs"
    $content = Get-Content $pluginPath -Raw
    $content = $content -replace "smartplaylist\.$oldVersion\.html", "smartplaylist.$newVersion.html"
    $content = $content -replace "smartplaylist\.$oldVersion\.js", "smartplaylist.$newVersion.js"
    Set-Content $pluginPath $content -NoNewline
    Write-Host "✓ Updated Plugin.cs to reference version $newVersion" -ForegroundColor Green
}

function Update-WebpackConfig($oldVersion, $newVersion) {
    $webpackPath = ".\frontend\webpack.config.prod.js"
    $content = Get-Content $webpackPath -Raw
    $content = $content -replace "smartplaylist\.$oldVersion", "smartplaylist.$newVersion"
    Set-Content $webpackPath $content -NoNewline
    Write-Host "✓ Updated webpack.config.prod.js to version $newVersion" -ForegroundColor Green
}

function Rename-HtmlFile($oldVersion, $newVersion) {
    $configDir = ".\backend\SmartPlaylist\Configuration"
    $oldPath = Join-Path $configDir "smartplaylist.$oldVersion.html"
    $newPath = Join-Path $configDir "smartplaylist.$newVersion.html"
    
    if (Test-Path $oldPath) {
        # Update version reference inside the HTML file before renaming
        $content = Get-Content $oldPath -Raw
        $content = $content -replace "smartplaylist\.$oldVersion\.js", "smartplaylist.$newVersion.js"
        Set-Content $oldPath $content -NoNewline
        
        # Rename the file
        Rename-Item $oldPath $newPath -Force
        Write-Host "✓ Renamed HTML file from $oldVersion to $newVersion" -ForegroundColor Green
    } else {
        Write-Host "⚠ HTML file not found: $oldPath" -ForegroundColor Yellow
    }
}

function Remove-OldVersionFiles($currentVersion) {
    $configDir = ".\backend\SmartPlaylist\Configuration"
    
    # Remove old HTML files (keep only current version)
    Get-ChildItem $configDir -Filter "smartplaylist.*.html" | Where-Object {
        $_.Name -ne "smartplaylist.$currentVersion.html"
    } | ForEach-Object {
        Remove-Item $_.FullName -Force
        Write-Host "✓ Removed old HTML file: $($_.Name)" -ForegroundColor Gray
    }
    
    # Remove old JS files (keep only current version)
    Get-ChildItem $configDir -Filter "smartplaylist.*.js" | Where-Object {
        $_.Name -ne "smartplaylist.$currentVersion.js"
    } | ForEach-Object {
        Remove-Item $_.FullName -Force
        Write-Host "✓ Removed old JS file: $($_.Name)" -ForegroundColor Gray
    }
    
    # Remove old CSS files (keep only current version)
    Get-ChildItem $configDir -Filter "smartplaylist.*.css" | Where-Object {
        $_.Name -ne "smartplaylist.$currentVersion.css"
    } | ForEach-Object {
        Remove-Item $_.FullName -Force
        Write-Host "✓ Removed old CSS file: $($_.Name)" -ForegroundColor Gray
    }
}

function Update-AllVersions($oldVersion, $newVersion) {
    Write-Host "`nUpdating from version $oldVersion to $newVersion..." -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    
    # Update all files
    Update-CsprojVersion $newVersion
    Update-PluginCs $oldVersion $newVersion
    Update-WebpackConfig $oldVersion $newVersion
    Rename-HtmlFile $oldVersion $newVersion
    
    # Clean up old version files
    Write-Host "`nCleaning up old version files..." -ForegroundColor Cyan
    Remove-OldVersionFiles $newVersion
    
    Write-Host "`n✓ All version updates completed!" -ForegroundColor Green
    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "  1. Run: cd frontend && npm run build" -ForegroundColor White
    Write-Host "  2. Run: cd backend && dotnet build --configuration Release" -ForegroundColor White
    Write-Host "  3. Deploy the updated SmartPlaylist.dll to your Emby server" -ForegroundColor White
}

# Main script execution
$currentVersion = Get-CurrentVersion

if (-not $NewVersion) {
    Write-Host "Current version: $currentVersion" -ForegroundColor Cyan
    Write-Host ""
    $NewVersion = Read-Host "Enter new version (e.g., 2.5.2.4863)"
}

# Validate version format
if ($NewVersion -notmatch '^\d+\.\d+\.\d+\.\d+$') {
    Write-Host "Error: Invalid version format. Use format: major.minor.build.revision (e.g., 2.5.2.4863)" -ForegroundColor Red
    exit 1
}

# Confirm the update
Write-Host "`nYou are about to update from $currentVersion to $NewVersion" -ForegroundColor Yellow
$confirm = Read-Host "Continue? (Y/N)"
if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "Update cancelled." -ForegroundColor Yellow
    exit 0
}

Update-AllVersions $currentVersion $NewVersion
