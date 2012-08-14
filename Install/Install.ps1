# Help
#############################################################################

<#
.SYNOPSIS


.DESCRIPTION


.INPUTS
None. You cannot pipe to this script.

.OUTPUTS
None. This script does not generate any output.

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 20.06.2012

TODO:


.EXAMPLE
#>
. .\GetTools.ps1

$script:startTime = get-date
 
function GetElapsedTime() {
    $runtime = $(get-date) - $script:StartTime
    $retStr = [string]::format("{0} days, {1} hours, {2} minutes, {3}.{4} seconds", `
        $runtime.Days, `
        $runtime.Hours, `
        $runtime.Minutes, `
        $runtime.Seconds, `
        $runtime.Milliseconds)
    $retStr
}

Function ResizeWindowBuffer (){
    $pshost = Get-Host
    $pswindow = $pshost.ui.rawui

    $newsize = $pswindow.buffersize
    $newsize.height = 32500
    $newsize.width = 120
    $pswindow.buffersize = $newsize
}

Clear-Host
ResizeWindowBuffer
Write-Host "Running the installer script." -ForegroundColor Magenta

#Main takes input parameters
#main partial all -tools:@('7-zip', 'jom')
main normal all

#python C:\Dev\CustusX3\install\Shared\script\cxInstaller.py --checkout --configure --all
#There is a bug in the script, where IGSTK tries to access information in the CustusX folder,
#which doesn't exist at that time
#python C:\Dev\CustusX3\install\Shared\script\cxInstaller.py --checkout --configure --build --silent_mode IGSTK
#python C:\Dev\CustusX3\install\Shared\script\cxInstaller.py --checkout --configure --silent_mode CustusX3
Write-Host "`nInstallation process took $(GetElapsedTime)" -ForegroundColor Green