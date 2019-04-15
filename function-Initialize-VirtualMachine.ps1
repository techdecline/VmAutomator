<#
    .SYNOPSIS
    Snapshots a virtual machine and starts it in case it is not online.

    .DESCRIPTION
    Snapshots a virtual machine and starts it in case it is not online.

    Currently, VMware is the only supported platform.
    .EXAMPLE
    Initialize-VirtualMachine -VirtualMachine TestVM1 -VCenterServerName vcenter1.contoso.com

#>
function Initialize-VirtualMachine {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        # Vcenter Server FQDN
        [Parameter(Mandatory,ParameterSetName="ByVmware")]
        [string]
        $VCenterServerName,

        # Input File
        [Parameter(Mandatory,ValueFromPipeline)]
        [String[]]
        $VirtualMachine,

        # Snapshot Name Prefix
        [Parameter(Mandatory=$false)]
        [string]
        $SnapshotNamePrefix = "Default_"
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
        $snapShotName = $SnapshotNamePrefix + "_" + (Get-Date -Format yyyyMMdd)
        switch ($PSCmdlet.ParameterSetName) {
            "ByVmWare" {
                $vmArr = Get-VM -Name $VirtualMachine
                foreach ($vmObj in $vmArr) {
                    $vmName = $vmObj.Name
                    if ($vmObj.PowerState -eq "PoweredOff") {
                        Write-Verbose -Message "Virtual Machine $VMName has been powered off...Powering on and waiting for 60 seconds"
                        Start-VM -VM $vmObj
                        Start-Sleep -Seconds 60
                    }
                    Write-Verbose "Creating Snapshot $snapShotName for VM $VMName"
                    try {
                        New-Snapshot -VM $vmObj -Name $snapShotName -ErrorAction Stop -ErrorVariable snapError | Out-Null
                        return $true
                    }
                    catch {
                        write-error $snapError[0].Message
                        return
                    }
                }
            }
            Default {
                Write-Warning "Unsupported Hypervisor Platform"
                return
            }
        }
    }
}