@echo off

rem Configuration
set SD_SCRIPTS_DIR=%~dp0sd-scripts
set SV_RATIO=16
set NEW_RANK=128
rem End of Configuration

pushd %SD_SCRIPTS_DIR%
call venv\Scripts\activate

set SUFFIX=-SvR%SV_RATIO%
setlocal enabledelayedexpansion
for %%i in (%*) do (
python networks\resize_lora.py^
 --model %%~fi^
 --save_to %%~dpni%SUFFIX%%%~xi^
 --dynamic_method sv_ratio^
 --dynamic_param %SV_RATIO%^
 --save_precision fp16^
 --new_rank %NEW_RANK%^
 --device cuda
)
endlocal
rem --verbose

popd
