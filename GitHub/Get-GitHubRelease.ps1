function Get-GitHubRelease {
    <#
        .SYNOPSIS
        Get a list of releases from a GitHub repository.
    #>
    Param(
        [Parameter(Mandatory = $true)]
        [string]$UserOrOrganization,
        [Parameter(Mandatory = $true)]
        [string]$Repository,
        [Parameter(Mandatory = $false)]
        [switch]$Latest
    )

    Process {
        if ($Latest) {
            $url = "https://api.github.com/repos/$UserOrOrganization/$Repository/releases/latest"
            return Invoke-RestMethod -Uri $url
        }
        # Determine if the user or organization is a user or an organization
        $url = "https://api.github.com/repos/$UserOrOrganization/$Repository/releases"

        Get-GitHubApi -Url $url
    }
}
