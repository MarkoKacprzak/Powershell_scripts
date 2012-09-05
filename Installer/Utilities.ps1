# AUTHOR: Janne Beate Bakeng, SINTEF
# DATE: 04.09.2012
#
# EXAMPLES OF USAGE
#$log = New-Object Log("C:\Users\jbake\Desktop\log.txt")
#$log.addSUCCESS("Test1")
#$log.addERROR("Test2")
#$log.addWARNING("Test3")
#$log.addINFO("Test4")
#$log.addDEBUG("Test5")
#$log.print()
$logType = @'
using System;
using System.IO;
using System.Collections.Generic;

public class Log
{
    public Log(string filepath){
        if(!File.Exists(filepath)){
            string dirname = Path.GetDirectoryName(filepath);
            if(!Directory.Exists(dirname)){
                Directory.CreateDirectory(dirname);
            }
            File.CreateText(filepath).Close();
        }
        filename = filepath;
        add("","\n");
        add("[START LOGGING]    ["+getTimestamp()+"]   ","=====================================");
    }
    ~Log(){
        //No idea when this is called...
        add("[STOP LOGGING]    ["+getTimestamp()+"]   ","=====================================");
        add("","\n");
    }
    public void addSUCCESS(string message){
        add("[SUCCESS]  ["+getTimestamp()+"]   ",message);
    }
    public void addERROR(string message){
        add("[ERROR]    ["+getTimestamp()+"]   ",message);
    }
    public void addWARNING(string message){
        add("[WARNING]  ["+getTimestamp()+"]   ",message);
    }
    public void addINFO(string message){
        add("[INFO]     ["+getTimestamp()+"]   ",message);
    }
    public void addDEBUG(string message){
        add("[DEBUG]    ["+getTimestamp()+"]   ",message);
    }
    public void addHEADER(string message){
        add("******** ",message+" ********");
    }
    public void addEMPHASIS(string message){
        add("[EMPHASIS]    ["+getTimestamp()+"]   ",message);
    }
    public void print(){
        using (StreamReader r = File.OpenText(filename)){
            string line;
            while ((line = r.ReadLine()) != null)
            {
                Console.WriteLine(line);
            }
        }
    }
    
    private string getTimestamp(){
        return DateTime.Now.ToString("dd.MM.yy H:mm:ss");
    }
    private void add(string label, string message){
        string msg = label+message;
        using (StreamWriter file = new StreamWriter(filename, true)){
            file.WriteLine(msg);
        }
    }
    
    private string filename;
}
'@
Add-Type -Language CSharp -TypeDefinition $logType

<#
.SYNOPSIS
Convenience function for logging and writing to screen.

WARNING: Depends on Config.ps1

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 04.09.2012

