# This is the CustusX development installer.

$psScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition
Push-Location $psScriptRoot
. ./Config.ps1
. ./Utilities.ps1
. ./Install.ps1
. ./GetTools.ps1
. ./BuildCustusX.ps1
Pop-Location


#Aliases
Set-Alias Install-CDE Install-CustusXDevelopmentEnvironment

#Define which functions to make available
Export-ModuleMember -Function @(
    "Install-CustusXDevelopmentEnvironment",
    "ConvertTo-DeveloperMachine",
    #"CX3_64bit_Release_jom", #Building dynamic does not work on windows yet
    "CX3_64bit_static_Release_jom",
    "CX3_64bit_static_Release_Eclipse",
    "CX3_64bit_static_Debug_jom",
    "CX3_64bit_static_Debug_Eclipse",
    "CX3_32bit_static_Release_jom",
    "CX3_32bit_static_Release_Eclipse",
    "CX3_32bit_static_Debug_jom",
    "CX3_32bit_static_Debug_Eclipse",
    "Get-Tools",
    "Mount-NetworkDrive",
    "Invoke-Environment",
    "Clear-PSSessionEnvironment",
    "Set-64bitEnvironment",
    "Set-32bitEnvironment",
    "Start-cxInstaller",
    "Add-ToPathSession",
    "Remove-FromPathSession"
    )
Export-ModuleMember -Alias @(
    'Install-CDE'
)