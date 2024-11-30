VegaActions:
.LeftIdleFrame:                ;current spriteframe, total animationsteps
  db    0,4
.LeftIdleAnimationSpeed:      ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.LeftIdleTable:
  dw Vegapage1frame000 | db 1 | dw Vegapage1frame001 | db 1
  dw Vegapage1frame002 | db 1 | dw Vegapage1frame001 | db 1
  ds 12
.RightIdleFrame:              ;current spriteframe, total animationsteps
  db    0,4
.RightIdleAnimationSpeed:     ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.rightIdleTable:
  dw Vegapage0frame000 | db 0 | dw Vegapage0frame001 | db 0
  dw Vegapage0frame002 | db 0 | dw Vegapage0frame001 | db 0
  ds 12
  
.LeftBendFrame:
  dw    Vegapage1frame005 | db 1
.RightBendFrame:
  dw    Vegapage0frame005 | db 0

;player facing left walking left
.LeftWalkLeftFrame:            ;current spriteframe, total animationsteps
  db    0,6
.LeftWalkLeftAnimationSpeed:  ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.LeftWalkLeftTable:
  dw Vegapage1frame004 | db 1 | dw Vegapage1frame004 | db 1
  dw Vegapage1frame003 | db 1 | dw Vegapage1frame000 | db 1
  dw Vegapage1frame003 | db 1 | dw Vegapage1frame004 | db 1
  ds 6
.LeftWalkLeftstartingframenumber:
  db    4
.LeftWalkLeftstartingframe:
  dw Vegapage1frame000 | db 1
  
;player facing left walking right
.LeftWalkRightFrame:          ;current spriteframe, total animationsteps
  db    0,6
.LeftWalkRightAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.LeftWalkRightTable:
  dw Vegapage1frame004 | db 1 | dw Vegapage1frame004 | db 1
  dw Vegapage1frame003 | db 1 | dw Vegapage1frame000 | db 1
  dw Vegapage1frame003 | db 1 | dw Vegapage1frame004 | db 1
  ds  6
.LeftWalkRightstartingframenumber:
  db    4
.LeftWalkRightstartingframe:
  dw Vegapage1frame000 | db 1

;player facing right walking left
.RightWalkLeftFrame:          ;current spriteframe, total animationsteps
  db    0,6
.RightWalkLeftAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.RightWalkLeftTable:
  dw Vegapage0frame004 | db 0 | dw Vegapage0frame004 | db 0
  dw Vegapage0frame003 | db 0 | dw Vegapage0frame000 | db 0
  dw Vegapage0frame003 | db 0 | dw Vegapage0frame004 | db 0  
  ds  6
.RightWalkLeftstartingframenumber:
  db    4
.RightWalkLeftstartingframe:
  dw Vegapage0frame000 | db 0
 
;player facing right walking right
.RightWalkRightFrame:         ;current spriteframe, total animationsteps
  db    0,6
.RightWalkRightAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.RightWalkRightTable:
  dw Vegapage0frame004 | db 0 | dw Vegapage0frame004 | db 0
  dw Vegapage0frame003 | db 0 | dw Vegapage0frame000 | db 0
  dw Vegapage0frame003 | db 0 | dw Vegapage0frame004 | db 0  
  ds 6
.RightWalkRightstartingframenumber:
  db    4
.RightWalkRightstartingframe:
  dw Vegapage0frame000 | db 0

.HorSpeedWalkSlowTable:       ;lenght table, pointer, movement speed
  db    5,0,   4,4,4,4,4
.HorSpeedWalkFastTable:       ;lenght table, pointer, movement speed
  db    5,0,   6,4,6,4,6

.LeftJumpStraightStartframe:
  dw Vegapage1frame008 | db 1
.LeftJumpStraightanimationTable:
  db    00 | dw Vegapage1frame006 | db 1
  db    11 | dw Vegapage1frame007 | db 1
  db    20 | dw Vegapage1frame008 | db 1
  ds    16

