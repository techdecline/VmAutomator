<#
    .SYNOPSIS
    Gets Computer Names from various sources.

    .DESCRIPTION
    Gets Computer Names from various sources. Parameter Sets are used to set source type. Currently, only Active Directory and File
    are implemented.

    .EXAMPLE
    PS> Get-SourceComputerList -OrganizationUnit 'OU=Workstations,DC=Contoso,DC=com'

    Get all computers from Organizational Unit 'OU=Workstations,DC=Contoso,DC=com'

    .EXAMPLE
    PS> Get-SourceComputerList -FilePath "C:\Temp\computerlist.txt"

    Get all computers from text file "C\Temp\computerlist.txt".
#>
function Get-SourceComputerList {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        # Organizational Unit
        [Parameter(Mandatory,ParameterSetName="ByActiveDirectory")]
        [string]
        $OrganizationUnit,

        # Input File
        [Parameter(Mandatory,ParameterSetName="ByFile")]
        [ValidateScript({Test-Path -Path $_})]
        [String]
        $FilePath
    )

    begin {
        Write-Verbose "Parameter Set Name is: $($PSCmdlet.ParameterSetName)"
        switch ($PSCmdlet.ParameterSetName) {
            "ByActiveDirectory" {
                try {
                    Import-Module ActiveDirectory -ErrorAction Stop -ErrorVariable modError -Verbose:$false
                }
                catch {
                    Write-Error $modError.Message
                    return
                }
            }
            "ByFile" {
                # Placeholder
            }
            Default {
                Write-Warning "unsupported input type"
                return
            }
        }
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            "ByActiveDirectory" {
                Write-Verbose "Scanning for computer objects at: $OrganizationUnit"
                $ouObj = Get-ADOrganizationalUnit -Identity $OrganizationUnit -ErrorAction SilentlyContinue
                if ($ouObj) {
                    $computerArr = Get-ADComputer -SearchBase $ouObj.DistinguishedName -Filter * | Select-Object -ExpandProperty Name
                    return $computerArr
                }
                else {
                    Write-Warning "Non-existing Organizational Unit selected: $OrganizationUnit"
                    return
                }
            }
            "ByFile" {
                Write-Verbose "Reading input file: $FilePath"
                $computerArr = Get-Content -Path $FilePath
                return $computerArr
            }
        }
    }
}