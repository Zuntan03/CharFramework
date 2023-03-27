# 黒猫と茶猫のLoRA学習環境

黒猫と茶猫のLoRA学習環境です。
このデータは成人向けですので、18歳未満の方の取り扱いを禁止します。

参考URL: https://github.com/Zuntan03/CharFramework

- チェックアウトした[CharFramework](https://github.com/Zuntan03/CharFramework)に展開したファイルを上書きすると利用できます。
- 「LearnKuronekoTyaneko.bat」を実行すると、kohya版LoRAのカーネルサイズ3x3のConv2dで学習します。
	- CharFrameworkの「InstallSdScripts.bat」で「[sd-scripts](https://github.com/kohya-ss/sd-scripts)」を先にインストールしてください。
	- デフォルトでは「./LoRAInput/」直下に学習元モデルの「Defmix-v2.0.safetensors」を配置する設定担っています。
		- 好きなモデルを「./LoRAInput/」直下に配置し、「LearnKuronekoTyaneko.bat」などの「Defmix-v2.0.safetensors」を書き換えてください。
- 「LearnKuronekoTyaneko-Locon.bat」や「LearnKuronekoTyaneko-Loha.bat」では、「[LyCORIS](https://github.com/KohakuBlueleaf/LyCORIS)」の「Locon(lora)」や「LoHa」で学習します。
	- CharFrameworkの「InstallLyCORIS.bat」で「[LyCORIS](https://github.com/KohakuBlueleaf/LyCORIS)」を先にインストールしてください。
	- 他の学習に合わせてnetwork_alphaやconv_alphaにnetwork_dimの半分を指定しています。1にしたい場合はbatの「call LoRA LohaA50p-」を「call LoRA LohaA1-」に変更してください。
- 学習素材は「./LoRAInput/」以下にあります。
	- 「4_krnk」: 黒猫の顔LoRA素材。
	- 「2_krnksf_krnk」: セーラー服(school uniform)を着た黒猫の体LoRA素材。
	- 「4_tyank」: 茶猫の顔LoRA素材。
	- 「2_tyankps_tyank」: プラグスーツ(plugsuit)を着た茶猫の体LoRA素材。
	- 「1_krnksf_tyankps_krnk_tyank」: セーラー服を着た黒猫とプラグスーツを着た茶猫のグループLoRA素材。
- 各素材のフォルダに自動生成したsd-scripts用の設定tomlファイルがあります。例：「4_krnk/4_krnk.toml」

作成したLoRAに合わせて、WebUIの拡張が必要になります。

|拡張|Kohya版LoRA Conv2d 3x3|LyCORIS Locon|LyCORIS Loha|
|--:|:--:|:--:|:--:|
|[Additional Networks](https://github.com/kohya-ss/sd-webui-additional-networks)|○|○|×|
|[a1111-sd-webui-locon](https://github.com/KohakuBlueleaf/a1111-sd-webui-locon)|○|○|○|

通常のKohya版LoRA(Conv2d 1x1)は拡張なしで利用できます。

## ライセンス

[MIT License](./LICENSE.txt)です。

This software is released under the MIT License, see [LICENSE.txt](./LICENSE.txt).
