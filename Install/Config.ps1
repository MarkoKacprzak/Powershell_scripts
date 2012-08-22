# Help
#############################################################################

<#
.SYNOPSIS
This file contains globals for the other scripts
in the Windows installer

.DESCRIPTION


.INPUTS
None. You cannot pipe to this script.

.OUTPUTS
None. This script does not generate any output.

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 21.08.2012

TODO:


.EXAMPLE
#>
Add-Type -AssemblyName System.Drawing #for function ExtractIcon

# System info
#=========================================================================

# Returns a string with a number
Function Cores () {
    $core_list = (Get-WmiObject -class Win32_Processor -Property "NumberOfCores" | Select-Object -Property "NumberOfCores")
    $cores = 0
    foreach($item in $core_list){$cores += $item.NumberOfCores}
    return $cores
}

# Known return values:
# 32-bit
# 64-bit
Function Os_Architecture () {
    return (Get-WmiObject -Class Win32_OperatingSystem | Select-Object OSArchitecture).OSArchitecture
}

#Valid compiler architectures to look for:
# x86, x64, x86_amd64 (cross compiler)
Function Compiler ($arch){
    $found = $false
    switch ($arch){
        "x86" {$found = (Test-Path "$global:CX_MSVC_CL_X86")}
        "x64" {$found = (Test-Path "$global:CX_MSVC_CL_X64")}
        "x86_amd64" {$found = (Test-Path "$global:CX_MSVC_CL_X86_AMD64")}
        default {Write-Host "Compiler architecture $arch not recognized."}
    }
    return $found
}

Function MSVC-Installed () {
    return (Test-Path $global:CX_MSVC_CL_X86)
}

function GetElapsedTime($startTime) {
    $runtime = $(get-date) - $startTime
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

Function ExtractIcon ($exeName, $saveAs){
    [Drawing.Icon]::ExtractAssociatedIcon((Get-Command $exeName).Path).ToBitMap().Save("$saveAs")
}

# Variables
#=========================================================================
$global:CX_DEBUG_SCRIPT = $true #use if developing the windows installer script

$global:CX_DEFAULT_DRIVE = "C:" #This should be the drive where windows and all your software is installed
$global:CX_PROGRAM_FILES = $CX_DEFAULT_DRIVE+"\Program Files"
$global:CX_PROGRAM_FILES_X86 = $CX_DEFAULT_DRIVE+"\Program Files (x86)"

$global:CX_MSVC_VERSION = "10.0"
$global:CX_MSVC = $CX_PROGRAM_FILES_X86+"\Microsoft Visual Studio $CX_MSVC_VERSION"
$global:CX_MSVC_CL_X86 = $CX_MSVC+"\VC\bin\cl.exe"
$global:CX_MSVC_CL_X64 = $CX_MSVC+"\VC\bin\amd64\cl.exe"
$global:CX_MSVC_CL_X86_AMD64 = $CX_MSVC+"\VC\bin\x86_amd64\cl.exe"
$global:CX_MSVC_VCVARSALL = $CX_MSVC+"\VC\vcvarsall.bat"

$global:CX_ROOT = $CX_DEFAULT_DRIVE+"\Dev"
$global:CX_WORKSPACE = $CX_ROOT+"\workspace"
$global:CX_EXTERNAL_CODE = $CX_ROOT+"\external_code"

$global:CX_QT_VERSION = "4.8.1"
$global:CX_QT_BUILD_TYPE = "debug-and-release"
$global:CX_QT_CONFIG_OPTIONS = "-mp -$global:CX_QT_BUILD_TYPE -opensource -platform win32-msvc2010 -nomake demos -nomake examples -confirm-license"
$global:CX_QT_BUILD_X86 = $global:CX_EXTERNAL_CODE+"\Qt\Qt_"+$CX_QT_VERSION+"_build32_jom_$global:CX_QT_BUILD_TYPE"
$global:CX_QT_BUILD_X64 = $global:CX_EXTERNAL_CODE+"\Qt\Qt_"+$CX_QT_VERSION+"_build64_jom_$global:CX_QT_BUILD_TYPE"
$global:CX_QT_QTDIR_X86 = $global:CX_QT_BUILD_X86
$global:CX_QT_QTDIR_X86 = $global:CX_QT_BUILD_X64
$global:CX_QT_QMAKESPEC = "win32-msvc2010"

$cores = Cores
$global:CX_INSTALL_GENERATOR = "jom" #alternatives: "jom", "eclipse"
$global:CX_INSTALL_BUILD_TYPE = "Debug" #alternatives: "Debug", "Release", "RelWithDebInfo"
$global:CX_INSTALL_COMMON_OPTIONS = @("--silent_mode", "--$global:CX_INSTALL_GENERATOR", "-j $cores", "--build_type $global:CX_INSTALL_BUILD_TYPE") #Do NOT specify components nor checkout, config or build here

$global:CX_TOOL_FOLDER = "$HOME\Downloaded_tools"
$global:CX_ENVIRONMENT_FOLDER = "$HOME\CustusX_environment"
$global:CX_CXVARS_86 = $CX_ENVIRONMENT_FOLDER+"\cxVars_x86.bat"
$global:CX_CXVARS_64 = $CX_ENVIRONMENT_FOLDER+"\cxVars_x64.bat"

$global:CX_GIT_NAME = "Developer"
$global:CX_GIT_EMAIL = "developer@sintef.no"
