# This is the CustusX development installer.

#Check that required files are present
Push-Location $psScriptRoot
. ./Install.ps1
. ./Config.ps1
. ./GetTools.ps1
Pop-Location

Function Install-CustusXDeveloperEnvironment {
    Write-Host "Installing!!!"
    Install 
}

#Aliases
Set-Alias Install-CDE Install-CustusXDeveloperEnvironment

#Define which functions to make available
Export-ModuleMember -Function @(
    "Install-CustusXDeveloperEnvironment"
    )
Export-ModuleMember -Alias @(
        'Install-CDE'
)