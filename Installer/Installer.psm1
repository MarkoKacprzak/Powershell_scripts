# This is the CustusX development installer.

$psScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition
Push-Location $psScriptRoot
. ./Utilities.ps1
. ./Install.ps1
. ./Config.ps1
. ./GetTools.ps1
. ./BuildCustusX.ps1
Pop-Location


#Aliases
Set-Alias Install-CDE Install-CustusXDevelopmentEnvironment

#Define which functions to make available
Export-ModuleMember -Function @(
    "Install-CustusXDevelopmentEnvironment",
    "ConvertTo-DeveloperMachine",
    "CX3_64bit_Release_jom",
    "CX3_64bit_Release_Eclipse",
    "CX3_64bit_Debug_jom",
    "CX3_64bit_Debug_Eclipse",
    "CX3_32bit_Release_jom",
    "CX3_32bit_Release_Eclipse",
    "CX3_32bit_Debug_jom",
    "CX3_32bit_Debug_Eclipse",
    "Get-Tools"
    )
Export-ModuleMember -Alias @(
    'Install-CDE'
)