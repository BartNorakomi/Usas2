[CmdletBinding()]
param
(	[switch]$run
)

pushd ..\Engine
& .\tniasm.exe .\Usas2.asm
popd
if ($run) {.\run.ps1}