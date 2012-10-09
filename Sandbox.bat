@echo off

set var = "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat"
call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x64


::cd C:\Dev\external\OpenIGTLink\build_static_jom_Release
::cd C:\Dev\workspace\ISB_DataStreaming\build_static_jom_Release
::jom /K /j 8
::echo Exit Code is %errorlevel%
::echo %errorlevel% > C:\Dev\Powershell\BuildStatus.txt
::set var=0
::set /p var=<C:\Dev\Powershell\BuildStatus.txt
::echo "%var%"
REM setlocal enabledelayedexpansion
REM set nmake_code=1
REM for /f %%a in (BuildStatus.txt) do (
	REM set nmake_code=%%a
	REM echo Inside: !nmake_code!
REM )
REM echo After: !nmake_code!
REM if NOT !nmake_code!==1 (
	REM echo If: !nmake_code!
REM ) else ( 
	REM echo Else: !nmake_code!
REM )
REM endlocal
::if errorlevel 0 (
::   echo Failure Reason Given is %errorlevel%
::   exit /b %errorlevel%
::)