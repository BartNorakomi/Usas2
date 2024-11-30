CammyActions:
.LeftIdleFrame:                ;current spriteframe, total animationsteps
  db    0,8
.LeftIdleAnimationSpeed:      ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.LeftIdleTable:
  dw cammypage1frame000 | db 1 | dw cammypage1frame001 | db 1
  dw cammypage1frame002 | db 1 | dw cammypage1frame003 | db 1
  dw cammypage1frame004 | db 1 | dw cammypage1frame003 | db 1
  dw cammypage1frame002 | db 1 | dw cammypage1frame001 | db 1
.RightIdleFrame:              ;current spriteframe, total animationsteps
  db    0,8
.RightIdleAnimationSpeed:     ;current speed step, ani. speed, ani. speed half frame
  db    0,3,0                 ;animation every 2,5 frames
.rightIdleTable:
  dw cammypage0frame000 | db 0 | dw cammypage0frame001 | db 0
  dw cammypage0frame002 | db 0 | dw cammypage0frame003 | db 0
  dw cammypage0frame004 | db 0 | dw cammypage0frame003 | db 0
  dw cammypage0frame002 | db 0 | dw cammypage0frame001 | db 0
  
.LeftBendFrame:
  dw    cammypage1frame011 | db 1
.RightBendFrame:
  dw    cammypage0frame011 | db 0

;player facing left walking left
.LeftWalkLeftFrame:            ;current spriteframe, total animationsteps
  db    0,6
.LeftWalkLeftAnimationSpeed:  ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.LeftWalkLeftTable:
  dw cammypage1frame007 | db 1 | dw cammypage1frame008 | db 1
  dw cammypage1frame009 | db 1 | dw cammypage1frame010 | db 1
  dw cammypage1frame005 | db 1 | dw cammypage1frame006 | db 1
  ds  6
.LeftWalkLeftstartingframenumber:
  db    4
.LeftWalkLeftstartingframe:
  dw cammypage1frame005 | db 1
  
;player facing left walking right
.LeftWalkRightFrame:          ;current spriteframe, total animationsteps
  db    0,6
.LeftWalkRightAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.LeftWalkRightTable:
  dw cammypage1frame008 | db 1 | dw cammypage1frame007 | db 1
  dw cammypage1frame006 | db 1 | dw cammypage1frame005 | db 1
  dw cammypage1frame010 | db 1 | dw cammypage1frame009 | db 1
  ds  6
.LeftWalkRightstartingframenumber:
  db    4
.LeftWalkRightstartingframe:
  dw cammypage1frame010 | db 1

;player facing right walking left
.RightWalkLeftFrame:          ;current spriteframe, total animationsteps
  db    0,6
.RightWalkLeftAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.RightWalkLeftTable:
  dw cammypage0frame008 | db 0 | dw cammypage0frame007 | db 0
  dw cammypage0frame006 | db 0 | dw cammypage0frame005 | db 0
  dw cammypage0frame010 | db 0 | dw cammypage0frame009 | db 0  
  ds  6
.RightWalkLeftstartingframenumber:
  db    4
.RightWalkLeftstartingframe:
  dw cammypage0frame010 | db 0
 
;player facing right walking right
.RightWalkRightFrame:         ;current spriteframe, total animationsteps
  db    0,6
.RightWalkRightAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.RightWalkRightTable:
  dw cammypage0frame007 | db 0 | dw cammypage0frame008 | db 0
  dw cammypage0frame009 | db 0 | dw cammypage0frame010 | db 0
  dw cammypage0frame005 | db 0 | dw cammypage0frame006 | db 0  
  ds  6
.RightWalkRightstartingframenumber:
  db    4
.RightWalkRightstartingframe:
  dw cammypage0frame005 | db 0

.HorSpeedWalkSlowTable:       ;lenght table, pointer, movement speed
  db    5,0,   4,4,4,2,4
