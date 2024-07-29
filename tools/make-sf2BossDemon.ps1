[CmdletBinding()]
param ()

.\make-sf2Object.ps1 -name bossDemon.idle
.\make-sf2Object.ps1 -name bossDemon.walk -append

.\make-sf2Object.ps1 -name bossDemon.hit
.\make-sf2Object.ps1 -name bossDemon.cleave -append

.\make-sf2Object.ps1 -name bossDemon.cast
.\make-sf2Object.ps1 -name bossDemon.death0 -append
.\make-sf2Object.ps1 -name bossDemon.death1 -append
.\make-sf2Object.ps1 -name bossDemon.death2 -append



#$name="bossdemon.idle";$append=$false
#$name="bossdemon.walk";$append=$true

#$name="bossdemon.hit";$append=$false
#$name="bossdemon.cleave";$append=$true

# $name="bossdemon.cast";$append=$false
# $name="bossdemon.death0";$append=$true
# $name="bossdemon.death1";$append=$true
# $name="bossdemon.death2";$append=$true