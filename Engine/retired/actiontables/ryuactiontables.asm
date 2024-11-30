RyuActions:
.LeftIdleFrame:                ;current spriteframe, total animationsteps
  db    0,4
.LeftIdleAnimationSpeed:      ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.LeftIdleTable:
  dw ryupage1frame001 | db 1 | dw ryupage1frame000 | db 1
  dw ryupage1frame001 | db 1 | dw ryupage1frame002 | db 1
  ds  12

.RightIdleFrame:              ;current spriteframe, total animationsteps
  db    0,4
.RightIdleAnimationSpeed:     ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.rightIdleTable:
  dw ryupage0frame001 | db 0 | dw ryupage0frame000 | db 0
  dw ryupage0frame001 | db 0 | dw ryupage0frame002 | db 0
  ds  12
  
.LeftBendFrame:
  dw    ryupage1frame008 | db 1
.RightBendFrame:
  dw    ryupage0frame008 | db 0

;player facing left walking left
.LeftWalkLeftFrame:            ;current spriteframe, total animationsteps
  db    0,5
.LeftWalkLeftAnimationSpeed:  ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.LeftWalkLeftTable:
;  dw    ryuframe009,ryuframe008,ryuframe007,ryuframe006,ryuframe010
  dw ryupage1frame006 | db 1 | dw ryupage1frame005 | db 1
  dw ryupage1frame004 | db 1 | dw ryupage1frame003 | db 1
  dw ryupage1frame007 | db 1     
  ds    9
.LeftWalkLeftstartingframenumber:
  db    3
.LeftWalkLeftstartingframe:
;  dw    ryuframe006
  dw ryupage1frame003 | db 1
  
;player facing left walking right
.LeftWalkRightFrame:          ;current spriteframe, total animationsteps
  db    0,5
.LeftWalkRightAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.LeftWalkRightTable:
;  dw    ryuframe010,ryuframe006,ryuframe007,ryuframe008,ryuframe009
  dw ryupage1frame007 | db 1 | dw ryupage1frame003 | db 1
  dw ryupage1frame004 | db 1 | dw ryupage1frame005 | db 1
  dw ryupage1frame006 | db 1
  ds    9
.LeftWalkRightstartingframenumber:
  db    2
.LeftWalkRightstartingframe:
;  dw    ryuframe006
  dw ryupage1frame002 | db 1

;player facing right walking left
.RightWalkLeftFrame:          ;current spriteframe, total animationsteps
  db    0,5
.RightWalkLeftAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.RightWalkLeftTable:
;  dw    ryuframe014,ryuframe013,ryuframe012,ryuframe011,ryuframe015
  dw ryupage0frame006 | db 0 | dw ryupage0frame005 | db 0
  dw ryupage0frame004 | db 0 | dw ryupage0frame003 | db 0
  dw ryupage0frame007 | db 0
  ds    9
.RightWalkLeftstartingframenumber:
  db    3
.RightWalkLeftstartingframe:
;  dw    ryuframe011
  dw ryupage0frame003 | db 0
 
;player facing right walking right
.RightWalkRightFrame:         ;current spriteframe, total animationsteps
  db    0,5
.RightWalkRightAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.RightWalkRightTable:
;  dw    ryuframe015,ryuframe011,ryuframe012,ryuframe013,ryuframe014
  dw ryupage0frame007 | db 0 | dw ryupage0frame003 | db 0
  dw ryupage0frame004 | db 0 | dw ryupage0frame005 | db 0
  dw ryupage0frame006 | db 0
  ds    9
.RightWalkRightstartingframenumber:
  db    2
.RightWalkRightstartingframe:
;  dw    ryuframe011
  dw ryupage0frame003 | db 0

.HorSpeedWalkSlowTable:       ;lenght table, pointer, movement speed
  db    5,0,   2,2,4,2,4
.HorSpeedWalkFastTable:       ;lenght table, pointer, movement speed
  db    1,0,   4 | ds 4

.LeftJumpStraightStartframe:
  dw ryupage1frame003 | db 1
.LeftJumpStraightanimationTable:
  db    00 | dw ryupage1frame009 | db 1
  db    04 | dw ryupage1frame010 | db 1
  db    14 | dw ryupage1frame009 | db 1
  db    20 | dw ryupage1frame003 | db 1
  ds    12

.LeftJumpLeftStartframe:
  dw ryupage1frame003 | db 1
