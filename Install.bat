:: Batch script that executes a series of scrips that will
:: install tools for software development on Windows.

powershell -command "& {Set-ExecutionPolicy Unrestricted}"

powershell -file GetTools.ps1

:: To stop the script from exiting without being able to
:: inspect the results
pause