@echo off

rem Configuration
set SD_SCRIPTS_DIR=%~dp0sd-scripts
set MODEL_DIR=%~dp0LoRAInput
rem set VAE_DIR=%~dp0LoRAInput
set SRC_DIR=%~dp0LoRAInput
set OUT_DIR=%~dp0LoRAOutput
set LOG_DIR=%~dp0LoRALog
rem End of Configuration

pushd %SD_SCRIPTS_DIR%
call venv\Scripts\activate

echo -- Configuration --
echo SD_SCRIPTS_DIR: %SD_SCRIPTS_DIR%
echo MODEL_DIR: %MODEL_DIR%
echo SRC_DIR: %SRC_DIR%
echo OUT_DIR: %OUT_DIR%

echo -- Argument --
set LEARNING_LOGIC=%1
echo LEARNING_LOGIC: %LEARNING_LOGIC%
shift /1

set BASE_DIM=%1
set /a BASE_DIM_75PER=%1*3/4
set /a BASE_DIM_67PER=%1*2/3
set /a BASE_DIM_50PER=%1/2
set /a BASE_DIM_25PER=%1/4
echo BASE_DIM: %BASE_DIM%, 75%%: %BASE_DIM_75PER%, 67%%: %BASE_DIM_67PER%, 50%%: %BASE_DIM_50PER%, 25%%: %BASE_DIM_25PER%
shift /1

set BASE_LR=%1
set LEARNING_RATE=%BASE_LR%e-6
set /a TEXT_ENCODER_LR=%BASE_LR%*44/100
set TEXT_ENCODER_LR=%TEXT_ENCODER_LR%e-6
echo BASE_LR: %BASE_LR%, learning_rate: %LEARNING_RATE%, text_encoder_lr: %TEXT_ENCODER_LR%
shift /1

set MAX_TRAIN_STEPS=%1
echo max_train_steps: %MAX_TRAIN_STEPS%
shift /1

set SOURCE_NAME=%1
set DATASET_CONFIG="%SRC_DIR%\%SOURCE_NAME%\%SOURCE_NAME%.toml"
echo SOURCE_NAME: %SOURCE_NAME%, dataset_config: %DATASET_CONFIG%
shift /1

set OUTPUT_DIR="%OUT_DIR%\%1"
echo output_dir: %OUTPUT_DIR%
set OUTPUT_NAME=%1-%LEARNING_LOGIC%-%BASE_DIM%-%BASE_LR%-%MAX_TRAIN_STEPS%
rem set OUTPUT_NAME=%1
echo output_name: %OUTPUT_NAME%
shift /1

set PRETRAINED_MODEL="%MODEL_DIR%\%1"
echo pretrained_model %PRETRAINED_MODEL%
shift /1

rem set VAE="%VAE_DIR%\%1"
rem echo vae %VAE%
rem shift /1

set CLIP_SKIP=%1
echo clip_skip %CLIP_SKIP%
shift /1

if "%1"=="" (
	set NETWORK_WEIGHTS=
) else (
	set NETWORK_WEIGHTS=--network_weights=%1
	echo network_weights %NETWORK_WEIGHTS%
)
shift /1

set LOGGING_DIR="%LOG_DIR%"
echo logging_dir: %LOGGING_DIR%

