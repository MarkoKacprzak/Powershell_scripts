# Help
#############################################################################

<#
.SYNOPSIS


.DESCRIPTION
This is my personal Powershell library.


.INPUTS
None. You cannot pipe to this script.

.OUTPUTS
None. This script does not generate any output.

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 20.08.2012

TODO:


.EXAMPLE
#>

# Import other scripts
############################

# Script variabels
############################
$script:startTime = get-date

# Functions
############################

# *** Time execution
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

# Classes
############################