.HorSpeedWalkFastTable:       ;lenght table, pointer, movement speed
  db    5,0,   6,4,6,4,4

.LeftJumpStraightStartframe:
  dw cammypage1frame011 | db 1
.LeftJumpStraightanimationTable:
  db    00 | dw cammypage1frame012 | db 1
  db    06 | dw cammypage1frame013 | db 1
  db    08 | dw cammypage1frame014 | db 1
  db    14 | dw cammypage1frame013 | db 1
  db    16 | dw cammypage1frame012 | db 1
  db    24 | dw cammypage1frame011 | db 1
  ds    4

.LeftJumpLeftStartframe:
  dw cammypage1frame011 | db 1
.LeftJumpLeftanimationTable:  ;face left, jump left
  db    00 | dw cammypage1frame015 | db 1
  db    06 | dw cammypage1frame016 | db 1
  db    09 | dw cammypage1frame017 | db 1
  db    12 | dw cammypage1frame018 | db 1
  db    15 | dw cammypage1frame019 | db 1
  db    18 | dw cammypage1frame012 | db 1
  db    24 | dw cammypage1frame011 | db 1

.LeftJumpRightStartframe:
  dw cammypage1frame011 | db 1
.LeftJumpRightanimationTable: ;face left, jump right
  db    00 | dw cammypage1frame019 | db 1
  db    06 | dw cammypage1frame018 | db 1
  db    09 | dw cammypage1frame017 | db 1
  db    12 | dw cammypage1frame016 | db 1
  db    15 | dw cammypage1frame015 | db 1
  db    19 | dw cammypage1frame012 | db 1
  db    24 | dw cammypage1frame011 | db 1

.RightJumpStraightStartframe:
  dw cammypage0frame011 | db 0
.RightJumpStraightanimationTable:
  db    00 | dw cammypage0frame012 | db 0
  db    06 | dw cammypage0frame013 | db 0
  db    08 | dw cammypage0frame014 | db 0
  db    14 | dw cammypage0frame013 | db 0
  db    16 | dw cammypage0frame012 | db 0
  db    24 | dw cammypage0frame011 | db 0
  ds    4

.RightJumpLeftStartframe:
  dw cammypage0frame011 | db 0
.RightJumpLeftanimationTable: ;face right, jump left
  db    00 | dw cammypage0frame019 | db 0
  db    06 | dw cammypage0frame018 | db 0
  db    09 | dw cammypage0frame017 | db 0
  db    12 | dw cammypage0frame016 | db 0
  db    15 | dw cammypage0frame015 | db 0
  db    19 | dw cammypage0frame012 | db 0
  db    24 | dw cammypage0frame011 | db 0
  
.RightJumpRightStartframe:
  dw cammypage0frame011 | db 0
.RightJumpRightanimationTable:;face right, jump right
  db    00 | dw cammypage0frame015 | db 0
  db    06 | dw cammypage0frame016 | db 0
  db    09 | dw cammypage0frame017 | db 0
  db    12 | dw cammypage0frame018 | db 0
  db    15 | dw cammypage0frame019 | db 0
  db    18 | dw cammypage0frame012 | db 0
  db    24 | dw cammypage0frame011 | db 0


.jumptable:                  ;pointer, y movement
  db    0,  -13,-11,-10,-09,-08,-07,-06,-05,-04,-03,-02
  db    -01,-00,+01,+02,+03,+04,+05,+06,+07,+08
  db    +09,+10,+12,+12
  db    +00,+00,+00,+128      ;end jumptable with 3x 0 otherwise "landing" sfx will not be player
  ds    16

.HorSpeedJumpSlowTable:       ;lenght table, pointer, movement speed
  db    5,0,   4,4,4,4,4
.HorSpeedJumpFastTable:       ;lenght table, pointer, movement speed
  db    5,0,   4,4,6,4,4

;player SoftStandPunching
.StandSoftPunchLeftFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SPL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SPL:
  dw cammypage1frame020 | db 1
  dw cammypage1frame021 | db 1
  dw cammypage1frame020 | db 1

