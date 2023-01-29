function Enable-Directory {
    <#
        .SYNOPSIS
        Ensure that a directory exists.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path        
    )
    
    process {
        if (!(Test-Path $Path)) {
            New-Item -ItemType Directory -Path $Path | Out-Null
        }
    }
}

function Read-JsonFileIfExists {
    <#
        .SYNOPSIS
        Read the contents of a json file if it exists
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        $AlternativeValue
    )

    process {
        if (!(Test-Path -Path $FilePath)) {
            return $AlternativeValue
        }

        Get-Content $FilePath | ConvertFrom-Json
    }
}

function Deploy-Asset {
    <#
        .SYNOPSIS
        Downloads and processes an asset

        .DESCRIPTION
        - The asset is downloaded to the temp directory
        - It is extracted into a subdirectory of the temp directory
        - The important files are then copied over to the target directory
        - Finally the temp-directory is completly removed.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$DownloadUrl,
        [Parameter(Mandatory=$true)]
        [string]$TargetDirectory,
        [Parameter(Mandatory=$true)]
        [string]$TempDirectory
    )

    Process {
        if (Test-Path $TempDirectory) {
            Remove-Item -Path $TempDirectory -Recurse | Out-Null
        }

        New-Item $TempDirectory -ItemType Directory | Out-Null

        $tempFilePath = Join-Path $TempDirectory "asset.zip"

        Invoke-WebRequest -Uri $DownloadUrl -OutFile $tempFilePath | Out-Null

        $ExpandedArchiveDirectory = Join-Path $TempDirectory "Expanded"
        Expand-Archive -Path $tempFilePath -DestinationPath $ExpandedArchiveDirectory | Out-Null
        
        Get-ChildItem -Path $ExpandedArchiveDirectory | Copy-Item -Destination $TargetDirectory | Out-Null

        Remove-Item -Path $TempDirectory -Recurse | Out-Null
    }
}