@ECHO OFF

rem powershell -noprofile -command "&{"^
rem  "$process = start-process powershell -ArgumentList '-noprofile -noexit -file C:\Dev\Powershell\Sandbox.ps1' -verb RunAs -PassThru;"^
rem "$process.WaitForExit();"^
rem "}"

echo where powershell /q
echo "Var: "%var%
 
pause