.LeftJumpLeftStartframe:
  dw Vegapage1frame008 | db 1
.LeftJumpLeftanimationTable:  ;face left, jump left
  db    00 | dw Vegapage1frame006 | db 1
  db    08 | dw Vegapage1frame009 | db 1
  db    11 | dw Vegapage1frame010 | db 1
  db    14 | dw Vegapage1frame011 | db 1
  db    17 | dw Vegapage1frame006 | db 1
  db    20 | dw Vegapage1frame008 | db 1
  ds    4

.LeftJumpRightStartframe:
  dw Vegapage1frame008 | db 1
.LeftJumpRightanimationTable: ;face left, jump right
  db    00 | dw Vegapage1frame006 | db 1
  db    11 | dw Vegapage1frame007 | db 1
  db    20 | dw Vegapage1frame008 | db 1
  ds    16

.RightJumpStraightStartframe:
  dw Vegapage0frame008 | db 0
.RightJumpStraightanimationTable:
  db    00 | dw Vegapage0frame006 | db 0
  db    11 | dw Vegapage0frame007 | db 0
  db    20 | dw Vegapage0frame008 | db 0
  ds    16

.RightJumpLeftStartframe:
  dw Vegapage0frame008 | db 0
.RightJumpLeftanimationTable: ;face right, jump left
  db    00 | dw Vegapage0frame006 | db 0
  db    11 | dw Vegapage0frame007 | db 0
  db    20 | dw Vegapage0frame008 | db 0
  ds    16
  
.RightJumpRightStartframe:
  dw Vegapage0frame008 | db 0
.RightJumpRightanimationTable:;face right, jump right
  db    00 | dw Vegapage0frame006 | db 0
  db    08 | dw Vegapage0frame009 | db 0
  db    11 | dw Vegapage0frame010 | db 0
  db    14 | dw Vegapage0frame011 | db 0
  db    17 | dw Vegapage0frame006 | db 0
  db    20 | dw Vegapage0frame008 | db 0
  ds    4


.jumptable:                  ;pointer, y movement
  db    0,  -16,-15,-14,-13,-11,-10,-08,-06,-04,-02,-00
  db    +02,+04,+06,+08,+10,+11,+13,+14,+15,+16
  db    +00,+00,+00,+128      ;end jumptable with 3x 0 otherwise "landing" sfx will not be player
  ds    20

.HorSpeedJumpSlowTable:       ;lenght table, pointer, movement speed
  db    5,0,   4,6,4,4,4
.HorSpeedJumpFastTable:       ;lenght table, pointer, movement speed
  db    5,0,   4,6,4,6,4

;player SoftStandPunching
.StandSoftPunchLeftFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SPL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SPL:
  dw Vegapage1frame000 | db 1
  dw Vegapage1frame012 | db 1
  dw Vegapage1frame008 | db 1

.StandSoftPunchRightFrame:    ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SPR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SPR:
  dw Vegapage0frame000 | db 0
  dw Vegapage0frame012 | db 0
  dw Vegapage0frame008 | db 0

;player HardStandPunching
.StandHardPunchLeftFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HPL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.AnimationTable_HPL:
  dw Vegapage1frame008 | db 1
  dw Vegapage1frame013 | db 1
  dw Vegapage1frame008 | db 1

.StandHardPunchRightFrame:    ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HPR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.AnimationTable_HPR:
  dw Vegapage0frame008 | db 0
  dw Vegapage0frame013 | db 0
  dw Vegapage0frame008 | db 0

;player SoftStandKicking
.StandSoftKickLeftFrame:      ;current spriteframe, total animationsteps
  db    0,4
.AnimationSpeed_SKL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SKL:
  dw Vegapage1frame015 | db 1
  dw Vegapage1frame014 | db 1
  dw Vegapage1frame014 | db 1
  dw Vegapage1frame015 | db 1

