GuileActions:
.LeftIdleFrame:                ;current spriteframe, total animationsteps
  db    0,4
.LeftIdleAnimationSpeed:      ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.LeftIdleTable:
  dw guilepage1frame001 | db 1 | dw guilepage1frame000 | db 1
  dw guilepage1frame001 | db 1 | dw guilepage1frame002 | db 1
  ds  12
.RightIdleFrame:              ;current spriteframe, total animationsteps
  db    0,4
.RightIdleAnimationSpeed:     ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.rightIdleTable:
  dw guilepage0frame001 | db 0 | dw guilepage1frame000 | db 0
  dw guilepage0frame001 | db 0 | dw guilepage1frame002 | db 0
  ds  12  
.LeftBendFrame:
  dw    guilepage1frame008 | db 1
.RightBendFrame:
  dw    guilepage0frame008 | db 0

;player facing left walking left
.LeftWalkLeftFrame:            ;current spriteframe, total animationsteps
  db    0,5
.LeftWalkLeftAnimationSpeed:  ;current speed step, ani. speed, ani. speed half frame
  db    0,3,0                 ;animation every 2,5 frames
.LeftWalkLeftTable:
  dw guilepage1frame005 | db 1 | dw guilepage1frame006 | db 1
  dw guilepage1frame007 | db 1 | dw guilepage1frame003 | db 1
  dw guilepage1frame004 | db 1
  ds    9
.LeftWalkLeftstartingframenumber:
  db    3
.LeftWalkLeftstartingframe:
  dw guilepage1frame003 | db 1
  
;player facing left walking right
.LeftWalkRightFrame:          ;current spriteframe, total animationsteps
  db    0,5
.LeftWalkRightAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,3,0                 ;animation every 2,5 frames
.LeftWalkRightTable:
  dw guilepage1frame004 | db 1 | dw guilepage1frame003 | db 1
  dw guilepage1frame007 | db 1 | dw guilepage1frame006 | db 1
  dw guilepage1frame005 | db 1
  ds    9
.LeftWalkRightstartingframenumber:
  db    2
.LeftWalkRightstartingframe:
  dw guilepage1frame007 | db 1

;player facing right walking left
.RightWalkLeftFrame:          ;current spriteframe, total animationsteps
  db    0,5
.RightWalkLeftAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,3,0                 ;animation every 2,5 frames
.RightWalkLeftTable:
  dw guilepage0frame005 | db 0 | dw guilepage0frame004 | db 0
  dw guilepage0frame003 | db 0 | dw guilepage0frame007 | db 0
  dw guilepage0frame006 | db 0
  ds    9
.RightWalkLeftstartingframenumber:
  db    3
.RightWalkLeftstartingframe:
  dw guilepage0frame007 | db 0
 
;player facing right walking right
.RightWalkRightFrame:         ;current spriteframe, total animationsteps
  db    0,5
.RightWalkRightAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,3,0                 ;animation every 2,5 frames
.RightWalkRightTable:
  dw guilepage0frame007 | db 0 | dw guilepage0frame003 | db 0
  dw guilepage0frame004 | db 0 | dw guilepage0frame005 | db 0
  dw guilepage0frame006 | db 0
  ds    9
.RightWalkRightstartingframenumber:
  db    2
.RightWalkRightstartingframe:
  dw guilepage0frame003 | db 0

.HorSpeedWalkSlowTable:       ;lenght table, pointer, movement speed
  db    5,0,   4,2,4,4,4
.HorSpeedWalkFastTable:       ;lenght table, pointer, movement speed
  db    5,0,   4,4,4,6,4

.LeftJumpStraightStartframe:
  dw guilepage1frame008 | db 1
.LeftJumpStraightanimationTable:
  db    00 | dw guilepage1frame009 | db 1
  db    06 | dw guilepage1frame010 | db 1
  db    09 | dw guilepage1frame011 | db 1
  db    15 | dw guilepage1frame010 | db 1
  db    18 | dw guilepage1frame009 | db 1
  db    22 | dw guilepage1frame008 | db 1
  ds    4

.LeftJumpLeftStartframe:
  dw guilepage1frame008 | db 1
.LeftJumpLeftanimationTable:  ;face left, jump left
  db    00 | dw guilepage1frame012 | db 1
  db    06 | dw guilepage1frame013 | db 1
  db    09 | dw guilepage1frame014 | db 1
  db    12 | dw guilepage1frame015 | db 1
  db    15 | dw guilepage1frame016 | db 1
  db    22 | dw guilepage1frame008 | db 1
  ds    4

