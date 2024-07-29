The "tools" directory contains external tooling files for the Usas2 project. It contains Powershell, Node.js, and other language files.

In the case of Powershell, only the Powershell host (CLI) is needed and comes default with Windows. There's also a Linux and Mac version, but need to be installed manually. Node.js files need to have the js parser installed, which isn't a default Windows program.

#The following Powershell tools are available
add-u2gfx.ps1	;add a bitmap gfx file to usas2.rom using DSM (updated 20240427)
add-u2maps.ps1	;add one or more room map files to usas2.rom using DSM (updated 20240427)
archive-file.ps1	;archive one or more files to "versions\"
commit.ps1		;shortcut for <<git add -A;git commit -m "x">>
concat-sc5files.ps1	;temp tool to concatenate two .sc5 files (*obsolete when Laurens his image convertor tool is available)
convert-tmxtoraw16.ps1	;Convert one or more Tiled .tmx map files to Usas2 custom format
convertpal-toasm.ps1	;temp tool to convert a 256 bytes *.pl file to 32 bytes asm text
dsm.ps1			;Core functions for DataSpaceManager (DSM) (include file)
get-U2RomSpace.ps1	;get usas2.rom statistics, based on old ROM format (*obsolete)
make-worldmap.ps1	;make a Tiled worldmap for one or more ruins (using excel map as source)
pack.exe		;bitbuster executable
Tiled-Functions.inc.ps1	;Tiled functions for powershell
Usas2-SharedFunctions.inc.ps1	;General powershell functions for usas2 tools
Usas2.Rom.dsm	;DSM config
rip-robert.ps1	;a temp converter for old Tiles map files (used by Robert, hence the filename)


#The next tools are Node.js based
convertgfx	;convert a bmp or png image to MSX screen5 format
romspace	;get the available ROM space and statistics, based on old ROM format (*obsolete)



add-u2gfx.ps1
=============
Add one or more graphic files to usas2.rom. The files will be indexed as Ruin bitmap graphics in a datalist (default "BitMapGfx"). Files get split into sections of max 16K.
You either give the -path to an .sc5 files, or give the -ruinid. The latter can will also convert bmp to sc5 by default.

add-u2gfx.ps1 [-ruinId <Object>] [-dsmName <Object>] [-datalistName <Object>] [-convertGfx] [-resetGlobals] [-updateIndex] [<CommonParameters>]
add-u2gfx.ps1 [-path <Object>] [-dsmName <Object>] [-datalistName <Object>] [-convertGfx] [-resetGlobals] [-updateIndex] [<CommonParameters>]

path*:		Path to the graphic file to be inserted in the ROM. example: -path "..\grapx\tilesheets\KarniMata.Tiles.sc5"
ruinId*:		One or more ruinId number(s). This will also convert to sc5 first (if not disabled)
dsmName:	Path to the DSM meta file, default is "Usas2.Rom.dsm" (note: should be changed to -dsmPath)
datalistName:	Name of the DSM datalist this file belongs to, default  is "BitMapGfx"
convertGfx:	Convert BMP to SC5 file first (only when using -ruinId as input0, enabled by default
resetGlobals:	clear known globals (use when updating global properties file in between adding)
updateIndex:	update the ROM index for this datalist, enabled by default (used for debugging)
* use only one of these option as input

example: the next example will convert the Pegu (ruin 4) bmp file to sc5, insert it into ROM, and update the index. This is the most simple way to quickly add tileset image file(s)
> add-u2gfx.ps1 -ruinId 4
you can also use more than one id, like: -ruinId 4,6. This will add Pegu and Karnimate files


add-u2maps.ps1
==============
Add one or more Usas2 .map files to usas2.rom. Map files are converted from Tiled and compressed using pack.exe (bitbuster) first before added to the DSM datalist and to the ROM file. Rooms, or maps, are either selected using a direct path to the .map file(s), room name(s), or ruinID(s).

add-u2maps.ps1 [-ruinId <Object>] [-dsmName <Object>] [-datalistName <Object>] [-mapslocation <Object>] [-TiledMapsLocation <Object>] [-convertTiledMap] [-resetGlobals] [-updateIndex] [<CommonParameters>]
add-u2maps.ps1 [-roomname <Object>] [-dsmName <Object>] [-datalistName <Object>] [-mapslocation <Object>] [-TiledMapsLocation <Object>] [-convertTiledMap] [-resetGlobals] [-updateIndex] [<CommonParameters>]
add-u2maps.ps1 [-path <Object>] [-dsmName <Object>] [-datalistName <Object>] [-mapslocation <Object>] [-TiledMapsLocation <Object>] [-convertTiledMap] [-resetGlobals] [-updateIndex] [<CommonParameters>]
add-u2maps.ps1 [-newest <Object>] [-dsmName <Object>] [-datalistName <Object>] [-mapslocation <Object>] [-TiledMapsLocation <Object>] [-convertTiledMap] [-resetGlobals] [-updateIndex] [<CommonParameters>]

ruinID*:		One or more ruin numbers. For example -ruinID 2,6 for both Lemniscate and Karnimata.
roomName*:		One or more room names. For example -roomname AT24 for map AT24.
path*:			- unused atm
newest*:			Take the most recent Tiled files, convert them and put them in the ROM
dsmName:		Path to the DSM meta file, default is "Usas2.Rom.dsm" (note: should be changed to -dsmPath)
datalistName:		Name of the DSM datalist this file belongs to, default  is "WorldMap"
mapslocation:		Base directory of .map files. Default is "..\maps"
TileMapsLocation:	Base directore of .tmx files. Default is "C:\Users\$($env:username)\OneDrive\Usas2\maps"
convertTiledMap:	[Switch] pre-convert .tmx file to .map before storing it in DSM and the ROM, enabled by default
resetGlobals:		clear known globals (use when updating global properties file in between adding)
updateIndex:		update the ROM index for this datalist, enabled by default (used for debugging)
* use only one of these option as room input

Example: use this to add the most recent (1) edited Tiled maps to the ROM
.\add-u2maps.ps1 -newest 1


voorbeelden:
add (dan druk tab voor auto completion)
.\add-u2maps.ps1
voor hulp
help .\add-u2maps.ps1

hele ruin:
.\add-u2maps.ps1 -ruinid 4 -convertTiledMap

-verbose voor aanvullende info (is wel trager)
b.v.: .\add-u2maps.ps1 -ruinid 4 -convertTiledMap -Verbose

losse room:
.\add-u2maps.ps1 -roomname AY23 -convertTiledMap

convert palette:
.\convert-paltoasm.ps1 -path "C:\Users\bartf\Documents\GitHub\Usas2\grapx\tilesheets\Lemniscate.tiles.PL"

convert gfx:
npx convertgfx .\pegu.tiles.json
.\add-u2gfx.ps1 -ruinId 4 (Deze zet de Pegu bmp om naar SC5 en pleurt'm in de ROM)

convert latest:
.\add-u2maps.ps1 -newest 1