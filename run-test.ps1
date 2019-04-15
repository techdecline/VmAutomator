param (
    [String]$vCenter,
    [String]$FilePath,
    [String]$Action,
    [PSCredential]$Credential
)

Import-Module .\VmAutomator.psd1

$computerList = Get-SourceComputerList -FilePath $FilePath

if ($vCenter) {
    if (-not ($global:vCenterObj) -or ($global:vCenterObj.Name -ne $VCenterServerName)) {
        Connect-VCenter -ComputerName $vCenter -Force -Credential $Credential
    }
    $vmArr = @()
    foreach ($computerStr in $computerList) {
        if (Test-VirtualMachine -VCenterServerName $vCenter -VirtualMachine $computerStr) {
            $vmArr += $computerStr
            Write-Verbose "added vm $computerStr to machine list"
        }
        else {
            Write-Verbose "no such vm: $computerStr"
        }
    }

    foreach ($vm in $vmArr) {
        Restart-VirtualMachine -VCenterServerName $vCenter -VirtualMachine $vm -verbose
    }
}