.StandSoftPunchRightFrame:    ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SPR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SPR:
  dw cammypage0frame020 | db 0
  dw cammypage0frame021 | db 0
  dw cammypage0frame020 | db 0

;player HardStandPunching
.StandHardPunchLeftFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HPL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.AnimationTable_HPL:
  dw cammypage1frame020 | db 1
  dw cammypage1frame022 | db 1
  dw cammypage1frame020 | db 1

.StandHardPunchRightFrame:    ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HPR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.AnimationTable_HPR:
  dw cammypage0frame020 | db 0
  dw cammypage0frame022 | db 0
  dw cammypage0frame020 | db 0

;player SoftStandKicking
.StandSoftKickLeftFrame:      ;current spriteframe, total animationsteps
  db    0,4
.AnimationSpeed_SKL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SKL:
  dw cammypage1frame023 | db 1
  dw cammypage1frame024 | db 1
  dw cammypage1frame024 | db 1
  dw cammypage1frame023 | db 1

.StandSoftKickRightFrame:     ;current spriteframe, total animationsteps
  db    0,4
.AnimationSpeed_SKR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SKR:
  dw cammypage0frame023 | db 0
  dw cammypage0frame024 | db 0
  dw cammypage0frame024 | db 0
  dw cammypage0frame023 | db 0

;player HardStandKicking
.StandHardKickLeftFrame:      ;current spriteframe, total animationsteps
  db    0,6
.AnimationSpeed_HKL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,1,1                 ;animation every 2,5 frames
.AnimationTable_HKL:
  dw cammypage1frame025 | db 1
  dw cammypage1frame026 | db 1
  dw cammypage1frame027 | db 1
  dw cammypage1frame027 | db 1
  dw cammypage1frame026 | db 1
  dw cammypage1frame025 | db 1

.StandHardKickRightFrame:     ;current spriteframe, total animationsteps
  db    0,6
.AnimationSpeed_HKR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,1,1                 ;animation every 2,5 frames
.AnimationTable_HKR:
  dw cammypage0frame025 | db 0
  dw cammypage0frame026 | db 0
  dw cammypage0frame027 | db 0
  dw cammypage0frame027 | db 0
  dw cammypage0frame026 | db 0
  dw cammypage0frame025 | db 0
  
;player SoftSitPunching
.SitSoftPunchLeftFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SPL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SPL:
  dw cammypage1frame028 | db 1
  dw cammypage1frame029 | db 1
  dw cammypage1frame028 | db 1

.SitSoftPunchRightFrame:      ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SPR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SPR:
  dw cammypage0frame028 | db 0
  dw cammypage0frame029 | db 0
  dw cammypage0frame028 | db 0

;player HardSitPunching
.SitHardPunchLeftFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_HPL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,3,0                 ;animation every 2,5 frames
.SitAnimationTable_HPL:
  dw cammypage3frame034 | db 3
  dw cammypage3frame035 | db 3
  dw cammypage3frame036 | db 3

.SitHardPunchRightFrame:      ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_HPR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,3,0                 ;animation every 2,5 frames
.SitAnimationTable_HPR:
  dw cammypage2frame034 | db 2
  dw cammypage2frame035 | db 2
  dw cammypage2frame036 | db 2

;player SoftSitKicking
.SitSoftKickLeftFrame:        ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SKL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SKL:
  dw cammypage3frame033 | db 3
  dw cammypage1frame030 | db 1
  dw cammypage3frame033 | db 3

.SitSoftKickRightFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SKR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SKR:
  dw cammypage2frame033 | db 2
  dw cammypage0frame030 | db 0
  dw cammypage2frame033 | db 2

;player HardSitKicking
.SitHardKickLeftFrame:        ;current spriteframe, total animationsteps
  db    0,5