.LeftJumpLeftanimationTable:  ;face left, jump left
  db    00 | dw ryupage1frame009 | db 1
  db    07 | dw ryupage1frame014 | db 1
  db    10 | dw ryupage1frame013 | db 1
  db    12 | dw ryupage1frame012 | db 1
  db    14 | dw ryupage1frame011 | db 1
  db    16 | dw ryupage1frame009 | db 1
  db    20 | dw ryupage1frame003 | db 1

.LeftJumpRightStartframe:
  dw ryupage1frame003 | db 1
.LeftJumpRightanimationTable: ;face left, jump right
  db    00 | dw ryupage1frame011 | db 1
  db    07 | dw ryupage1frame012 | db 1
  db    10 | dw ryupage1frame013 | db 1
  db    12 | dw ryupage1frame014 | db 1
  db    14 | dw ryupage1frame009 | db 1
  db    20 | dw ryupage1frame003 | db 1
  ds    4

.RightJumpStraightStartframe:
  dw ryupage0frame003 | db 0
.RightJumpStraightanimationTable:
  db    00 | dw ryupage0frame009 | db 0
  db    04 | dw ryupage0frame010 | db 0
  db    14 | dw ryupage0frame009 | db 0
  db    20 | dw ryupage0frame003 | db 0
  ds    12

.RightJumpLeftStartframe:
  dw ryupage0frame003 | db 0
.RightJumpLeftanimationTable: ;face right, jump left
  db    00 | dw ryupage0frame011 | db 0
  db    07 | dw ryupage0frame012 | db 0
  db    10 | dw ryupage0frame013 | db 0
  db    12 | dw ryupage0frame014 | db 0
  db    14 | dw ryupage0frame009 | db 0
  db    20 | dw ryupage0frame003 | db 0
  ds    4
  
.RightJumpRightStartframe:
  dw ryupage0frame003 | db 0
.RightJumpRightanimationTable:;face right, jump right
  db    00 | dw ryupage0frame009 | db 0
  db    07 | dw ryupage0frame014 | db 0
  db    10 | dw ryupage0frame013 | db 0
  db    12 | dw ryupage0frame012 | db 0
  db    14 | dw ryupage0frame011 | db 0
  db    16 | dw ryupage0frame009 | db 0
  db    20 | dw ryupage0frame003 | db 0

.jumptable:                  ;pointer, y movement
  db    0,  -14,-14,-13,-12,-10,-08,-06,-04,-02,-01,-00
  db    +01,+02,+04,+06,+08,+10,+12,+13,+14,+14
  db    +00,+00,+00,+128      ;end jumptable with 3x 0 otherwise "landing" sfx will not be player
  ds    20

.HorSpeedJumpSlowTable:       ;lenght table, pointer, movement speed
  db    5,0,   4,4,4,4,4
.HorSpeedJumpFastTable:       ;lenght table, pointer, movement speed
  db    5,0,   4,6,4,6,4

;player SoftStandPunching
.StandSoftPunchLeftFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SPL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,1,1                 ;animation every 2,5 frames
.AnimationTable_SPL:
  dw ryupage1frame000 | db 1
  dw ryupage1frame015 | db 1
  dw ryupage1frame015 | db 1

.StandSoftPunchRightFrame:    ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SPR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,1,1                 ;animation every 2,5 frames
.AnimationTable_SPR:
  dw ryupage0frame000 | db 0
  dw ryupage0frame015 | db 0
  dw ryupage0frame015 | db 0

;player HardStandPunching
.StandHardPunchLeftFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HPL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_HPL:
  dw ryupage1frame006 | db 1
  dw ryupage1frame016 | db 1
  dw ryupage1frame016 | db 1

.StandHardPunchRightFrame:    ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HPR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_HPR:
  dw ryupage0frame004 | db 0
  dw ryupage0frame016 | db 0
  dw ryupage0frame016 | db 0
;player SoftStandKicking
.StandSoftKickLeftFrame:      ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SKL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SKL:
  dw ryupage1frame004 | db 1
  dw ryupage1frame019 | db 1
  dw ryupage1frame019 | db 1
  ds  3
.StandSoftKickRightFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SKR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SKR:
  dw ryupage0frame004 | db 0
  dw ryupage0frame019 | db 0
  dw ryupage0frame019 | db 0
  ds  3
;player HardStandKicking
.StandHardKickLeftFrame:      ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HKL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.AnimationTable_HKL:
  dw ryupage3frame032 | db 3
  dw ryupage1frame020 | db 1
  dw ryupage3frame033 | db 3
  ds  9
.StandHardKickRightFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HKR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.AnimationTable_HKR:
  dw ryupage2frame032 | db 2
  dw ryupage0frame020 | db 0
  dw ryupage2frame033 | db 2
  ds  9
;player SoftSitPunching
.SitSoftPunchLeftFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SPL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SPL:
  dw ryupage1frame008 | db 1
  dw ryupage1frame017 | db 1
  dw ryupage1frame017 | db 1

.SitSoftPunchRightFrame:      ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SPR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SPR:
  dw ryupage0frame008 | db 0
  dw ryupage0frame017 | db 0
  dw ryupage0frame017 | db 0


;player HardSitPunching
.SitHardPunchLeftFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_HPL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_HPL:
  dw ryupage1frame018 | db 1
  dw ryupage1frame018 | db 1
  dw ryupage1frame003 | db 1

.SitHardPunchRightFrame:      ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_HPR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_HPR:
  dw ryupage0frame018 | db 0
  dw ryupage0frame018 | db 0
  dw ryupage0frame003 | db 0


;player SoftSitKicking
.SitSoftKickLeftFrame:        ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SKL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.SitAnimationTable_SKL:
  dw ryupage1frame008 | db 1
  dw ryupage1frame021 | db 1
  dw ryupage1frame021 | db 1

.SitSoftKickRightFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SKR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.SitAnimationTable_SKR:
  dw ryupage0frame008 | db 0
  dw ryupage0frame021 | db 0
  dw ryupage0frame021 | db 0


;player HardSitKicking
.SitHardKickLeftFrame:        ;current spriteframe, total animationsteps
  db    0,5
.SitAnimationSpeed_HKL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,3,0                 ;animation every 2,5 frames
.SitAnimationTable_HKL:
  dw ryupage3frame028 | db 3
  dw ryupage1frame022 | db 1
  dw ryupage3frame029 | db 3
  dw ryupage3frame030 | db 3
  dw ryupage3frame031 | db 3
  db  0                       ;movement speed-> move horizontally while performing hard kick ?

.SitHardKickRightFrame:       ;current spriteframe, total animationsteps
  db    0,5
.SitAnimationSpeed_HKR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,3,0                 ;animation every 2,5 frames
.SitAnimationTable_HKR:
  dw ryupage2frame028 | db 2
  dw ryupage0frame022 | db 0
  dw ryupage2frame029 | db 2
  dw ryupage2frame030 | db 2
  dw ryupage2frame031 | db 2
  db  0                       ;movement speed-> move horizontally while performing hard kick ?
  
  
.LeftSoftJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    ryupage1frame024 | db 1
  dw    ryupage1frame024 | db 1
  dw    ryupage1frame010 | db 1  
.RightSoftJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    ryupage0frame024 | db 0
  dw    ryupage0frame024 | db 0
  dw    ryupage0frame010 | db 0
.LeftHardJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    ryupage1frame024 | db 1
  dw    ryupage1frame010 | db 1
  dw    ryupage1frame009 | db 1  
.RightHardJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    ryupage0frame024 | db 0
  dw    ryupage0frame010 | db 0
  dw    ryupage0frame009 | db 0
.LeftSoftJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    ryupage1frame024 | db 1
  dw    ryupage1frame024 | db 1
  dw    ryupage1frame010 | db 1  
.RightSoftJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    ryupage0frame024 | db 0
  dw    ryupage0frame024 | db 0
  dw    ryupage0frame010 | db 0
.LeftHardJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    ryupage1frame024 | db 1
  dw    ryupage1frame010 | db 1
  dw    ryupage1frame009 | db 1  
.RightHardJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    ryupage0frame024 | db 0
  dw    ryupage0frame010 | db 0
  dw    ryupage0frame009 | db 0
.LeftSoftJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    ryupage1frame025 | db 1
  dw    ryupage1frame025 | db 1
  dw    ryupage1frame010 | db 1  
.RightSoftJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    ryupage0frame025 | db 0
  dw    ryupage0frame025 | db 0
  dw    ryupage0frame010 | db 0
.LeftHardJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    ryupage1frame025 | db 1
  dw    ryupage1frame010 | db 1
  dw    ryupage1frame009 | db 1  
.RightHardJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    ryupage0frame025 | db 0
  dw    ryupage0frame010 | db 0
  dw    ryupage0frame009 | db 0
.LeftSoftJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    ryupage1frame023 | db 1
  dw    ryupage1frame023 | db 1
  dw    ryupage1frame010 | db 1  
.RightSoftJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    ryupage0frame023 | db 0
  dw    ryupage0frame023 | db 0
  dw    ryupage0frame010 | db 0
.LeftHardJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    ryupage1frame023 | db 1
  dw    ryupage1frame010 | db 1
  dw    ryupage1frame009 | db 1  
.RightHardJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    ryupage0frame023 | db 0
  dw    ryupage0frame010 | db 0
  dw    ryupage0frame009 | db 0  
  
.LeftStandDefendFrame:
  dw    ryupage3frame000 | db 3
.RightStandDefendFrame:
  dw    ryupage2frame000 | db 2
.LeftBendDefendFrame:
  dw    ryupage3frame001 | db 3
.RightBendDefendFrame:
  dw    ryupage2frame001 | db 2
 
.LeftStandHitFrame:
  dw    ryupage3frame002 | db 3
.RightStandHitFrame:
  dw    ryupage2frame002 | db 2
.LeftBendHitFrame:
  dw    ryupage3frame003 | db 3
.RightBendHitFrame:
  dw    ryupage2frame003 | db 2
.LeftJumpHitFrame:
  dw    ryupage3frame004 | db 3
.RightJumpHitFrame:
  dw    ryupage2frame004 | db 2

.HeavilyHitLeftFrame:        ;current spriteframe, total animationsteps
  db    0,13
.HeavilyHitLeftAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.HeavilyHitLeftAnimationTable:
  dw ryupage3frame004 | db 3
  dw ryupage3frame004 | db 3
  dw ryupage3frame004 | db 3
  dw ryupage3frame004 | db 3
  dw ryupage3frame004 | db 3
  dw ryupage3frame005 | db 3
  dw ryupage3frame005 | db 3
  dw ryupage3frame005 | db 3
  dw ryupage3frame005 | db 3
  dw ryupage3frame005 | db 3
  dw ryupage3frame005 | db 3
  dw ryupage3frame005 | db 3
  dw ryupage3frame005 | db 3

.HeavilyHitRightFrame:       ;current spriteframe, total animationsteps
  db    0,13
.HeavilyHitRightAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.HeavilyHitRightAnimationTable:
  dw ryupage2frame004 | db 2
  dw ryupage2frame004 | db 2
  dw ryupage2frame004 | db 2
  dw ryupage2frame004 | db 2
  dw ryupage2frame004 | db 2
  dw ryupage2frame005 | db 2
  dw ryupage2frame005 | db 2
  dw ryupage2frame005 | db 2
  dw ryupage2frame005 | db 2
  dw ryupage2frame005 | db 2
  dw ryupage2frame005 | db 2
  dw ryupage2frame005 | db 2
  dw ryupage2frame005 | db 2
  
.JumpHitLeftFrame:        ;current spriteframe, total animationsteps
  db    0,13
.JumphitLeftAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.JumphitLeftAnimationTable:
  dw ryupage3frame004 | db 3
  dw ryupage3frame004 | db 3
  dw ryupage3frame004 | db 3
  dw ryupage3frame004 | db 3
  dw ryupage1frame012 | db 1
  dw ryupage1frame013 | db 1
  dw ryupage1frame014 | db 1
  dw ryupage1frame010 | db 1
  dw ryupage1frame009 | db 1
  dw ryupage1frame009 | db 1
  dw ryupage1frame009 | db 1
  dw ryupage1frame009 | db 1
  dw ryupage1frame009 | db 1

.JumpHitRightFrame:       ;current spriteframe, total animationsteps
  db    0,13
.JumphitRightAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.JumphitRightAnimationTable:
  dw ryupage2frame004 | db 2
  dw ryupage2frame004 | db 2
  dw ryupage2frame004 | db 2
  dw ryupage2frame004 | db 2
  dw ryupage0frame012 | db 0
  dw ryupage0frame013 | db 0
  dw ryupage0frame014 | db 0
  dw ryupage0frame010 | db 0
  dw ryupage0frame009 | db 0
  dw ryupage0frame009 | db 0
  dw ryupage0frame009 | db 0
  dw ryupage0frame009 | db 0
  dw ryupage0frame009 | db 0  

.KnockDownRecoverLeftFrame:
  db    0,5
.AnimationSpeed_KDARR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_KDARR:
  dw ryupage3frame006 | db 3
  dw ryupage3frame006 | db 3
  dw ryupage3frame007 | db 3
  dw ryupage3frame008 | db 3
  dw ryupage3frame009 | db 3

.KnockDownRecoverRightFrame:
  db    0,5
