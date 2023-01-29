function Get-GitHubReleaseAsset {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Owner,
        [Parameter(Mandatory=$true)]
        [string]$Repository,
        [Parameter(Mandatory=$true)]
        [string]$Tag
    )

    Process {
        $url = "https://api.github.com/repos/$Owner/$Repository/releases/$Tag/assets"
        $assets = Invoke-RestMethod -Uri $url
    
        $assets
    }
}
