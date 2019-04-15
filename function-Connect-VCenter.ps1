<#
    .SYNOPSIS
    Connects to a VI Server and persists the connection globally.

    .DESCRIPTION
    Connects to a VI Server using PowerCLI and persists the connection globally.

    .EXAMPLE
    PS> Connect-VCenter -ComputerName vcenter1.contoso.com

    Connects to vcenter1.contoso.com using PowerCLI and persists connection object in global variable $vCenterObj.
#>
function Connect-VCenter {
    [CmdletBinding()]
    param (
        # vCenter Name
        [Parameter(Mandatory)]
        [ValidateScript({test-connection $_ -Quiet})]
        [string]
        $ComputerName,

        # Switch Parameter to allow lower security
        [Parameter(Mandatory=$false)]
        [switch]
        $Force,

        # Credential Object
        [Parameter(Mandatory)]
        [PSCredential]$Credential
    )

    begin {
        try {
            Import-Module VMware.PowerCLI -ErrorAction Stop -ErrorVariable modError -Verbose:$false
        }
        catch {
            Write-Error $modError.Message
            return
        }
    }

    process {
        if (Get-Module vmware.PowerCLI) {
            if ($Force) {
                Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -ParticipateInCeip:$false -Confirm:$false -Scope Session | Out-Null
            }
            try {
                Write-Verbose "Connecting vCenter $ComputerName"
                $Global:vCenterObj = Connect-VIServer $ComputerName -ErrorAction Stop -ErrorVariable conError -Credential $Credential
                return $Global:vCenterObj
            }
            catch {
                Write-Error $conError.Message
                return
            }
        }
    }

    end {
    }
}