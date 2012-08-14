# Help
#############################################################################

<#
.SYNOPSIS
Script that prepares a Windows machine for software development.

.DESCRIPTION
Downloads and installs:
-7-zip
-CppUnit
-jom
-git
-svn
-cmake
-python
-eclipse
-Qt
-Boost

.PARAMETER 
None.

.INPUTS
None. You cannot pipe to this script.

.OUTPUTS
None. This script does not generate any output.

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 21.05.2012

Microsoft Visual C++ Studio 2010 Express (Free) have some
limitations: 
- No resource editor.
- No built-in MFC support.
- No built-in ATL support.
- No profiling support.
- No built-in x64 compiler (you can download one from the windows SDK).
- No support for OpenMP.
- No support for add-ins or IDE macros.
- Ability to attach the debugger to an already-running process is possible by enabling Tools -> Settings -> Expert settings (starting with 2010).
- No option for crash dump generation (Debug->Save Dump As).
(http://en.wikipedia.org/wiki/Microsoft_Visual_Studio_Express#Visual_C.2B.2B_Express)

.EXAMPLE
PS C:\> .GetTools.ps1

.TODO
-add compiler environment
-add options:
  --git/-g = git
  --svn/-s = svn
  --cmake/-c = cmake
  --python/-p = python
  --eclipse/-e = eclipse
  --qt/-q = qt
  --mvs_express/-m = microsoft visual studio express
-add icons to shortcuts
#>

# Classes
#############################################################################

$toolType = @'
public class Tool{
    public Tool(
        string name, 
        string downloadUrl, 
        string saveAs, 
        string packageType, 
        string installedBinFolder, 
        string extractFolder, 
        string executableName 
        )
    {
        mName = name;
        mDownloadUrl = downloadUrl;
        mSaveAs = saveAs;
        mPackageType = packageType;
        mInstalledBinFolder = installedBinFolder;
        mExtractFolder = extractFolder;
        mExecutableName = executableName;
    }
    
    public string get_name(){ return mName;}
    public string get_downloadUrl(){ return mDownloadUrl;}
    public string get_saveAs(){ return mSaveAs;}
    public string get_packageType(){ return mPackageType;}
    public string get_installedBinFolder(){ return mInstalledBinFolder;}
    public string get_extractFolder(){ return mInstalledBinFolder;}
    public string get_executableName(){ return mInstalledBinFolder;}
    
    private string mName; //name of the tool
    private string mDownloadUrl; //the url to the downloadable file
    private string mSaveAs; //what the downloaded file should be saved as
    private string mPackageType; //the download file type
    private string mInstalledBinFolder; //where the executable can be found after tool is installed
    private string mExtractFolder; //if package type is extractable archive we need a extraction folder
    private string mExecutableName; //name of the executable
}
'@

# Functions
#############################################################################
Function Tool-Exists ($tool) {
    if(Command-Exists $tool.get_executableName())
        {Write-Host $tool.get_name() " already exists" -ForegroundColor "green"}
}

Function Command-Exists ($commandname) {
    
    if (Get-Command $commandname -errorAction SilentlyContinue)
        {return $true}
}

Function Download ($tool) { 

    $success = $false  
   
    $success = Download-Url $tool
    
    if($success)
        {Write-Host "Downloaded " $tool.get_name() "!" -ForegroundColor "Green"}
    else
        {Write-Host "Could not download " $tool.get_name() ", you will have to do it manually!" -ForegroundColor "Red"}
        
    return $success
}

Function Download-Url ($tool){
    $success = $false
    try{
        Write-Host "Downloading " $tool.get_name()
        $webclient = New-Object Net.WebClient
        $webclient.DownloadFile($tool.get_downloadUrl(), $tool.get_saveAs())
        Write-Host "Download done."
        $success = $true
    }
    catch
    {
        Write-Host "Exception caught when trying to download " $tool.get_name() " from " $url " to " $targetFile "." -ForegroundColor "Red"
    }
    finally
    {
        return $success
    }
}

Function Install ($tool){
    $success = $false 

    $success = Install-File $tool
    
    if($success)
        {Write-Host "Installed " $tool.get_name() "!" -ForegroundColor "Green"}
    else
        {Write-Host "Could not install " $tool.get_name() ", you will have to do it manually!" -ForegroundColor "Red"}
        
    return $success
}

Function Install-File ($tool){

    Write-Host "Installing " $tool.get_name()
    $defaultDesitantionFolder = 'C:\Program Files'
    
    $success = $false
    $packageType = $tool.get_packageType()
    if($packageType -eq "NSIS package"){
        #piping to Out-Null seems to by-pass the UAC
        Start-Process $tool.get_saveAs() -ArgumentList "/S" -NoNewWindow -Wait | Out-Null
        $success = $true    
    }
    elseif($packageType -eq "Inno Setup package"){
        #piping to Out-Null seems to by-pass the UAC
        Start-Process $tool.get_saveAs() -ArgumentList "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-" -NoNewWindow -Wait | Out-Null
        $success = $true
    }
    elseif($packageType -eq "MSI"){
        $installer = $tool.get_saveAs()
        Start-Process msiexec -ArgumentList "/i $installer /quiet /passive" -NoNewWindow -Wait
        $success = $true
    }
    elseif($packageType -eq "ZIP"){
        #$destinationFolder = (Get-Item $defaultDesitantionFolder).fullname
        $destinationFolder = $tool.get_extractFolder()
        #Write-Host $destinationFolder
        $shell_app = new-object -com shell.application
        $zip_file = $shell_app.namespace($tool.get_saveAs())
        if(!(Test-Path $destinationFolder))
            {mkdir $destinationFolder}
        $destination = $shell_app.namespace($destinationFolder)
        $destination.Copyhere($zip_file.items(),0x14) #0x4 hides dialogbox, 0x10 overwrites existing files, 0x14 combines both
        $success = $true
    }
    elseif($packageType -eq "TarGz"){
        $z ="7z.exe"

        #Destination folder cannot contain spaces for 7z to work with -o
        $destinationFolder = (Get-Item $defaultDesitantionFolder).fullname
         
        $targzSource = $tool.get_saveAs()
        & "$z" x -y $targzSource | Out-Null
        
        $tarSource = (Get-Item $targzSource).basename
        & "$z" x -y $tarSource "-o$destinationFolder" | Out-Null #Need to have double quotes around the -o parameter because of whitespaces in destination folder
   
        Remove-Item $tarSource
        
        $success = $true
    }
    elseif($packageType -eq "EXE"){
        #Made to work with the Microsoft Visual Studio 2010 Express C++ web installer
        Start-Process $tool.get_saveAs() -ArgumentList "/q /norestart" -NoNewWindow -Wait | Out-Null
        $success = $true
    }
    else{
        Write-Host "Could not figure out which installer "$tool.get_name()" has used, could not install "$tool.get_name()"."
    }

    return $success
}

# Adds a tools installed path to the system environment,
# both for this session and permanently
Function Add-To-Path($tool) {
    Write-Host "Adding "$tool.get_name()" to system environment (Path)."

    $success = $false 
    
    $path = $tool.get_installedBinFolder()
    Add-To-Path-Permanent($path)
    Add-To-Path-Session($path)
    $success = $true
    
    if($success)
        {Write-Host "Added " $tool.get_name() " to path!" -ForegroundColor "Green"}
    else
        {Write-Host "Could not add " $tool.get_name() " to path, you will have to do it manually!" -ForegroundColor "Red"}
        
    return $success
}

# Adds a path to the environment for this session only
Function Add-To-Path-Session($path) {
    $env:path = $env:path + ";" + $path
}

# Adds a path permanently to the system environment
Function Add-To-Path-Permanent($path) {
    [System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + $path, "Machine")
}

# Creates a bat file that sets up a CustusX build environment
Function Create-Cx-Environment($filename, $targetPlatform, $extendedPath){
    
    #only support 32 bit (x86)
    if($targetPlatform -ne "x86")
        {return}
    
    #Variables
    $vcvarsallDOTbat = "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat"
    #$qtvarsDOTbat_x86 = (Get-ChildItem -Path "C:\Qt" -Filter "qtvars.bat" -Recurse).fullname
    $qtDir = "C:\Qt\4.8.2" #find this somehow
    
    #write content
    $stream = New-Object System.IO.StreamWriter("$filename")
    $stream.WriteLine("`@echo off")
    $stream.WriteLine("rem")
    $stream.WriteLine("rem This file is generated by the Windows installer script for CustusX")
    $stream.WriteLine("rem")

    $stream.WriteLine("echo Setting up a CustusX $targetPlatform environment...")
    
    $stream.WriteLine("set PATH=%PATH%$extendedPath")
    #$stream.WriteLine("call $qtvarsDOTbat_x86") #only works for x86 ...
    
    # Copied from qtvars.bat
    $stream.WriteLine("set QTDIR=$qtDir")
    $stream.WriteLine("echo -- QTDIR set to $qtDir")
    $stream.WriteLine("set PATH=$qtDir\bin;%PATH%") #Added in extendedPath???
    $stream.WriteLine("echo -- Added $qtDir\bin to PATH")
    $stream.WriteLine("set QMAKESPEC=win32-msvc2010") #what is this???
    $stream.WriteLine("echo -- QMAKESPEC set to `"win32-msvc2010`"")
    
    $stream.WriteLine("call `"$vcvarsallDOTbat`" $targetPlatform")
    
    $stream.Close()
}

# Creates a shortcut to a batch file that run a tool with visual studio
# variables loaded.
Function Create-Batch-Exe-With-VCVars64($tool){
    #Will eclipse executed in 64 bit environment build 32 bit builds???

    if($tool.get_name() -eq "cmake"){
        $toolName = "cmake-gui"
    }
    
    #variables
    $batchName = "$toolName-MSVC1064bit"
    $batchEnding = ".bat"
    $batchFolder = "$HOME\Batch_files"
    mkdir $batchFolder -force | Out-Null
    $batchPath = "$batchFolder\$batchName$batchEnding"
    $toolExe = (Get-Command $toolName | Select-Object Name).Name
    $toolFolder = (Get-Item (Get-Command $toolName | Select-Object Definition).Definition).directory.fullname
    $vcVarsFolder = ((Get-Item (Get-Command nmake).Definition).directory).GetDirectories("amd64")[0].fullname
    $vcVarsBat = "vcvars64.bat"
    $desktopFolder = "$HOME\Desktop\"
    $taskbarFolder = "$Home\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\Taskbar\"
    $shortcutFolder = $batchFolder
    
    #write content
    $stream = New-Object System.IO.StreamWriter("$batchPath")
    $stream.WriteLine("`@cd $vcVarsFolder")
    $stream.WriteLine("`@call $vcVarsBat > nul 2>&1")
    $stream.WriteLine("`@cd $toolFolder")
    $stream.WriteLine("`@start $toolExe > nul 2>&1")
    $stream.WriteLine("`@exit")
    $stream.Close()
    
    #create shortcut on taskbar
    $shortcutPath = "$shortcutFolder\$batchName.lnk"
    $objShell = New-Object -ComObject WScript.Shell
    $objShortCut = $objShell.CreateShortcut($shortcutPath)
    $objShortCut.TargetPath = 'cmd'
    $objShortCut.Arguments = "/c ""$batchPath"""
    $objShortCut.Save()
    
    Toggle-PinTo-Taskbar $shortcutPath
    
    return $true
}

# Un-/pins a file to the users taskbar
function Toggle-PinTo-Taskbar
{
  param([parameter(Mandatory = $true)]
        [string]$application)
 
  $al = $application.Length
  $appfolderpath = $application.SubString(0, $al - ($application.Split("\")[$application.Split("\").Count - 1].Length))
 
  $objshell = New-Object -ComObject "Shell.Application"
  $objfolder = $objshell.Namespace($appfolderpath)
  $appname = $objfolder.ParseName($application.SubString($al - ($application.Split("\")[$application.Split("\").Count - 1].Length)))
  $verbs = $appname.verbs()
 
  foreach ($verb in $verbs)
  {
    if ($verb.name -match "(&K)")
    {
      $verb.DoIt()
    }
  }
}

Function Configure-Git($name, $email){
    git config --global user.name $name
    git config --global user.email $email
    git config --global color.diff auto
    git config --global color.status auto
    git config --global color.branch auto
    git config --global core.autocrlf input
    git config --global core.filemode false #(ONLY FOR WINDOWS)
}

# Main
#############################################################################
Function main {

# Input parameters
#--------------
param (
    [Parameter(Mandatory=$true, position=0, HelpMessage="Select installation type. (-normal, -full, -partial)")]
    [ValidateSet('normal', 'full', 'partial')]
    [string]$type, 
    [Parameter(Mandatory=$true, position=1, HelpMessage="Select installation mode. (-all, -download, -install, -environment")]
    [ValidateSet('all', 'download', 'install', 'environment')]
    [string]$mode,
    [Parameter(Mandatory=$false, HelpMessage="Select tool(s). (7-Zip, CppUnit, jom, git, svn, cmake, python, eclipse, qt, boost, MVS2010expressCpp)")]
    [string[]]$tools
)

## Add class definition it to the powershell session
Add-Type -TypeDefinition $toolType

#Information 
#--------------
$ToolFolder = "$HOME\Desktop\Downloaded_Tools"
$BatchFolder = "$HOME\Batch_Files"

#Available tools
$mvs2010expressCpp = New-Object Tool("MVS2010expressCpp", "http://go.microsoft.com/?linkid=9709949", "$ToolFolder\MVS2010Express_web.exe", "EXE", "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin", "", "nmake")
$7zip = New-Object Tool("7-Zip", "http://downloads.sourceforge.net/sevenzip/7z920-x64.msi", "$ToolFolder\7-Zip-installer.msi", "MSI", "C:\Program Files\7-Zip", "", "7z")
$CppUnit = New-Object Tool("CppUnit", "http://sourceforge.net/projects/cppunit/files/cppunit/1.12.1/cppunit-1.12.1.tar.gz/download", "$ToolFolder\CppUnit.tar.gz", "TarGz", "C:\Program Files\cppunit-1.12.1", "", "")
$jom = New-Object Tool("jom", "ftp://ftp.qt.nokia.com/jom/jom.zip", "$ToolFolder\jom.zip", "ZIP", "C:\Program Files\jom", "C:\Program Files\jom", "jom")
$git = New-Object Tool("git", "http://msysgit.googlecode.com/files/Git-1.7.10-preview20120409.exe", "$ToolFolder\git-installer.exe", "Inno Setup package", "C:\Program Files (x86)\Git\cmd", "", "git")
$svn = New-Object Tool("svn", "http://www.sliksvn.com/pub/Slik-Subversion-1.7.5-x64.msi", "$ToolFolder\svn-installer.msi", "MSI", "C:\Program Files\SlikSvn\bin", "", "svn")
$cmake = New-Object Tool("cmake", "http://www.cmake.org/files/v2.8/cmake-2.8.8-win32-x86.exe", "$ToolFolder\cmake-installer.exe", "NSIS package", "C:\Program Files (x86)\CMake 2.8\bin", "", "cmake")
$python = New-Object Tool("python", "http://www.python.org/ftp/python/2.7.3/python-2.7.3.msi", "$ToolFolder\python-installer.msi", "MSI", "C:\Python27", "", "python")
$eclipse = New-Object Tool("eclipse", "http://eclipse.mirror.kangaroot.net/technology/epp/downloads/release/indigo/SR2/eclipse-cpp-indigo-SR2-incubation-win32-x86_64.zip", "$ToolFolder\eclipse.zip", "ZIP", "C:\Program Files\eclipse", "C:\Program Files", "eclipse")
$qt = New-Object Tool("qt", "ftp://ftp.qt.nokia.com/qt/source/qt-win-opensource-4.8.1-vs2010.exe", "$ToolFolder\qt.exe", "NSIS package", "C:\Qt\4.8.1\bin", "", "") #Installing Qt this way only gives x86 libs
$boost = New-Object Tool("boost", "http://downloads.sourceforge.net/project/boost/boost/1.49.0/boost_1_49_0.zip?r=&ts=1340279004&use_mirror=dfn", "$ToolFolder\boost.zip", "ZIP", "C:\Program Files\boost_1_49_0", "C:\Program Files", "")

#Parse parameters
#--------------
$AllTools = @($mvs2010expressCpp, $7zip, $CppUnit, $jom, $git, $svn, $cmake, $python, $eclipse, $qt, $boost)
$SelectedTools = @()
switch ($type)
{
    "normal" {
        $SelectedTools = @($7zip, $CppUnit, $jom, $git, $svn, $cmake, $python, $eclipse, $qt, $boost)
        #Check that prerequirements are met
        if(!(Command-Exists nmake)){
            Write-Host "You need to have Microsoft Visual Studio 2010 installed before running this script as normal." -ForegroundColor Red
            return "error"
        }
    }
    "full" {$SelectedTools = $AllTools}
    "partial" {
        foreach($selected_tool in $tools){
            foreach($available_tool in $AllTools){
                if($selected_tool -eq $available_tool.get_name()){
                    $SelectedTools +=  $available_tool
                    Write-Host "DEBUG: Added "$available_tool.get_name()"."
                }
            }
        }
    }
    default {Write-Host "Error!!!" return "Default error"}
}

#Prompt to continue
#--------------
Write-Host "You have selected the following tools:`n"
foreach($t in $SelectedTools){
    Write-Host "--"$t.get_name()
}
Write-Host "`nYou have selected the following actions:`n"
if((($mode -eq "all") -or ($mode -eq "download")))
    {Write-Host "-- Downloading"}
if((($mode -eq "all") -or ($mode -eq "install")))
    {Write-Host "-- Installing"}
if((($mode -eq "all") -or ($mode -eq "environment")))
    {Write-Host "-- Setting up environment"}
    
$ready = Read-Host "`nContinue? y/n"
if($ready -eq "n")
    {return "quit"}

#Get user information
#--------------

#Git information
foreach($t in $SelectedTools){
    if($t.get_name() -eq "git"){
        Write-Host "Need some information to be able to setup git:" -ForegroundColor DarkYellow
        $git_name = Read-Host "Your name"
        $git_email = Read-Host "Your email address"
        break
    }
}

#Create folders
#--------------
if((($mode -eq "all") -or ($mode -eq "download")))
 {mkdir $ToolFolder -force | Out-Null}
if((($mode -eq "all") -or ($mode -eq "environment")))
 {mkdir $BatchFolder -force | Out-Null}

#Download and install tools
#--------------
for($i=0; $i -le $SelectedTools.Length -1;$i++)
{
    $tool = $SelectedTools[$i]
    
    if(Tool-Exists $tool)
        {continue}
        
    Write-Host "Missing tool "$tool.get_name()
    #Downloading tool
    if((($mode -eq "all") -or ($mode -eq "download")))
    {
        if(!(Download $tool))
           {continue}
    }
    #Installing tool
    if((($mode -eq "all") -or ($mode -eq "install")))
    {
        if(!(Install $tool))
            {continue}
    }
    #if(!(Add-To-Path $tool))
    #    {continue}
        
    $extendedPath = $extendedPath+";`""+$tool.get_installedBinFolder()+"`""
    Write-Host $extendedPath
    
    if($tool.get_executableName() -eq "git")
        {Configure-Git $git_name $git_email}


    # create shortcut for eclipse and cmake    
    #TODO move to after cx env is created to be able to use that file!
    if(($tool -eq "cmake") -or ($tool -eq "eclipse")){
        if(!(Create-Batch-Exe-With-VCVars64 $tool)){
            Write-Host "Could not create shortcut and batch file for $tool"
        }
    }
    
}
if((($mode -eq "all") -or ($mode -eq "environment")))
{
    # create 32bit CustusX environment
    $path32 = $batchFolder+"\cx32vars.bat"
    Create-Cx-Environment $path32 "x86" $extendedPath
    
    # create 64bit CustusX environment
    $path64 = $batchFolder+"\cx64vars.bat"
    Create-Cx-Environment $path64 "x64" $extendedPath
}
}