#Create SF2 object files for Usas2
#Shadow@Fuzzylogic
#20240304-20240730


[CmdletBinding()]
param
(	$manifestPath=".\Sf2LargeObjects.manifest",
	$name="areaSign.Karnimata",
	[switch]$append=$false,
	$destinationPath,
	$pixelFilePath,
	$frame
)


##### Globals #####

#[SF2]
$sf2SliceHeaderStructure=
@(	[pscustomobject]@{mandatory=$true;label="Width";offset=0x00;size=1;default=0x00};
	[pscustomobject]@{mandatory=$true;label="Height";offset=0x01;size=1;default=0x00};
	[pscustomobject]@{mandatory=$true;label="X";offset=0x02;size=1;default=0x00};
	[pscustomobject]@{mandatory=$true;label="Y";offset=0x03;size=1;default=0x00};
	[pscustomobject]@{mandatory=$true;label="Offset";offset=0x04;size=1;default=0x00};
)
$sf2SliceHeaderBinSize=($sf2SliceHeaderStructure.size|measure -Sum).sum


##### Includes #####
. .\Usas2-SharedFunctions.inc.ps1
. .\bmpfile-functions.inc.ps1


##### Functions #####

#search pattern in byte array. I'd like to use core .net function cus of its speed.
#in:  haystack(array), needle (array)
#out: -1, not found, else return index
function find-PatternInByteArray
{	[CmdletBinding()]
	param
	(	$hayStack,$hayStackWindowStart=0,$hayStackWindowLength=$hayStack.length,
		$needle,$needleWindowStart=0,$needleWindowLength=$needle.length
	)

	if ($hayStack.length -lt ($hayStackWindowStart+$hayStackWindowLength)) {write-error "Haystack Window out of range";exit}
	if ($needle.length -lt ($needleWindowStart+$needleWindowLength)) {write-error "Needle Window out of range";exit}
	if ($hayStackWindowLength -lt $needleWindowLength){return -1}

	#The quickest method is to use default .net functions, even if that includes full data conversion (todo: see if "span" would be posible here)
	$hayStackStr=[System.BitConverter]::ToString($hayStack,$hayStackWindowStart,$hayStackWindowLength)
	$NeedleStr=[System.BitConverter]::ToString($needle,$needleWindowStart,$needleWindowLength)
	$result=$hayStackStr.indexOf($needleStr)
	if ($result -eq -1) {return -1}
	return $result/3	#the .ToString conversion makes "nn-" of every byte *yeah, I know... bleh. 
}


# Return an MSX pal from a file (first 32 bytes) as an array of [color]=0x0grb
function get-MsxPaletteFromFile
{	param ($path)
	$pal=Get-Content $path -Encoding Byte
	$msxcoltab=[uint32[]]::new(16)
	for ($c=0;$c -lt 16;$c++)
	{	$grb=read-fromByteArray -data $pal -offset ($c*2) -size 2
		$msxcoltab[$c]=[uint32]$grb
	}
	return $msxcoltab
}


# Return an array with [colorBmp]=colorMSX
#in:	BmpFileObject, msxPallette(32bytes)
#out:	16bytes array with [index:BMPcolor]=MSXcolorIndex
function get-colorConversionTable
{	param ($bmpfile,$msxColTab)
	$ColorConverstionTable=[byte[]]::new(16)
	if ($bmpfile.numBitsPerPixel -le 8)
	{	if (($numColors=$bmpfile.NumColors) -gt 16) {$numColors=16} #force 16 colors
		write-verbose "Converting $numColors colors"
		for ($i=0;$i -lt $numcolors;$i++)
		{	$b=$bmpfile.colortable[$i*4+0]
			$g=[byte]($bmpfile.colortable[$i*4+1])
			$r=[byte]($bmpfile.colortable[$i*4+2])
			$msxRgb=[uint32]([math]::Round($g/255*7)-shl 8 -bor [math]::Round($r/255*7) -shl 4 -bor [math]::Round($b/255*7))
			#$rgb=[System.BitConverter]::ToUInt32($bmpfile.colortable,0) #(alternative)read 4bytes
			if (($msxcolor=$($msxcoltab.IndexOf([uint32]$msxrgb))) -ne -1)
			{	write-verbose "$i 0.$g.$r.$b -> $("{0:X4}" -f $msxrgb) -> $msxcolor)"
				$ColorConverstionTable[$i]=$msxcolor
			} else
			{	$ColorConverstionTable[$i]=0x0ff
			}
		}
	}
	return ,$ColorConverstionTable
}


