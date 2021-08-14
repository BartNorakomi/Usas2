ChunliActions:
.LeftIdleFrame:                ;current spriteframe, total animationsteps
  db    0,4
.LeftIdleAnimationSpeed:      ;current speed step, ani. speed, ani. speed half frame
  db    0,4,1                 ;animation every 2,5 frames
.LeftIdleTable:
  dw chunlipage1frame001 | db 1 | dw chunlipage1frame000 | db 1
  dw chunlipage1frame001 | db 1 | dw chunlipage1frame002 | db 1
  ds  12
.RightIdleFrame:              ;current spriteframe, total animationsteps
  db    0,4
.RightIdleAnimationSpeed:     ;current speed step, ani. speed, ani. speed half frame
  db    0,4,1                 ;animation every 2,5 frames
.rightIdleTable:
  dw chunlipage0frame001 | db 0 | dw chunlipage0frame000 | db 0
  dw chunlipage0frame001 | db 0 | dw chunlipage0frame002 | db 0
  ds  12  
.LeftBendFrame:
  dw    chunlipage1frame008 | db 1
.RightBendFrame:
  dw    chunlipage0frame008 | db 0

;player facing left walking left
.LeftWalkLeftFrame:            ;current spriteframe, total animationsteps
  db    0,8
.LeftWalkLeftAnimationSpeed:  ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.LeftWalkLeftTable:
  dw chunlipage1frame007 | db 1 | dw chunlipage1frame006 | db 1
  dw chunlipage1frame005 | db 1 | dw chunlipage1frame004 | db 1
  dw chunlipage1frame003 | db 1 | dw chunlipage1frame004 | db 1
  dw chunlipage1frame005 | db 1 | dw chunlipage1frame006 | db 1
.LeftWalkLeftstartingframenumber:
  db    0
.LeftWalkLeftstartingframe:
  dw chunlipage1frame007 | db 1
  
;player facing left walking right
.LeftWalkRightFrame:          ;current spriteframe, total animationsteps
  db    0,8
.LeftWalkRightAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.LeftWalkRightTable:
  dw chunlipage1frame007 | db 1 | dw chunlipage1frame006 | db 1
  dw chunlipage1frame005 | db 1 | dw chunlipage1frame004 | db 1
  dw chunlipage1frame003 | db 1 | dw chunlipage1frame004 | db 1
  dw chunlipage1frame005 | db 1 | dw chunlipage1frame006 | db 1
.LeftWalkRightstartingframenumber:
  db    4
.LeftWalkRightstartingframe:
  dw chunlipage1frame003 | db 1

;player facing right walking left
.RightWalkLeftFrame:          ;current spriteframe, total animationsteps
  db    0,8
.RightWalkLeftAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.RightWalkLeftTable:
  dw chunlipage0frame007 | db 0 | dw chunlipage0frame006 | db 0
  dw chunlipage0frame005 | db 0 | dw chunlipage0frame004 | db 0
  dw chunlipage0frame003 | db 0 | dw chunlipage0frame004 | db 0
  dw chunlipage0frame005 | db 0 | dw chunlipage0frame006 | db 0
.RightWalkLeftstartingframenumber:
  db    0
.RightWalkLeftstartingframe:
  dw chunlipage0frame007 | db 0
 
;player facing right walking right
.RightWalkRightFrame:         ;current spriteframe, total animationsteps
  db    0,8
.RightWalkRightAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.RightWalkRightTable:
  dw chunlipage0frame007 | db 0 | dw chunlipage0frame006 | db 0
  dw chunlipage0frame005 | db 0 | dw chunlipage0frame004 | db 0
  dw chunlipage0frame003 | db 0 | dw chunlipage0frame004 | db 0
  dw chunlipage0frame005 | db 0 | dw chunlipage0frame006 | db 0
.RightWalkRightstartingframenumber:
  db    4
.RightWalkRightstartingframe:
  dw chunlipage0frame003 | db 0