.StandSoftKickRightFrame:     ;current spriteframe, total animationsteps
  db    0,4
.AnimationSpeed_SKR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SKR:
  dw Vegapage0frame015 | db 0
  dw Vegapage0frame014 | db 0
  dw Vegapage0frame014 | db 0
  dw Vegapage0frame015 | db 0

;player HardStandKicking
.StandHardKickLeftFrame:      ;current spriteframe, total animationsteps
  db    0,6
.AnimationSpeed_HKL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.AnimationTable_HKL:
  dw Vegapage1frame008 | db 1
  dw Vegapage1frame015 | db 1
  dw Vegapage1frame016 | db 1
  dw Vegapage1frame016 | db 1
  dw Vegapage1frame015 | db 1
  dw Vegapage1frame008 | db 1

.StandHardKickRightFrame:     ;current spriteframe, total animationsteps
  db    0,6
.AnimationSpeed_HKR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.AnimationTable_HKR:
  dw Vegapage0frame008 | db 0
  dw Vegapage0frame015 | db 0
  dw Vegapage0frame016 | db 0
  dw Vegapage0frame016 | db 0
  dw Vegapage0frame015 | db 0
  dw Vegapage0frame008 | db 0
  
;player SoftSitPunching
.SitSoftPunchLeftFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SPL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SPL:
  dw Vegapage1frame005 | db 1
  dw Vegapage1frame017 | db 1
  dw Vegapage1frame005 | db 1

.SitSoftPunchRightFrame:      ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SPR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SPR:
  dw Vegapage0frame005 | db 0
  dw Vegapage0frame017 | db 0
  dw Vegapage0frame005 | db 0

;player HardSitPunching
.SitHardPunchLeftFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_HPL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,3,0                 ;animation every 2,5 frames
.SitAnimationTable_HPL:
  dw Vegapage1frame005 | db 1
  dw Vegapage1frame018 | db 1
  dw Vegapage1frame005 | db 1

.SitHardPunchRightFrame:      ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_HPR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,3,0                 ;animation every 2,5 frames
.SitAnimationTable_HPR:
  dw Vegapage0frame005 | db 0
  dw Vegapage0frame018 | db 0
  dw Vegapage0frame005 | db 0

;player SoftSitKicking
.SitSoftKickLeftFrame:        ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SKL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SKL:
  dw Vegapage1frame005 | db 1
  dw Vegapage1frame019 | db 1
  dw Vegapage1frame005 | db 1

.SitSoftKickRightFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SKR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SKR:
  dw Vegapage0frame005 | db 0
  dw Vegapage0frame019 | db 0
  dw Vegapage0frame005 | db 0

;player HardSitKicking
.SitHardKickLeftFrame:        ;current spriteframe, total animationsteps
  db    0,5
.SitAnimationSpeed_HKL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.SitAnimationTable_HKL:
  dw Vegapage1frame019 | db 1
  dw Vegapage1frame019 | db 1
  dw Vegapage1frame005 | db 1
  dw Vegapage1frame005 | db 1
  dw Vegapage1frame005 | db 1
  db  07                       ;movement speed-> move horizontally while performing hard kick ?

.SitHardKickRightFrame:       ;current spriteframe, total animationsteps
  db    0,5
.SitAnimationSpeed_HKR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.SitAnimationTable_HKR:
  dw Vegapage0frame019 | db 0
  dw Vegapage0frame019 | db 0
  dw Vegapage0frame005 | db 0
  dw Vegapage0frame005 | db 0
  dw Vegapage0frame005 | db 0
  db  07                       ;movement speed-> move horizontally while performing hard kick ?

.LeftSoftJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,5,0                 ;animation every 2,5 frames
  dw    Vegapage1frame020 | db 1
  dw    Vegapage1frame020 | db 1
  dw    Vegapage1frame020 | db 1
.RightSoftJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,5,0                 ;animation every 2,5 frames
  dw    Vegapage0frame020 | db 0
  dw    Vegapage0frame020 | db 0
  dw    Vegapage0frame020 | db 0
.LeftHardJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,1                 ;animation every 2,5 frames
  dw    Vegapage1frame020 | db 1
  dw    Vegapage1frame006 | db 1
  dw    Vegapage1frame006 | db 1
.RightHardJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,1                 ;animation every 2,5 frames
  dw    Vegapage0frame020 | db 0
  dw    Vegapage0frame006 | db 0
  dw    Vegapage0frame006 | db 0

.LeftSoftJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,0                 ;animation every 2,5 frames
  dw    Vegapage1frame020 | db 1
  dw    Vegapage1frame020 | db 1
  dw    Vegapage1frame006 | db 1
.RightSoftJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,0                 ;animation every 2,5 frames
  dw    Vegapage0frame020 | db 0
  dw    Vegapage0frame020 | db 0
  dw    Vegapage0frame006 | db 0
.LeftHardJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,1                 ;animation every 2,5 frames
  dw    Vegapage1frame020 | db 1
  dw    Vegapage1frame006 | db 1
  dw    Vegapage1frame006 | db 1
.RightHardJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,1                 ;animation every 2,5 frames
  dw    Vegapage0frame020 | db 0
  dw    Vegapage0frame006 | db 0
  dw    Vegapage0frame006 | db 0

.LeftSoftJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,3,1                 ;animation every 2,5 frames
  dw    Vegapage1frame022 | db 1
  dw    Vegapage1frame022 | db 1
  dw    Vegapage1frame022 | db 1
.RightSoftJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,3,1                 ;animation every 2,5 frames
  dw    Vegapage0frame022 | db 0
  dw    Vegapage0frame022 | db 0
  dw    Vegapage0frame022 | db 0
  
.LeftHardJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,1                 ;animation every 2,5 frames
  dw    Vegapage1frame022 | db 1
  dw    Vegapage1frame006 | db 1
  dw    Vegapage1frame006 | db 1
.RightHardJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,1                 ;animation every 2,5 frames
  dw    Vegapage0frame022 | db 0
  dw    Vegapage0frame006 | db 0
  dw    Vegapage0frame006 | db 0
  
.LeftSoftJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;animation every 2,5 frames
  dw    Vegapage1frame021 | db 1
  dw    Vegapage1frame021 | db 1
  dw    Vegapage1frame021 | db 1
.RightSoftJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;animation every 2,5 frames
  dw    Vegapage0frame021 | db 0
  dw    Vegapage0frame021 | db 0
  dw    Vegapage0frame021 | db 0
  
.LeftHardJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,1                 ;animation every 2,5 frames
  dw    Vegapage1frame021 | db 1
  dw    Vegapage1frame006 | db 1
  dw    Vegapage1frame006 | db 1
.RightHardJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,1                 ;animation every 2,5 frames
  dw    Vegapage0frame021 | db 0
  dw    Vegapage0frame006 | db 0
  dw    Vegapage0frame006 | db 0
  
.LeftStandDefendFrame:
  dw    Vegapage1frame023 | db 1
.RightStandDefendFrame:
  dw    Vegapage0frame023 | db 0
.LeftBendDefendFrame:
  dw    Vegapage1frame024 | db 1
.RightBendDefendFrame:
  dw    Vegapage0frame024 | db 0


 
.LeftStandHitFrame:
  dw    Vegapage1frame025 | db 1
.RightStandHitFrame:
  dw    Vegapage0frame025 | db 0
.LeftBendHitFrame:
  dw    Vegapage1frame026 | db 1
.RightBendHitFrame:
  dw    Vegapage0frame026 | db 0
.LeftJumpHitFrame:
  dw    Vegapage3frame000 | db 3
.RightJumpHitFrame:
  dw    Vegapage2frame000 | db 2

.HeavilyHitLeftFrame:         ;current spriteframe, total animationsteps
  db    0,13
.HeavilyHitLeftAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.HeavilyHitLeftAnimationTable:
  dw Vegapage3frame000 | db 3
  dw Vegapage3frame000 | db 3
  dw Vegapage3frame000 | db 3
  dw Vegapage3frame000 | db 3
  dw Vegapage3frame002 | db 3
  dw Vegapage3frame002 | db 3
  dw Vegapage3frame002 | db 3
  dw Vegapage3frame002 | db 3
  dw Vegapage3frame002 | db 3
  dw Vegapage3frame002 | db 3
  dw Vegapage3frame002 | db 3
  dw Vegapage3frame002 | db 3
  dw Vegapage3frame002 | db 3

.HeavilyHitRightFrame:        ;current spriteframe, total animationsteps
  db    0,13
.HeavilyHitRightAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.HeavilyHitRightAnimationTable:
  dw Vegapage2frame000 | db 2
  dw Vegapage2frame000 | db 2
  dw Vegapage2frame000 | db 2
  dw Vegapage2frame000 | db 2
  dw Vegapage2frame002 | db 2
  dw Vegapage2frame002 | db 2
  dw Vegapage2frame002 | db 2
  dw Vegapage2frame002 | db 2
  dw Vegapage2frame002 | db 2
  dw Vegapage2frame002 | db 2
  dw Vegapage2frame002 | db 2
  dw Vegapage2frame002 | db 2
  dw Vegapage2frame002 | db 2
    
.JumpHitLeftFrame:        ;current spriteframe, total animationsteps
  db    0,13
.JumphitLeftAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.JumphitLeftAnimationTable:
  dw Vegapage3frame000 | db 3
  dw Vegapage3frame000 | db 3
  dw Vegapage3frame000 | db 3
  dw Vegapage3frame001 | db 3
  dw Vegapage3frame001 | db 3
  dw Vegapage3frame001 | db 3
  dw Vegapage3frame001 | db 3
  dw Vegapage3frame005 | db 3
  dw Vegapage3frame006 | db 3
  dw Vegapage3frame007 | db 3
  dw Vegapage1frame006 | db 1
  dw Vegapage1frame006 | db 1
  dw Vegapage1frame006 | db 1

.JumpHitRightFrame:       ;current spriteframe, total animationsteps
  db    0,13
.JumphitRightAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.JumphitRightAnimationTable:
  dw Vegapage2frame000 | db 2
  dw Vegapage2frame000 | db 2
  dw Vegapage2frame000 | db 2
  dw Vegapage2frame001 | db 2
  dw Vegapage2frame001 | db 2
  dw Vegapage2frame001 | db 2
  dw Vegapage2frame001 | db 2
  dw Vegapage2frame005 | db 2
  dw Vegapage2frame006 | db 2
  dw Vegapage2frame007 | db 2
  dw Vegapage0frame006 | db 0
  dw Vegapage0frame006 | db 0
  dw Vegapage0frame006 | db 0

.KnockDownRecoverLeftFrame:
  db    0,4
.AnimationSpeed_KDARR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.AnimationTable_KDARR:
  dw Vegapage3frame003 | db 3
  dw Vegapage1frame027 | db 1
  dw Vegapage1frame005 | db 1
  dw Vegapage1frame005 | db 1
  ds 3

.KnockDownRecoverRightFrame:
  db    0,4
.AnimationSpeed_KDARL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.AnimationTable_KDARL:
  dw Vegapage2frame003 | db 2
  dw Vegapage0frame027 | db 0
  dw Vegapage0frame005 | db 0
  dw Vegapage0frame005 | db 0
  ds 3

.TossLeftFrame:
  db    0,2
.AnimationSpeed_TossL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,9,0                 ;animation every 2,5 frames
.AnimationTable_TossL:
  dw Vegapage2frame008 | db 2
  dw Vegapage2frame009 | db 2

.TossRightFrame:
  db    0,2