#[SF2]
#new-sf2object
function new-sf2object
{	param
	(	$name="Default",
		$imageObject,
		$imageWidth=$imageObject.width,$imageHeight=$imageObject.height,
		$canvasX=0,$canvasY=0,$canvasWidth=$imageWidht,$canvasHeight=$imageHeight,
		$frameWidth=256,$frameHeight=136,
		$subjectX=0,$subjectY=0,$subjectWidth=$frameWidth,$subjectHeight=$frameHeight,
		$slices=1,
		$transparentColor,$fillColor
	)
	$frameCountHorizontal=$canvasWidth/$frameWidth
	$frameCountVertical=$canvasHeight/$frameHeight
	$frameCount=$frameCountHorizontal*$frameCountVertical
	$sliceCount=$slices*$frameCount
	$sf2Object=[PSCustomObject]`
	@{	type="SF2";name=$name;
		image=[pscustomObject]@{object=$imageObject;width=$imageWidth;height=$imageHeight}; #the actual bmp image
		canvas=[pscustomObject]@{x=$canvasX;y=$canvasY;width=$canvasWidth;height=$canvasHeight}; #the working canvas
		frame=[pscustomObject]@{width=$frameWidth;height=$frameHeight;numHorizontal=$frameCountHorizontal;numVertical=$frameCountVertical;count=$frameCount}; #frames on the canvas
		subject=[pscustomObject]@{x=$subjectX;y=$subjectY;width=$subjectWidth;height=$subjectHeight;numSlices=$slices}; #the subject we're interrested in 
		slice=[pscustomObject]@{count=$sliceCount;list=[pscustomobject[]]::new($sliceCount)};
		transparentColor=$transparentColor;fillColor=$fillcolor
	}
	return ,$sf2Object
}

#[SF2]
# return the frame position within the SF2 image as both X,Y and pixelarrayOffset 
function get-Sf2FramePosition
{	param ($sf2object,$frame=0)
	$frameX=$frame %$sf2object.frame.numHorizontal * $sf2object.frame.width +$sf2object.canvas.x
	$frameY=[math]::floor($frame/$sf2object.frame.numHorizontal)*$sf2object.frame.height +$sf2object.canvas.y
	$frameOffset=$sf2object.image.object.numBitsPerPixel/8*$framex +($bmpfile.height-1-$frameY)*$bmpfile.rowsize
	return ,[pscustomobject]@{frame=$frame;x=$framex;y=$frameY;offset=$frameOffset}
}

#[SF2]
#if color not in color table or is transparent, return NULL else return new color byte
#if one color is valid, fill the other with $fillcolor
#4bit pixels, like scr5 only
#out: $null=not found, else new color is returned
function get-msxpixel
{	param ([byte]$pixelColor,$transparentColor,$ColorConversionTable,$fillColor)
	$cL=$pixelColor -band 0x0f;$lsb=$ColorConversionTable[$cL]
	if ($fillColor -eq $null -and ($cL -eq $transparentColor -or $lsb -eq 0xff)) {return $NULL}
	# if ($cL -eq $transparentColor) {$lsb=$c} else {$lsb=$ColorConversionTable[$c]}
	# if (($lsb=$ColorConversionTable[$c]) -eq 0x0ff) {return $NULL}

	$cH=$pixelColor -shr 4 -band 0x0f;$msb=$ColorConversionTable[$cH]
	if ($fillColor -eq $null -and ($cH -eq $transparentColor -or $msb -eq 0xff)) {return $NULL}
	# if ($c -eq $transparentColor) {$msb=$c} else {$msb=$ColorConversionTable[$c]}
	# if (($msb=$ColorConversionTable[$c]) -eq 0x0ff) {return $NULL}

	if (($msb -eq 0xff -or $cH -eq $transparentColor) -and ($lsb -eq 0xff -or $cL -eq $transparentColor)) {return $NULL}
	if ($cL -eq $transparentColor -or $lsb -eq 0xFF) {$lsb=$fillColor}
	elseif ($cH -eq $transparentColor -or $msb -eq 0xff) {$msb=$fillColor}
	return [byte]($msb -shl 4 -bor $lsb)
}

#[SF2]
#Locatie subject in frame
#in:	$sf2object, $frame
#		optional: $onlyVertical (don't include X and width, wich makes the function exit faster)
function get-sf2FrameSubjectLocation
{	param ($sf2object,$frame,$onlyVertical=$true)
	$transparentColor=$sf2object.transparentColor
	$fillColor=$sf2object.fillColor
	$framePos=get-Sf2FramePosition -sf2object $sf2object -frame $frame
	$widthBytes=($sf2object.image.object.numBitsPerPixel/8*$sf2object.frame.width)
	$widthBytes
	$pix=@{top=[uint32]$sf2object.frame.height;bottom=[uint32]0;left=[uint32]$widthBytes;right=[uint32]0;width=0;height=0;}
	for ($y=0;$y -lt $sf2object.frame.height;$y++)
	{	$rowOffset=$framepos.offset -($y*$sf2object.image.object.rowsize)
		$found=$false
		for ($x=0;$x -lt $widthBytes;$x++)
		{	$pixelByte=get-msxpixel -pixelColor $sf2object.image.object.pixelarray[$rowOffset+$x] -transparentColor $transparentColor -fillColor $fillColor -ColorConversionTable $ColorConversionTable
			if ($pixelbyte)
			{	if ($onlyVertical) {$x=$widthbytes;}
				if ($x -lt $pix.left) {$pix.left=$x}
				if ($x -gt $pix.right) {$pix.right=$x}
				$found=$true
			}
		}
		if ($found)
		{	if ($y -lt $pix.top) {$pix.top=$y}
			if ($y -gt $pix.bottom) {$pix.bottom=$y}
		}
	}
	$pix.width=$pix.right-$pix.left+1;$pix.height=$pix.bottom-$pix.top+1
	return ,$pix
}

#[SF2]
# Process one SF2 slice
# in:	SF2object, FramePixel, Frame, Slice
# 		optional: $subjectY, $subjectHeight (if ommited, the default object subject location will be used)
# out:	$sliceMeta object, framePixel array appended with new found pixels
# uses globals: $sf2SliceHeaderBinS
function convert-sf2Slice
{	param	($sf2object,$framePixels,$Frame,$slice,$subjectY,$subjectHeight)
	Write-verbose ">> convert-sf2Slice -frame $frame -slice $slice"
	#setup
	$MSXscreen5=[pscustomObject]@{width=256;height=256;numBitsPerPixel=4;numCol=16;}
	$sliceMeta=[pscustomobject]@{id=($frame*$sf2object.subject.numSlices+$slice);frame=$frame;slice=$slice;index=$sf2SliceHeaderBinSize;pixelArrayCount=0;redundancyCount=0;data=[byte[]]::new(16KB)} #max 16KB for MSX
	$bmpfile=$sf2object.image.object
	$transparentColor=$sf2object.transparentColor
	$fillColor=$sf2object.fillColor
	
	$subjectXBytes=($bmpfile.numBitsPerPixel/8*$sf2object.subject.x)
	$subjectWidth=$sf2object.subject.width
	$widthBytes=($bmpfile.numBitsPerPixel/8*$subjectWidth);write-verbose "Row width in bytes: $widthbytes"
	$incBytesX=$bmpfile.numBitsPerPixel/4; #write-verbose "IncBytesX: $incbytesX" #1=4bpp,2=8bpp
	if (-not $subjectY) {$subjectY=$sf2object.subject.y} #if not specified, take the default subjectY and height
	if (-not $subjectHeight) {$subjectHeight=$sf2object.subject.height}
	
	$sliceHeight=[math]::Floor($subjectHeight/$sf2object.subject.numSlices)
	$sliceY=$slice*$sliceHeight
	if ($slice -eq $sf2object.subject.numSlices-1) {$sliceheight=$subjectHeight-$slice*$sliceHeight}
	
	$framePos=get-Sf2FramePosition -sf2object $sf2object -frame $frame
	$pixelArrayOffset=($bmpfile.height-1 -$framePos.y -$subjecty -$sliceY)*$bmpfile.rowsize +($bmpfile.numBitsPerPixel/8*($framepos.x+$subjectX))
	write-verbose "Slice $slice starts at Y=$($framePos.y +$subjectY +$sliceY), heigth is $sliceHeight"
	$sliceMinX=$widthBytes;$sliceMaxX=0;$offsetX=-1;$pixelIndex=0;$lineSkip=0
	$whiteSpaceCounter=0;$pixelCounter=0;$edge=($MSXscreen5.width-$subjectWidth)*$MSXscreen5.numBitsPerPixel/8 #(256-$width)/2;
	$flagPixel=$false;$flagSpace=$false;$flagLineSkip=$false;$flagNext=$false;$flagWritePixel=$false;$flagEod=$false;

	function commit-sf2record #yes, this is a sub function
	{	param ($distanceToNext)
		if (($whiteSpaceCounter+$lastPixelCount) -gt 255) {write-error "Pixel distance to high (>255) at frame $frame, slice $slice, y $y";exit}
		$sliceMeta.data[$sliceMeta.Index]=[byte]($distanceToNext); #NextPixelDistance
		$sliceMeta.Index+=4
	}

	#Run through pixelArray
	$y=0;$x=0
	while (($y -lt $sliceHeight) -and ($x -lt $widthBytes))
	{	if ($x -eq 0) {$rowOffset=$pixelArrayOffset -($y*$bmpfile.rowsize)}
		if ($bmpfile.numBitsPerPixel -eq 4) {$bmpPixel=$bmpfile.pixelarray[$rowOffset+$subjectXBytes+$x]} #4bpp
		elseif ($bmpfile.numBitsPerPixel -eq 8) {$bmpPixel=($bmpfile.pixelarray[$rowOffset+$subjectXBytes+$x] -shl 4 -band 0xf0) -bor ($bmpfile.pixelarray[$rowOffset+$subjectXBytes+$x+1] -band 15)} #8bpp
		$pixelByte=get-msxpixel -pixelColor $bmpPixel -transparentColor $transparentColor -fillColor $fillColor -ColorConversionTable $ColorConversionTable

		if ($pixelByte -ne $null)	
		{	if ($pixelCounter -eq 0) {$pixelIndex=$framePixels.Index} #save the startIndex of this new string of pixels
			if ($framepixels.index -ge 16KB) {write-error "Max dat size of 16KB reached.";exit}
			$framePixels.data[$framePixels.Index]=$pixelByte;$framePixels.Index++
			if ($x -lt $sliceMinX) {$sliceMinX=$x}
			if ($x -gt $sliceMaxX) {$sliceMaxX=$x}
			if ($offsetX -eq -1) {$offsetX=$whiteSpaceCounter*2;$whiteSpaceCounter=0} #first time pixel encounter
			if ($whiteSpaceCounter)	{$flagNext=$true;}
			if ($x -ge ($widthBytes-1)) #End Of Line, break this pixelrun
			{	$flagWritePixel=$true;
				if ($flagNext) {commit-sf2record -distanceToNext ($whiteSpaceCounter+$lastPixelCount);$flagnext=$false;$whiteSpaceCounter=0;} #clean up open run
			} 
			$pixelCounter++
			$flagPixel=$true
		} else
		{	$whiteSpaceCounter++
			if ($pixelCounter) {$flagWritePixel=$true}
			$flagSpace=$true #un-used atm
		}
		
		$x+=$incBytesX
		if ($x -ge $widthBytes)
		{	$x=0;$y++
			if (-not $flagPixel) {$sliceY++;$whiteSpaceCounter=0;$lineSkip++;$flagLineSkip=$true;} #if there are no pixels found yet, skip this row and increase startY
			else {$whiteSpaceCounter+=$edge} #padding for edge distances to nextPixelDistance
			if ($y -ge $sliceHeight)
			{	$flagEod=$true
				if ($pixelCounter) {$flagWritePixel=$true;$flagNext=$true;} #remaining pixel on last line
			}
		}
		
		if ($flagWritePixel) #write pixelCount
		{	$sliceMeta.data[$sliceMeta.Index+1]=[byte]($PixelCounter) #PixelArrayLength (numpix)
			#Look in history to remove redundancy
			$pixelPointer=find-PatternInByteArray -hayStack $framePixels.data -hayStackWindowStart 0 -hayStackWindowLength $pixelIndex -needle $framePixels.data -needleWindowStart $pixelIndex -needleWindowLength $pixelCounter 
			if ($pixelPointer -ne -1) {$framePixels.Index=$pixelIndex; $sliceMeta.redundancyCount++}
			else {$pixelPointer=$pixelIndex;}
			write-toByteArray -offset ($sliceMeta.Index+2) -size 2 -data $sliceMeta.data -value $pixelPointer; #pointer to PixelArray
			$lastPixelCount=$pixelCounter
			$sliceMeta.pixelArrayCount++
			$pixelcounter=0	#reset the pixel counter
			$flagWritePixel=$false
		}

		if ($flagNext) #write record
		{	#if (($whiteSpaceCounter+$lastPixelCount) -gt 255) {write-error "Pixel distance to high (>255) at frame $frame, slice $slice, y $y";exit}
			if (-not $flagEod) {$n=$whiteSpaceCounter+$lastPixelCount} else {$n=0}
			#$sliceMeta.data[$sliceMeta.Index]=[byte]($n); #NextPixelDistance
			#$sliceMeta.Index+=4
			commit-sf2record -distanceToNext $n
			$whiteSpaceCounter=0
			$flagNext=$false
		}
	}

	if ($flagLineSkip)	{write-verbose "$lineSkip lines skipped";}
	if ($whiteSpaceCounter) {$sliceMeta.Index+=4}
	$sf2SliceHeader=[pscustomobject]@{Width=[byte]($sliceMaxX-$sliceMinX+1)*2;Height=[byte]($sliceHeight-$lineskip);X=[byte]($sliceMinX*2+$edge);Y=([byte]$sliceY+$subjecty);offset=($offsetX+$edge)}
	write-structData -byteArray $sliceMeta.data -struct $sf2SliceHeaderStructure -offset 0 -data $sf2SliceHeader
	write-verbose $sf2SliceHeader
	Write-verbose "Current dat size: $($framePixels.Index) bytes"
	Write-verbose "Slice size: $($sliceMeta.Index) bytes"
	write-verbose "Number of pixel arrays: $($sliceMeta.pixelArrayCount)"
	write-verbose "Number of redundant pixel arrays: $($sliceMeta.redundancyCount)"
	return $sliceMeta
}


#[SF2]
#Convert all frame slices
#in:	sf2Object, Frame, FramePixels array
#out:	$sf2object.slice.list array filled with sliceMeta data
function convert-sf2FrameAllSlices
{	param ($sf2object,$framepixels,$frame)
	$numSlices=$sf2object.subject.numSlices

	if ($sf2object.subject.Y -eq -1 -or $sf2Object.subject.y -eq $null) 
	{	$subjectLocation=get-sf2FrameSubjectLocation -sf2object $sf2object -frame $frame
		$subjectY=$subjectLocation.Top;$subjectHeight=$subjectLocation.height;
		write-verbose "Retreived subject location: Y=$($subjectlocation.top) h=$($subjectLocation.height)"
	} else
	{	$subjectY=$sf2object.subject.Y;$subjectHeight=$sf2object.subject.height
	}

	for ($i=0;$i -lt $numSlices;$i++)
	{	$sliceMeta=convert-sf2Slice -sf2object $sf2object -framePixels $framePixels -Frame $frame -slice $i -subjectY $subjectY -subjectHeight $subjectHeight
		$sf2object.slice.list[$sliceMeta.id]=$sliceMeta
		# [System.BitConverter]::tostring($listfile.slices[$i].data[0..4])
		# [System.BitConverter]::tostring($listfile.slices[$i].data[5..$listfile.slices[$i].index])
	}
}


#[SF2]
#Convert all frames and all slices
#in:	sf2Object, FramePixels array
#out:	$sf2object.slice.list array filled with sliceMeta data
function convert-sf2AllFramesSlices
{	param ($sf2object,$framepixels,$frameselect=-1)
	if ($frameselect -eq -1)
	{	for ($frame=0;$frame -lt $sf2object.frame.count;$frame++)
		{	convert-sf2FrameAllSlices -sf2object $sf2object -framepixels $framePixels -frame $frame
		}
	} else
	{	foreach ($frame in $frameselect)
		{	convert-sf2FrameAllSlices -sf2object $sf2object -framepixels $framePixels -frame $frame
		}
	}
}


#[SF2]
#Creat a pointerTable for the slice lists
#in:	[object]sf2Object
#out:	[array]pointerTable
function new-sf2SlicePointerTable
{	param ($sf2object)
	$numSlices=$sf2object.slice.count;
	$tableLength=2*$numSlices
	$dataIndex=$tableLength
	$pointerTable=[byte[]]::new($tableLength);
	for ($i=0;$i -lt $numSlices;$i++)
	{	write-toByteArray -data $pointerTable -offset ($i*2) -size 2 -value $dataIndex
		$dataIndex+=$sf2object.slice.list[$i].index
	}
	return $pointerTable
}


#[SF2]
#Creat a pointerTable for all frames@slice0
#in:	[object]sf2Object
#out:	[array]pointerTable
function new-sf2FramePointerTable
{	param ($sf2object)
	$numSlices=$sf2object.slice.count;
	$numFrames=$sf2object.frame.count;
	$tableLength=2*$numFrames
	$dataIndex=$tableLength
	$pointerTable=[byte[]]::new($tableLength);
	$frame=0
	for ($i=0;$i -lt $numSlices;$i++)
	{	if ($i%$sf2object.subject.numSlices -eq 0)
		{	write-toByteArray -data $pointerTable -offset ($frame*2) -size 2 -value $dataIndex
			$frame++
		}
		$dataIndex+=$sf2object.slice.list[$i].index
	}
	return $pointerTable
}


#[SF2]
#return Slice meta data as object
function get-sf2SliceMeta
{	param ($sf2object,$frame=0,$slice=0)
	$sliceNumber=$sf2object.subject.numSlices*$frame+$slice
	if (-not $sf2object.slice.list[$sliceNumber])
	{	return $false
	}	else
	{	$sliceHeader=$sf2object.slice.list[$sliceNumber].data[0..5]
		$dataLength=$sf2object.slice.list[$sliceNumber].index
		$header=@{Width=$sliceHeader[0];height=$sliceHeader[1];X=$sliceHeader[2];Y=$sliceHeader[3];offsetX=$sliceHeader[4]}
		
		$index=5;$bytes=$sf2object.slice.list[$sliceNumber].data
		$data=[System.Collections.Generic.List[pscustomobject]]::new()
		while ($index -lt $sf2object.slice.list[$sliceNumber].index)
			{	$data.add([pscustomobject]@{next=$bytes[$index];width=$bytes[$index+1];pointer=([uint16]$bytes[$index+3] -shl 8) +$bytes[$index+2]})
				$index+=4
			}
		return ,[pscustomobject]@{header=$header;data=$data}
	}
}


#[SF2]
#return an .asm list of a slice
function get-sf2SliceMetaAsmText
{	param ($sf2object,$slice=0,$frame=0)
	# write "; Frame $frame, Slice $slice"
	write "$($sf2object.name)_$frame`_$slice`:`t; Frame $frame, Slice $slice"
	if ($data=get-sf2SliceMeta -sf2object $sf2object -frame $frame -slice $slice)
	{	write "DB`t$($data.header.width),$($data.header.height),$($data.header.x),$($data.header.y),$($data.header.offsetX) ;w,h,x,y,o"
		foreach ($this in $data.data)
		{	write "DW`t0x$("{0:X4}" -f (([uint16]$this.width -shl 8) +$this.next)),base+0x$("{0:X4}" -f $this.pointer)"
		}
	}
}