.AnimationSpeed_KDARL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_KDARL:
  dw ryupage2frame006 | db 2
  dw ryupage2frame006 | db 2
  dw ryupage2frame007 | db 2
  dw ryupage2frame008 | db 2
  dw ryupage2frame009 | db 2

.TossLeftFrame:
  db    0,2
.AnimationSpeed_TossL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,9,0                 ;animation every 2,5 frames
.AnimationTable_TossL:
  dw ryupage3frame010 | db 3
  dw ryupage3frame011 | db 3

.TossRightFrame:
  db    0,2
.AnimationSpeed_TossR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,9,0                 ;animation every 2,5 frames
.AnimationTable_TossR:
  dw ryupage2frame010 | db 2
  dw ryupage2frame011 | db 2

.VictoryLeftFrame:
  db    0,3
.AnimationSpeed_VictL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_VictL:
  dw ryupage3frame012 | db 3
  dw ryupage3frame012 | db 3
  dw ryupage3frame012 | db 3

.VictoryRightFrame:
  db    0,3
.AnimationSpeed_VictR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_VictR:
  dw ryupage2frame012 | db 2
  dw ryupage2frame012 | db 2
  dw ryupage2frame012 | db 2

;Projectile shot (hadouken)
.Special1MovementTablePointer:
  db    0
.Special1DurationTimer:
  db    60                    ;Amount of frames that Special move takes
.Special1MovementTable:      ;movement(y,x)
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, -00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
;shoryuken
.Special2MovementTablePointer:
  db    0
.Special2DurationTimer:
  db    56                    ;Amount of frames that Special move takes
.Special2MovementTable:      ;movement(y,x)
  db    -17,+06, -14,+04, -12,+04, -10,+02, -08,+04, -07,+02, -06,+02, -05,+00, -04,+02, -03,+00, -02,+00, -01,+00, -00,+00, -00,+00, -00,+00
  db    +01,+00, +02,+00, +03,+00, +05,+00, +06,+00, +08,+00, +09,+00, +12,+00, +13,+00, +15,+00, +18,+00, +00,+00, +00,+00, +00,+00, +00,+00
;hurricane kick ryu part 1 (taking off)
.Special3MovementTablePointer:
  db    0
.Special3DurationTimer:
  db    08                    ;Amount of frames that Special move takes
.Special3MovementTable:      ;movement(y,x)
  db    -03,+02, -03,+02, -03,+04, -03,+02 | ds 22+30
;hurricane kick ryu part 2 (the actual spinning part)
.Special4MovementTablePointer:
  db    0
.Special4DurationTimer:
  db    38                    ;Amount of frames that Special move takes
.Special4MovementTable:      ;movement(y,x)
  db    +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04
  db    +00,+04, +00,+04, +00,+04, +00,+04 | ds 22
;hurricane kick ryu part 3  (landing)
.Special5MovementTablePointer:
  db    0
.Special5DurationTimer:
  db    30                    ;Amount of frames that Special move takes
.Special5MovementTable:      ;movement(y,x)
  db    +03,+02, +04,+04, +05,+02, +06,+02, +07,+04, +08,+02, +09,+02, +10,+02, +11,+00, +12,+02, +13,+02, +14,+00, +15,+02, +16,+00, +17,+00
  ds    30

;Projectile shot (hadouken)
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
;shoryuken
.VariableTableSpecial2:
  db    7                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    1                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    0                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    1                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;hurricane kick ryu part 1 (taking off)
.VariableTableSpecial3:                 ;ch=charge, d=down, u=up, b=back, f=foreward, p=punch, k=kick, r=repeat
  db    6                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    1                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    4                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    0                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;hurricane kick ryu part 2 (the actual spinning part)
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
;hurricane kick ryu part 3  (landing)
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

;Projectile shot (hadouken)
.Special1LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;current speed step, ani. speed, ani. speed half frame
  dw ryupage3frame013 | db 3
  dw ryupage3frame014 | db 3
  dw ryupage3frame014 | db 3
  dw ryupage3frame014 | db 3
.Special1RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;current speed step, ani. speed, ani. speed half frame
  dw ryupage2frame013 | db 2
  dw ryupage2frame014 | db 2
  dw ryupage2frame014 | db 2
  dw ryupage2frame014 | db 2  
;shoryuken
.Special2LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,17,0                 ;current speed step, ani. speed, ani. speed half frame
  dw ryupage3frame022 | db 3
  dw ryupage3frame023 | db 3
  dw ryupage3frame023 | db 3
  dw ryupage3frame023 | db 3