.EXAMPLE
Add-Logging 'SUCCESS' "This worked."
#>
Function Add-Logging{
    param(
        ## The category the message should be logged as
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateSet('SUCCESS','ERROR','DEBUG','INFO','WARNING','HEADER','EMPHASIS')]
        [string]$type,
        ## The message to log
        [Parameter(Mandatory=$true, Position=1)]
        [string]$message
    )
    if(!$script:CX_LOGGER){return "ERROR COULD NOT FIND LOGGER!!!"}
    switch($type){
        'SUCCESS'{$script:CX_LOGGER.addSUCCESS($message); Write-Host $message -ForegroundColor "Green"}
        'ERROR'{$script:CX_LOGGER.addERROR($message); Write-Host $message -ForegroundColor "Red"}
        'DEBUG'{$script:CX_LOGGER.addDEBUG($message); if($script:CX_DEBUG_SCRIPT){Write-Host $message -ForegroundColor "DarkGray"}}
        'INFO'{$script:CX_LOGGER.addINFO($message); Write-Host $message -ForegroundColor "White"}
        'WARNING'{$script:CX_LOGGER.addWARNING($message); Write-Host $message -ForegroundColor "DarkRed"}
        'HEADER'{$script:CX_LOGGER.addHEADER($message); Write-Host "`n******** "$message" ********" -ForegroundColor "Blue"}
        'EMPHASIS'{$script:CX_LOGGER.addEMPHASIS($message); Write-Host $message -ForegroundColor "Magenta"}
        default{Write-Host "Could not send messageto log: `"$message`" " -ForegroundColor "Red"}
    }
}

<#
.SYNOPSIS
Create new shortcut.

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 04.09.2012

.EXAMPLE
Add-Shortcut "C:\Path\To\Shortcut.lnk" 'cmd.exe'
Creates a new shortcut that points to cmd.exe.

.EXAMPLE
Add-Shortcut "C:\Path\To\Shortcut.lnk" 'cmd.exe' "/C" "C:\Path\To\Icon.ico"
Creates a new shortcut that points at cmd.exe, sends arguments /C to cmd.exe and
adds icon Icon.ico as shortcuts icon.
#>
Function Add-Shortcut{
    param(
        ## Full path to shortcut
        [Parameter(Mandatory=$true)]
        [string]$saveAsPath,
        ## Path to shortcuts target application
        [Parameter(Mandatory=$true)]
        [string]$targetPath,
        ## Arguments for the target application
        [Parameter(Mandatory=$false)]
        [string]$arguments="",
        ## Shortcuts icon
        [Parameter(Mandatory=$false)]
        [string]$iconLocation=""
    )
    $objShell = New-Object -ComObject WScript.Shell
    $objShortCut = $objShell.CreateShortcut($saveAsPath)
    $objShortCut.IconLocation = $iconLocation
    $objShortCut.TargetPath = $targetPath
    $objShortCut.Arguments = $arguments
    $objShortCut.Save()
}

<#
.SYNOPSIS
Configures machine with given ssh keys.

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 31.08.2012

.EXAMPLE
Install-SSHKey "./my_id_rsa.pub" "./my_id_rsa" "./known_hosts"

#>
Function Install-SSHKey{
    param(
        ## Path to public key file (~/.ssh/id_rsa.pub)
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [string]$public_key,
        
        ## Path to private key file (~/.ssh/id_rsa)
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [string]$private_key,
        
        ## Path to known host file (~/.ssh/known_hosts)
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [string]$known_hosts,
        
        ## Whether to append or replace existing ssh keys
        [Parameter(Mandatory=$false)]
        [bool]$append=$true
    )

    $ssh_folder = "~/.ssh"
    $sshkey_public = "/id_rsa.pub"
    $sshkey_private = "/id_rsa"
    $sshkey_known_hosts = "/known_hosts"
    
    if(!(Test-Path $ssh_folder)){
        mkdir $ssh_folder | Out-Null
    }
    if(-not $append){
        #replace
        Copy-Item $public_key "$ssh_folder$sshkey_public" -Force
        Copy-Item $private_key "$ssh_folder$sshkey_private" -Force
        Copy-Item $known_hosts "$ssh_folder$sshkey_known_hosts" -Force
    }else{
        #append
        Add-Content -Path "$ssh_folder$sshkey_public" -Value (Get-Content $public_key)
        Add-Content -Path "$ssh_folder$sshkey_private" -Value (Get-Content $private_key)
        Add-Content -Path "$ssh_folder$sshkey_known_hosts" -Value (Get-Content $known_hosts)
    }
}

<#
.SYNOPSIS
Add new tab to the Console2 application.

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 23.08.2012

.EXAMPLE
Add-Console2Tab "MyTest" "C:\Dev\powershell-cxVars_x64.bat" "C:\Temp"
Adds a tab in Console2 which starts up cmd.exe with C:\Temp as default dir.

.EXAMPLE
Add-Console2Tab "MyTest3" "%comspec%" "C:\Temp" $true
Adds a tab in Console2 which starts up cmd.exe with C:\Temp as default dir.
This time the tabs is saved in on a user level.
#>
Function Add-Console2Tab{
    param(
        ## The title of the new tab.
        [Parameter(Mandatory=$true, Position=0)]
        [string]$TabTitle,
        
        ## The console shell to execute.
        [Parameter(Mandatory=$true, Position=1)]
        [AllowEmptyString()]
        [string]$ConsoleShell,
        
        ## The startup directory.
        [Parameter(Mandatory=$true, Position=2)]
        #[ValidateScript({Test-Path $_})]
        [string]$InitalDir,
        
        ## Wheter Console saves on user or on system.
        [Parameter(Mandatory=$false, Position=3)]
        [bool]$SaveSettingsToUserDir = $false #This is default behavior of Console2
    )

    $console_xml = (Get-ChildItem -Path "\*\Console2\console.xml" -Recurse).fullname
    if($SaveSettingsToUserDir)
        {$console_xml ="$HOME\AppData\Roaming\Console\console.xml"}
    
    if(!(Test-Path $console_xml)) {return "Could not find: $console_xml"}

    $doc = [xml] (Get-Content $console_xml)
    $tab = $doc.Settings.Tabs.Tab
    
    $exists = $false
    for($i=0; $i -le ($tab.Count -1); $i++){
        if($tab[$i].title -eq "$TabTitle"){$exists = $true; "Tab already exists, not adding anything."}
    }

    if(!$exists){
        $newTab = [xml] "
        <tab title=`"$TabTitle`" use_default_icon=`"1`">
        	<console shell=`"$ConsoleShell`" init_dir=`"$InitalDir`" run_as_user=`"0`" user=`"`"/>
        	<cursor style=`"0`" r=`"255`" g=`"255`" b=`"255`"/>
        	<background type=`"0`" r=`"0`" g=`"0`" b=`"0`">
        		<image file=`"`" relative=`"0`" extend=`"0`" position=`"0`">
        			<tint opacity=`"0`" r=`"0`" g=`"0`" b=`"0`"/>
        		</image>
        	</background>
        </tab>"
        $newNode = $doc.ImportNode($newTab.tab, $true)
        $tabs = $doc.Settings.Tabs
        $appendedNode = $tabs.AppendChild($newNode)
            
        $doc.Save($console_xml)
        Write-Host "Added tab `"$TabTitle`" to Console2." -ForegroundColor Green
    }
}

<#
.SYNOPSIS
Test if Qt is configured. It looks for configure.cache.

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 15.08.2012

.EXAMPLE
Test-QtConfigured "C:\Dev\external_code\Qt\Qt_4.8.1_build32_DebugAndRelease"
Returns true if config.cache is present, false if not.
#>
Function Test-QtConfigured{
    param(
    ## The path to the Qt build folder
    [string]$buildFolder
    )
    
    $configured = $false
    $cache = $buildFolder+"\configure.cache"
    if(Test-Path $cache)
        {$configured = $true}
    
    return $configured
}

<#
.SYNOPSIS
Get the number of cores the computer has.

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 15.08.2012

.EXAMPLE
Get-Cores
#>
Function Get-Cores{
    $core_list = (Get-WmiObject -class Win32_Processor -Property "NumberOfCores" | Select-Object -Property "NumberOfCores")
    $cores = 0
    foreach($item in $core_list){$cores += $item.NumberOfCores}
    return $cores
}

<#
.SYNOPSIS
Get the computers operative architecture.

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 15.08.2012

.EXAMPLE
Get-OsArchitecture
Known return values: 32-bit, 64-bit
#>
Function Get-OsArchitecture{
    return (Get-WmiObject -Class Win32_OperatingSystem | Select-Object OSArchitecture).OSArchitecture
}

<#
.SYNOPSIS
Check if a microsoft visual studio c++ 2010 compiler
for the give architecuter is found.

WARNING: Depends on Config.ps1

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 15.08.2012

.EXAMPLE
Find-Compiler "x86"
Looks for a 32 bit compiler

.EXAMPLE
Find-Compiler "x64"
Looks for a 64 bit compiler

.EXAMPLE
Find-Compiler "x86_amd64"
Looks for a cross compiler
#>
Function Find-Compiler{
    param(
    ## The compiler architecture to look for
    [string]$arch
    )
    $found = $false
    switch ($arch){
        "x86" {$found = (Test-Path "$script:CX_MSVC_CL_X86")}
        "x64" {$found = (Test-Path "$script:CX_MSVC_CL_X64")}
        "x86_amd64" {$found = (Test-Path "$script:CX_MSVC_CL_X86_AMD64")}
        default {Write-Host "Compiler architecture $arch not recognized."}
    }
    return $found
}

<#
.SYNOPSIS
Check if a microsoft visual studio c++ 2010 is installed

WARNING: Depends on Config.ps1

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 15.08.2012

.EXAMPLE
Test-MSVCInstalled
Returns true if 32 bit compiler of mvs2010 is found, false if not.
#>
Function Test-MSVCInstalled{
    return (Test-Path $script:CX_MSVC_CL_X86)
}

<#
.SYNOPSIS
Get the elapsed time since a give input.

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 15.08.2012

.EXAMPLE
Test-MSVCInstalled
Returns true if 32 bit compiler of mvs2010 is found, false if not.
#>
Function Get-ElapsedTime{
    param(
    [System.DateTime]$startTime
    )
    $runtime = $(get-date) - $startTime
    $retStr = [string]::format("{0} days, {1} hours, {2} minutes, {3}.{4} seconds", `
        $runtime.Days, `
        $runtime.Hours, `
        $runtime.Minutes, `
        $runtime.Seconds, `
        $runtime.Milliseconds)
    $retStr
}

<#
.SYNOPSIS
Resizes the current powershell window buffer to 120x32500

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 15.08.2012

.EXAMPLE
Expand-WindowBuffer
Resized the powershells window buffer to 120x32500
#>
Function Expand-WindowBuffer{
    $pshost = Get-Host
    $pswindow = $pshost.ui.rawui

    $newsize = $pswindow.buffersize
    $newsize.height = 32500
    $newsize.width = 120
    $pswindow.buffersize = $newsize
}

Add-Type -AssemblyName System.Drawing #for function Export-Icon
<#
.SYNOPSIS
Exports a executables icon.

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 15.08.2012

.EXAMPLE
Export-Icon "C:\Application.exe" "C:\Temp\Icon.ico"
Export Application.exe's icon and saves it as Icon.ico
#>
Function Export-Icon{
    param(
    ## Path to the executable with icon to extract
    $exeName,
    ## Full path to file where icon should be saved
    $saveAs
    )
    $stream = [System.IO.File]::OpenWrite($saveAs)
    $icon = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command $exeName).Path)
    $icon.Save($stream)
    $stream.Close()
}