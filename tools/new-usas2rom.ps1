. .\dsm.ps1
. .\Usas2-SharedFunctions.inc.ps1
$usas2=get-Usas2Globals -force

#Create the Managed data space
$DSM=new-DSM -name $usas2.dsm.name -BlockSize $usas2.dsm.blocksize -size $usas2.dsm.size -SegmentSize $usas2.dsm.segmentSize -firstblock $usas2.dsm.firstBlock -numBlocks $usas2.dsm.numblocks
$blockExclusions=[int[]]$usas2.dsm.blockExclusion.split(",")
$dsm|exclude-dsmblock -block $blockExclusions

#create the filespace (usas2.rom)
$DSM|create-DSMFileSpace  -force -path $usas2.dsm.filespace
#save the filespace config (usas2.rom.dsm)
$dsm|save-dsm -path $usas2.dsm.path -verbose

#add Karnimata
.\add-u2maps.ps1 -convertTiledMap:$false -ruinId 6 #-dsmPath $usas2.dsm.path
.\add-u2gfx.ps1 -path "..\grapx\tilesheets\KarniMata.tiles.SC5" #-dsmPath $usas2.dsm.path

$DSM
