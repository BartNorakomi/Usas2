$symfile="..\engine\tniasm.sym"
$symbols=Get-Content $symfile
$delim="`t"

$symbols=Import-Csv -Delimiter " " -Path $symfile -Header label,equ,address|select label,address
$symbols|%{$_.address = [uint32]("0x"+$_.address.replace("h",""))}

$manifest=`
[pscustomobject]@{name="engineRomBlock";start="EnginePage3RomStartAddress";len="engineRomBlockLength"}`
,[pscustomobject]@{name="F1Menublock";start="f1MenuRomStartAddress";len="f1MenuBlockLength"}`
,[pscustomobject]@{name="F2Menublock";start="f2MenuRomStartAddress";len="f2MenuBlockLength"}`
,[pscustomobject]@{name="loader";start="loaderRomStartAddress";len="loaderBlockLength"}`
,[pscustomobject]@{name="PlayerMovementRoutinesBlock";start="PlayerMovementRomStartAddress";len="PlayerMovementBlockLength"}`
,[pscustomobject]@{name="movementpatterns1block";start="movementPat1RomStartAddress";len="movementPat1BlockLength"}`
,[pscustomobject]@{name="MovementPatternsFixedPage1block";start="movementPatFixedRomStartAddress";len="movementPatFixedBlockLength"}`
,[pscustomobject]@{name="movementpatterns2block";start="movementPat2RomStartAddress";len="movementPat2BlockLength"}`
,[pscustomobject]@{name="teamNXTlogoblock";start="teamNXTlogoRomStartAddress";len="teamNXTlogoBlockLength"}`
,[pscustomobject]@{name="usas2sfx1repBlock";start="usas2sfx1repRomStartAddress";len="usas2sfx1repBlockLength"}`
,[pscustomobject]@{name="usas2sfx2repBlock";start="usas2sfx2repRomStartAddress";len="usas2sfx2repBlockLength"}`
,[pscustomobject]@{name="usas2repBlock";start="usas2repRomStartAddress";len="usas2repBlockLength"}`
,[pscustomobject]@{name="GraphicsSc5DataStartBlock";start="GraphicsSc5DataRomStartAddress";len="GraphicsSc5DataBlockLength"}`
,[pscustomobject]@{name="SpriteDataStartBlock";start="SpriteDataRomStartAddress";len="SpriteDataBlockLength"}`
,[pscustomobject]@{name="BossSpritesDataStartBlock";start="BossSpritesDataRomStartAddress";len="BossSpritesDataBlockLength"}`


foreach ($record in $manifest)
{   $data=[pscustomobject]@{blockName=$record.name;romAdr=0;dataLen=0;block=0;numBlocks=0;lastblock=0}
    $data.blockName=$record.name
    $data.romAdr=($symbols|where{$_.label -eq "$($record.start):"}).address
    $data.dataLen=($symbols|where{$_.label -eq "$($record.len):"}).address
    $data.block=[math]::floor($data.romAdr/16KB)
    $data.numBlocks=[math]::floor((($data.romAdr%16KB)+$data.datalen)/16KB)+1
    $data.lastBlock=$data.block+$data.numblocks-1
    $data
}