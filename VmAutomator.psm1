# Implement your module commands in this script.
. $PSScriptRoot\function-Get-SourceComputerList.ps1
. $PSScriptRoot\function-Connect-VCenter.ps1
. $PSScriptRoot\function-Initialize-VirtualMachine.ps1
. $PSScriptRoot\function-Test-VirtualMachine.ps1
. $PSScriptRoot\function-Restart-VirtualMachine.ps1

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function Get-SourceComputerList,Initialize-VirtualMachine,Connect-VCenter,Test-VirtualMachine,Restart-VirtualMachine