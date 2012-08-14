# Help
#############################################################################

<#
.SYNOPSIS
Sandbox for testing Powershell commands.

.DESCRIPTION


.PARAMETER 

.INPUTS
None.

.OUTPUTS
None. This script does not generate any output.

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 14.06.2012

TODO:


.EXAMPLE
#>

param (
    [Parameter(Mandatory=$true, position=0, HelpMessage="Select installation type. (normal, full, partial)")]
    [ValidateSet('normal', 'full', 'partial')]
    [string]$type, 
    [Parameter(Mandatory=$true, position=1, HelpMessage="Select installation mode. (-all, download, install, environment")]
    [ValidateSet('all', 'download', 'install', 'environment')]
    [string]$mode,
    [Parameter(Mandatory=$true, HelpMessage="Select tool(s). (7zip, cppunit, jom, git, svn, cmake, python, eclipse, qt, boost, mvs2010expressCpp)")]
    [string[]]$tools
)

Clear
Write-host "Tools: "$tools

switch ($type)
{
    "normal" { Write-Host "Normal"}
    "full" {Write-Host "Full"}
    "partial" {Write-Host "Partial"}
    default {Write-Host "Default"}
}

if((($mode -eq "all") -or ($mode -eq "download")))
{Write-Host "Downloading"}
if((($mode -eq "all") -or ($mode -eq "install")))
{Write-Host "Installing"}
if((($mode -eq "all") -or ($mode -eq "environment")))
{Write-Host "Setting up environment"}

#Clear
#write-host "==============================="  
#write-host "Playing in the  powershell sandbox!"  
#write-host "===============================" 

#$employee_list = @() # Dynamic array definition 
#write-host "-------------------------------"  
#write-host "Checking array information"  
#write-host "-------------------------------" 
#$employee_list.gettype() # Check array information 

#$Host.UI.RawUI.BackgroundColor="magenta"
#$Host.UI.RawUI.ForegroundColor="white"
#$Host.UI.RawUI.BufferSize
#exit 99