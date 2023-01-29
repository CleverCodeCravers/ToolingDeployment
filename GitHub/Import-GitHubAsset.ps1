function Import-GitHubAsset {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$UserOrOrganization,
        [Parameter(Mandatory = $true)]
        [string]$Repository,
        [Parameter(Mandatory = $true)]
        [string]$ReleaseId,
        [Parameter(Mandatory = $true)]
        [string]$AssetId,
        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    process {
        # Determine if the user or organization is a user or an organization
        $url = "https://api.github.com/users/$UserOrOrganization"
        $response = Invoke-RestMethod -Uri $url -Method Get
        if ($response.type -eq "Organization") {
            $url = "https://api.github.com/orgs/$UserOrOrganization/repos/$Repository/releases/$ReleaseId/assets/$AssetId"
        }
        else {
            $url = "https://api.github.com/users/$UserOrOrganization/repos/$Repository/releases/$ReleaseId/assets/$AssetId"
        }

        # Get the asset
        $asset = Invoke-RestMethod -Uri $url -Method Get

        # Download the asset
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $Destination
    }
}