#[SF2]
#Save SF2 object meta data as an .asm text file
function export-Sf2MetaAsmText
{	param ($sf2object,$path)
	write-verbose "Writing ASM text file $path"
	Set-Content -path $path -value ";SF2object" -Encoding Ascii
	for ($frame=0;$frame -lt $sf2object.frame.count;$frame++)
	{	for ($slice=0;$slice -lt $sf2object.subject.numslices;$slice++)
		{	get-sf2SliceMetaAsmText -sf2object $sf2object -slice $slice -frame $frame|out-file $asmfile -Append -Encoding ascii
		}
	}
}


#[SF2]
#Save SF2 object  data as .dat (bin) file
function export-Sf2PixelData
{	param ($framePixels,$path)
	write-verbose "Writing DAT file $path"
	$framePixels.data[0..$framePixels.Index]|Set-Content -Path $path -Encoding byte # pixels
	write-verbose "dat file size: $($framePixels.Index) bytes"
}


#[SF2]
#Export the slices as .lst (bin) file
function export-sf2MetaData
{	param ($Sf2object,$pointerTable,$path)
	write-verbose "Writing LST file $path"
	if (-not ($path=Resolve-newPath $path)) {exit;}
	if (-not ($fs=[io.file]::Create($path)))
	{	Write-Error "Could not create file $path"
	} else
	{	$fs.write($pointerTable,0,$pointerTable.length)	#.lst pointers
		$sf2object.slice.list|%{if($_){$fs.write($_.data,0,$_.index)}}	# .lst slices
		write-verbose "lst file size: $($fs.length) bytes"
		$fs.close()
	}
}



