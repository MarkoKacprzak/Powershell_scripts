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
# Import other scripts
############################
. .\GetTools.ps1

# Global variabels
############################
$script:startTime = get-date

# Functions
############################
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

Function GenerateSSHKeys (){

}

# Classes
############################
$processRunnerType = @'
using System;
using System.Diagnostics;
using System.ComponentModel;

public class Runner{
    public Runner(string exe, string args){
        ProcessStartInfo processStartInfo = new ProcessStartInfo(exe, args);
        processStartInfo.RedirectStandardInput = true;
        processStartInfo.RedirectStandardOutput = true;
        processStartInfo.UseShellExecute = false;
        processStartInfo.CreateNoWindow = true;

        process = Process.Start(processStartInfo);
    }
    
    public void call(string[] command)
    {
        if (process != null)
        {
            for(int x = 0; x < command.Length; x++){
                process.StandardInput.WriteLine(command[x]);
            }
            process.StandardInput.Close(); // line added to stop process from hanging on ReadToEnd()

            //string outputString = process.StandardOutput.ReadToEnd();
            //return outputString;
        }

        //return string.Empty;
    }
    
    private Process process;
}
'@

Add-Type -TypeDefinition $processRunnerType
#$run = New-Object Runner("cmd", "`"/K `"C:\Dev\Powershell\cxVars_x64.bat`"`"");
#$run.call(@("cl", "dir"));

# Run
############################
#Clear-Host
ResizeWindowBuffer
Write-Host "Running the installer script." -ForegroundColor Magenta

# Get system info
#####
$os_arch = (Get-WmiObject -Class Win32_OperatingSystem | Select-Object OSArchitecture).OSArchitecture
Write-Host "* You are on a $os_arch operating system *" -ForegroundColor DarkYellow

$core_list = (Get-WmiObject -class Win32_Processor -Property "NumberOfCores" | Select-Object -Property "NumberOfCores")
$cores = 0
foreach($item in $core_list){$cores += $item.NumberOfCores}
Write-Host "* You have $cores cores available *" -ForegroundColor DarkYellow

$build32bit = $true
$build64bit = $true
if(!(Test-Path 'C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\cl.exe')){
    $build64bit = $false
    Write-Host "* You do NOT have a 64 bit compiler available. Will only build 32 bit. *" -ForegroundColor DarkYellow
}

# Check requirements
#####
if($os_arch -ne "64-bit")
    {Write-Host "This script only works for 64-bit Windows" -ForegroundColor Red; return "Abort."}

# Get tools
#####

#Main takes input parameters
#main partial all -tools:@('7-zip', 'jom')
Write-Host "`n***** TOOLS *****" -ForegroundColor Yellow
#main normal all
main normal download

# Build Qt 32- and 64-bit
#####
$qt_dir = (Get-Item -Path "C:\Dev\external_code\Qt").fullname
$qt_source_dir = (Get-ChildItem -Path $qt_dir -Filter "qt-every*").fullname
$vcvarsallDOTbat = (Get-ChildItem -Path "C:\Program Files","C:\Program Files (x86)" -Filter "vcvarsall.bat" -Recurse | Where-Object{$_.DirectoryName -like "*Microsoft Visual Studio 10.0*"}).FullName

if($build64bit){
    ### BUILDING 64 bit Qt ###
    #$qt_cmd_64bit = New-Object Runner("cmd", "/C `" `"$vcvarsallDOTbat`" `" x64 ");
    #$qt_cmd_64bit.call(@("mkdir $qt_64build_dir", "cd $qt_64build_dir", "set PATH=%PATH%;$qt_64build_dir\bin", "$qt_source_dir\configure -mp -debug-and-release -opensource -platform win32-msvc2010", "jom /j $cores"));
    $qt_64build_dir = ""+$qt_dir+"\build64_jom_DebugAndRelease"
    $qt_64buildbin_dir = $qt_64build_dir+"\bin"
    $batch_64bit = @"
echo on
call "$vcvarsallDOTbat" x64
mkdir "$qt_64build_dir"
cd "$qt_64build_dir"
set QTDIR=$qt_dir
set QMAKESPEC=win32-msvc2010
set PATH="$qt_64buildbin_dir";%PATH%
"$qt_source_dir"\configure -mp -debug-and-release -opensource -platform win32-msvc2010 -nomake demos -nomake examples -confirm-license
jom /j $cores
"@

    $tempFile64 = [IO.Path]::GetTempFileName() | Rename-Item -NewName {$_ -replace 'tmp$', 'bat'} -PassThru
    Add-Content $tempFile64 $batch_64bit
    cmd /C "$tempFile64"

    Remove-Item $tempFile64
}

