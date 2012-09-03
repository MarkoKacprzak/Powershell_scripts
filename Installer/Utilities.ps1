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
        Copy-Item $public_key "$ssh_folder$sshkey_public" -Force
        Copy-Item $private_key "$ssh_folder$sshkey_private" -Force
        Copy-Item $known_hosts "$ssh_folder$sshkey_known_hosts" -Force
    }else{
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

Add-Type -AssemblyName System.Drawing #for function Export-Icon
Function Export-Icon ($exeName, $saveAs){
    $stream = [System.IO.File]::OpenWrite($saveAs)
    $icon = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command $exeName).Path)
    $icon.Save($stream)
    $stream.Close()
}