# This is the CustusX development installer.

#Check that required files are present
Push-Location $psScriptRoot
. ./Install.ps1
. ./Config.ps1
. ./GetTools.ps1
Pop-Location


<#
.SYNOPSIS
Add new tab to the Console2 application.

.DESCRIPTION

.INPUTS
None.

.OUTPUTS
None. This script does not generate any output.

.NOTES
AUTHOR: Janne Beate Bakeng, SINTEF
DATE: 23.08.2012

.EXAMPLE
Add-Console2Tab "MyTest" "" "C:\Temp"
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
        [ValidateScript({Test-Path $_})]
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
    }
}

#Get-Help Add-Console2Tab -Full
#Add-Console2Tab "MyTest3" "%comspec%" "C:\Temp" $true

#Aliases
Set-Alias Install-CDE Install-CustusXDevelopmentEnvironment

#Define which functions to make available
Export-ModuleMember -Function @(
    "Install-CustusXDevelopmentEnvironment"
    )
Export-ModuleMember -Alias @(
    'Install-CDE'
)