.LeftJumpRightStartframe:
  dw guilepage1frame008 | db 1
.LeftJumpRightanimationTable: ;face left, jump right
  db    00 | dw guilepage1frame016 | db 1
  db    06 | dw guilepage1frame015 | db 1
  db    09 | dw guilepage1frame014 | db 1
  db    12 | dw guilepage1frame013 | db 1
  db    15 | dw guilepage1frame012 | db 1
  db    22 | dw guilepage1frame008 | db 1
  ds    4

.RightJumpStraightStartframe:
  dw guilepage0frame008 | db 0
.RightJumpStraightanimationTable:
  db    00 | dw guilepage0frame009 | db 0
  db    06 | dw guilepage0frame010 | db 0
  db    09 | dw guilepage0frame011 | db 0
  db    15 | dw guilepage0frame010 | db 0
  db    18 | dw guilepage0frame009 | db 0
  db    22 | dw guilepage0frame008 | db 0
  ds    4

.RightJumpLeftStartframe:
  dw guilepage0frame008 | db 0
.RightJumpLeftanimationTable: ;face right, jump left
  db    00 | dw guilepage0frame016 | db 0
  db    06 | dw guilepage0frame015 | db 0
  db    09 | dw guilepage0frame014 | db 0
  db    12 | dw guilepage0frame013 | db 0
  db    15 | dw guilepage0frame012 | db 0
  db    22 | dw guilepage0frame008 | db 0
  ds    4
  
.RightJumpRightStartframe:
  dw guilepage0frame008 | db 0
.RightJumpRightanimationTable:;face right, jump right
  db    00 | dw guilepage0frame012 | db 0
  db    06 | dw guilepage0frame013 | db 0
  db    09 | dw guilepage0frame014 | db 0
  db    12 | dw guilepage0frame015 | db 0
  db    15 | dw guilepage0frame016 | db 0
  db    22 | dw guilepage0frame008 | db 0
  ds    4

.jumptable:                  ;pointer, y movement
  db    0,  -14,-14,-13,-12,-10,-08,-06,-04,-03,-02,-01,-00
  db    +01,+02,03,+04,+06,+08,+10,+12,+13,+14,+14
  db    +00,+00,+00,+128      ;end jumptable with 3x 0 otherwise "landing" sfx will not be player
  ds    18

.HorSpeedJumpSlowTable:       ;lenght table, pointer, movement speed
  db    5,0,   4,4,6,4,4
.HorSpeedJumpFastTable:       ;lenght table, pointer, movement speed
  db    5,0,   4,6,4,6,4

;player SoftStandPunching
.StandSoftPunchLeftFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SPL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,1,1                 ;animation every 2,5 frames
.AnimationTable_SPL:
  dw guilepage1frame001 | db 1
  dw guilepage1frame017 | db 1
  dw guilepage1frame017 | db 1

.StandSoftPunchRightFrame:    ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SPR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,1,1                 ;animation every 2,5 frames
.AnimationTable_SPR:
  dw guilepage0frame001 | db 0
  dw guilepage0frame017 | db 0
  dw guilepage0frame017 | db 0

;player HardStandPunching
.StandHardPunchLeftFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HPL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,4,1                 ;animation every 2,5 frames
.AnimationTable_HPL:
  dw guilepage1frame018 | db 1
  dw guilepage1frame019 | db 1
  dw guilepage1frame020 | db 1

.StandHardPunchRightFrame:    ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HPR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,4,1                 ;animation every 2,5 frames
.AnimationTable_HPR:
  dw guilepage0frame018 | db 0
  dw guilepage0frame019 | db 0
  dw guilepage0frame020 | db 0

;player SoftStandKicking
.StandSoftKickLeftFrame:      ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SKL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SKL:
  dw guilepage1frame004 | db 1
  dw guilepage1frame021 | db 1
  dw guilepage1frame021 | db 1
  ds  3
.StandSoftKickRightFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SKR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SKR:
  dw guilepage0frame004 | db 0
  dw guilepage0frame021 | db 0
  dw guilepage0frame021 | db 0
  ds  3
;player HardStandKicking
.StandHardKickLeftFrame:      ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HKL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.AnimationTable_HKL:
  dw guilepage1frame022 | db 1
  dw guilepage1frame023 | db 1
  dw guilepage1frame024 | db 1
  ds  9
.StandHardKickRightFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HKR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.AnimationTable_HKR:
  dw guilepage0frame022 | db 0
  dw guilepage0frame023 | db 0
  dw guilepage0frame024 | db 0
    ds  9
;player SoftSitPunching
.SitSoftPunchLeftFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SPL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SPL:
  dw guilepage1frame008 | db 1
  dw guilepage1frame025 | db 1
  dw guilepage1frame025 | db 1

.SitSoftPunchRightFrame:      ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SPR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SPR:
  dw guilepage0frame008 | db 0
  dw guilepage0frame025 | db 0
  dw guilepage0frame025 | db 0

;player HardSitPunching
.SitHardPunchLeftFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_HPL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_HPL:
  dw guilepage1frame026 | db 1
  dw guilepage1frame026 | db 1
  dw guilepage1frame002 | db 1

.SitHardPunchRightFrame:      ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_HPR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_HPR:
  dw guilepage0frame026 | db 0
  dw guilepage0frame026 | db 0
  dw guilepage0frame002 | db 0

;player SoftSitKicking
.SitSoftKickLeftFrame:        ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SKL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.SitAnimationTable_SKL:
  dw guilepage1frame008 | db 1
  dw guilepage3frame001 | db 3
  dw guilepage3frame001 | db 3

.SitSoftKickRightFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SKR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.SitAnimationTable_SKR:
  dw guilepage0frame008 | db 0
  dw guilepage2frame001 | db 2
  dw guilepage2frame001 | db 2

;player HardSitKicking
.SitHardKickLeftFrame:        ;current spriteframe, total animationsteps
  db    0,5
.SitAnimationSpeed_HKL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,5,1                 ;animation every 2,5 frames
.SitAnimationTable_HKL:
  dw guilepage3frame000 | db 3
  dw guilepage3frame001 | db 3
  dw guilepage3frame002 | db 3
  dw guilepage3frame003 | db 3
  dw guilepage3frame004 | db 3
  db  0                       ;movement speed-> move horizontally while performing hard kick ?

.SitHardKickRightFrame:       ;current spriteframe, total animationsteps
  db    0,5
.SitAnimationSpeed_HKR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,5,1                 ;animation every 2,5 frames
.SitAnimationTable_HKR:
  dw guilepage2frame003 | db 2
  dw guilepage2frame001 | db 2
  dw guilepage2frame002 | db 2
  dw guilepage2frame003 | db 2
  dw guilepage2frame004 | db 2
  db  0                       ;movement speed-> move horizontally while performing hard kick ?
  
.LeftSoftJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    guilepage3frame005 | db 3
  dw    guilepage3frame005 | db 3
  dw    guilepage1frame009 | db 1  
.RightSoftJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    guilepage2frame005 | db 2
  dw    guilepage2frame005 | db 2
  dw    guilepage0frame009 | db 0
.LeftHardJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    guilepage3frame005 | db 3
  dw    guilepage1frame010 | db 1
  dw    guilepage1frame010 | db 1  
.RightHardJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    guilepage2frame005 | db 2
  dw    guilepage0frame010 | db 0
  dw    guilepage0frame010 | db 0
  
.LeftSoftJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    guilepage3frame005 | db 3
  dw    guilepage3frame005 | db 3
  dw    guilepage1frame009 | db 1  
.RightSoftJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    guilepage2frame005 | db 2
  dw    guilepage2frame005 | db 2
  dw    guilepage0frame009 | db 0
.LeftHardJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    guilepage3frame005 | db 3
  dw    guilepage1frame010 | db 1
  dw    guilepage1frame010 | db 1
.RightHardJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    guilepage2frame005 | db 2
  dw    guilepage0frame010 | db 0
  dw    guilepage0frame010 | db 0
  
.LeftSoftJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    guilepage3frame007 | db 3
  dw    guilepage3frame007 | db 3
  dw    guilepage3frame007 | db 3  
.RightSoftJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    guilepage2frame007 | db 2
  dw    guilepage2frame007 | db 2
  dw    guilepage2frame007 | db 2
  
.LeftHardJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    guilepage3frame008 | db 3
  dw    guilepage3frame009 | db 3
  dw    guilepage1frame009 | db 1
.RightHardJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    guilepage2frame008 | db 2
  dw    guilepage2frame009 | db 2
  dw    guilepage0frame009 | db 0
  
.LeftSoftJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    guilepage3frame006 | db 3
  dw    guilepage3frame006 | db 3
  dw    guilepage1frame010 | db 1  
.RightSoftJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    guilepage2frame006 | db 2
  dw    guilepage2frame006 | db 2
  dw    guilepage0frame010 | db 0
  
.LeftHardJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    guilepage3frame008 | db 3
  dw    guilepage3frame009 | db 3
  dw    guilepage1frame009 | db 1
.RightHardJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,7,0                 ;animation every 2,5 frames
  dw    guilepage2frame008 | db 2
  dw    guilepage2frame009 | db 2
  dw    guilepage0frame009 | db 0
  
.LeftStandDefendFrame:
  dw    guilepage3frame010 | db 3
.RightStandDefendFrame:
  dw    guilepage2frame010 | db 2
.LeftBendDefendFrame:
  dw    guilepage3frame011 | db 3
.RightBendDefendFrame:
  dw    guilepage2frame011 | db 2
 
.LeftStandHitFrame:
  dw    guilepage3frame012 | db 3
.RightStandHitFrame:
  dw    guilepage2frame012 | db 2
.LeftBendHitFrame:
  dw    guilepage3frame013 | db 3
.RightBendHitFrame:
  dw    guilepage2frame013 | db 2
.LeftJumpHitFrame:
  dw    guilepage3frame012 | db 3
.RightJumpHitFrame:
  dw    guilepage2frame012 | db 2

.HeavilyHitLeftFrame:        ;current spriteframe, total animationsteps
  db    0,13
.HeavilyHitLeftAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.HeavilyHitLeftAnimationTable:
  dw guilepage3frame014 | db 3
  dw guilepage3frame014 | db 3
  dw guilepage3frame014 | db 3
  dw guilepage3frame014 | db 3
  dw guilepage3frame014 | db 3
  dw guilepage3frame015 | db 3
  dw guilepage3frame015 | db 3
  dw guilepage3frame015 | db 3
  dw guilepage3frame015 | db 3
  dw guilepage3frame015 | db 3
  dw guilepage3frame015 | db 3
  dw guilepage3frame015 | db 3
  dw guilepage3frame015 | db 3

.HeavilyHitRightFrame:       ;current spriteframe, total animationsteps
  db    0,13
.HeavilyHitRightAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.HeavilyHitRightAnimationTable:
  dw guilepage2frame014 | db 2
  dw guilepage2frame014 | db 2
  dw guilepage2frame014 | db 2
  dw guilepage2frame014 | db 2
  dw guilepage2frame014 | db 2
  dw guilepage2frame015 | db 2
  dw guilepage2frame015 | db 2
  dw guilepage2frame015 | db 2
  dw guilepage2frame015 | db 2
  dw guilepage2frame015 | db 2
  dw guilepage2frame015 | db 2
  dw guilepage2frame015 | db 2
  dw guilepage2frame015 | db 2
  
.JumpHitLeftFrame:        ;current spriteframe, total animationsteps
  db    0,13
.JumphitLeftAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.JumphitLeftAnimationTable:
  dw guilepage3frame012 | db 3
  dw guilepage3frame012 | db 3
  dw guilepage3frame012 | db 3
  dw guilepage3frame012 | db 3
  dw guilepage3frame014 | db 3
  dw guilepage3frame016 | db 3
  dw guilepage3frame018 | db 3
  dw guilepage1frame015 | db 1
  dw guilepage1frame011 | db 1
  dw guilepage1frame011 | db 1
  dw guilepage1frame009 | db 1
  dw guilepage1frame009 | db 1
  dw guilepage1frame009 | db 1

.JumpHitRightFrame:       ;current spriteframe, total animationsteps
  db    0,13
.JumphitRightAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.JumphitRightAnimationTable:
  dw guilepage2frame012 | db 2
  dw guilepage2frame012 | db 2
  dw guilepage2frame012 | db 2
  dw guilepage2frame012 | db 2
  dw guilepage2frame014 | db 2
  dw guilepage2frame016 | db 2
  dw guilepage2frame018 | db 2
  dw guilepage0frame015 | db 0
  dw guilepage0frame011 | db 0
  dw guilepage0frame011 | db 0
  dw guilepage0frame009 | db 0
  dw guilepage0frame009 | db 0
  dw guilepage0frame009 | db 0  

.KnockDownRecoverLeftFrame:
  db    0,5
.AnimationSpeed_KDARR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_KDARR:
  dw guilepage3frame016 | db 3
  dw guilepage3frame016 | db 3
  dw guilepage3frame018 | db 3
  dw guilepage1frame015 | db 1
  dw guilepage1frame011 | db 1