if($build32bit){
    ### BUILDING 32 bit Qt ###
    #$qt_cmd_32bit = New-Object Runner("cmd", "/C `" `"$vcvarsallDOTbat`" `" x86 ");
    #$qt_cmd_32bit.call(@("mkdir $qt_32build_dir", "cd $qt_32build_dir", "set PATH=%PATH%;$qt_32build_dir\bin", "$qt_source_dir\configure -mp -debug-and-release -opensource -platform win32-msvc2010", "jom /j $cores"));
    $qt_32build_dir = ""+$qt_dir+"\build32_jom_DebugAndRelease"
    $qt_32buildbin_dir = $qt_32build_dir+"\bin"
    $batch_32bit = @"
echo on
call "$vcvarsallDOTbat" x86
mkdir "$qt_32build_dir"
cd "$qt_32build_dir"
set QTDIR=$qt_dir
set QMAKESPEC=win32-msvc2010
set PATH="$qt_32buildbin_dir";%PATH%
"$qt_source_dir"\configure -mp -debug-and-release -opensource -platform win32-msvc2010 -nomake demos -nomake examples -confirm-license
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
python .\cxInstaller.py --checkout --build_type Debug --silent_mode --all
# There is a bug in the script, where IGSTK tries to access information in the CustusX folder,
# which doesn't exist at that time
python .\cxInstaller.py --checkout --build_type Debug --silent_mode IGSTK


# Configure and build libs
#####
Write-Host "`n***** LIBS CONFIGURE AND BUILD *****" -ForegroundColor Yellow

# 64 bit #
if($build64bit){
    Write-Host "* 64 bit *" -ForegroundColor DarkYellow
    $cxVars_x64 = (Get-ChildItem -Path "$HOME\" -Recurse -Filter "cxVars*x64.bat").fullname
    #***** cxInstaller.py arguments for 64 bit: --configure --build --silent_mode --jom --j $cores --build_type Debug
    
    $configureAndBuild64 = @"
call $cxVars_x64
python .\cxInstaller.py --configure --build --silent_mode --jom -j $cores --build_type Debug
"@
    $tempFile64 = [IO.Path]::GetTempFileName() | Rename-Item -NewName {$_ -replace 'tmp$', 'bat'} -PassThru
    Add-Content $tempFile64 $configureAndBuild64
    cmd /C "$tempFile64"

    Remove-Item $tempFile64
    
    #$cmd_64bit = New-Object Runner("cmd", "`"/K `"$cxVars_x64`"`"");
    #$cmd_64bit.call(@(" ","python .\cxInstaller.py --configure --build --silent_mode --jom --j $cores --build_type Debug --all"))
    #TESTING
    #$cmd_64bit.call(@("python .\cxInstaller.py --configure --build --silent_mode --jom --j $cores OpenIGTLink ")) #- NOT TESTED
    #$cmd_64bit.call(@("python .\cxInstaller.py --configure --build --silent_mode --jom --j $cores ITK ")) #- NOT TESTED
    #$cmd_64bit.call(@("python .\cxInstaller.py --configure --build --silent_mode --jom --j $cores VTK ")) #- NOT TESTED
    #$cmd_64bit.call(@("python .\cxInstaller.py --configure --build --silent_mode --jom --j $cores OpenCV ")) #- NOT TESTED
    #$cmd_64bit.call(@("python .\cxInstaller.py --configure --build --silent_mode --jom --j $cores IGSTK ")) #- NOT TESTED
    #$cmd_64bit.call(@("python .\cxInstaller.py --configure --build --silent_mode --jom --j $cores CustusX3 ")) #- NOT TESTED (SETUP GITHUB FIRST!!!)
}

# 32 bit #
if($build32bit){
    Write-Host "* 32 bit *" -ForegroundColor DarkYellow
    $cxVars_x86 = (Get-ChildItem -Path "$HOME\" -Recurse -Filter "cxVars*x86.bat").fullname
    #***** cxInstaller.py arguments for 32 bit: --configure --build --silent_mode --b32 --jom --j$cores --build_type Debug  --all
    
    $configureAndBuild32 = @"
call $cxVars_x86
python .\cxInstaller.py --configure --build --silent_mode --jom -j $cores --build_type Debug
"@
    $tempFile32 = [IO.Path]::GetTempFileName() | Rename-Item -NewName {$_ -replace 'tmp$', 'bat'} -PassThru
    Add-Content $tempFile32 $configureAndBuild32
    cmd /C "$tempFile32"

    Remove-Item $tempFile32
    
    #$cmd_32bit = New-Object Runner("cmd", "`"/K `"$cxVars_x86`"`"");
    #$cmd_32bit.call(@(" ","python .\cxInstaller.py --configure --build --silent_mode --b32 --jom --j$cores --build_type Debug  --all"))
    #TESTING
    #$cmd_32bit.call(@("nmake /P","python .\cxInstaller.py --configure --build --silent_mode OpenIGTLink")) #- PASSED
    #$cmd_32bit.call(@("nmake /P","python .\cxInstaller.py --configure --build --silent_mode ITK")) #- PASSED
    #$cmd_32bit.call(@("nmake /P","python .\cxInstaller.py --configure --build --silent_mode --b32 --jom --j $cores ITK")) #- RUNNING
    #$cmd_32bit.call(@("nmake /P","python .\cxInstaller.py --configure --build --silent_mode VTK")) #- FAILED @ building vtkQtImageToImageSource
    #$cmd_32bit.call(@("nmake /P","python .\cxInstaller.py --configure --build --b32 --jom --silent_mode OpenCV")) #- PASSED
    #$cmd_32bit.call(@("nmake /P","python .\cxInstaller.py --configure --build --b32 --jom --silent_mode IGSTK")) #- NOT TESTED
    #$cmd_32bit.call(@("nmake /P","python .\cxInstaller.py --configure --build --b32 --jom --silent_mode CustusX3")) #- NOT TESTED (SETUP GITHUB FIRST!!!)
}


Write-Host "`nInstallation process took $(GetElapsedTime)" -ForegroundColor Green