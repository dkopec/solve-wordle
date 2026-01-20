# PowerShell script to update .csproj version from version.json

param(
    [Parameter(Mandatory=$true)]
    [string]$VersionJsonPath,
    
    [Parameter(Mandatory=$true)]
    [string]$CsprojPath
)

# Read version from version.json
$versionContent = Get-Content -Path $VersionJsonPath -Raw | ConvertFrom-Json
$newVersion = $versionContent.version

Write-Host "Updating .csproj version to: $newVersion"

# Read .csproj content
$csprojContent = Get-Content -Path $CsprojPath -Raw

# Update version using regex
$pattern = '<Version>[^<]+</Version>'
$replacement = "<Version>$newVersion</Version>"
$updatedContent = $csprojContent -replace $pattern, $replacement

# Write back to file
Set-Content -Path $CsprojPath -Value $updatedContent -NoNewline

Write-Host "Successfully updated $CsprojPath"