if "%LEARNING_LOGIC%"=="Lora3x3A1-AdamW8" (
set NETWORK_DIM=%BASE_DIM%
set NETWORK_ALPHA=1
set LEARNING_OPTIONS=--network_module=networks.lora^
 --network_args "conv_dim=%BASE_DIM%" "conv_alpha=1"^
 --optimizer_type=AdamW8bit^
 --learning_rate=%LEARNING_RATE%^
 --text_encoder_lr=%TEXT_ENCODER_LR%^
 --lr_scheduler=cosine_with_restarts

) else if "%LEARNING_LOGIC%"=="Lora3x3A50p-AdamW8" (
set NETWORK_DIM=%BASE_DIM%
set NETWORK_ALPHA=%BASE_DIM_50PER%
set LEARNING_OPTIONS=--network_module=networks.lora^
 --network_args "conv_dim=%BASE_DIM%" "conv_alpha=%BASE_DIM_50PER%"^
 --optimizer_type=AdamW8bit^
 --learning_rate=%LEARNING_RATE%^
 --text_encoder_lr=%TEXT_ENCODER_LR%^
 --lr_scheduler=cosine_with_restarts

) else if "%LEARNING_LOGIC%"=="Lora3x3A1-AdaFacotor" (
set NETWORK_DIM=%BASE_DIM%
set NETWORK_ALPHA=1
set LEARNING_OPTIONS=--network_module=networks.lora^
 --network_args "conv_dim=%BASE_DIM%" "conv_alpha=1" "algo=lora"^
 --optimizer_type=adafactor^
 --optimizer_args "relative_step=True" "scale_parameter=True" "warmup_init=False"

) else if "%LEARNING_LOGIC%"=="Lora3x3A50p-AdaFacotor" (
set NETWORK_DIM=%BASE_DIM%
set NETWORK_ALPHA=%BASE_DIM_50PER%
set LEARNING_OPTIONS=--network_module=networks.lora^
 --network_args "conv_dim=%BASE_DIM%" "conv_alpha=%BASE_DIM_50PER%"^
 --optimizer_type=adafactor^
 --optimizer_args "relative_step=True" "scale_parameter=True" "warmup_init=False"

) else if "%LEARNING_LOGIC%"=="Lora1x1A1-AdamW8" (
set NETWORK_DIM=%BASE_DIM%
set NETWORK_ALPHA=1
set LEARNING_OPTIONS=--network_module=networks.lora^
 --optimizer_type=AdamW8bit^
 --learning_rate=%LEARNING_RATE%^
 --text_encoder_lr=%TEXT_ENCODER_LR%^
 --lr_scheduler=cosine_with_restarts

) else if "%LEARNING_LOGIC%"=="Lora1x1A50p-AdamW8" (
set NETWORK_DIM=%BASE_DIM%
set NETWORK_ALPHA=%BASE_DIM_50PER%
set LEARNING_OPTIONS=--network_module=networks.lora^
 --optimizer_type=AdamW8bit^
 --learning_rate=%LEARNING_RATE%^
 --text_encoder_lr=%TEXT_ENCODER_LR%^
 --lr_scheduler=cosine_with_restarts

) else if "%LEARNING_LOGIC%"=="Lora1x1A1-AdaFacotor" (
set NETWORK_DIM=%BASE_DIM%
set NETWORK_ALPHA=1
set LEARNING_OPTIONS=--network_module=networks.lora^
 --optimizer_type=adafactor^
 --optimizer_args "relative_step=True" "scale_parameter=True" "warmup_init=False"

) else if "%LEARNING_LOGIC%"=="Lora1x1A50p-AdaFacotor" (
set NETWORK_DIM=%BASE_DIM%
set NETWORK_ALPHA=%BASE_DIM_50PER%
set LEARNING_OPTIONS=--network_module=networks.lora^
 --optimizer_type=adafactor^
 --optimizer_args "relative_step=True" "scale_parameter=True" "warmup_init=False"

) else if "%LEARNING_LOGIC%"=="LohaA1-AdamW8" (
set NETWORK_DIM=%BASE_DIM%
set NETWORK_ALPHA=1
set LEARNING_OPTIONS=--network_module=lycoris.kohya^
 --network_args "conv_dim=%BASE_DIM%" "conv_alpha=1" "algo=loha"^
 --optimizer_type=AdamW8bit^
 --learning_rate=%LEARNING_RATE%^
 --text_encoder_lr=%TEXT_ENCODER_LR%^
 --lr_scheduler=cosine_with_restarts

) else if "%LEARNING_LOGIC%"=="LohaA50p-AdamW8" (
set NETWORK_DIM=%BASE_DIM%
set NETWORK_ALPHA=%BASE_DIM_50PER%
set LEARNING_OPTIONS=--network_module=lycoris.kohya^
 --network_args "conv_dim=%BASE_DIM%" "conv_alpha=%BASE_DIM_50PER%" "algo=loha"^
 --optimizer_type=AdamW8bit^
 --learning_rate=%LEARNING_RATE%^
 --text_encoder_lr=%TEXT_ENCODER_LR%^
 --lr_scheduler=cosine_with_restarts

) else if "%LEARNING_LOGIC%"=="LohaA1-AdaFacotor" (
set NETWORK_DIM=%BASE_DIM%
set NETWORK_ALPHA=1
set LEARNING_OPTIONS=--network_module=lycoris.kohya^
 --network_args "conv_dim=%BASE_DIM%" "conv_alpha=1" "algo=loha"^
 --optimizer_type=adafactor^
 --optimizer_args "relative_step=True" "scale_parameter=True" "warmup_init=False"

) else if "%LEARNING_LOGIC%"=="LohaA50p-AdaFacotor" (
set NETWORK_DIM=%BASE_DIM%
set NETWORK_ALPHA=%BASE_DIM_50PER%
set LEARNING_OPTIONS=--network_module=lycoris.kohya^
 --network_args "conv_dim=%BASE_DIM%" "conv_alpha=%BASE_DIM_50PER%" "algo=loha"^
 --optimizer_type=adafactor^
 --optimizer_args "relative_step=True" "scale_parameter=True" "warmup_init=False"

) else if "%LEARNING_LOGIC%"=="LoconA1-AdamW8" (
set NETWORK_DIM=%BASE_DIM%
set NETWORK_ALPHA=1
set LEARNING_OPTIONS=--network_module=lycoris.kohya^
 --network_args "conv_dim=%BASE_DIM%" "conv_alpha=1" "algo=lora"^
 --optimizer_type=AdamW8bit^
 --learning_rate=%LEARNING_RATE%^
 --text_encoder_lr=%TEXT_ENCODER_LR%^
 --lr_scheduler=cosine_with_restarts

) else if "%LEARNING_LOGIC%"=="LoconA50p-AdamW8" (
set NETWORK_DIM=%BASE_DIM%
set NETWORK_ALPHA=%BASE_DIM_50PER%
set LEARNING_OPTIONS=--network_module=lycoris.kohya^
 --network_args "conv_dim=%BASE_DIM%" "conv_alpha=%BASE_DIM_50PER%" "algo=lora"^
 --optimizer_type=AdamW8bit^
 --learning_rate=%LEARNING_RATE%^
 --text_encoder_lr=%TEXT_ENCODER_LR%^
 --lr_scheduler=cosine_with_restarts

) else if "%LEARNING_LOGIC%"=="LoconA1-AdaFacotor" (
set NETWORK_DIM=%BASE_DIM%
set NETWORK_ALPHA=1
set LEARNING_OPTIONS=--network_module=lycoris.kohya^
 --network_args "conv_dim=%BASE_DIM%" "conv_alpha=1" "algo=lora"^
 --optimizer_type=adafactor^
 --optimizer_args "relative_step=True" "scale_parameter=True" "warmup_init=False"


) else if "%LEARNING_LOGIC%"=="LoconA50p-AdaFacotor" (
set NETWORK_DIM=%BASE_DIM%
set NETWORK_ALPHA=%BASE_DIM_50PER%
set LEARNING_OPTIONS=--network_module=lycoris.kohya^
 --network_args "conv_dim=%BASE_DIM%" "conv_alpha=%BASE_DIM_50PER%" "algo=lora"^
 --optimizer_type=adafactor^
 --optimizer_args "relative_step=True" "scale_parameter=True" "warmup_init=False"

) else (
	echo Unknown LEARNING_LOGIC: %LEARNING_LOGIC%
	exit /b 1
)
echo LEARNING_OPTIONS: %LEARNING_OPTIONS%
echo network_dim %NETWORK_DIM%
echo network_alpha %NETWORK_ALPHA%

echo -- Run --
echo on
accelerate launch train_network.py^
 %LEARNING_OPTIONS%^
 --network_dim=%NETWORK_DIM%^
 --network_alpha=%NETWORK_ALPHA%^
 --dataset_config=%DATASET_CONFIG%^
 --max_train_steps=%MAX_TRAIN_STEPS%^
 --output_dir=%OUTPUT_DIR%^
 --output_name=%OUTPUT_NAME%^
 --pretrained_model_name_or_path=%PRETRAINED_MODEL%^
 --clip_skip=%CLIP_SKIP%^
 %NETWORK_WEIGHTS%^
 --logging_dir=%LOGGING_DIR%^
 --log_prefix=%OUTPUT_NAME%^
 --xformers^
 --save_model_as=safetensors^
 --mixed_precision=fp16^
 --save_precision=fp16^
 --gradient_checkpointing^
 --persistent_data_loader_workers^
 --seed=31337
@echo off
rem --vae=%VAE%^
rem --save_every_n_epochs=1^
rem --max_token_length=150^
rem --num_cpu_threads_per_process 4^
popd
