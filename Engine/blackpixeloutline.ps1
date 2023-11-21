# Load the System.Drawing assembly
Add-Type -AssemblyName System.Drawing

# Input and output file paths
$inputFilePath = "BattleMonstersSpriteSheet9.bmp"
$outputFilePath = "BattleMonstersSpriteSheet9output.bmp"
$backgroundColor = "#52184A"

# Function to add a black pixel to the left, right, above, or below a specified position
function Add-BlackPixel($bitmap, $x, $y, $direction) {
    $newX = $x
    $newY = $y

    switch ($direction) {
        "Left" { $newX = $x - 1 }
        "Right" { $newX = $x + 1 }
        "Up" { $newY = $y - 1 }
        "Down" { $newY = $y + 1 }
    }

    $bitmap.SetPixel($newX, $newY, [System.Drawing.Color]::Black)
}

# Function to convert a hex color code to System.Drawing.Color
function Get-ColorFromHex($hexColor) {
    $red = [convert]::ToInt32($hexColor.Substring(1,2), 16)
    $green = [convert]::ToInt32($hexColor.Substring(3,2), 16)
    $blue = [convert]::ToInt32($hexColor.Substring(5,2), 16)

    [System.Drawing.Color]::FromArgb(255, $red, $green, $blue)
}

# Load the input image
$image = [System.Drawing.Bitmap]::FromFile($inputFilePath)

# Create a copy of the input image
$outputImage = $image.Clone()

# Get the background color
$bgColor = Get-ColorFromHex $backgroundColor

# Flag to check if a non-background and non-black pixel is found
$nonBackgroundNonBlackFound = $false

# Loop through each pixel in the image
for ($x = 0; $x -lt $image.Width; $x++) {
    for ($y = 0; $y -lt $image.Height; $y++) {
        $pixelColor = $image.GetPixel($x, $y)

        # Check if the pixel color is not background and not black
        if ($pixelColor.ToArgb() -ne $bgColor.ToArgb() -and
            $pixelColor.ToArgb() -ne [System.Drawing.Color]::Black.ToArgb()) {

            # Check if the pixel to the left is background
            if ($x - 1 -ge 0 -and $image.GetPixel($x - 1, $y).ToArgb() -eq $bgColor.ToArgb()) {
                Add-BlackPixel -bitmap $outputImage -x $x -y $y -direction "Left"
                $nonBackgroundNonBlackFound = $true
            }

            # Check if the pixel to the right is background
            if ($x + 1 -lt $image.Width -and $image.GetPixel($x + 1, $y).ToArgb() -eq $bgColor.ToArgb()) {
                Add-BlackPixel -bitmap $outputImage -x $x -y $y -direction "Right"
                $nonBackgroundNonBlackFound = $true
            }

            # Check if the pixel above is background
            if ($y - 1 -ge 0 -and $image.GetPixel($x, $y - 1).ToArgb() -eq $bgColor.ToArgb()) {
                Add-BlackPixel -bitmap $outputImage -x $x -y $y -direction "Up"
                $nonBackgroundNonBlackFound = $true
            }

            # Check if the pixel below is background
            if ($y + 1 -lt $image.Height -and $image.GetPixel($x, $y + 1).ToArgb() -eq $bgColor.ToArgb()) {
                Add-BlackPixel -bitmap $outputImage -x $x -y $y -direction "Down"
                $nonBackgroundNonBlackFound = $true
            }
        }
    }
}

# Save the output image if a non-background and non-black pixel is found
if ($nonBackgroundNonBlackFound) {
    $outputImage.Save($outputFilePath)
    Write-Host "Black pixels added successfully."
} else {
    Write-Host "No suitable pixels found. Output image not created."
}
