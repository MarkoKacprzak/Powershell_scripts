:: Batch script that executes a powershell scrip that will
:: install tools for software development on Windows.
@echo off 

:: Sets the execution policy for powershell
powershell -command "& {Set-ExecutionPolicy Unrestricted}"

:: Starts a powershell session that starts a powershell process with administrator privileges (needed for adding to PATH)
powershell -noprofile -command "&{"^
 "$process = start-process powershell -ArgumentList '-noprofile -noexit -file Install.ps1' -verb RunAs -PassThru;"^
 "$process.WaitForExit();"^
 "}"