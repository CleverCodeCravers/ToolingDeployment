function Get-GitHubReleaseAsset {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Owner,
        [Parameter(Mandatory=$true)]
        [string]$Repository,
        [Parameter(Mandatory=$true)]
        [string]$ReleaseId
    )

    Process {
        $url = "https://api.github.com/repos/$Owner/$Repository/releases/$ReleaseId/assets"
        $assets = Invoke-RestMethod -Uri $url
    
        $assets
    }
}
