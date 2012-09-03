# This is the CustusX development installer.

#Check that required files are present
Push-Location $psScriptRoot
. ./Utilities.ps1
. ./Install.ps1
. ./Config.ps1
. ./GetTools.ps1
Pop-Location


#Aliases
Set-Alias Install-CDE Install-CustusXDevelopmentEnvironment

#Define which functions to make available
Export-ModuleMember -Function @(
    "Install-CustusXDevelopmentEnvironment",
    "ConvertTo-DeveloperMachine"
    )
Export-ModuleMember -Alias @(
    'Install-CDE'
)