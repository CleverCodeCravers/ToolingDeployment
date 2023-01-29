param (
    [Parameter(Mandatory = $true)]
    [string]$TargetDirectory
)

Import-Module "$PSScriptRoot\GitHub\GitHub.psm1"
$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot

. .\Generic-Tools.ps1

Enable-Directory -Path $TargetDirectory

$repositories   = Get-GitHubRepository -UserOrOrganization "CleverCodeCravers"
$configFilePath = Join-Path -Path $TargetDirectory "version-information.json"
$localVersions  = Read-JsonFileIfExists -FilePath "$configFilePath" -AlternativeValue $null
$tempDirectory  = Join-Path $TargetDirectory "TempDirectory"
$assetfilter    = "*win-x64*"
if ( [bool]$IsLinux ) {
    $assetfilter = "*linux*"
}

$new_version_information = $repositories | ForEach-Object {
    $repository = $_
    Write-Host "  - Checking repository $($repository.full_name)..."
    
    try {
        $remoteVersion = Get-GitHubRelease -UserOrOrganization $repository.owner.login -Repository $repository.name -Latest
    } catch {
        Write-Host "    - The repository $($repository.full_name) does not have any releases."
        return
    }

    $localVersion = $localVersions | Where-Object full_name -eq $repository.full_name

    $updatesNeeded = !([bool]$localVersion)
    if (!$updatesNeeded) {
        if ($localVersion.created_at -ne $remoteVersion.created_at) {
            $updatesNeeded = $true
        }
    }

    if (!$updatesNeeded) {
        Write-Host "    - The repository $($repository.full_name) does not have any changes."
        
        New-Object -Type PSObject -Property @{
            full_name  = $localVersion.full_name
            created_at = $localVersion.created_at
            tag_name   = $localVersion.tag_name
        }
        return
    }

    $assets = Get-GitHubReleaseAsset -Owner $repository.owner.login -Repository $repository.name -ReleaseId $remoteVersion.id

    foreach ( $asset in $assets ) {
        if ($asset.name -like $assetfilter) {
            Write-Host "    - updating asset $($asset.name)..."
            Deploy-Asset -DownloadUrl $asset.browser_download_url -TargetDirectory $TargetDirectory -TempDirectory $tempDirectory
        }
    }

    New-Object -Type PSObject -Property @{
        full_name  = $repository.full_name
        created_at = $remoteVersion.created_at
        tag_name   = $remoteVersion.tag_name
    }
}

$new_version_information | ConvertTo-Json | Set-Content -Path $configFilePath

Remove-ItemsIfAvailable -TargetDirectory $TargetDirectory -Filter "*.pdb"
Remove-ItemsIfAvailable -TargetDirectory $TargetDirectory -Filter "appsettings*.json"
Remove-ItemsIfAvailable -TargetDirectory $TargetDirectory -Filter "web.config"
