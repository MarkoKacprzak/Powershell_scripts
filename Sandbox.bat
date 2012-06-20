@ECHO OFF

powershell -noprofile -command "&{"^
 "$process = start-process powershell -ArgumentList '-noprofile -noexit -file C:\Dev\Powershell\Sandbox.ps1' -verb RunAs -PassThru;"^
 "$process.WaitForExit();"^
 "}"
 
pause