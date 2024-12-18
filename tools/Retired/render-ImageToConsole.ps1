#region Parameters

[CmdletBinding(DefaultParameterSetName = "Normal")]
param(
	[Parameter(Mandatory, ParameterSetName = "Normal")]
	[Parameter(Mandatory, ParameterSetName = "Resize")]
	[Parameter(Mandatory, ParameterSetName = "FillMode")]
	[String]$Path,
	
	[Parameter(Mandatory, ParameterSetName = "FillMode")]
	[ValidateSet("Stretch", "ProportionalWidth", "ProportionalHeight")]
	[String]$FillMode,
	
	[Parameter(Mandatory, ParameterSetName = "Resize")]
	[Int]$Width,
	
	[Parameter(Mandatory, ParameterSetName = "Resize")]
	[Int]$Height
)

#endregion

#region Functions

function RenderImage([System.Drawing.Image]$Image)
{
	[Console]::CursorVisible = $false
	for ($y = 0; $y -lt $Image.Height; $y += 2)
	{
		$pixelStrings = for ($x = 0; $x -lt $Image.Width; $x++)
		{
			$f = $Image.GetPixel($x, $y)
			"$escape[38;2;$($f.R);$($f.G);$($f.b)m"
			
			if ($y -lt $Image.Height - 1)
			{
				$b = $Image.GetPixel($x, $y + 1)
				"$escape[48;2;$($b.R);$($b.G);$($b.B)m"
			}
			
			$halfCharString
		}
		[String]::Join('', $pixelStrings + "$escape[0m")
	}
	[Console]::CursorVisible = $true
}

function ResizeImage([System.Drawing.Image]$Image, $NewWidth, $NewHeight)
{
	return $img.GetThumbnailImage($NewWidth, $NewHeight, $null, [IntPtr]::Zero)
}

function LoadImage()
{
	$urlRegex = "^http[s]?://"
	if ($Path -match $urlRegex)
	{
		$webClient = [System.Net.WebClient]::new()
		$imageStream = [System.IO.MemoryStream]::new($webClient.DownloadData($Path))
		$webClient.Dispose()
	}
	else
	{
		$absolutePath = Resolve-Path $Path
		$imageStream = [System.IO.File]::OpenRead($absolutePath)
	}
	$img = [System.Drawing.Image]::FromStream($imageStream, $false, $false)
	$imageStream.Dispose()
	return $img
}

#endregion

#region Main flow

[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

$escape = [Char]0x1B
$halfCharString = [Char]0x2580

$img = LoadImage

switch ($PSCmdlet.ParameterSetName)
{
	"Resize"
	{
		$img = ResizeImage -Image $img -NewWidth $Width -NewHeight $Height
	}
	"FillMode"
	{
		switch ($FillMode)
		{
			"Stretch"
			{
				$w = [Console]::WindowWidth
				$h = [Console]::WindowHeight * 2
			}
			"ProportionalWidth"
			{
				$w = [Console]::WindowWidth
				$h = ($img.Height / $img.Width) * [Console]::WindowWidth
			}
			"ProportionalHeight"
			{
				$w = ($img.Height / $img.Width) * [Console]::WindowHeight * 2
				$h = [Console]::WindowHeight * 2
			}
		}
		
		$img = ResizeImage -Image $img -NewWidth $w -NewHeight $h
	}
}

RenderImage -Image $img 

$img.Dispose()

#endregion