.Special2RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,17,0                 ;current speed step, ani. speed, ani. speed half frame
  dw ryupage2frame022 | db 2
  dw ryupage2frame023 | db 2
  dw ryupage2frame023 | db 2
  dw ryupage2frame023 | db 2  
;hurricane kick ryu part 1 (taking off)
.Special3LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,2,0                 ;current speed step, ani. speed, ani. speed half frame
  dw ryupage1frame009 | db 1
  dw ryupage1frame009 | db 1
  dw ryupage1frame009 | db 1
  dw ryupage1frame009 | db 1
.Special3RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,2,0                 ;current speed step, ani. speed, ani. speed half frame
  dw ryupage0frame009 | db 0
  dw ryupage0frame009 | db 0
  dw ryupage0frame009 | db 0
  dw ryupage0frame009 | db 0
;hurricane kick ryu part 2 (the actual spinning part)
.Special4LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,2,0                 ;current speed step, ani. speed, ani. speed half frame
  dw ryupage3frame021 | db 3
  dw ryupage3frame018 | db 3
  dw ryupage3frame019 | db 3
  dw ryupage3frame020 | db 3
.Special4RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,2,0                 ;current speed step, ani. speed, ani. speed half frame
  dw ryupage2frame021 | db 2
  dw ryupage2frame018 | db 2
  dw ryupage2frame019 | db 2
  dw ryupage2frame020 | db 2
;hurricane kick ryu part 3  (landing)
.Special5LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;current speed step, ani. speed, ani. speed half frame
  dw ryupage3frame019 | db 3
  dw ryupage1frame010 | db 1
  dw ryupage1frame009 | db 1
  dw ryupage1frame009 | db 1
.Special5RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;current speed step, ani. speed, ani. speed half frame
  dw ryupage2frame019 | db 2
  dw ryupage0frame010 | db 0
  dw ryupage0frame009 | db 0
  dw ryupage0frame009 | db 0

.GettingTossedLeftFrame:      ;current spriteframe, total animationsteps
  db    0,4
.GettingTossedLeftAnimationSpeed:
  db    0,9,1                 ;current speed step, ani. speed, ani. speed half frame
.GettingTossedLeftAnimationTable:
  dw ryupage3frame002 | db 3
  dw ryupage3frame006 | db 3
  dw ryupage3frame005 | db 3
  dw ryupage3frame005 | db 3

.GettingTossedRightFrame:     ;current spriteframe, total animationsteps
  db    0,4
.GettingTossedRightAnimationSpeed:
  db    0,9,1                 ;current speed step, ani. speed, ani. speed half frame
.GettingTossedRightAnimationTable:
  dw ryupage2frame002 | db 2
  dw ryupage2frame006 | db 2
  dw ryupage2frame005 | db 2
  dw ryupage2frame005 | db 2

.DamageTabel: ;SoftStandPunch, HardStandPunch, SoftStandKick, HardStandKick, SoftSitPunch, HardSitPunch, 
              ;SoftSitKick, HardSitKick, JumpSoftPunch, JumpHardPunch, JumpSoftKick, JumpHardKick, Special1-5, Toss
  db    12,16,12,16,12,16,12,20, 12,16,12,16,  0,20,0,08,0, 20
.endDamageTabel:

.ProjectileLeftFrame:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,1,0                 ;current speed step, ani. speed, ani. speed half frame
  dw ryupage3frame015 | db 3
  dw ryupage3frame016 | db 3
  dw ryupage3frame024 | db 3
  ds  3
.ProjectileRightFrame:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,1,0                 ;current speed step, ani. speed, ani. speed half frame
  dw ryupage2frame015 | db 2
  dw ryupage2frame016 | db 2
  dw ryupage2frame024 | db 2  
  ds  3
.ProjectileLeftEndFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,1                 ;current speed step, ani. speed, ani. speed half frame
  dw ryupage3frame025 | db 3
  dw ryupage3frame026 | db 3
  dw ryupage3frame027 | db 3
  dw ryupage3frame017 | db 3
.ProjectileRightEndFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,1                 ;current speed step, ani. speed, ani. speed half frame
  dw ryupage2frame025 | db 2
  dw ryupage2frame026 | db 2
  dw ryupage2frame027 | db 2
  dw ryupage2frame017 | db 2

.DiedLeftFrame:
  dw ryupage3frame007 | db 3
.DiedRightFrame:
  dw ryupage2frame007 | db 2
  