.HorSpeedWalkSlowTable:       ;lenght table, pointer, movement speed
  db    4,0,   2,4,4,4 | ds 1
.HorSpeedWalkFastTable:       ;lenght table, pointer, movement speed
  db    5,0,   4,6,4,6,4





.LeftJumpStraightStartframe:
  dw chunlipage1frame008 | db 1
.LeftJumpStraightanimationTable:
  db    00 | dw chunlipage1frame009 | db 1
  db    06 | dw chunlipage1frame010 | db 1
  db    14 | dw chunlipage1frame009 | db 1
  db    21 | dw chunlipage1frame008 | db 1
  ds    12

.LeftJumpLeftStartframe:
  dw chunlipage1frame009 | db 1
.LeftJumpLeftanimationTable:  ;face left, jump left
  db    07 | dw chunlipage1frame015 | db 1
  db    10 | dw chunlipage1frame014 | db 1
  db    12 | dw chunlipage1frame013 | db 1
  db    14 | dw chunlipage1frame012 | db 1
  db    16 | dw chunlipage1frame011 | db 1
  db    18 | dw chunlipage1frame009 | db 1
  db    21 | dw chunlipage1frame008 | db 1

.LeftJumpRightStartframe:
  dw chunlipage1frame009 | db 1
.LeftJumpRightanimationTable: ;face left, jump right
  db    06 | dw chunlipage1frame011 | db 1
  db    08 | dw chunlipage1frame012 | db 1
  db    11 | dw chunlipage1frame013 | db 1
  db    13 | dw chunlipage1frame014 | db 1
  db    16 | dw chunlipage1frame015 | db 1
  db    18 | dw chunlipage1frame009 | db 1
  db    21 | dw chunlipage1frame008 | db 1

.RightJumpStraightStartframe:
  dw chunlipage0frame008 | db 0
.RightJumpStraightanimationTable:
  db    00 | dw chunlipage0frame009 | db 0
  db    06 | dw chunlipage0frame010 | db 0
  db    14 | dw chunlipage0frame009 | db 0
  db    21 | dw chunlipage0frame008 | db 0
  ds    12

.RightJumpLeftStartframe:
  dw chunlipage0frame009 | db 0
.RightJumpLeftanimationTable: ;face right, jump left
  db    06 | dw chunlipage0frame011 | db 0
  db    08 | dw chunlipage0frame012 | db 0
  db    11 | dw chunlipage0frame013 | db 0
  db    13 | dw chunlipage0frame014 | db 0
  db    16 | dw chunlipage0frame015 | db 0
  db    18 | dw chunlipage0frame009 | db 0
  db    21 | dw chunlipage0frame008 | db 0
  
.RightJumpRightStartframe:
  dw chunlipage0frame009 | db 0
.RightJumpRightanimationTable:;face right, jump right
  db    07 | dw chunlipage0frame015 | db 0
  db    10 | dw chunlipage0frame014 | db 0
  db    12 | dw chunlipage0frame013 | db 0
  db    14 | dw chunlipage0frame012 | db 0
  db    16 | dw chunlipage0frame011 | db 0
  db    18 | dw chunlipage0frame009 | db 0
  db    21 | dw chunlipage0frame008 | db 0

.jumptable:                  ;pointer, y movement
  db    +00,-15,-15,-14,-13,-11,-09,-07,-05,-03,-02,-01
  db    -00,+01,+02,+04,+06,+08,+11,+13,+15,+17,+18
  db    +00,+00,+00,+128      ;end jumptable with 3x 0 otherwise "landing" sfx will not be player
  ds    19

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
  dw chunlipage1frame003 | db 1
  dw chunlipage1frame016 | db 1
  dw chunlipage1frame016 | db 1

.StandSoftPunchRightFrame:    ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SPR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SPR:
  dw chunlipage0frame003 | db 0
  dw chunlipage0frame016 | db 0
  dw chunlipage0frame016 | db 0