.KnockDownRecoverRightFrame:
  db    0,5
.AnimationSpeed_KDARL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_KDARL:
  dw guilepage2frame016 | db 2
  dw guilepage2frame016 | db 2
  dw guilepage2frame018 | db 2
  dw guilepage0frame015 | db 0
  dw guilepage0frame011 | db 0

.TossLeftFrame:
  db    0,2
.AnimationSpeed_TossL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,9,0                 ;animation every 2,5 frames
.AnimationTable_TossL:
  dw guilepage3frame020 | db 3
  dw guilepage3frame021 | db 3

.TossRightFrame:
  db    0,2
.AnimationSpeed_TossR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,9,0                 ;animation every 2,5 frames
.AnimationTable_TossR:
  dw guilepage2frame020 | db 2
  dw guilepage2frame021 | db 2

.VictoryLeftFrame:
  db    0,3
.AnimationSpeed_VictL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_VictL:
  dw guilepage3frame022 | db 3
  dw guilepage3frame022 | db 3
  dw guilepage3frame022 | db 3

.VictoryRightFrame:
  db    0,3
.AnimationSpeed_VictR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_VictR:
  dw guilepage2frame022 | db 2
  dw guilepage2frame022 | db 2
  dw guilepage2frame022 | db 2

;Projectile shot (sonic boom)
.Special1MovementTablePointer:
  db    0
.Special1DurationTimer:
  db    18                    ;Amount of frames that Special move takes
.Special1MovementTable:      ;movement(y,x)
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, -00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
;flash kick (part 1) this is the first kick and ends at the highest point in the air
.Special2MovementTablePointer:
  db    0
.Special2DurationTimer:
  db    12                    ;Amount of frames that Special move takes
.Special2MovementTable:      ;movement(y,x)
  db    -18,+06, -15,+04, -13,+04, -11,+02, -09,+04, -07,+02 | ds 48
;flash kick (part 2) this is the second part of flash kick, and player falls down (and has the chance to do a 2nd flash kick)
.Special3MovementTablePointer:
  db    0
.Special3DurationTimer:
  db    36                    ;Amount of frames that Special move takes
.Special3MovementTable:      ;movement(y,x)
  db    -05,+04, -03,+02, -01,+02, -00,+02, +01,+02, +03,+02, +05,+02, +07,+02, +09,+02, +11,+02, +13,+02, +15,+02, +18,+02, +00,+00, +00,+00
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00 | ds 12
;empty
.Special4MovementTablePointer:
  db    0
.Special4DurationTimer:
  db    38                    ;Amount of frames that Special move takes
.Special4MovementTable:      ;movement(y,x)
  db    +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04, +00,+04
  db    +00,+04, +00,+04, +00,+04, +00,+04 | ds 22
;empty
.Special5MovementTablePointer:
  db    0
.Special5DurationTimer:
  db    30                    ;Amount of frames that Special move takes
.Special5MovementTable:      ;movement(y,x)
  db    +03,+02, +04,+04, +05,+02, +06,+02, +07,+04, +08,+02, +09,+02, +10,+02, +11,+00, +12,+02, +13,+02, +14,+00, +15,+02, +16,+00, +17,+00
  ds    30

;Projectile shot (sonic boom)
.VariableTableSpecial1:
  db    2                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    1                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    0                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    0                     ;attack knocks you down ? (counts as being heavily hit)
  db    10                    ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;flash kick (part 1) this is the first kick and ends at the highest point in the air
.VariableTableSpecial2:
  db    1                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    1                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    3                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    1                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;flash kick (part 2) this is the second part of flash kick, and player falls down (and has the chance to do a 2nd flash kick)
.VariableTableSpecial3:                 ;ch=charge, d=down, u=up, b=back, f=foreward, p=punch, k=kick, r=repeat
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
;unused
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
;unused
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

;Projectile shot (sonic boom)
.Special1LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
  dw guilepage3frame023 | db 3
  dw guilepage3frame024 | db 3
  dw guilepage1frame003 | db 1
  dw guilepage1frame000 | db 1
.Special1RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
  dw guilepage2frame023 | db 2
  dw guilepage2frame024 | db 2
  dw guilepage0frame003 | db 0
  dw guilepage0frame000 | db 0
;flash kick (part 1) this is the first kick and ends at the highest point in the air
.Special2LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,1                 ;current speed step, ani. speed, ani. speed half frame
  dw guilepage1frame016 | db 1
  dw guilepage1frame016 | db 1
  dw guilepage3frame025 | db 3
  dw guilepage3frame033 | db 3
