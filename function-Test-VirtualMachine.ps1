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
function Test-VirtualMachine {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        # Organizational Unit
        [Parameter(Mandatory,ParameterSetName="ByVmware")]
        [string]
        $VCenterServerName,

        # Input File
        [Parameter(Mandatory,ValueFromPipeline)]
        [String]
        $VirtualMachine
    )

    begin {
        Write-Verbose "Selected Parameter Set is: $($PSCmdlet.ParameterSetName)"
        switch ($PSCmdlet.ParameterSetName) {
            "ByVmWare" {
                if (-not ($global:vCenterObj) -or ($global:vCenterObj.Name -ne $VCenterServerName)) {
                    Write-Verbose "Connecting vCenter: $VCenterServerName"
                    Connect-VCenter -ComputerName $VCenterServerName -Force
                }
                else {
                    Write-Verbose "Connected to vCenter: $VCenterServerName"
                }
            }
            Default {
                Write-Warning "Unsupported Hypervisor Platform"
                return
            }
        }
    }

    process {
        try {
            Write-Verbose "Searching for VM: $VirtualMachine"
            Get-VM -Name $VirtualMachine -ErrorVariable vmError -ErrorAction Stop
            return $true
        }
        catch [System.Management.Automation.ActionPreferenceStopException] {
            Write-Warning $vmError[0].Message
            return $false
        }
    }
}