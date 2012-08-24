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

#>
Add-Type -AssemblyName System.Drawing #for function ExtractIcon

# System info
#=========================================================================
Function Test-QtConfigured ($buildFolder){
    $configured = $false
    $cache = $buildFolder+"\configure.cache"
    if(Test-Path $cache)
        {$configured = $true}
    
    return $configured
}

# Returns a string with a number
Function Get-Cores () {
    $core_list = (Get-WmiObject -class Win32_Processor -Property "NumberOfCores" | Select-Object -Property "NumberOfCores")
    $cores = 0
    foreach($item in $core_list){$cores += $item.NumberOfCores}
    return $cores
}

# Known return values:
# 32-bit
# 64-bit
Function Get-OsArchitecture () {
    return (Get-WmiObject -Class Win32_OperatingSystem | Select-Object OSArchitecture).OSArchitecture
}

#Valid compiler architectures to look for:
# x86, x64, x86_amd64 (cross compiler)
Function Find-Compiler ($arch){
    $found = $false
    switch ($arch){
        "x86" {$found = (Test-Path "$script:CX_MSVC_CL_X86")}
        "x64" {$found = (Test-Path "$script:CX_MSVC_CL_X64")}
        "x86_amd64" {$found = (Test-Path "$script:CX_MSVC_CL_X86_AMD64")}
        default {Write-Host "Compiler architecture $arch not recognized."}
    }
    return $found
}

Function Test-MSVCInstalled () {
    return (Test-Path $script:CX_MSVC_CL_X86)
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
    $stream = [System.IO.File]::OpenWrite($saveAs)
    #$bitmap = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command $exeName).Path).ToBitMap()
    #$bitmap.SetResolution(72,72)
    #$icon = [System.Drawing.Icon]::FromHandle($bitmap.GetHicon())
    $icon = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command $exeName).Path)
    $icon.Save($stream)
    $stream.Close()
}

# Variables
#=========================================================================

# User specific information
###################################################
$script:CX_GIT_NAME = "Developer"
$script:CX_GIT_EMAIL = "developer@sintef.no"

$script:CX_MEDTEK_USERNAME = "medtek"

$script:CX_GITHUB_USERNAME = "user"
$script:CX_GITHUB_PASSWORD = "password" #TODO not nice to have in plain text...

# System information
###################################################
$script:CX_DEBUG_SCRIPT = $true #use if developing the windows installer script

$script:CX_DEFAULT_DRIVE = "C:" #This should be the drive where windows and all your software is installed
$script:CX_PROGRAM_FILES = $CX_DEFAULT_DRIVE+"\Program Files"
$script:CX_PROGRAM_FILES_X86 = $CX_DEFAULT_DRIVE+"\Program Files (x86)"

$script:CX_MSVC_VERSION = "10.0"
$script:CX_MSVC = $CX_PROGRAM_FILES_X86+"\Microsoft Visual Studio $CX_MSVC_VERSION"
$script:CX_MSVC_CL_X86 = $CX_MSVC+"\VC\bin\cl.exe"
$script:CX_MSVC_CL_X64 = $CX_MSVC+"\VC\bin\amd64\cl.exe"
$script:CX_MSVC_CL_X86_AMD64 = $CX_MSVC+"\VC\bin\x86_amd64\cl.exe"
$script:CX_MSVC_VCVARSALL = $CX_MSVC+"\VC\vcvarsall.bat"

$script:CX_ROOT = $CX_DEFAULT_DRIVE+"\Dev"
$script:CX_WORKSPACE = $CX_ROOT+"\workspace"
$script:CX_EXTERNAL_CODE = $CX_ROOT+"\external_code"

$script:CX_QT_VERSION = "4.8.1"
$script:CX_QT_QMAKESPEC = "win32-msvc2010"
$script:CX_QT_BUILD_TYPE = "debug-and-release"
$script:CX_QT_CONFIG_OPTIONS = @("-$script:CX_QT_BUILD_TYPE", "-opensource", "-platform", "$script:CX_QT_QMAKESPEC", "-confirm-license")
$script:CX_QT_BUILD_X86 = $script:CX_EXTERNAL_CODE+"\Qt\Qt_"+$CX_QT_VERSION+"_build32_jom_DebugAndRelease"
$script:CX_QT_BUILD_X64 = $script:CX_EXTERNAL_CODE+"\Qt\Qt_"+$CX_QT_VERSION+"_build64_jom_DebugAndRelease"
$script:CX_QT_QTDIR_X86 = $script:CX_QT_BUILD_X86
$script:CX_QT_QTDIR_X64 = $script:CX_QT_BUILD_X64

$cores = Cores
#REMOVE when used as a parameter in Installer.ps1
$script:CX_INSTALL_GENERATOR = "jom" #alternatives: "jom", "eclipse"
#REMOVE when used as a parameter in Installer.ps1
$script:CX_INSTALL_BUILD_TYPE = "Debug" #alternatives: "Debug", "Release", "RelWithDebInfo"
$script:CX_INSTALL_COMMON_OPTIONS = @("--silent_mode", "--static", "--$script:CX_INSTALL_GENERATOR", "-j", "$cores", "--build_type", "$script:CX_INSTALL_BUILD_TYPE", "--user", "$script:CX_MEDTEK_USERNAME", "--github_user", "$script:CX_GITHUB_USERNAME", "--github_password", "$script:CX_GITHUB_PASSWORD") #Do NOT specify components nor checkout, config or build here

#TODO should look like this instead
#$script:CX_INSTALL_COMMON_OPTIONS = @("--silent_mode", "--static", "-j", "$cores", "--user", "$script:CX_MEDTEK_USERNAME")

$script:CX_TOOL_FOLDER = "$HOME\Downloaded_tools"
$script:CX_ENVIRONMENT_FOLDER = "$HOME\CustusX_environment"
$script:CX_CXVARS_86 = $CX_ENVIRONMENT_FOLDER+"\cxVars_x86.bat"
$script:CX_CXVARS_64 = $CX_ENVIRONMENT_FOLDER+"\cxVars_x64.bat"
