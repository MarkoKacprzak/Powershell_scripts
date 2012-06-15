# Help
#############################################################################

<#
.SYNOPSIS
Script that prepares a Windows machine for software development.

.DESCRIPTION
Downloads and installs:
-git
-svn
-cmake
-python

.PARAMETER 
None.

.INPUTS
None. You cannot pipe to this script.

.OUTPUTS
None. This script does not generate any output.

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 21.05.2012

.EXAMPLE
PS C:\Dev\Temp> ..\Powershell\GetTools.ps1
#>

# Functions
#############################################################################
Function Command-Exists ($tool) {
    if (Get-Command $tool -errorAction SilentlyContinue)
    {
        Write-Host $tool " already exists" -ForegroundColor "green"
        return $true
    }
}

Function Download ($tool) { 

    $success = $false  
    
    for($i=0; $i -le $RequiredTools.Length -1;$i++){
        if($tool -eq $RequiredTools[$i][0])
        {
            $success = Download-Url $RequiredTools[$i][0] $RequiredTools[$i][1] $RequiredTools[$i][2]
        }
    }
    
    if($success)
        {Write-Host "Downloaded " $tool " successfully!" -ForegroundColor "Green"}
    else
        {Write-Host "Could not download " $tool ", you will have to do it manually!" -ForegroundColor "Red"}
        
    return $success
}

Function Download-Url ($tool, $url, $targetFile) {
    #Write-Host "Downloading " $tool " from " $url " to " $targetFile -ForegroundColor "Gray"

    $success = $false
    try{
        Write-Host "Downloading " $tool
        $webclient = New-Object Net.WebClient
        $webclient.DownloadFile($url, $targetFile)
        Write-Host "Download done."
        $success = $true
    }
    catch
    {
        Write-Host "Exception caught when trying to download " $tool " from " $url " to " $targetFile "." -ForegroundColor "Red"
    }
    finally
    {
        return $success
    }
}

Function Install ($tool){
    $success = $false 
    
    for($i=0; $i -le $RequiredTools.Length -1;$i++){
        if($tool -eq $RequiredTools[$i][0])
        {
            $success = Install-File $RequiredTools[$i][0] $RequiredTools[$i][2] $RequiredTools[$i][3]
        }
    }
    
    if($success)
        {Write-Host "Installed " $tool " successfully!" -ForegroundColor "Green"}
    else
        {Write-Host "Could not install " $tool ", you will have to do it manually!" -ForegroundColor "Red"}
        
    return $success
}

Function Install-File ($tool, $targetFile, $packageType){

    $success = $false
    if($packageType -eq "NSIS package"){
        #piping to Out-Null seems to by-pass the UAC
        #Invoke-Expression "& $targetFile /S" | Out-Null
        Start-Process $targetFile -ArgumentList "/S" -NoNewWindow -Wait | Out-Null
        $success = $true    
    }
    if($packageType -eq "Inno Setup package"){
        #piping to Out-Null seems to by-pass the UAC
        #Invoke-Expression "& $targetFile  /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-" | Out-Null
        Start-Process $targetFile -ArgumentList "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-" -NoNewWindow -Wait | Out-Null
        $success = $true
    }
    if($packageType -eq "MSI"){
        #Invoke-Expression "& msiexec /i $targetFile /quiet /passive"
        Start-Process msiexec -ArgumentList "/i $targetFile /quiet /passive" -NoNewWindow -Wait
        $success = $true
    }
    return $success
}

Function Add-To-Path($tool) {
    $success = $false 
    
    for($i=0; $i -le $RequiredTools.Length -1;$i++){
        if($tool -eq $RequiredTools[$i][0])
        {
            $path = $RequiredTools[$i][4]
            Add-To-Path-Session($path)
            Add-To-Path-Permanent($path)
            $success = $true
        }
    }
    
    if($success)
        {Write-Host "Added " $tool " to path successfully!" -ForegroundColor "Green"}
    else
        {Write-Host "Could not add " $tool " to path, you will have to do it manually!" -ForegroundColor "Red"}
        
    return $success
}

Function Add-To-Path-Session($path) {
    $env:path = $env:path + ";" + $path
}

Function Add-To-Path-Permanent($path) {
    [System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + $path, "Machine")
}

# Main
#############################################################################
Clear-Host

$ToolFolder = "$HOME\Desktop\DownloadedTools\"
mkdir $ToolFolder -force | Out-Null
$RequiredTools = @( 
                #(tool name, download link, target file, package type, installed bin folder )
                ("git", "http://msysgit.googlecode.com/files/Git-1.7.10-preview20120409.exe", "$ToolFolder\git-installer.exe", "Inno Setup package", "C:\Program Files (x86)\Git\cmd"),
                ("svn", "http://www.sliksvn.com/pub/Slik-Subversion-1.7.5-x64.msi", "$ToolFolder\svn-installer.msi", "MSI", "C:\Program Files\SlikSvn\bin"),
                ("cmake", "http://www.cmake.org/files/v2.8/cmake-2.8.8-win32-x86.exe", "$ToolFolder\cmake-installer.exe", "NSIS package", "C:\Program Files (x86)\CMake 2.8\bin"),
                ("python", "http://www.python.org/ftp/python/2.7.3/python-2.7.3.msi", "$ToolFolder\python-installer.msi", "MSI", "C:\Python27")
                )

#Download and install tools
for($i=0; $i -le $RequiredTools.Length -1;$i++)
{
    $tool = $RequiredTools[$i][0]
    
    if(Command-Exists $tool)
        {continue}
        
    Write-Host "Missing tool: "$tool
    if(!(Download $tool))
        {continue}
    if(!(Install $tool))
        {continue}
    if(!(Add-To-Path $tool))
        {continue}
}
   
    