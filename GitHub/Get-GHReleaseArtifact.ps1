function Get-GHReleaseArtifact {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Owner,
        [Parameter(Mandatory=$true)]
        [string]$Repository,
        [Parameter(Mandatory=$true)]
        [string]$Tag
    )

    Process {
        $url = "https://api.github.com/repos/$owner/$repo/releases/tags/$tag"
        $release = Invoke-RestMethod -Uri $url
    
        $assets = $release.assets
        $assets | Select-Object -Property name, download_count, created_at
    }
}