.Special2RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,1                 ;current speed step, ani. speed, ani. speed half frame
  dw guilepage0frame016 | db 0
  dw guilepage0frame016 | db 0
  dw guilepage2frame025 | db 2
  dw guilepage2frame033 | db 2
;flash kick (part 2) this is the second part of flash kick, and player falls down (and has the chance to do a 2nd flash kick)
.Special3LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,5,0                 ;current speed step, ani. speed, ani. speed half frame
  dw guilepage1frame013 | db 1
  dw guilepage1frame009 | db 1
  dw guilepage1frame009 | db 1
  dw guilepage1frame008 | db 1
.Special3RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,5,0                 ;current speed step, ani. speed, ani. speed half frame
  dw guilepage0frame013 | db 0
  dw guilepage0frame009 | db 0
  dw guilepage0frame009 | db 0
  dw guilepage0frame008 | db 0
;empty
.Special4LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,2,0                 ;current speed step, ani. speed, ani. speed half frame
  dw guilepage3frame021 | db 3
  dw guilepage3frame018 | db 3
  dw guilepage3frame019 | db 3
  dw guilepage3frame020 | db 3
.Special4RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,2,0                 ;current speed step, ani. speed, ani. speed half frame
  dw guilepage2frame021 | db 2
  dw guilepage2frame018 | db 2
  dw guilepage2frame019 | db 2
  dw guilepage2frame020 | db 2
;empty
.Special5LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;current speed step, ani. speed, ani. speed half frame
  dw guilepage3frame019 | db 3
  dw guilepage1frame010 | db 1
  dw guilepage1frame009 | db 1
  dw guilepage1frame009 | db 1
.Special5RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;current speed step, ani. speed, ani. speed half frame
  dw guilepage2frame019 | db 2
  dw guilepage0frame010 | db 0
  dw guilepage0frame009 | db 0
  dw guilepage0frame009 | db 0

.GettingTossedLeftFrame:      ;current spriteframe, total animationsteps
  db    0,4
.GettingTossedLeftAnimationSpeed:
  db    0,9,1                 ;current speed step, ani. speed, ani. speed half frame
.GettingTossedLeftAnimationTable:
  dw guilepage3frame012 | db 3
  dw guilepage3frame014 | db 3
  dw guilepage3frame015 | db 3
  dw guilepage3frame015 | db 3

.GettingTossedRightFrame:     ;current spriteframe, total animationsteps
  db    0,4
.GettingTossedRightAnimationSpeed:
  db    0,9,1                 ;current speed step, ani. speed, ani. speed half frame
.GettingTossedRightAnimationTable:
  dw guilepage2frame012 | db 2
  dw guilepage2frame014 | db 2
  dw guilepage2frame015 | db 2
  dw guilepage2frame015 | db 2

.DamageTabel: ;SoftStandPunch, HardStandPunch, SoftStandKick, HardStandKick, SoftSitPunch, HardSitPunch, 
              ;SoftSitKick, HardSitKick, JumpSoftPunch, JumpHardPunch, JumpSoftKick, JumpHardKick, Special1-5, Toss
  db    12,16,12,16,12,16,12,20, 12,16,12,16,  0,20,0,08,0, 20
.endDamageTabel:

.ProjectileLeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,0                 ;current speed step, ani. speed, ani. speed half frame
  dw guilepage3frame029 | db 3
  dw guilepage3frame030 | db 3
  dw guilepage3frame031 | db 3
  dw guilepage3frame032 | db 3
.ProjectileRightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,0                 ;current speed step, ani. speed, ani. speed half frame
  dw guilepage2frame029 | db 2
  dw guilepage2frame030 | db 2
  dw guilepage2frame031 | db 2  
  dw guilepage2frame032 | db 2  
.ProjectileLeftEndFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,1                 ;current speed step, ani. speed, ani. speed half frame
  dw guilepage3frame019 | db 3
  dw guilepage3frame026 | db 3
  dw guilepage3frame027 | db 3
  dw guilepage3frame028 | db 3
.ProjectileRightEndFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,1                 ;current speed step, ani. speed, ani. speed half frame
  dw guilepage2frame019 | db 2
  dw guilepage2frame026 | db 2
  dw guilepage2frame027 | db 2
  dw guilepage2frame028 | db 2

.DiedLeftFrame:
  dw guilepage3frame017 | db 3
.DiedRightFrame:
  dw guilepage2frame017 | db 2
  