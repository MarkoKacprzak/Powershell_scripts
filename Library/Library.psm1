if(Get-Module Library){return}

#Check that required files are present
Push-Location $psScriptRoot
Import-Module .\Utilities
. ./Time.ps1
. ./Console.ps1
Pop-Location

#Define which functions to make available
Export-ModuleMember -Function @(
        'Set-StartTime',
        'Get-ElapsedTime', 
        'Update-WindowBufferSize'
)

# Classes
############################
#$processRunnerType = @'
#using System;
#using System.Diagnostics;
#using System.ComponentModel;
#
#public class Runner{
#    public Runner(string exe, string args){
#        ProcessStartInfo processStartInfo = new ProcessStartInfo(exe, args);
#        processStartInfo.RedirectStandardInput = true;
#        processStartInfo.RedirectStandardOutput = true;
#        processStartInfo.UseShellExecute = false;
#        processStartInfo.CreateNoWindow = true;
#
#        process = Process.Start(processStartInfo);
#    }
#    
#    public void call(string[] command)
#    {
#        if (process != null)
#        {
#            for(int x = 0; x < command.Length; x++){
#                process.StandardInput.WriteLine(command[x]);
#            }
#            process.StandardInput.Close(); // line added to stop process from hanging on ReadToEnd()
#
#            //string outputString = process.StandardOutput.ReadToEnd();
#            //return outputString;
#        }
#
#        //return string.Empty;
#    }
#    
#    private Process process;
#}
#'@
#Add-Type -TypeDefinition $processRunnerType
#$run = New-Object Runner("cmd", "`"/K `"C:\Dev\Powershell\cxVars_x64.bat`"`"");
#$run.call(@("cl", "dir"));