# Generates img/noise.png — a 200x200 grayscale film-grain texture with
# subtle vertical bands and CRT scan-lines baked in, so the page needs only
# ONE cheap fixed layer (no SVG feTurbulence, no mix-blend-mode).
Add-Type -AssemblyName System.Drawing

$size = 200
$outDir = Join-Path $PSScriptRoot "..\img"
$outPath = Join-Path $outDir "noise.png"

$bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$rng = New-Object System.Random

for ($y = 0; $y -lt $size; $y++) {
    # Horizontal CRT line: every 6th row gets darker.
    $crtLine = ($y % 6) -eq 0
    for ($x = 0; $x -lt $size; $x++) {
        $v = 120 + $rng.Next(0, 100)   # grain: ~120..219 range
        if ($crtLine) { $v -= 30 }
        # Vertical bands like the old body::after gradients:
        # strong band at 50%, faint bands at 20% and 80%.
        if ($x -eq [int]($size * 0.50)) { $v += 16 }
        elseif ($x -eq [int]($size * 0.20)) { $v += 6 }
        elseif ($x -eq [int]($size * 0.80)) { $v += 6 }
        $v = [Math]::Max(0, [Math]::Min(255, $v))
        $bmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $v, $v, $v))
    }
}

$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output "Saved: $outPath"
