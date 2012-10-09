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
$psScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition
Push-Location $psScriptRoot
. .\Utilities.ps1
Pop-Location

# PRIVATE user information 
# (EDIT)
###################################################
$script:CX_GIT_NAME = "Janne Beate Bakeng"
$script:CX_GIT_EMAIL = "janne.beate.lervik.bakeng@sintef.no"

$script:CX_MEDTEK_USERNAME = "jannebb"

$script:CX_ISB_PASSWORD = "sintefsvn" # must not be saved?

# System information 
# (normally no need to edit)
###################################################
$script:CX_DEBUG_SCRIPT = $false #use if developing the windows installer script

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
$script:CX_EXTERNAL_CODE = $CX_ROOT+"\external"

$script:CX_QT_VERSION = "4.8.1"
$script:CX_QT_QMAKESPEC = "win32-msvc2010"
$script:CX_QT_BUILD_TYPE = "debug-and-release"
$script:CX_QT_CONFIG_OPTIONS = @("-$script:CX_QT_BUILD_TYPE", "-opensource", "-platform", "$script:CX_QT_QMAKESPEC", "-confirm-license")
$script:CX_QT_BUILD_X86 = $script:CX_EXTERNAL_CODE+"\Qt\Qt_"+$CX_QT_VERSION+"_build32_DebugAndRelease"
$script:CX_QT_BUILD_X64 = $script:CX_EXTERNAL_CODE+"\Qt\Qt_"+$CX_QT_VERSION+"_build64_DebugAndRelease"
$script:CX_QT_QTDIR_X86 = $script:CX_QT_BUILD_X86
$script:CX_QT_QTDIR_X64 = $script:CX_QT_BUILD_X64

$script:CX_CORES = Get-Cores
$script:CX_INSTALL_COMMON_OPTIONS = @("--silent_mode", "--static", "--user", "$script:CX_MEDTEK_USERNAME", "--isb_password", "$script:CX_ISB_PASSWORD") #Do NOT specify components, checkout, config or build here

$script:CX_TOOL_FOLDER = "$script:CX_ROOT\Downloaded_applications"
$script:CX_ENVIRONMENT_FOLDER = "$script:CX_ROOT\CustusX_environment"
$script:CX_CXVARS_86 = $CX_ENVIRONMENT_FOLDER+"\cxVars_x86.bat"
$script:CX_CXVARS_64 = $CX_ENVIRONMENT_FOLDER+"\cxVars_x64.bat"

if(!$script:CX_LOGGER){
    $script:CX_LOGGER = New-Object Log($script:CX_ENVIRONMENT_FOLDER+"\Installation_log.txt")
}