;player HardStandPunching
.StandHardPunchLeftFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HPL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_HPL:
  dw chunlipage3frame028 | db 3
  dw chunlipage1frame017 | db 1
  dw chunlipage3frame028 | db 3

.StandHardPunchRightFrame:    ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HPR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_HPR:
  dw chunlipage2frame028 | db 2
  dw chunlipage0frame017 | db 0
  dw chunlipage2frame028 | db 2

;player SoftStandKicking
.StandSoftKickLeftFrame:      ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SKL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SKL:
  dw chunlipage1frame005 | db 1
  dw chunlipage1frame020 | db 1
  dw chunlipage1frame020 | db 1
  ds  3
.StandSoftKickRightFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SKR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SKR:
  dw chunlipage0frame005 | db 0
  dw chunlipage0frame020 | db 0
  dw chunlipage0frame020 | db 0
  ds  3
;player HardStandKicking
.StandHardKickLeftFrame:      ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HKL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.AnimationTable_HKL:
  dw chunlipage3frame029 | db 3
  dw chunlipage1frame021 | db 1
  dw chunlipage3frame030 | db 3
  ds  9
.StandHardKickRightFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HKR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.AnimationTable_HKR:
  dw chunlipage2frame029 | db 2
  dw chunlipage0frame021 | db 0
  dw chunlipage2frame030 | db 2
    ds  9
;player SoftSitPunching
.SitSoftPunchLeftFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SPL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SPL:
  dw chunlipage1frame008 | db 1
  dw chunlipage1frame019 | db 1
  dw chunlipage1frame019 | db 1

.SitSoftPunchRightFrame:      ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SPR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SPR:
  dw chunlipage0frame008 | db 0
  dw chunlipage0frame019 | db 0
  dw chunlipage0frame019 | db 0

;player HardSitPunching
.SitHardPunchLeftFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_HPL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.SitAnimationTable_HPL:
  dw chunlipage1frame018 | db 1
  dw chunlipage1frame019 | db 1
  dw chunlipage1frame008 | db 1

.SitHardPunchRightFrame:      ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_HPR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.SitAnimationTable_HPR:
  dw chunlipage0frame018 | db 0
  dw chunlipage0frame019 | db 0
  dw chunlipage0frame008 | db 0

;player SoftSitKicking
.SitSoftKickLeftFrame:        ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SKL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SKL:
  dw chunlipage1frame008 | db 1
  dw chunlipage1frame022 | db 1
  dw chunlipage1frame022 | db 1

.SitSoftKickRightFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SKR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SKR:
  dw chunlipage0frame008 | db 0
  dw chunlipage0frame022 | db 0
  dw chunlipage0frame022 | db 0

;player HardSitKicking
.SitHardKickLeftFrame:        ;current spriteframe, total animationsteps
  db    0,4
.SitAnimationSpeed_HKL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,3,0                 ;animation every 2,5 frames
.SitAnimationTable_HKL:
  dw chunlipage3frame027 | db 3
  dw chunlipage1frame023 | db 1
  dw chunlipage3frame027 | db 3
  dw chunlipage3frame027 | db 3
  ds  3
  db  0                       ;movement speed-> move horizontally while performing hard kick ?

.SitHardKickRightFrame:       ;current spriteframe, total animationsteps
  db    0,4
.SitAnimationSpeed_HKR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,3,0                 ;animation every 2,5 frames
.SitAnimationTable_HKR:
  dw chunlipage2frame027 | db 2
  dw chunlipage0frame023 | db 0
  dw chunlipage2frame027 | db 2
  dw chunlipage2frame027 | db 2
  ds  3
  db  0                       ;movement speed-> move horizontally while performing hard kick ?
 
.LeftSoftJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,9,0                 ;animation every 2,5 frames
  dw    chunlipage1frame025 | db 1
  dw    chunlipage1frame025 | db 1
  dw    chunlipage1frame009 | db 1  
.RightSoftJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,9,0                 ;animation every 2,5 frames
  dw    chunlipage0frame025 | db 0
  dw    chunlipage0frame025 | db 0
  dw    chunlipage0frame009 | db 0
.LeftHardJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,5,0                 ;animation every 2,5 frames
  dw    chunlipage1frame025 | db 1
  dw    chunlipage1frame025 | db 1
  dw    chunlipage1frame009 | db 1  
.RightHardJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,5,0                 ;animation every 2,5 frames
  dw    chunlipage0frame025 | db 0
  dw    chunlipage0frame025 | db 0
  dw    chunlipage0frame009 | db 0
.LeftSoftJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,9,0                 ;animation every 2,5 frames
  dw    chunlipage1frame025 | db 1
  dw    chunlipage1frame025 | db 1
  dw    chunlipage1frame009 | db 1  
.RightSoftJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,9,0                 ;animation every 2,5 frames
  dw    chunlipage0frame025 | db 0
  dw    chunlipage0frame025 | db 0
  dw    chunlipage0frame009 | db 0
.LeftHardJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,0                 ;animation every 2,5 frames
  dw    chunlipage1frame025 | db 1
  dw    chunlipage1frame025 | db 1
  dw    chunlipage1frame009 | db 1  
.RightHardJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,0                 ;animation every 2,5 frames
  dw    chunlipage0frame025 | db 0
  dw    chunlipage0frame025 | db 0
  dw    chunlipage0frame009 | db 0
  
.LeftSoftJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;animation every 2,5 frames
  dw    chunlipage1frame026 | db 1
  dw    chunlipage1frame026 | db 1
  dw    chunlipage1frame009 | db 1  
.RightSoftJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;animation every 2,5 frames
  dw    chunlipage0frame026 | db 0
  dw    chunlipage0frame026 | db 0
  dw    chunlipage0frame009 | db 0
.LeftHardJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,9,0                 ;animation every 2,5 frames
  dw    chunlipage1frame026 | db 1
  dw    chunlipage1frame009 | db 1
  dw    chunlipage1frame009 | db 1  
.RightHardJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,9,0                 ;animation every 2,5 frames
  dw    chunlipage0frame026 | db 0
  dw    chunlipage0frame009 | db 0
  dw    chunlipage0frame009 | db 0
.LeftSoftJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;animation every 2,5 frames
  dw    chunlipage1frame024 | db 1
  dw    chunlipage1frame024 | db 1
  dw    chunlipage1frame009 | db 1  
.RightSoftJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;animation every 2,5 frames
  dw    chunlipage0frame024 | db 0
  dw    chunlipage0frame024 | db 0
  dw    chunlipage0frame009 | db 0
.LeftHardJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,5,0                 ;animation every 2,5 frames
  dw    chunlipage1frame024 | db 1
  dw    chunlipage1frame024 | db 1
  dw    chunlipage1frame009 | db 1  
.RightHardJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,5,0                 ;animation every 2,5 frames
  dw    chunlipage0frame024 | db 0
  dw    chunlipage0frame024 | db 0
  dw    chunlipage0frame009 | db 0  
  
.LeftStandDefendFrame:
  dw    chunlipage1frame027 | db 1
.RightStandDefendFrame:
  dw    chunlipage0frame027 | db 0
.LeftBendDefendFrame:
  dw    chunlipage1frame028 | db 1
.RightBendDefendFrame:
  dw    chunlipage0frame028 | db 0
 
.LeftStandHitFrame:
  dw    chunlipage3frame000 | db 3
.RightStandHitFrame:
  dw    chunlipage2frame000 | db 2
.LeftBendHitFrame:
  dw    chunlipage3frame001 | db 3
.RightBendHitFrame:
  dw    chunlipage2frame001 | db 2
.LeftJumpHitFrame:
  dw    chunlipage1frame011 | db 1
.RightJumpHitFrame:
  dw    chunlipage0frame011 | db 0

.HeavilyHitLeftFrame:        ;current spriteframe, total animationsteps
  db    0,13
.HeavilyHitLeftAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.HeavilyHitLeftAnimationTable:
  dw chunlipage3frame002 | db 3
  dw chunlipage3frame002 | db 3
  dw chunlipage3frame002 | db 3
  dw chunlipage3frame002 | db 3
  dw chunlipage3frame002 | db 3
  dw chunlipage3frame003 | db 3
  dw chunlipage3frame003 | db 3
  dw chunlipage3frame003 | db 3
  dw chunlipage3frame003 | db 3
  dw chunlipage3frame003 | db 3
  dw chunlipage3frame003 | db 3
  dw chunlipage3frame003 | db 3
  dw chunlipage3frame003 | db 3

.HeavilyHitRightFrame:       ;current spriteframe, total animationsteps
  db    0,13
.HeavilyHitRightAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.HeavilyHitRightAnimationTable:
  dw chunlipage2frame002 | db 2
  dw chunlipage2frame002 | db 2
  dw chunlipage2frame002 | db 2
  dw chunlipage2frame002 | db 2
  dw chunlipage2frame002 | db 2
  dw chunlipage2frame003 | db 2
  dw chunlipage2frame003 | db 2
  dw chunlipage2frame004 | db 2
  dw chunlipage2frame004 | db 2
  dw chunlipage2frame004 | db 2
  dw chunlipage2frame004 | db 2
  dw chunlipage2frame004 | db 2
  dw chunlipage2frame004 | db 2
  
.JumpHitLeftFrame:        ;current spriteframe, total animationsteps
  db    0,13
.JumphitLeftAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.JumphitLeftAnimationTable:
  dw chunlipage1frame011 | db 1
  dw chunlipage1frame011 | db 1
  dw chunlipage1frame011 | db 1
  dw chunlipage1frame011 | db 1
  dw chunlipage1frame011 | db 1
  dw chunlipage1frame011 | db 1
  dw chunlipage1frame011 | db 1
  dw chunlipage1frame011 | db 1
  dw chunlipage1frame012 | db 1
  dw chunlipage1frame013 | db 1
  dw chunlipage1frame014 | db 1
  dw chunlipage1frame015 | db 1
  dw chunlipage1frame009 | db 1

.JumpHitRightFrame:       ;current spriteframe, total animationsteps
  db    0,13
.JumphitRightAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.JumphitRightAnimationTable:
  dw chunlipage0frame011 | db 0
  dw chunlipage0frame011 | db 0
  dw chunlipage0frame011 | db 0
  dw chunlipage0frame011 | db 0
  dw chunlipage0frame011 | db 0
  dw chunlipage0frame011 | db 0
  dw chunlipage0frame011 | db 0
  dw chunlipage0frame011 | db 0
  dw chunlipage0frame012 | db 0
  dw chunlipage0frame013 | db 0
  dw chunlipage0frame014 | db 0
  dw chunlipage0frame015 | db 0
  dw chunlipage0frame009 | db 0  

.KnockDownRecoverLeftFrame:
  db    0,5
.AnimationSpeed_KDARR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_KDARR:
  dw chunlipage3frame005 | db 3
  dw chunlipage3frame005 | db 3
  dw chunlipage3frame005 | db 3
  dw chunlipage3frame006 | db 3
  dw chunlipage3frame006 | db 3

.KnockDownRecoverRightFrame:
  db    0,5
.AnimationSpeed_KDARL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_KDARL:
  dw chunlipage2frame005 | db 2
  dw chunlipage2frame005 | db 2
  dw chunlipage2frame005 | db 2
  dw chunlipage2frame006 | db 2
  dw chunlipage2frame006 | db 2

.TossLeftFrame:
  db    0,2
.AnimationSpeed_TossL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,9,0                 ;animation every 2,5 frames
.AnimationTable_TossL:
  dw chunlipage3frame007 | db 3
  dw chunlipage3frame008 | db 3

.TossRightFrame:
  db    0,2
.AnimationSpeed_TossR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,9,0                 ;animation every 2,5 frames
.AnimationTable_TossR:
  dw chunlipage2frame007 | db 2
  dw chunlipage2frame008 | db 2

