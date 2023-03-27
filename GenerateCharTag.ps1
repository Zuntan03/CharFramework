
$ErrorActionPreference = "Stop";

class CharTagGenerator {
	[void] Generate($path) {
		$dirPath = [System.IO.Path]::GetFullPath($path);

		if (![System.IO.Directory]::Exists($dirPath)) {
			Write-Error "Invalid folder path: $dirPath";
			return;
		}

		foreach ($pngPath in [System.IO.Directory]::EnumerateFiles($dirPath, "*.png", "AllDirectories")) {
			$this.GenerateTxt($pngPath);
		}
	}

	[void] GenerateTxt($pngPath) {
		$fileName = [System.IO.Path]::GetFileNameWithoutExtension($pngPath);

		if (!($fileName -match "^[fb][0-2][0-7]")) {
			Write-Host "Skip: Invalid file name [regex]!(^[fb][0-2][0-7]) $pngPath";
			return;
		}
		$status = "`r`n$fileName.png ";

		$dirName = [System.IO.Path]::GetFileName([System.IO.Path]::GetDirectoryName($pngPath));
		$keyword = $dirName;
		$delIdx = $dirName.IndexOf(" ");
		if ($delIdx -ge 0) {
			$keyword = $dirName.Substring(0, $delIdx);
		}
		else {
			$delIdx = $dirName.IndexOf("_");
			if ($delIdx -ge 0) { $keyword = $dirName.Substring(0, $delIdx); }
		}
		$status += "$($keyword): ";


		$faceTag = $fileName[0] -eq "f";
		if ($faceTag) { $status += "FaceTag "; }
		$bodyTag = $fileName[0] -eq "b";
		if ($bodyTag) { $status += "BodyTag "; }

		$fromHorizontal = $fileName[1] -eq "0";
		if ($fromHorizontal) { $status += "FromHorizontal "; }
		$fromAbove = $fileName[1] -eq "1";
		if ($fromAbove) { $status += "FromAbove "; }
		$fromBelow = $fileName[1] -eq "2";
		if ($fromBelow) { $status += "FromBelow "; }

		$fromFront = $fileName[2] -match "[017]";
		if ($fromFront) { $status += "FromFront "; }
		$fromSide = $fileName[2] -match "[26]";
		if ($fromSide) { $status += "FromSide "; }
		$fromBehind = $fileName[2] -match "[345]";
		if ($fromBehind) { $status += "FromBehind "; }

		$front = $fileName[2] -match "[01267]";
		if ($front) { $status += "Front "; }
		$back = $fileName[2] -match "[345]";
		if ($back) { $status += "Back "; }
		$navel = ($fromAbove -and $front) -or ($fromBelow -and $fromFront);
		if ($navel) { $status += "Navel "; }

		$lookViewer = $fileName[2] -match "[0]";
		if ($lookViewer) { $status += "LookViewer "; }
		$lookAway = $fileName[2] -match "[1-7]";
		if ($lookAway) { $status += "LookAway "; }

		$facial = $fileName[2] -match "[0123567]";
		if ($facial) { $status += "Facial "; }

		$tags = "";

		if (![string]::IsNullOrEmpty($keyword)) { $tags += "$keyword, "; }
		$tags += "white background, black background, simple background";
		if ($faceTag) { $tags += ", fully clothed"; }

		if ($fromHorizontal) { $tags += ", from horizontal"; }
		if ($fromAbove) { $tags += ", from above"; }
		if ($fromBelow) { $tags += ", from below"; }

		if ($fromFront) { $tags += ", from front"; }
		if ($fromSide) { $tags += ", from side"; }
		if ($fromBehind) { $tags += ", from behind"; }

		if ($faceTag) { $tags += ", upper body"; }
		if ($bodyTag) { $tags += ", full body"; }

		$tags += ", standing, straight standing"

		if ($faceTag) {
			$tags += ", nude, completely nude, bare shoulders";

			if ($front) { $tags += ", nipples, collarbone, abs, ribs"; }
			if ($back) { $tags += ", shoulder blades, median furrow"; }
			if ($navel) { $tags += ", navel"; }
		}

		if ($lookViewer) { $tags += ", looking at viewer"; }
		if ($lookAway) { $tags += ", looking away"; }

		if ($facial) { $tags += ", smile, open mouth, blush"; }

		Write-Host $status;
		Write-Host $tags;
		$txtPath = [System.IO.Path]::ChangeExtension($pngPath, "txt");
		[System.IO.File]::WriteAllText($txtPath, $tags);
	}
}

$charTagGenerator = New-Object CharTagGenerator;
$charTagGenerator.Generate($args[0]);