.SitAnimationSpeed_HKL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.SitAnimationTable_HKL:
  dw cammypage1frame031 | db 1
  dw cammypage1frame032 | db 1
  dw cammypage3frame000 | db 3
  dw cammypage3frame001 | db 3
  dw cammypage3frame002 | db 3
  db  0                       ;movement speed-> move horizontally while performing hard kick ?

.SitHardKickRightFrame:       ;current spriteframe, total animationsteps
  db    0,5
.SitAnimationSpeed_HKR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.SitAnimationTable_HKR:
  dw cammypage0frame031 | db 0
  dw cammypage0frame032 | db 0
  dw cammypage2frame000 | db 2
  dw cammypage2frame001 | db 2
  dw cammypage2frame002 | db 2
  db  0                       ;movement speed-> move horizontally while performing hard kick ?

.LeftSoftJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,5,0                 ;animation every 2,5 frames
  dw    cammypage3frame003 | db 3
  dw    cammypage3frame003 | db 3
  dw    cammypage3frame003 | db 3
.RightSoftJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,5,0                 ;animation every 2,5 frames
  dw    cammypage2frame003 | db 2
  dw    cammypage2frame003 | db 2
  dw    cammypage2frame003 | db 2
.LeftHardJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,1                 ;animation every 2,5 frames
  dw    cammypage3frame003 | db 3
  dw    cammypage1frame012 | db 1
  dw    cammypage1frame013 | db 1
.RightHardJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,1                 ;animation every 2,5 frames
  dw    cammypage2frame003 | db 2
  dw    cammypage0frame012 | db 0
  dw    cammypage0frame013 | db 0

.LeftSoftJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,0                 ;animation every 2,5 frames
  dw    cammypage3frame003 | db 3
  dw    cammypage3frame003 | db 3
  dw    cammypage1frame013 | db 1
.RightSoftJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,0                 ;animation every 2,5 frames
  dw    cammypage2frame003 | db 2
  dw    cammypage2frame003 | db 2
  dw    cammypage0frame013 | db 0
.LeftHardJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,1                 ;animation every 2,5 frames
  dw    cammypage3frame003 | db 3
  dw    cammypage1frame013 | db 1
  dw    cammypage1frame012 | db 1
.RightHardJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,1                 ;animation every 2,5 frames
  dw    cammypage2frame003 | db 2
  dw    cammypage0frame013 | db 0
  dw    cammypage0frame012 | db 0

.LeftSoftJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,3,1                 ;animation every 2,5 frames
  dw    cammypage3frame037 | db 3
  dw    cammypage3frame004 | db 3
  dw    cammypage3frame004 | db 3
.RightSoftJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,3,1                 ;animation every 2,5 frames
  dw    cammypage2frame037 | db 2
  dw    cammypage2frame004 | db 2
  dw    cammypage2frame004 | db 2
  
.LeftHardJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,1                 ;animation every 2,5 frames
  dw    cammypage3frame005 | db 3
  dw    cammypage3frame006 | db 3
  dw    cammypage1frame014 | db 1
.RightHardJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,1                 ;animation every 2,5 frames
  dw    cammypage2frame005 | db 2
  dw    cammypage2frame006 | db 2
  dw    cammypage0frame014 | db 0
  
.LeftSoftJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;animation every 2,5 frames
  dw    cammypage3frame037 | db 3
  dw    cammypage3frame004 | db 3
  dw    cammypage3frame004 | db 3
.RightSoftJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;animation every 2,5 frames
  dw    cammypage2frame037 | db 2
  dw    cammypage2frame004 | db 2
  dw    cammypage2frame004 | db 2
  
.LeftHardJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,1                 ;animation every 2,5 frames
  dw    cammypage3frame005 | db 3
  dw    cammypage3frame006 | db 3
  dw    cammypage1frame014 | db 1
.RightHardJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,1                 ;animation every 2,5 frames
  dw    cammypage2frame005 | db 2
  dw    cammypage2frame006 | db 2
  dw    cammypage0frame014 | db 0
  
