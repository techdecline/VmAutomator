<#
    .SYNOPSIS
    Restarts a virtual machine in case it is online.

    .DESCRIPTION
    Restarts a virtual machine in case it is online.

    Currently, VMware is the only supported platform.
    .EXAMPLE
    Restart-VirtualMachine -VirtualMachine TestVM1 -VCenterServerName vcenter1.contoso.com

#>
function Restart-VirtualMachine {
    [CmdletBinding(DefaultParameterSetName="Default")]
    param (
        # # Vcenter Server FQDN
        [Parameter(Mandatory,ParameterSetName="ByVmware")]
        [string]
        $VCenterServerName,

        # Virtual Machine Name
        [Parameter(Mandatory,ValueFromPipeline)]
        [String]
        $VirtualMachine,

        [Parameter(Mandatory=$false)]
        [PScredential]$Credential
    )

    begin {
        Write-Verbose "Selected Parameter Set is: $($PSCmdlet.ParameterSetName)"
        switch ($PSCmdlet.ParameterSetName) {
            "ByVmWare" {
                if (-not ($global:vCenterObj) -or ($global:vCenterObj.Name -ne $VCenterServerName)) {
                    Write-Verbose "Connecting vCenter: $VCenterServerName"
                    Connect-VCenter -ComputerName $VCenterServerName -Force -Credential $Credential
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
        switch ($PSCmdlet.ParameterSetName) {
            "ByVmWare" {
                $vmObj = Get-VM -Name $VirtualMachine
                if ($vmObj.PowerState -ne "PoweredOff") {
                    try {
                        Write-Verbose "Machine $VirtualMachine is currently running"
                        Test-WSMan $VirtualMachine -ErrorAction Stop | Out-Null
                        Write-Verbose "VM $VirtualMachine allows Windows Remote Management, will use WSMan to determine online state."

                    }
                    catch [System.Management.Automation.ActionPreferenceStopException] {
                        Write-Verbose "VM $VirtualMachine does not allow Windows Remote Management, will fallback to timer-based mode."
                        $onlineTimerSeconds = 45
                    }
                    Stop-VM $vmObj -RunAsync:$false -Confirm:$false
                    Start-VM $vmObj
                    if ($onlineTimerSeconds) {
                        Start-Sleep -Seconds 45
                    }
                    else {
                        while (-not (Test-WSMan $VirtualMachine)) {
                            Write-Verbose "Waiting for Machine $virtualMachine to come online"
                            Start-Sleep -Seconds 5
                        }
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