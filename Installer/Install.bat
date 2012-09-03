:: Batch script that executes a powershell scrip that will
:: install tools for software development on Windows.
@echo off 

:: Sets the execution policy for powershell
powershell -command "& {Set-ExecutionPolicy Unrestricted}"

:: Starts a powershell session that starts a powershell process with administrator privileges (needed for adding to PATH)
::powershell -noprofile -command "&{"^
:: "$process = start-process powershell -ArgumentList '-noprofile -noexit -file Install.ps1' -verb RunAs -PassThru;"^
:: "$process.WaitForExit();"^
:: "}"

:: Imports the installer module and runs the Install function
:: which will install a CustusX developer environment
powershell -noprofile -command "&{"^
 "Import-Module ..\Installer -Force;"^
 "Install-CustusXDevelopmentEnvironment -dummy $false -tool_package 'developer' -tool_actions 'all' -tools @('jom') -lib_package 'all' -lib_actions @('all') -libs @('OpenCV') -cmake_generator 'NMake Makefiles JOM' -build_type 'Release' -target_archs @('x86', 'x64') -ssh_keys 'append';"^
 "Read-Host 'Convert to developer machine? Ctrl+C if no'"^
 "ConvertTo-DeveloperMachine"^
 "}"