##### Main: #####
if (-not $manifestPath) {write-error "Please provide the location of a manifest file";exit}
if (-not $name) {write-error "Please provide the name of the object";exit}
Write-host "Manifest: $manifestpath :: $name"
$text=gc $manifestPath
$manifest=Invoke-Expression "@{$text}.$name" #turn the manifest into a hash table
$global:manifest=$manifest

if (-not $destinationPath){if ( -not ($destinationPath=($manifest.destinationPath))) {$destinationPath=".\"}}
write-verbose "Destination Path: $destinationPath"
#Dat file
	if ($pixelFilePath) {$datFile=$pixelFilePath}
	elseif ($manifest.pixelFilePath) {$datfile=$manifest.pixelFilePath}
	else {$datFile="$($manifest.name).dat"}
	if (-not (Split-Path $datFile -Parent)) {$datFile=join-path -path $destinationPath -ChildPath $datFile}
#lst file
	if ($listFilePath) {$lstFile=$listFilePath}
	elseif ($manifest.listFilePath) {$lstfile=$manifest.listFilePath}
	else {$lstFile="$($manifest.name).lst"}
	if (-not (Split-Path $lstFile -Parent)) {$lstFile=join-path -path $destinationPath -ChildPath $lstFile}

$AsmFile="$destinationPath\$($manifest.name).asm"
Write-verbose "Pixel file: $datfile"
Write-verbose "List file: $lstfile"
Write-verbose "Asm text file: $asmfile"

$framePixels=@{index=0;data=[byte[]]::new(16KB)}
if ($append)
{	if (-not ($path=Resolve-Path $datfile)) {exit;}
	write-verbose "Using $path as pixels data file"
	if (-not ($fs=[io.file]::OpenRead($path))) {exit}
	write-verbose "file Size: 0x$("{0:X8}" -f $fs.length)"
	[void]$fs.read($framePixels.data,0,$fs.length)
	$framePixels.index=$fs.length
	$fs.close()
}

$bmpfile=import-bmpFile -path $manifest.imagePath
$global:bmpfile=$bmpfile
$msxcoltab=get-MsxPaletteFromFile -path $manifest.palettePath
$global:ColorConversionTable=get-colorConversionTable -bmpfile $bmpfile -msxColTab $msxcoltab
$global:sf2object=$sf2object=new-sf2object @manifest -imageObject $bmpfile
# $global:sf2object=$sf2object=new-sf2object -name $manifest.name -imageObject $bmpfile `
# 	-canvasX $manifest.canvasX -canvasY $manifest.canvasY -canvasWidth $manifest.canvasWidth -canvasHeight $manifest.canvasHeight`
# 	-subjectX $manifest.subjectX -subjectWidth $manifest.subjectWidth -subjectY $manifest.subjectY -subjectHeight $manifest.subjectHeight`
# 	-frameWidth $manifest.frameWidth -frameHeight $manifest.frameHeight`
# 	-slices $manifest.slices`
# 	-transparentColor $manifest.transparentcolor -fillColor $manifest.fillColor
# exit

if ($frame -ne $Null) {convert-sf2FrameAllSlices -sf2object $sf2object -framepixels $framePixels -frame $frame}
else {convert-sf2AllFramesSlices -sf2object $sf2object -framepixels $framePixels}

export-Sf2MetaAsmText -sf2object $sf2object -path $asmfile

#Currently, store a slice pointer table.
# $pointerTable=new-sf2FramePointerTable -sf2object $sf2object
# $msg="Frame pointerTable: ";for ($i=0;$i -lt $sf2object.frame.count;$i++) {$msg+=[string]([System.BitConverter]::ToInt16($pointerTable,$i*2))+","};write-verbose $msg
$pointerTable=new-sf2SlicePointerTable -sf2object $sf2object
# $msg="Slice pointerTable: ";for ($i=0;$i -lt $sf2object.slice.count;$i++) {$msg+=[string]([System.BitConverter]::ToInt16($pointerTable,$i*2))+","};write-verbose $msg

export-Sf2PixelData -framePixels $framePixels -path $datfile
export-sf2MetaData -Sf2object $sf2object -pointerTable $pointertable -path $lstFile

#exit
#tests for Ro only :)
copy-item $lstfile -Destination "C:\Users\rvand\OneDrive\Documents\openMSX\DirAsDisk\frame.lst"
copy-item $datfile -Destination "C:\Users\rvand\OneDrive\Documents\openMSX\DirAsDisk\frame.dat"
