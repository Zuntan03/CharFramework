@echo off

pushd sd-scripts
call venv\Scripts\activate

pip install lycoris_lora

popd
pause
