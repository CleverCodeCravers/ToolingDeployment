Remove-Module GitHub*
Import-Module "C:\Projekte\ToolingDeployment\GitHub\GitHub.psm1"

# Get a list of repositories from the clever code cravers
Get-GitHubRepository -UserOrOrganization "CleverCodeCravers"

# Get a list of repositories from stho32 - Multipaging is required
Get-GitHubRepository -UserOrOrganization "stho32"

# Get a list of releases from the visual pair coding repository
Get-GitHubRelease -UserOrOrganization "CleverCodeCravers" -Repository "VisualPairCoding"

# Get information about the latest release
Get-GitHubRelease -UserOrOrganization "CleverCodeCravers" -Repository "VisualPairCoding" -Latest
Get-GitHubRelease -UserOrOrganization "CleverCodeCravers" -Repository "LittleScriptBuddy" -Latest

# Get a list of release assets
$release = Get-GitHubRelease -UserOrOrganization "CleverCodeCravers" -Repository "VisualPairCoding" -Latest
$asset = Get-GitHubReleaseAsset -Owner "CleverCodeCravers" -Repository "VisualPairCoding" -Tag $release.id 
$asset.browser_download_url

# Invoke-WebRequest -Uri $asset.browser_download_url -OutFile "C:\path\file"
# Download the asset

# Extract the asset
# Expand-Archive -Path $zipFile -Force