.VictoryLeftFrame:
  db    0,3
.AnimationSpeed_VictL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_VictL:
  dw chunlipage3frame009 | db 3
  dw chunlipage3frame009 | db 3
  dw chunlipage3frame009 | db 3

.VictoryRightFrame:
  db    0,3
.AnimationSpeed_VictR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_VictR:
  dw chunlipage2frame009 | db 2
  dw chunlipage2frame009 | db 2
  dw chunlipage2frame009 | db 2

;Projectile shot
.Special1MovementTablePointer:
  db    0
.Special1DurationTimer:
  db    56                    ;Amount of frames that Special move takes
.Special1MovementTable:       ;movement(y,x)
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, -00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
;Lightning Kick
.Special2MovementTablePointer:
  db    0
.Special2DurationTimer:
  db    60                    ;Amount of frames that Special move takes
.Special2MovementTable:       ;movement(y,x)
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, -00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
;Spinning Bird Kick 1 chunli
.Special3MovementTablePointer:
  db    0
.Special3DurationTimer:
  db    16                    ;Amount of frames that Special move takes
.Special3MovementTable:       ;movement(y,x)
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, -00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
;Spinning Bird Kick 2 chunli
.Special4MovementTablePointer:
  db    0
.Special4DurationTimer:
  db    60                    ;Amount of frames that Special move takes
.Special4MovementTable:       ;movement(y,x)
  db    +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04
  db    +00,+04, +00,+04, +00,+04, +00,+04, +03,+02, +04,+04, +05,+02, +06,+02, +07,+04, +08,+02, +09,+02, +10,+02, +11,+00, +12,+02, +13,+02
;Spinning Bird Kick 3 chunli
.Special5MovementTablePointer:
  db    0
.Special5DurationTimer:
  db    16                    ;Amount of frames that Special move takes
.Special5MovementTable:       ;movement(y,x)
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, -00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
;Projectile shot
.VariableTableSpecial1:
  db    5                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    1                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    0                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    0                     ;attack knocks you down ? (counts as being heavily hit)
  db    14                    ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;Lightning Kick
.VariableTableSpecial2:
  db    4                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    1                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    0                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    0                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    2                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;Spinning Bird Kick 1 chunli
.VariableTableSpecial3:                 ;ch=charge, d=down, u=up, b=back, f=foreward, p=punch, k=kick, r=repeat
  db    1                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    0                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    4                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    0                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;Spinning Bird Kick 2 chunli
.VariableTableSpecial4:
  db    0                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    0                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    5                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    0                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;Spinning Bird Kick 3 chunli
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
;Projectile shot
.Special1LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;current speed step, ani. speed, ani. speed half frame
  dw chunlipage3frame010 | db 3
  dw chunlipage3frame011 | db 3
  dw chunlipage3frame011 | db 3
  dw chunlipage3frame011 | db 3
.Special1RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;current speed step, ani. speed, ani. speed half frame
  dw chunlipage2frame010 | db 2
  dw chunlipage2frame011 | db 2
  dw chunlipage2frame011 | db 2
  dw chunlipage2frame011 | db 2  
;Lightning Kick
.Special2LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,1                 ;current speed step, ani. speed, ani. speed half frame
  dw chunlipage3frame019 | db 3
  dw chunlipage3frame020 | db 3
  dw chunlipage3frame021 | db 3
  dw chunlipage3frame022 | db 3
.Special2RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,1                 ;current speed step, ani. speed, ani. speed half frame
  dw chunlipage2frame019 | db 2
  dw chunlipage2frame020 | db 2
  dw chunlipage2frame021 | db 2
  dw chunlipage2frame022 | db 2  
;Spinning Bird Kick 1 chunli
.Special3LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,2,0                 ;current speed step, ani. speed, ani. speed half frame
  dw chunlipage1frame015 | db 1
  dw chunlipage1frame014 | db 1
  dw chunlipage1frame013 | db 1
  dw chunlipage1frame013 | db 1
