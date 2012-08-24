# Help
#############################################################################

<#
.SYNOPSIS
Installs tools, sets up developer environment
and builds CustusX and required libraries.

.DESCRIPTION


.INPUTS
None. You cannot pipe to this script.

.OUTPUTS
None. This script does not generate any output.

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 20.06.2012

.EXAMPLE
#>
# Import other scripts
############################
. .\Config.ps1
. .\GetTools.ps1

# Global variabels
############################
$script:startTime = get-date

# Run
############################
#Clear-Host
ResizeWindowBuffer
Write-Host "Running the installer script." -ForegroundColor Magenta

# Get system info
#####
$os_arch = Get-OsArchitecture
Write-Host "* You are on a $os_arch operating system *" -ForegroundColor DarkYellow

$cores = Get-Cores
Write-Host "* You have $cores core(s) available *" -ForegroundColor DarkYellow

# Check requirements
#####
if($os_arch -ne "64-bit")
    {Write-Host "This script only works for 64-bit Windows" -ForegroundColor Red; return "Abort."}

# Get tools
#####

Write-Host "`n***** TOOLS *****" -ForegroundColor Yellow
#$success = main partial all -tools:@('console2', 'cppunit')
#$success = main normal all
#$success = main full all
$success = main developer all
if(!($success -eq $true))
    {Write-Host "Script failed when getting tools."; return $false}
    
# Build Qt 32- and 64-bit
#####
$build32bit = Find-Compiler "x86"
$build64bit = Find-Compiler "x64"
if(!$build32bit)
    {Write-Host "* You do NOT have a 32 bit compiler available. *" -ForegroundColor DarkYellow}
if(!$build64bit)
    {Write-Host "* You do NOT have a 64 bit compiler available. *" -ForegroundColor DarkYellow}

if($build64bit){
    ### BUILDING 64 bit Qt ###
    $qt_64buildbin_dir = $script:CX_QT_BUILD_X64+"\bin"
    $configure = "configure $script:CX_QT_CONFIG_OPTIONS"
    if(Test-QtConfigured $script:CX_QT_BUILD_X64)
        {$configure = "echo Qt already configured, skipping."}
    $batch_64bit = @"
echo ***** Building Qt 64 bit using jom with $cores core(s) *****
call "$script:CX_MSVC_VCVARSALL" x64
cd $script:CX_QT_BUILD_X64
set PATH=$qt_64buildbin_dir;%PATH%
$configure
jom /j $cores
"@

    $tempFile64 = [IO.Path]::GetTempFileName() | Rename-Item -NewName {$_ -replace 'tmp$', 'bat'} -PassThru
    Add-Content $tempFile64 $batch_64bit
    cmd /C "$tempFile64"

    Remove-Item $tempFile64
}

if($build32bit){
    ### BUILDING 32 bit Qt ###
    $qt_32buildbin_dir = $script:CX_QT_BUILD_X86+"\bin"
    $configure = "configure $script:CX_QT_CONFIG_OPTIONS"
    if(Test-QtConfigured $script:CX_QT_BUILD_X86)
        {$configure = "echo Qt already configured, skipping."}
    $batch_32bit = @"
echo ***** Building Qt 32 bit using jom with $cores core(s) *****
call "$script:CX_MSVC_VCVARSALL" x86
cd $script:CX_QT_BUILD_X86
set PATH=$qt_32buildbin_dir;%PATH%
$configure
jom /j $cores
"@

    $tempFile32 = [IO.Path]::GetTempFileName() | Rename-Item -NewName {$_ -replace 'tmp$', 'bat'} -PassThru
    Add-Content $tempFile32 $batch_32bit
    cmd /C "$tempFile32"

    Remove-Item $tempFile32
}

# Checkout libs
#####
Write-Host "`n***** LIBS CHECKOUT *****" -ForegroundColor Yellow
python .\cxInstaller.py --checkout --all $script:CX_INSTALL_COMMON_OPTIONS
# There is a bug in the script, where IGSTK tries to access information in the CustusX folder,
# which doesn't exist at that time
python .\cxInstaller.py --checkout $script:CX_INSTALL_COMMON_OPTIONS IGSTK
##python .\cxInstaller.py --checkout $script:CX_INSTALL_COMMON_OPTIONS CustusX3 UltrasonixSDK


# Configure and build libs
#####
Write-Host "`n***** LIBS CONFIGURE AND BUILD *****" -ForegroundColor Yellow

# 64 bit #
if($build64bit){
    Write-Host "* 64 bit *" -ForegroundColor DarkYellow
  
    $configureAndBuild64 = @"
call $script:CX_CXVARS_64
python .\cxInstaller.py --configure --build --all $script:CX_INSTALL_COMMON_OPTIONS
"@
    $tempFile64 = [IO.Path]::GetTempFileName() | Rename-Item -NewName {$_ -replace 'tmp$', 'bat'} -PassThru
    Add-Content $tempFile64 $configureAndBuild64
    cmd /C "$tempFile64"

    Remove-Item $tempFile64
}

# 32 bit #
if($build32bit){
    Write-Host "* 32 bit *" -ForegroundColor DarkYellow
    
    $configureAndBuild32 = @"
call $script:CX_CXVARS_86
python .\cxInstaller.py --configure_clean --build --all $script:CX_INSTALL_COMMON_OPTIONS
::python .\cxInstaller.py --configure_clean --build $script:CX_INSTALL_COMMON_OPTIONS CustusX3 UltrasonixSDK
"@
    $tempFile32 = [IO.Path]::GetTempFileName() | Rename-Item -NewName {$_ -replace 'tmp$', 'bat'} -PassThru
    Add-Content $tempFile32 $configureAndBuild32
    cmd /C "$tempFile32"

    Remove-Item $tempFile32
}


Write-Host "`nInstallation process took $(GetElapsedTime $script:startTime)" -ForegroundColor Green