.LeftStandDefendFrame:
  dw    cammypage3frame007 | db 3
.RightStandDefendFrame:
  dw    cammypage2frame007 | db 2
.LeftBendDefendFrame:
  dw    cammypage3frame008 | db 3
.RightBendDefendFrame:
  dw    cammypage2frame008 | db 2
 
.LeftStandHitFrame:
  dw    cammypage3frame009 | db 3
.RightStandHitFrame:
  dw    cammypage2frame009 | db 2
.LeftBendHitFrame:
  dw    cammypage3frame010 | db 3
.RightBendHitFrame:
  dw    cammypage2frame010 | db 2
.LeftJumpHitFrame:
  dw    cammypage3frame013 | db 3
.RightJumpHitFrame:
  dw    cammypage2frame013 | db 2

.HeavilyHitLeftFrame:         ;current spriteframe, total animationsteps
  db    0,13
.HeavilyHitLeftAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.HeavilyHitLeftAnimationTable:
  dw cammypage3frame011 | db 3
  dw cammypage3frame011 | db 3
  dw cammypage3frame011 | db 3
  dw cammypage3frame011 | db 3
  dw cammypage3frame012 | db 3
  dw cammypage3frame012 | db 3
  dw cammypage3frame012 | db 3
  dw cammypage3frame012 | db 3
  dw cammypage3frame012 | db 3
  dw cammypage3frame012 | db 3
  dw cammypage3frame012 | db 3
  dw cammypage3frame012 | db 3
  dw cammypage3frame012 | db 3

.HeavilyHitRightFrame:        ;current spriteframe, total animationsteps
  db    0,13
.HeavilyHitRightAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.HeavilyHitRightAnimationTable:
  dw cammypage2frame011 | db 2
  dw cammypage2frame011 | db 2
  dw cammypage2frame011 | db 2
  dw cammypage2frame011 | db 2
  dw cammypage2frame012 | db 2
  dw cammypage2frame012 | db 2
  dw cammypage2frame012 | db 2
  dw cammypage2frame012 | db 2
  dw cammypage2frame012 | db 2
  dw cammypage2frame012 | db 2
  dw cammypage2frame012 | db 2
  dw cammypage2frame012 | db 2
  dw cammypage2frame012 | db 2
  
.JumpHitLeftFrame:        ;current spriteframe, total animationsteps
  db    0,13
.JumphitLeftAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.JumphitLeftAnimationTable:
  dw cammypage3frame013 | db 3
  dw cammypage3frame013 | db 3
  dw cammypage3frame013 | db 3
  dw cammypage3frame013 | db 3
  dw cammypage3frame013 | db 3
  dw cammypage3frame014 | db 3
  dw cammypage1frame018 | db 1
  dw cammypage1frame017 | db 1
  dw cammypage1frame016 | db 1
  dw cammypage1frame015 | db 1
  dw cammypage1frame015 | db 1
  dw cammypage1frame015 | db 1
  dw cammypage1frame015 | db 1

.JumpHitRightFrame:       ;current spriteframe, total animationsteps
  db    0,13
.JumphitRightAnimationSpeed:
  db    0,2,0                 ;current speed step, ani. speed, ani. speed half frame
.JumphitRightAnimationTable:
  dw cammypage2frame013 | db 2
  dw cammypage2frame013 | db 2
  dw cammypage2frame013 | db 2
  dw cammypage2frame013 | db 2
  dw cammypage2frame013 | db 2
  dw cammypage2frame014 | db 2
  dw cammypage0frame018 | db 0
  dw cammypage0frame017 | db 0
  dw cammypage0frame016 | db 0
  dw cammypage0frame015 | db 0
  dw cammypage0frame015 | db 0
  dw cammypage0frame015 | db 0
  dw cammypage0frame015 | db 0  

.KnockDownRecoverLeftFrame:
  db    0,5
