[CmdletBinding()]
param
(	$source,$fixedPalette,$targetScreen5
)

#npx convertgfx --source ..\grapx\sourcefiles\GfxObjectsForVram.bmp  --slice.x 0 --slice.y 0 --slice.width 128 --slice.height 16 --fixedPalette "..\grapx\tilesheets\pollux.tiles.pl" --targetScreen5 ..\grapx\016-PlatformMovingSmallOmnidirectional.sc5.gfx
#npx convertgfx --source ..\grapx\sourcefiles\GfxObjectsForVram.bmp  --slice.x 0 --slice.y 16 --slice.width 56 --slice.height 31 --fixedPalette "..\grapx\tilesheets\karnimata.tiles.pl" --targetScreen5 ..\grapx\020-ratFaceBatSpawner.sc5.gfx
#npx convertgfx --source ..\grapx\sourcefiles\GfxObjectsForVram.bmp  --slice.x 168 --slice.y 16 --slice.width 54 --slice.height 21 --fixedPalette "..\grapx\tilesheets\karnimata.tiles.pl" --targetScreen5 ..\grapx\129-hugeSpider.sc5.gfx

<#
Usage: npx convertgfx [<options>] [resources.json]

Options:
  --help           Show this help text
  --source         Input BMP or PNG file.
  --targetScreen5  Output raw screen 5 pixel data file.
  --targetPalette  Output raw palette data file.
  --targetSC5      Output MSX-BASIC format .SC5 image file to use with BLOAD ,S.
  --targetBMP      Output BMP-format file for debugging.
  --path           Base path to prefix to every file path.
  --group          Group of images to process, with options array, inheriting from parent.
  --gamma          Gamma to use when converting, default 2.2.
  --slice          Take a slice of the image, with dimensions {x: …, y: …, width: …, height: …}.
  --swizzlePalette Map palette to new positions, with new indices array.
  --prunePalette   De-duplicate and remove unused palette colours, if true.
  --fixedPalette   Fix colour positions in palette, with [r, g, b] array or raw palette data file.

The command-line options correspond to JSON fields.
When options are specified the resources json is optional.
If a resources json is provided, the options specify overrides.
Options can use a "." to give a path into sub-objects/arrays.
E.g. --slice.height 100 --group.0.path ../images
#>

npx convertgfx --source $bmpfile --fixedPalette $palfile --targetScreen5 $sc5file --gamma 2.2