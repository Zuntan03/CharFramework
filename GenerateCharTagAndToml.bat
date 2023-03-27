@echo off
pushd %~dp0

setlocal enabledelayedexpansion
for %%i in (%*) do (
	echo "%%~fi"
	PowerShell -Version 5.1 -ExecutionPolicy Bypass -File "%~dp0GenerateCharTag.ps1" "%%~fi"
	if %ERRORLEVEL% neq 0 pause
)
for %%i in (%*) do (
	PowerShell -Version 5.1 -ExecutionPolicy Bypass -File "%~dp0GenerateCharToml.ps1" "%%~fi"
	if %ERRORLEVEL% neq 0 pause
)
endlocal

popd
rem pause
