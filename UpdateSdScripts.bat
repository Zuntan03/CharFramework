@echo off
pushd sd-scripts

git pull
call venv\Scripts\activate
pip install --use-pep517 --upgrade -r requirements.txt

popd
pause
