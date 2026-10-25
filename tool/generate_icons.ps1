Add-Type -AssemblyName System.Drawing

function Draw-LogoPaths {
    param(
        [System.Drawing.Graphics]$g,
        [float]$offsetX,
        [float]$offsetY,
        [float]$scale
    )

    $blueBrush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#0960D5'))
    $pinkBrush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#FF007F'))

    # Helper function to transform point
    $p = {
        param([float]$px, [float]$py)
        return New-Object System.Drawing.PointF(($offsetX + $px * $scale), ($offsetY + $py * $scale))
    }

    # Blue Circle (Left dot)
    $bluePath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $bluePath.AddBezier((& $p 20.6294395 10.1695828), (& $p 20.6294395 15.7864719), (& $p 16.0145249 20.3418803), (& $p 10.3092127 20.3418803))
    $bluePath.AddBezier((& $p 10.3092127 20.3418803), (& $p 4.61216113 20.3418803), (& $p 0 15.7864719), (& $p 0 10.1695828))
    $bluePath.AddBezier((& $p 0 10.1695828), (& $p 0 4.55540841), (& $p 4.61216113 0), (& $p 10.3092127 0))
    $bluePath.AddBezier((& $p 10.3092127 0), (& $p 16.0145249 0), (& $p 20.6294395 4.55540841), (& $p 20.6294395 10.1695828))
    $bluePath.CloseFigure()
    $g.FillPath($blueBrush, $bluePath)
    $blueBrush.Dispose()
    $bluePath.Dispose()

    # Pink Circle (Right dot)
    $pinkPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $pinkPath.AddBezier((& $p 46.8292683 10.1695828), (& $p 46.8292683 15.7864719), (& $p 42.2171072 20.3418803), (& $p 36.5173021 20.3418803))
    $pinkPath.AddBezier((& $p 36.5173021 20.3418803), (& $p 30.8119899 20.3418803), (& $p 26.1970752 15.7864719), (& $p 26.1970752 10.1695828))
    $pinkPath.AddBezier((& $p 26.1970752 10.1695828), (& $p 26.1970752 4.55540841), (& $p 30.8119899 0), (& $p 36.5173021 0))
    $pinkPath.AddBezier((& $p 36.5173021 0), (& $p 42.2171072 0), (& $p 46.8292683 4.55540841), (& $p 46.8292683 10.1695828))
    $pinkPath.CloseFigure()
    $g.FillPath($pinkBrush, $pinkPath)
    $pinkBrush.Dispose()
    $pinkPath.Dispose()
}

function Create-RoundedRectPath {
    param(
        [float]$x,
        [float]$y,
        [float]$w,
        [float]$h,
        [float]$r
    )
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2.0
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

function Generate-TransparentLogo {
    param(
        [int]$size,
        [string]$outputPath
    )
    $dir = Split-Path -Parent $outputPath
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    $bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)

    # SVG geometry: width=46.8292683, height=20.3418803, aspect ~ 2.3:1
    # For a square canvas, fit logo horizontally with ~10% margin on each side
    $usableW = [float]($size * 0.82)
    $scale = $usableW / 46.8292683
    $drawW = 46.8292683 * $scale
    $drawH = 20.3418803 * $scale
    $offsetX = [float](($size - $drawW) / 2.0)
    $offsetY = [float](($size - $drawH) / 2.0)

    Draw-LogoPaths -g $g -offsetX $offsetX -offsetY $offsetY -scale $scale

    $g.Dispose()
    $bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Created transparent logo: $outputPath ($size x $size)"
}

function Generate-LauncherIcon {
    param(
        [int]$size,
        [string]$outputPath,
        [bool]$isRound = $false
    )
    $dir = Split-Path -Parent $outputPath
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    $bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)

    # Background: clean white surface with subtle soft rose rim
    $bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $pad = [float]($size * 0.04)
    $bgSize = [float]($size - ($pad * 2.0))

    if ($isRound) {
        $g.FillEllipse($bgBrush, $pad, $pad, $bgSize, $bgSize)
        $rimPen = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml('#EEDEE4'), [float]([Math]::Max(1.0, $size * 0.015)))
        $g.DrawEllipse($rimPen, $pad, $pad, $bgSize, $bgSize)
        $rimPen.Dispose()
    } else {
        $radius = [float]($size * 0.22) # Standard squircle radius for Android
        $bgPath = Create-RoundedRectPath -x $pad -y $pad -w $bgSize -h $bgSize -r $radius
        $g.FillPath($bgBrush, $bgPath)
        $rimPen = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml('#EEDEE4'), [float]([Math]::Max(1.0, $size * 0.015)))
        $g.DrawPath($rimPen, $bgPath)
        $rimPen.Dispose()
        $bgPath.Dispose()
    }
    $bgBrush.Dispose()

    # Draw logo centered in safe zone (54% of icon size)
    $usableW = [float]($size * 0.54)
    $scale = $usableW / 46.8292683
    $drawW = 46.8292683 * $scale
    $drawH = 20.3418803 * $scale
    $offsetX = [float](($size - $drawW) / 2.0)
    $offsetY = [float](($size - $drawH) / 2.0)

    Draw-LogoPaths -g $g -offsetX $offsetX -offsetY $offsetY -scale $scale

    $g.Dispose()
    $bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Created launcher icon: $outputPath ($size x $size, round=$isRound)"
}

# --- 1. Flutter Assets ---
Generate-TransparentLogo -size 512 -outputPath "E:\HerCare\assets\images\hercare_logo.png"
Generate-TransparentLogo -size 1024 -outputPath "E:\HerCare\assets\images\hercare_logo_1024.png"
Generate-TransparentLogo -size 1024 -outputPath "E:\HerCare\assets\images\2.0x\hercare_logo.png"
Generate-TransparentLogo -size 1536 -outputPath "E:\HerCare\assets\images\3.0x\hercare_logo.png"

# Copy SVGs to assets
if (!(Test-Path "E:\HerCare\assets\icons")) { New-Item -ItemType Directory -Path "E:\HerCare\assets\icons" -Force | Out-Null }
Copy-Item -Path "E:\HerCare\hercare-logo.svg" -Destination "E:\HerCare\assets\icons\hercare_logo.svg" -Force
Copy-Item -Path "E:\HerCare\hercare-logo.svg" -Destination "E:\HerCare\assets\images\hercare_logo.svg" -Force

# --- 2. Android Launcher Icons (Square / Rounded & Round) ---
$sizes = @{
    "mdpi" = 48
    "hdpi" = 72
    "xhdpi" = 96
    "xxhdpi" = 144
    "xxxhdpi" = 192
}

foreach ($density in $sizes.Keys) {
    $dim = $sizes[$density]
    $iconPath = "E:\HerCare\android\app\src\main\res\mipmap-$density\ic_launcher.png"
    $roundPath = "E:\HerCare\android\app\src\main\res\mipmap-$density\ic_launcher_round.png"
    Generate-LauncherIcon -size $dim -outputPath $iconPath -isRound $false
    Generate-LauncherIcon -size $dim -outputPath $roundPath -isRound $true
}

Write-Host "All assets and Android launcher icons successfully generated!"