.AnimationSpeed_KDARR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.AnimationTable_KDARR:
  dw cammypage3frame019 | db 3
  dw cammypage3frame015 | db 3
  dw cammypage3frame016 | db 3
  dw cammypage3frame017 | db 3
  dw cammypage3frame018 | db 3

.KnockDownRecoverRightFrame:
  db    0,5
.AnimationSpeed_KDARL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.AnimationTable_KDARL:
  dw cammypage2frame019 | db 2
  dw cammypage2frame015 | db 2
  dw cammypage2frame016 | db 2
  dw cammypage2frame017 | db 2
  dw cammypage2frame018 | db 2

.TossLeftFrame:
  db    0,2
.AnimationSpeed_TossL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,9,0                 ;animation every 2,5 frames
.AnimationTable_TossL:
  dw cammypage3frame020 | db 3
  dw cammypage3frame021 | db 3

.TossRightFrame:
  db    0,2
.AnimationSpeed_TossR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,9,0                 ;animation every 2,5 frames
.AnimationTable_TossR:
  dw cammypage2frame020 | db 2
  dw cammypage2frame021 | db 2

.VictoryLeftFrame:
  db    0,3
.AnimationSpeed_VictL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_VictL:
  dw cammypage3frame022 | db 3
  dw cammypage3frame022 | db 3
  dw cammypage3frame022 | db 3

.VictoryRightFrame:
  db    0,3
.AnimationSpeed_VictR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_VictR:
  dw cammypage2frame022 | db 2
  dw cammypage2frame022 | db 2
  dw cammypage2frame022 | db 2

 

;Spiral Arrow
.Special1MovementTablePointer:
  db    0
.Special1DurationTimer:
  db    24                    ;Amount of frames that Special move takes
.Special1MovementTable:      ;movement(y,x)
  db    -13,+03, +00,+05, +00,+08, +01,+08, +00,+08, +01,+08, +01,+08, +02,+08, +01,+08, +02,+08, +02,+08, +03,+08, +00,+00, +00,+00, +00,+00
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
;Axel Spin Knuckle
.Special2MovementTablePointer:
  db    0
.Special2DurationTimer:
  db    50                    ;Amount of frames that Special move takes
.Special2MovementTable:      ;movement(y,x)
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+06, +00,+06, +00,+06, +00,+06, +00,+06, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
;Cannon Spike 
.Special3MovementTablePointer:
  db    0
.Special3DurationTimer:
  db    24                    ;Amount of frames that Special move takes
.Special3MovementTable:      ;movement(y,x)
  db    +00,+00, +00,+00, +00,+06, +00,+00, +00,+00, +00,+00, +00,+04, +00,+04, +00,+04, -04,+06, -08,+06, -12,+06, +00,+00, +00,+00, +00,+00
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
;Cannon Spike part 2
.Special4MovementTablePointer:
  db    0
.Special4DurationTimer:
  db    60                    ;Amount of frames that Special move takes
.Special4MovementTable:      ;movement(y,x)
  db    -16,+06, -14,+04, -12,+06, -08,+04, -04,+02, -02,+00, -01,+00, +00,+00, +01,+00, +02,+00, +05,+00, +08,+00, +11,+00, +14,+00, +16,+00
  db    +17,+00, +20,+00, +20,+00, +20,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
;Spiral Arrow part 2
.Special5MovementTablePointer:
  db    0
.Special5DurationTimer:
  db    32                    ;Amount of frames that Special move takes
.Special5MovementTable:      ;movement(y,x)
  db    +00,+06, +00,+04, +00,+02, +00,+02, +00,+00, +00,+02, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
;Spiral Arrow
.VariableTableSpecial1:
  db    5                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    1                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    5                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    1                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;Axel Spin Knuckle
.VariableTableSpecial2:                 ;ch=charge, d=down, u=up, b=back, f=foreward, p=punch, k=kick, r=repeat
  db    2                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    1                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    0                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    1                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    2                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;Cannon Spike 