.Special3RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,2,0                 ;current speed step, ani. speed, ani. speed half frame
  dw chunlipage0frame015 | db 0
  dw chunlipage0frame014 | db 0
  dw chunlipage0frame013 | db 0
  dw chunlipage0frame013 | db 0
;Spinning Bird Kick 2 chunli
.Special4LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,2,0                 ;current speed step, ani. speed, ani. speed half frame
  dw chunlipage3frame015 | db 3
  dw chunlipage3frame016 | db 3
  dw chunlipage3frame017 | db 3
  dw chunlipage3frame018 | db 3
.Special4RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,2,0                 ;current speed step, ani. speed, ani. speed half frame
  dw chunlipage2frame015 | db 2
  dw chunlipage2frame016 | db 2
  dw chunlipage2frame017 | db 2
  dw chunlipage2frame018 | db 2
;Spinning Bird Kick 3 chunli
.Special5LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;current speed step, ani. speed, ani. speed half frame
  dw chunlipage0frame013 | db 0
  dw chunlipage0frame014 | db 0
  dw chunlipage0frame015 | db 0
  dw chunlipage0frame009 | db 0
.Special5RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;current speed step, ani. speed, ani. speed half frame
  dw chunlipage1frame013 | db 1
  dw chunlipage1frame014 | db 1
  dw chunlipage1frame015 | db 1
  dw chunlipage1frame009 | db 1



.GettingTossedLeftFrame:      ;current spriteframe, total animationsteps
  db    0,4
.GettingTossedLeftAnimationSpeed:
  db    0,9,1                 ;current speed step, ani. speed, ani. speed half frame
.GettingTossedLeftAnimationTable:
  dw chunlipage3frame000 | db 3
  dw chunlipage0frame012 | db 0
  dw chunlipage0frame011 | db 0
  dw chunlipage0frame011 | db 0

.GettingTossedRightFrame:     ;current spriteframe, total animationsteps
  db    0,4
.GettingTossedRightAnimationSpeed:
  db    0,9,1                 ;current speed step, ani. speed, ani. speed half frame
.GettingTossedRightAnimationTable:
  dw chunlipage2frame000 | db 2
  dw chunlipage1frame012 | db 1
  dw chunlipage0frame011 | db 0
  dw chunlipage0frame011 | db 0


.DamageTabel: ;SoftStandPunch, HardStandPunch, SoftStandKick, HardStandKick, SoftSitPunch, HardSitPunch, 
              ;SoftSitKick, HardSitKick, JumpSoftPunch, JumpHardPunch, JumpSoftKick, JumpHardKick, Special1-5, Toss
  db    12,16,12,16,12,16,12,20, 12,16,12,16,  0,08,0,12,0, 20
.endDamageTabel:

.ProjectileLeftFrame:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,1,0                 ;current speed step, ani. speed, ani. speed half frame
  dw chunlipage3frame012 | db 3
  dw chunlipage3frame013 | db 3
  dw chunlipage3frame026 | db 3
  ds  3
.ProjectileRightFrame:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,1,0                 ;current speed step, ani. speed, ani. speed half frame
  dw chunlipage2frame012 | db 2
  dw chunlipage2frame013 | db 2
  dw chunlipage2frame026 | db 2  
  ds  3
.ProjectileLeftEndFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,1                 ;current speed step, ani. speed, ani. speed half frame
  dw chunlipage3frame023 | db 3
  dw chunlipage3frame024 | db 3
  dw chunlipage3frame025 | db 3
  dw chunlipage3frame014 | db 3
.ProjectileRightEndFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,1                 ;current speed step, ani. speed, ani. speed half frame
  dw chunlipage2frame023 | db 2
  dw chunlipage2frame024 | db 2
  dw chunlipage2frame025 | db 2
  dw chunlipage2frame014 | db 2

.DiedLeftFrame:
  dw chunlipage3frame005 | db 3
.DiedRightFrame:
  dw chunlipage2frame005 | db 2