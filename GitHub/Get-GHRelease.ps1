function Get-GHRelease {
    <#
        .SYNOPSIS
        Get a list of repositories from a github organization
    #>
    [CmdletBinding()]
    param (
        [string]$Organization,
        [string]$User
    )
    
    process {
        if ([bool]$Organization) {
            $repositories = Invoke-RestMethod -Uri "https://api.github.com/orgs/$Organization/repos"
            $repositories | Select-Object name, description, url
        }

        if ([bool]$User) {
            $repositories = Invoke-RestMethod -Uri "https://api.github.com/users/$User/repos"
            $repositories | Select-Object name, description, url
        }        

    }
}