.VariableTableSpecial3:
  db    1                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    1                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    4                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    1                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;Cannon Spike part 2
.VariableTableSpecial4:
  db    0                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    0                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    0                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    1                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;Spiral Arrow part 2
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
;Spiral Arrow
.Special1LeftFrame:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,2,0                 ;current speed step, ani. speed, ani. speed half frame
  dw cammypage3frame023 | db 3
  dw cammypage3frame024 | db 3
  dw cammypage3frame025 | db 3
  ds  3
.Special1RightFrame:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,2,0                 ;current speed step, ani. speed, ani. speed half frame
  dw cammypage2frame023 | db 2
  dw cammypage2frame024 | db 2
  dw cammypage2frame025 | db 2
  ds  3
;Axel Spin Knuckle
.Special2LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,5,0                 ;current speed step, ani. speed, ani. speed half frame
  dw cammypage3frame026 | db 3
  dw cammypage3frame027 | db 3
  dw cammypage3frame030 | db 3
  dw cammypage3frame031 | db 3
.Special2RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,5,0                 ;current speed step, ani. speed, ani. speed half frame
  dw cammypage2frame026 | db 2
  dw cammypage2frame027 | db 2
  dw cammypage2frame030 | db 2
  dw cammypage2frame031 | db 2
;Cannon Spike 
.Special3LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;current speed step, ani. speed, ani. speed half frame
  dw cammypage3frame026 | db 3
  dw cammypage3frame027 | db 3
  dw cammypage3frame028 | db 3
  dw cammypage3frame029 | db 3
.Special3RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;current speed step, ani. speed, ani. speed half frame
  dw cammypage2frame026 | db 2
  dw cammypage2frame027 | db 2
  dw cammypage2frame028 | db 2
  dw cammypage2frame029 | db 2
;Cannon Spike part 2
.Special4LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,4,1                 ;current speed step, ani. speed, ani. speed half frame
  dw cammypage3frame029 | db 3
  dw cammypage3frame029 | db 3
  dw cammypage1frame016 | db 1
  dw cammypage1frame015 | db 1
.Special4RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,4,1                 ;current speed step, ani. speed, ani. speed half frame
  dw cammypage2frame029 | db 2
  dw cammypage2frame029 | db 2
  dw cammypage0frame016 | db 0
  dw cammypage0frame015 | db 0
;Spiral Arrow part 2
.Special5LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,4,0                 ;current speed step, ani. speed, ani. speed half frame
  dw cammypage3frame032 | db 3
  dw cammypage3frame008 | db 3
  dw cammypage1frame011 | db 1
  dw cammypage1frame011 | db 1
.Special5RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,4,0                 ;current speed step, ani. speed, ani. speed half frame
  dw cammypage2frame032 | db 2
  dw cammypage2frame008 | db 2
  dw cammypage0frame011 | db 0
  dw cammypage0frame011 | db 0

.GettingTossedLeftFrame:      ;current spriteframe, total animationsteps
  db    0,4
.GettingTossedLeftAnimationSpeed:
  db    0,9,1                 ;current speed step, ani. speed, ani. speed half frame
.GettingTossedLeftAnimationTable:
  dw cammypage3frame009 | db 3
  dw cammypage3frame013 | db 3
  dw cammypage3frame014 | db 3
  dw cammypage3frame014 | db 3

.GettingTossedRightFrame:     ;current spriteframe, total animationsteps
  db    0,4
.GettingTossedRightAnimationSpeed:
  db    0,9,1                 ;current speed step, ani. speed, ani. speed half frame
.GettingTossedRightAnimationTable:
  dw cammypage2frame009 | db 2
  dw cammypage2frame013 | db 2
  dw cammypage2frame014 | db 2
  dw cammypage2frame014 | db 2

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
  dw cammypage3frame019 | db 3
.DiedRightFrame:
  dw cammypage2frame019 | db 2
  