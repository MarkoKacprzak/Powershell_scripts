:: Batch script that executes a series of scrips that will
:: install tools for software development on Windows.

:: Sets the execution policy for powershell
powershell -command "& {Set-ExecutionPolicy Unrestricted}"

:: Starts a powershell process
REM powershell -file GetTools.ps1

:: Starts a powershell session that starts a powershell process with administrator privileges (needed for adding to PATH)
powershell -noprofile -noexit -command "&{start-process powershell -ArgumentList '-noprofile -noexit -file GetTools.ps1' -verb RunAs}"

:: To stop the script from exiting without being able to inspect the results
::pause

:: Run python script to install libraries