.AnimationSpeed_TossR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,9,0                 ;animation every 2,5 frames
.AnimationTable_TossR:
  dw Vegapage3frame008 | db 3
  dw Vegapage3frame009 | db 3

.VictoryLeftFrame:
  db    0,3
.AnimationSpeed_VictL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_VictL:
  dw Vegapage3frame010 | db 3
  dw Vegapage3frame010 | db 3
  dw Vegapage3frame010 | db 3

.VictoryRightFrame:
  db    0,3
.AnimationSpeed_VictR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_VictR:
  dw Vegapage2frame010 | db 2
  dw Vegapage2frame010 | db 2
  dw Vegapage2frame010 | db 2

;Rolling crystal flash
.Special1MovementTablePointer:
  db    0
.Special1DurationTimer:
  db    32                    ;Amount of frames that Special move takes
.Special1MovementTable:       ;movement(y,x)
  db    -10,+04, -03,+04, -02,+04, -11,+04,   +01,+04, +02,+04, +03,+04, +14,+04,     -04,+04, -03,+04, -02,+04, -11,+04, +01,+04, +02,+04, +13,+04
  db    +10,+04 | ds 28
;Rolling crystal flash part 2
.Special2MovementTablePointer:
  db    0
.Special2DurationTimer:
  db    10                    ;Amount of frames that Special move takes
.Special2MovementTable:      ;movement(y,x)
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+06, +00,+06, +00,+06, +00,+06, +00,+06, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
;Backslash
.Special3MovementTablePointer:
  db    0
.Special3DurationTimer:
  db    46                    ;Amount of frames that Special move takes
.Special3MovementTable:       ;movement(y,x)
  db    +00,-00, +00,-06, +00,-06, +00,-06, +00,-06, +00,-06, +00,-04, +00,-02, +00,-02, +00,-00, +00,-00, +00,-14, +00,-06, +00,-06, +00,-06
  db    +00,-06, +00,-04, +00,-02, +00,-02, +00,-00, +00,-00, +00,-00, +00,-00, +00,-00, +00,-00, +00,-00, +00,-00, +00,-00, +00,-00, +00,-00
;empty
.Special4MovementTablePointer:
  db    0
.Special4DurationTimer:
  db    60                    ;Amount of frames that Special move takes
.Special4MovementTable:      ;movement(y,x)
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
;empty
.Special5MovementTablePointer:
  db    0
.Special5DurationTimer:
  db    60                    ;Amount of frames that Special move takes
.Special5MovementTable:      ;movement(y,x)
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
;Rolling crystal flash
.VariableTableSpecial1:
  db    2                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    1                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    2                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    0                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;Rolling crystal flash part 2
.VariableTableSpecial2:                 ;ch=charge, d=down, u=up, b=back, f=foreward, p=punch, k=kick, r=repeat
  db    0                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    1                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    0                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    1                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;Backslash
.VariableTableSpecial3:
  db    6                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    1                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    0                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    0                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;empty
.VariableTableSpecial4:
  db    0                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    0                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    0                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    0                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;empty
.VariableTableSpecial5:
  db    0                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    0                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    0                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    0                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;Rolling crystal flash
.Special1LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,2,0                 ;current speed step, ani. speed, ani. speed half frame
  dw Vegapage3frame007 | db 3
  dw Vegapage3frame011 | db 3
  dw Vegapage1frame028 | db 1
  dw Vegapage1frame027 | db 1
.Special1RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,2,0                 ;current speed step, ani. speed, ani. speed half frame
  dw Vegapage2frame007 | db 2
  dw Vegapage2frame011 | db 2
  dw Vegapage0frame028 | db 0
  dw Vegapage0frame027 | db 0
;Rolling crystal flash part 2
.Special2LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,5,0                 ;current speed step, ani. speed, ani. speed half frame
  dw Vegapage1frame018 | db 1
  dw Vegapage1frame018 | db 1
  dw Vegapage1frame018 | db 1
  dw Vegapage1frame018 | db 1
