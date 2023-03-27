@echo off

rem Configuration
set SD_SCRIPTS_DIR=%~dp0sd-scripts
set LOG_DIR=%~dp0LoRALog
rem End of Configuration

pushd %SD_SCRIPTS_DIR%
call venv\Scripts\activate

if "%1"=="" (
	tensorboard --logdir="%LOG_DIR%"
) else (
    tensorboard --logdir="%~f1"
)
popd
