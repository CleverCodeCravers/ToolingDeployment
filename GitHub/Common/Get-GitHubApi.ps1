function Get-GitHubApi {
    <#
        .SYNOPSIS
        In the GitHub API there are a lot of paged endpoints. This function will handle that.
    #>
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Url
    )

    process {
        $results = @()
        $page = 1
 
        while ($true) {
            $pageUrl = $Url + "?page=$page"
            $response = Invoke-RestMethod -Uri $pageUrl -Method Get
            if ($response.Count -eq 0) {
                break
            }
            $results += $response
            $page++
        }

        return $results
    }
}
