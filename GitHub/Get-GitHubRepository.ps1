function Get-GitHubRepository {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$UserOrOrganization
    )

    process {
        # Determine if the user or organization is a user or an organization
        $url = "https://api.github.com/users/$UserOrOrganization"
        $response = Invoke-RestMethod -Uri $url -Method Get
        if ($response.type -eq "Organization") {
            $url = "https://api.github.com/orgs/$UserOrOrganization/repos"
        }
        else {
            $url = "https://api.github.com/users/$UserOrOrganization/repos"
        }

        Get-GitHubApi -Url $url
    }
}
