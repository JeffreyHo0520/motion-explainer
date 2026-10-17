param(
    [string]$ProjectDir = "."
)

$ErrorActionPreference = "Stop"
$ResolvedProjectDir = (Resolve-Path $ProjectDir).Path
$Dest = Join-Path $ResolvedProjectDir "assets\fonts"
if (-not (Test-Path $Dest)) {
    New-Item -ItemType Directory -Path $Dest -Force | Out-Null
}

$TempDir = Join-Path $env:TEMP ("fetch_fonts_" + [System.Guid]::NewGuid().ToString().Substring(0, 8))
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

try {
    Write-Host "Installing font packages into temporary directory..."
    Push-Location $TempDir
    cmd.exe /c "npm init -y >nul 2>&1 && npm install --no-audit --no-fund @fontsource/newsreader@5.2.8 @fontsource/dm-mono@5.2.7 @fontsource/hanken-grotesk@5.2.8 >nul 2>&1"
    Pop-Location

    $F = Join-Path $TempDir "node_modules\@fontsource"

    Copy-Item "$F\newsreader\files\newsreader-latin-400-normal.woff2" "$Dest\Newsreader-Regular.woff2" -Force
    Copy-Item "$F\newsreader\files\newsreader-latin-400-italic.woff2" "$Dest\Newsreader-Italic.woff2" -Force
    Copy-Item "$F\dm-mono\files\dm-mono-latin-400-normal.woff2" "$Dest\DMMono-Regular.woff2" -Force
    Copy-Item "$F\dm-mono\files\dm-mono-latin-500-normal.woff2" "$Dest\DMMono-Medium.woff2" -Force

    $weights = @(
        @{ Weight = "400"; Name = "Regular" },
        @{ Weight = "500"; Name = "Medium" },
        @{ Weight = "600"; Name = "SemiBold" },
        @{ Weight = "700"; Name = "Bold" }
    )

    foreach ($w in $weights) {
        Copy-Item "$F\hanken-grotesk\files\hanken-grotesk-latin-$($w.Weight)-normal.woff2" "$Dest\HankenGrotesk-$($w.Name).woff2" -Force
    }

    $cjkFonts = @("NotoSansTC-VF.ttf", "NotoSerifTC-VF.ttf")
    $searchDirs = @(
        "C:\Windows\Fonts",
        "$env:LOCALAPPDATA\Microsoft\Windows\Fonts",
        "$env:USERPROFILE\.local\share\fonts"
    )

    foreach ($name in $cjkFonts) {
        $found = $false
        foreach ($d in $searchDirs) {
            $p = Join-Path $d $name
            if (Test-Path $p) {
                Copy-Item $p -Destination $Dest -Force
                $found = $true
                break
            }
        }
        if (-not $found) {
            Write-Warning "$name not found in system fonts. Please download from https://fonts.google.com/noto and place in $Dest"
        }
    }

    Write-Host "Fonts successfully fetched into: $Dest"
    Get-ChildItem $Dest | Select-Object Name, Length
}
finally {
    if (Test-Path $TempDir) {
        Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
    }
}
