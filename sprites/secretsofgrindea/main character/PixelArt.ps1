param (
    [string]$InputPath = "input.png",
    [string]$OutputPath = "output.png",
    [string]$OutputResizedPath = "outputresized.png"
)

Add-Type -AssemblyName System.Drawing

# Easy modification: offset added to detected block size
$BlockSizeOffset = +0

function Colors-AreClose {
    param (
        [System.Drawing.Color]$c1,
        [System.Drawing.Color]$c2,
        [int]$threshold = 10
    )
    return ([math]::Abs($c1.R - $c2.R) -le $threshold) -and
           ([math]::Abs($c1.G - $c2.G) -le $threshold) -and
           ([math]::Abs($c1.B - $c2.B) -le $threshold)
}

function Get-DominantBlockSize {
    param ([System.Drawing.Bitmap]$bmp)

    $blockSizes = @()
    $scanRows = 5
    $startY = [math]::Floor($bmp.Height / 2) - [math]::Floor($scanRows / 2)

    for ($row = $startY; $row -lt ($startY + $scanRows); $row++) {
        $lastColor = $bmp.GetPixel(0, $row)
        $lastX = 0

        for ($x = 1; $x -lt $bmp.Width; $x++) {
            $color = $bmp.GetPixel($x, $row)
            if (-not (Colors-AreClose $color $lastColor)) {
                $size = $x - $lastX
                if ($size -ge 8 -and $size -le 100) {
                    $blockSizes += $size
                }
                $lastX = $x
                $lastColor = $color
            }
        }
    }

    if ($blockSizes.Count -eq 0) {
        throw "Could not detect block size — try a clearer image."
    }

    return [int](($blockSizes | Group-Object | Sort-Object Count -Descending | Select-Object -First 1).Name)
}

function Fix-PixelGrid {
    param (
        [System.Drawing.Bitmap]$bmp,
        [int]$BlockSize,
        [int]$ColorTolerance = 15  # Adjust color grouping tolerance here
    )

    $width = $bmp.Width
    $height = $bmp.Height
    $newBmp = New-Object System.Drawing.Bitmap $width, $height
    $graphics = [System.Drawing.Graphics]::FromImage($newBmp)

    # Dictionary to store canonical colors (key: "R,G,B", value: [System.Drawing.Color])
    $canonicalColors = @{}

    function Get-CanonicalColor {
        param ([System.Drawing.Color]$color)

        foreach ($key in $canonicalColors.Keys) {
            $existingColor = $canonicalColors[$key]
            if (Colors-AreClose $color $existingColor $ColorTolerance) {
                return $existingColor
            }
        }
        # No close color found, add new
        $newKey = "$($color.R),$($color.G),$($color.B)"
        $canonicalColors[$newKey] = $color
        return $color
    }

    for ($y = 0; $y -lt $height; $y += $BlockSize) {
        for ($x = 0; $x -lt $width; $x += $BlockSize) {
            $colors = @{}

            for ($i = 0; $i -lt $BlockSize; $i++) {
                for ($j = 0; $j -lt $BlockSize; $j++) {
                    $px = $x + $j
                    $py = $y + $i
                    if ($px -lt $width -and $py -lt $height) {
                        $color = $bmp.GetPixel($px, $py)
                        $key = "$($color.R),$($color.G),$($color.B)"
                        if ($colors.ContainsKey($key)) {
                            $colors[$key]++
                        } else {
                            $colors[$key] = 1
                        }
                    }
                }
            }

            $dominant = $colors.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 1
            $rgb = $dominant.Key.Split(',') | ForEach-Object { [int]$_ }
            $originalColor = [System.Drawing.Color]::FromArgb($rgb[0], $rgb[1], $rgb[2])

            # Get canonical (grouped) color
            $blockColor = Get-CanonicalColor -color $originalColor

            $brush = New-Object System.Drawing.SolidBrush $blockColor
            $graphics.FillRectangle($brush, $x, $y, $BlockSize, $BlockSize)
            $brush.Dispose()
        }
    }

    $graphics.Dispose()
    return $newBmp
}

function Resize-Image {
    param (
        [System.Drawing.Bitmap]$bmp,
        [int]$BlockSize
    )

    $newWidth = [math]::Floor($bmp.Width / $BlockSize)
    $newHeight = [math]::Floor($bmp.Height / $BlockSize)

    Write-Host "Resizing image from $($bmp.Width)x$($bmp.Height) to $newWidth x $newHeight"

    if ($newWidth -le 0 -or $newHeight -le 0) {
        throw "Resize dimensions invalid: $newWidth x $newHeight"
    }

    $pixelFormat = [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    $resizedBmp = New-Object System.Drawing.Bitmap ($newWidth), ($newHeight), $pixelFormat

    $graphics = [System.Drawing.Graphics]::FromImage($resizedBmp)

    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half

    $graphics.DrawImage($bmp, 0, 0, $newWidth, $newHeight)
    $graphics.Dispose()

    return $resizedBmp
}

# MAIN EXECUTION

if (-not (Test-Path $InputPath)) {
    throw "Input file not found: $InputPath"
}

$bmp = [System.Drawing.Bitmap]::FromFile($InputPath)

$blockSize = Get-DominantBlockSize -bmp $bmp
$finalBlockSize = $blockSize + $BlockSizeOffset
Write-Host "Detected Block Size: $blockSize px"
Write-Host "Using final Block Size (with offset): $finalBlockSize px"

$fixedBmp = Fix-PixelGrid -bmp $bmp -BlockSize $finalBlockSize -ColorTolerance 15
$fixedBmp.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "✅ Clean pixel grid saved to '$OutputPath'"

$resizedBmp = Resize-Image -bmp $fixedBmp -BlockSize $finalBlockSize
$resizedBmp.Save($OutputResizedPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "✅ Final resized image saved to '$OutputResizedPath'"

# Cleanup
$bmp.Dispose()
$fixedBmp.Dispose()
$resizedBmp.Dispose()
