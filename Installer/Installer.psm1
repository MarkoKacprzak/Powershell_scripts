# This is the CustusX development installer.

#Check that required files are present
Push-Location $psScriptRoot
. ./Install.ps1
. ./Config.ps1
. ./GetTools.ps1
Pop-Location

Function Install {
    Write-Host "Installing!!!"
    Install-CustusXDevelopmentEnvironment -dummy $true
}

#Aliases
#Set-Alias Install-CDE Install-CustusXDeveloperEnvironment

#Define which functions to make available
Export-ModuleMember -Function @(
    "Install"
    )
#Export-ModuleMember -Alias @(
#        'Install-CDE'
#)