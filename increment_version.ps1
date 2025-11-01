# Increment build number script for SmartPlaylist plugin
# Automatically increments the build number (third part of version)
# Example: 2.5.2.4862 -> 2.5.2.4863

function Get-CurrentVersion {
    $csprojPath = ".\backend\SmartPlaylist\SmartPlaylist.csproj"
    [xml]$csproj = Get-Content $csprojPath
    return $csproj.Project.PropertyGroup.Version
}

function Increment-BuildNumber($version) {
    $parts = $version.Split('.')
    $parts[3] = [int]$parts[3] + 1
    return $parts -join '.'
}

# Get current version
$currentVersion = Get-CurrentVersion
$newVersion = Increment-BuildNumber $currentVersion

Write-Host "Current version: $currentVersion" -ForegroundColor Cyan
Write-Host "New version:     $newVersion" -ForegroundColor Green
Write-Host ""

# Call the main update script
& ".\update_version.ps1" -NewVersion $newVersion
