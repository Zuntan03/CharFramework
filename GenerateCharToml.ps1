class CharTomlGenerator {
	# Configuration
	$RESOLUTIONS = @(512, 768, 1024);
	$RESOLUTION_NAMES = @("LOW", "MID", "HIGH");
	$BATCH_SIZE_TABLE = @{
		"LOW_LOW" = 4; "MID_LOW" = 3; "LOW_MID" = 3; "MID_MID" = 2; "HIGH_LOW" = 2; "LOW_HIGH" = 2; # VRAM 12GB
	};
	$MULTI_RESOLUTION = $true; # $false > $SINGLE_RESOLUTION_NAME only
	$SINGLE_RESOLUTION_NAME = "LOW_LOW";
	$DEFAULT_FLIP_AUG = $true;
	$FROM_SD_SCRIPTS = "..\";
	# End of Configuration

	#$TRANS_REG_DIR = "..\LoRATransReg\"; # from sd-scripts\
	#$TRANS_REG_CLASS_TOKENS = "girl";
	#$TRANS_REG_NUM_REPEATS = 100000; # 枚数計測必要

	$resNames = @();
	$datasets = @{};

	CharTomlGenerator() {
		for ($wIdx = 0; $wIdx -lt $this.RESOLUTIONS.Count; $wIdx++) {
			$width = $this.RESOLUTIONS[$wIdx];
			$wName = $this.RESOLUTION_NAMES[$wIdx];
			for ($hIdx = 0; $hIdx -lt $this.RESOLUTIONS.Count; $hIdx++) {
				$height = $this.RESOLUTIONS[$hIdx];
				$hName = $this.RESOLUTION_NAMES[$hIdx];
				$resName = "$($wName)_$($hName)";
				$this.resNames += $resName;
				$dataset = New-Object CharTomlDataset($width, $height);
				$this.datasets[$resName] = $dataset;
			}
		}
	}

	[void] Generate($path) {
		$dirPath = [System.IO.Path]::GetFullPath($path);
		if (![System.IO.Directory]::Exists($dirPath)) {
			Write-Error "Invalid folder path: $dirPath";
			return;
		}

		$dirName = [System.IO.Path]::GetFileName($dirPath);
		$generalNumRepeats = 1;
		$delIdx = $dirName.IndexOf("_");
		if ($delIdx -ge 0) {
			$numRep = 0;
			if ([int]::TryParse($dirName.Substring(0, $delIdx), [ref]$numRep)) {
				$generalNumRepeats = $numRep; 
			}
		}

		$pathDic = @{};
		foreach ($pngPath in [System.IO.Directory]::EnumerateFiles($dirPath, "*.png", "AllDirectories")) {
			$this.CollectPng($pathDic, $pngPath);
		}

		$toml = $this.GenerateToml($generalNumRepeats);

		$tomlPath = [System.IO.Path]::Combine($dirPath, "$dirName.toml");
		[System.IO.File]::WriteAllText($tomlPath, $toml);

		Write-Host $tomlPath;
		#Write-Host $toml;
	}

	[void] CollectPng($pathDic, $path) {
		$pngPath = [System.IO.Path]::GetFullPath($path);
		$dirPath = [System.IO.Path]::GetDirectoryName($pngPath);
		$newDir = !$pathDic.ContainsKey($dirPath);

		if ($this.MULTI_RESOLUTION) {
			$pngW = $pngH = 0;
			GetImageSize $pngPath ([ref]$pngW) ([ref]$pngH);

			$wName = $hName = $null;
			for ($wIdx = 0; $wIdx -lt ($this.RESOLUTIONS.Count - 1); $wIdx++) {
				if ($pngW -le $this.RESOLUTIONS[$wIdx]) {
					$wName = $this.RESOLUTION_NAMES[$wIdx];
					break;
				}
			}
			if ($null -eq $wName) { $wName = $this.RESOLUTION_NAMES[$this.RESOLUTION_NAMES.Count - 1]; }

			for ($hIdx = 0; $hIdx -lt ($this.RESOLUTIONS.Count - 1); $hIdx++) {
				if ($pngH -le $this.RESOLUTIONS[$hIdx]) {
					$hName = $this.RESOLUTION_NAMES[$hIdx];
					break;
				}
			}
			if ($null -eq $hName) { $hName = $this.RESOLUTION_NAMES[$this.RESOLUTION_NAMES.Count - 1]; }
			$resName = "$($wName)_$($hName)";
			$dataset = $this.datasets[$resName];

			#Write-Host "png[$pngW, $pngH] $resName[$($dataset.width), $($dataset.height)] $pngPath";

			if ($newDir) {
				$dataset.paths += $dirPath;
				$pathDic[$dirPath] = $dataset;
			}
			else {
				$registered = $pathDic[$dirPath];
				if (($registered.width -ne $dataset.width) -or ($registered.height -ne $dataset.height)) {
					Write-Error "Invalid png size. dataset[$($registered.width), $($registered.height)] png[$pngW, $pngH] $pngPath"
				}
			}
		}
		else {
			if ($newDir) {
				$dataset = $this.datasets[$this.SINGLE_RESOLUTION_NAME];
				$dataset.paths += $dirPath;
				$pathDic[$dirPath] = $dataset;
			}
		}
	}

	[string] GenerateToml($generalNumRepeats) {
		$toml = "[general]`r`n";
		$toml += "color_aug = true`r`n";
		$toml += "enable_bucket  = true`r`n";
		$toml += "bucket_no_upscale = true`r`n";
		$toml += "caption_extension = '.txt'`r`n";
		$toml += "num_repeats = $generalNumRepeats`r`n";

		foreach ($resName in $this.resNames) {
			$dataset = $this.datasets[$resName];
			if ($dataset.paths.Count -eq 0) { continue; }

			$toml += "`r`n[[datasets]]`r`n";
			$toml += "resolution = [$($dataset.width), $($dataset.height)]`r`n";
			if ($this.BATCH_SIZE_TABLE.ContainsKey($resName)) {
				$toml += "batch_size = $($this.BATCH_SIZE_TABLE[$resName])`r`n"
			}
			else {
				$toml += "batch_size = 1`r`n"
			}
			
			#if (![string]::IsNullOrEmpty($this.TRANS_REG_DIR)) {
			#	$toml += "`r`n[[datasets.subsets]]`r`n";
			#	$toml += "image_dir = '$($this.TRANS_REG_DIR + $resName)'`r`n";
			#	if (![string]::IsNullOrEmpty($this.TRANS_REG_CLASS_TOKENS)) {
			#		$toml += "class_tokens = '$($this.TRANS_REG_CLASS_TOKENS)'`r`n"; 
			#	}
			#	$toml += "is_reg = true`r`n";
			#	$toml += "num_repeats = $($this.TRANS_REG_NUM_REPEATS)`r`n";
			#}

			foreach ($iamge_dir in $dataset.paths) {
				$toml += "`r`n[[datasets.subsets]]`r`n";
				if ([string]::IsNullOrEmpty($this.FROM_SD_SCRIPTS)) {
					$toml += "image_dir = '$iamge_dir'`r`n";
				}
				else {
					$relPath = $iamge_dir | Resolve-Path -Relative;
					if ($relPath.StartsWith(".\")) { $relPath = $relPath.Substring(2); }
					$relPath = [System.IO.Path]::Combine($this.FROM_SD_SCRIPTS, $relPath);
					$toml += "image_dir = '$relPath'`r`n";
				}

				$dirName = [System.IO.Path]::GetFileName($iamge_dir);
				$class_tokens = $dirName;
				$delIdx = $dirName.IndexOf("_");
				if ($delIdx -ge 0) { $class_tokens = $dirName.Substring(0, $delIdx); }
				$toml += "class_tokens = '$class_tokens'`r`n";

				$flip_aug = $this.DEFAULT_FLIP_AUG;
				$flipIdx = $dirName.IndexOf("_flip_");
				if ($flipIdx -ge 0) { $flip_aug = $true; }
				$flipIdx = $dirName.IndexOf("_noflip_");
				if ($flipIdx -ge 0) { $flip_aug = $false; }
				if ($flip_aug) {
					$toml += "flip_aug = true`r`n";
				}
				else {
					$toml += "flip_aug = false`r`n";
				}
				
			}
		}
		return $toml;
	}
}

class CharTomlDataset {
	$width;
	$height;
	$paths = @();
	CharTomlDataset($w, $h) {
		$this.width = $w;
		$this.height = $h;
	}
}

$ErrorActionPreference = "Stop";
Add-Type -AssemblyName System.Drawing;
function GetImageSize($path, [ref]$width, [ref]$height) {
	$stream = $image = $null;
	try {
		$stream = New-Object System.IO.FileStream($pngPath, "Open", "Read");
		$image = [System.Drawing.Image]::FromStream($stream);
		$width.Value = $image.Width;
		$height.Value = $image.Height;
	}
	catch {
		Write-Error $_;
	}
	finally {
		if ($null -ne $image) { $image.Dispose(); }
		if ($null -ne $stream) { $stream.Dispose(); }
	}
}

$charTomlGenerator = New-Object CharTomlGenerator;
$charTomlGenerator.Generate($args[0]);