.Special2RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,5,0                 ;current speed step, ani. speed, ani. speed half frame
  dw Vegapage0frame018 | db 0
  dw Vegapage0frame018 | db 0
  dw Vegapage0frame018 | db 0
  dw Vegapage0frame018 | db 0
;Backslash
.Special3LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;current speed step, ani. speed, ani. speed half frame
  dw Vegapage3frame004 | db 3
  dw Vegapage3frame005 | db 3
  dw Vegapage3frame012 | db 3
  dw Vegapage3frame012 | db 3
.Special3RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;current speed step, ani. speed, ani. speed half frame
  dw Vegapage2frame004 | db 2
  dw Vegapage2frame005 | db 2
  dw Vegapage2frame012 | db 2
  dw Vegapage2frame012 | db 2
;empty
.Special4LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,4,1                 ;current speed step, ani. speed, ani. speed half frame
  dw Vegapage3frame009 | db 3
  dw Vegapage3frame009 | db 3
  dw Vegapage1frame006 | db 1
  dw Vegapage1frame005 | db 1
.Special4RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,4,1                 ;current speed step, ani. speed, ani. speed half frame
  dw Vegapage2frame009 | db 2
  dw Vegapage2frame009 | db 2
  dw Vegapage0frame006 | db 0
  dw Vegapage0frame005 | db 0
;empty
.Special5LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,4,0                 ;current speed step, ani. speed, ani. speed half frame
  dw Vegapage3frame002 | db 3
  dw Vegapage3frame008 | db 3
  dw Vegapage1frame001 | db 1
  dw Vegapage1frame001 | db 1
.Special5RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,4,0                 ;current speed step, ani. speed, ani. speed half frame
  dw Vegapage2frame002 | db 2
  dw Vegapage2frame008 | db 2
  dw Vegapage0frame001 | db 0
  dw Vegapage0frame001 | db 0

.GettingTossedLeftFrame:      ;current spriteframe, total animationsteps
  db    0,4
.GettingTossedLeftAnimationSpeed:
  db    0,9,1                 ;current speed step, ani. speed, ani. speed half frame
.GettingTossedLeftAnimationTable:
  dw Vegapage1frame025 | db 1
  dw Vegapage3frame001 | db 3
  dw Vegapage3frame002 | db 3
  dw Vegapage3frame002 | db 3

.GettingTossedRightFrame:     ;current spriteframe, total animationsteps
  db    0,4
.GettingTossedRightAnimationSpeed:
  db    0,9,1                 ;current speed step, ani. speed, ani. speed half frame
.GettingTossedRightAnimationTable:
  dw Vegapage0frame025 | db 0
  dw Vegapage2frame001 | db 2
  dw Vegapage2frame002 | db 2
  dw Vegapage2frame002 | db 2

.DamageTabel: ;SoftStandPunch, HardStandPunch, SoftStandKick, HardStandKick, SoftSitPunch, HardSitPunch, 
              ;SoftSitKick, HardSitKick, JumpSoftPunch, JumpHardPunch, JumpSoftKick, JumpHardKick, Special1-5, Toss
  db    12,12,12,12,12,12,12,18, 12,16,12,16,  12,12,16,16,08, 20
.endDamageTabel:

.ProjectileLeftFrame:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,1,0                 ;current speed step, ani. speed, ani. speed half frame
  ds  12
.ProjectileRightFrame:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,1,0                 ;current speed step, ani. speed, ani. speed half frame
  ds  12
.ProjectileLeftEndFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,1                 ;current speed step, ani. speed, ani. speed half frame
  ds  12
.ProjectileRightEndFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,1                 ;current speed step, ani. speed, ani. speed half frame
  ds  12

.DiedLeftFrame:
  dw Vegapage3frame003 | db 3
.DiedRightFrame:
  dw Vegapage2frame003 | db 2
