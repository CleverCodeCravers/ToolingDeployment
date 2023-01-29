# Get command line arguments
param (
  [string]$TargetDirectory = "C:\Tools"
)

Set-Location $PSScriptRoot

Import-Module "$PSScriptRoot\GitHub\GitHub.psm1"

if (!(Test-Path $TargetDirectory)) {
  Write-Host "Target Directory not found, Creating..." -ForegroundColor Green
  New-Item -ItemType Directory -Path $TargetDirectory | Out-Null
}

$organization = "CleverCodeCravers"
$apiUrl = "https://api.github.com/orgs/$organization/repos"
$releasesFile = Join-Path $TargetDirectory "releases.json"

if (!(Test-Path $releasesFile)) {
  Write-Host "Releases File not found, Generating..." -ForegroundColor Green
  New-Item -ItemType File -Path $releasesFile
  $defaultContent = @{
    repos = @() | ConvertTo-Json
  }
  $defaultContent | ConvertTo-Json | Set-Content -Path $releasesFile
}

$response = Invoke-RestMethod -Uri $apiUrl

foreach ($repository in $response) {

  # Fetch the latest release information
  $repoName = $repository.name
  $releaseUrl = $repository.releases_url -replace "{/id}"
  $release = (Invoke-RestMethod -Uri $releaseUrl)[0]

  if (Test-Path $releasesFile) {
    $content = Get-Content $releasesFile | ConvertFrom-Json
    if ($content.repos.$repoName.version -eq $release.tag_name) {
      Write-Host "Repository $repoName is up to date" -ForegroundColor Green
      continue
    }
  }
    
  $assets = $release.assets
  foreach ($asset in $assets) {
    # download the zip files that match the operating system (win-x64)
    if ($asset.name -like "*win-x64*") {
      $zipFile = $asset.name
      $folder = $zipFile -replace ".zip", ""
      Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipFile

      Expand-Archive -Path $zipFile -Force

      # copy only the exe file to the target directory
      Get-ChildItem -Filter "*.exe" -Recurse | Copy-Item -Destination $TargetDirectory -Force
      $exeFileLocation = Get-ChildItem -Filter "*.exe" -Recurse

      Remove-Item -Path $zipFile -Force
      Remove-Item -Path $folder -Recurse -Force

      $releasesJSON = Get-Content -Raw -Path $releasesFile | ConvertFrom-Json
          
      if ($releasesJSON.repos.$repoName) {
        $newInfo = @{
          version = $release.tag_name; 
          zipFile = $zipFile; 
          exeFile = Join-Path $TargetDirectory $exeFileLocation
        }
        $releasesJSON.repos.$repoName = $newInfo
      }
      else {
        $newRepoInfo = @{
          version = $release.tag_name
          zipFile = $zipFile
          exeFile = Join-Path $TargetDirectory $exeFileLocation  
        }
        $releasesJSON.repos | Add-Member NoteProperty -Name $repoName -Value $newRepoInfo
      }
      $releasesJSON | ConvertTo-Json | Set-Content -Path $releasesFile
    }
  }
}
