DhalsimActions:
.LeftIdleFrame:                ;current spriteframe, total animationsteps
  db    0,4
.LeftIdleAnimationSpeed:      ;current speed step, ani. speed, ani. speed half frame
  db    0,4,1                 ;animation every 2,5 frames
.LeftIdleTable:
  dw dhalsimpage1frame001 | db 1 | dw dhalsimpage1frame000 | db 1
  dw dhalsimpage1frame001 | db 1 | dw dhalsimpage1frame002 | db 1
  ds  12
.RightIdleFrame:              ;current spriteframe, total animationsteps
  db    0,4
.RightIdleAnimationSpeed:     ;current speed step, ani. speed, ani. speed half frame
  db    0,4,1                 ;animation every 2,5 frames
.rightIdleTable:
  dw dhalsimpage0frame001 | db 0 | dw dhalsimpage0frame000 | db 0
  dw dhalsimpage0frame001 | db 0 | dw dhalsimpage0frame002 | db 0
  ds  12  
.LeftBendFrame:
  dw    dhalsimpage1frame008 | db 1
.RightBendFrame:
  dw    dhalsimpage0frame008 | db 0

;player facing left walking left
.LeftWalkLeftFrame:            ;current spriteframe, total animationsteps
  db    0,8
.LeftWalkLeftAnimationSpeed:  ;current speed step, ani. speed, ani. speed half frame
  db    0,4,1                 ;animation every 2,5 frames
.LeftWalkLeftTable:
  dw dhalsimpage1frame007 | db 1 | dw dhalsimpage1frame006 | db 1
  dw dhalsimpage1frame005 | db 1 | dw dhalsimpage1frame004 | db 1
  dw dhalsimpage1frame003 | db 1 | dw dhalsimpage1frame004 | db 1
  dw dhalsimpage1frame005 | db 1 | dw dhalsimpage1frame006 | db 1
.LeftWalkLeftstartingframenumber:
  db    4
.LeftWalkLeftstartingframe:
  dw dhalsimpage1frame003 | db 1
  
;player facing left walking right
.LeftWalkRightFrame:          ;current spriteframe, total animationsteps
  db    0,8
.LeftWalkRightAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,4,1                 ;animation every 2,5 frames
.LeftWalkRightTable:
  dw dhalsimpage1frame007 | db 1 | dw dhalsimpage1frame006 | db 1
  dw dhalsimpage1frame005 | db 1 | dw dhalsimpage1frame004 | db 1
  dw dhalsimpage1frame003 | db 1 | dw dhalsimpage1frame004 | db 1
  dw dhalsimpage1frame005 | db 1 | dw dhalsimpage1frame006 | db 1
.LeftWalkRightstartingframenumber:
  db    4
.LeftWalkRightstartingframe:
  dw dhalsimpage1frame003 | db 1

;player facing right walking left
.RightWalkLeftFrame:          ;current spriteframe, total animationsteps
  db    0,8
.RightWalkLeftAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,4,1                 ;animation every 2,5 frames
.RightWalkLeftTable:
  dw dhalsimpage0frame007 | db 0 | dw dhalsimpage0frame006 | db 0
  dw dhalsimpage0frame005 | db 0 | dw dhalsimpage0frame004 | db 0
  dw dhalsimpage0frame003 | db 0 | dw dhalsimpage0frame004 | db 0
  dw dhalsimpage0frame005 | db 0 | dw dhalsimpage0frame006 | db 0
.RightWalkLeftstartingframenumber:
  db    4
.RightWalkLeftstartingframe:
  dw dhalsimpage0frame003 | db 0
 
;player facing right walking right
.RightWalkRightFrame:         ;current spriteframe, total animationsteps
  db    0,8
.RightWalkRightAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,4,1                 ;animation every 2,5 frames
.RightWalkRightTable:
  dw dhalsimpage0frame007 | db 0 | dw dhalsimpage0frame006 | db 0
  dw dhalsimpage0frame005 | db 0 | dw dhalsimpage0frame004 | db 0
  dw dhalsimpage0frame003 | db 0 | dw dhalsimpage0frame004 | db 0
  dw dhalsimpage0frame005 | db 0 | dw dhalsimpage0frame006 | db 0
.RightWalkRightstartingframenumber:
  db    4
.RightWalkRightstartingframe:
  dw dhalsimpage0frame003 | db 0

.HorSpeedWalkSlowTable:       ;lenght table, pointer, movement speed
  db    5,0,   2,2,2,2,2
.HorSpeedWalkFastTable:       ;lenght table, pointer, movement speed
  db    5,0,   2,4,2,4,2

.LeftJumpStraightStartframe:
  dw dhalsimpage1frame008 | db 1
.LeftJumpStraightanimationTable:
  db    00 | dw dhalsimpage1frame009 | db 1
  db    09 | dw dhalsimpage1frame010 | db 1
  db    13 | dw dhalsimpage1frame009 | db 1
  db    27 | dw dhalsimpage1frame008 | db 1
  ds    12

.LeftJumpLeftStartframe:
  dw dhalsimpage1frame008 | db 1
.LeftJumpLeftanimationTable:  ;face left, jump left
  db    00 | dw dhalsimpage1frame009 | db 1
  db    09 | dw dhalsimpage1frame010 | db 1
  db    13 | dw dhalsimpage1frame009 | db 1
  db    27 | dw dhalsimpage1frame008 | db 1
  ds    12

.LeftJumpRightStartframe:
  dw dhalsimpage1frame008 | db 1
.LeftJumpRightanimationTable: ;face left, jump right
  db    00 | dw dhalsimpage1frame009 | db 1
  db    09 | dw dhalsimpage1frame010 | db 1
  db    13 | dw dhalsimpage1frame009 | db 1
  db    27 | dw dhalsimpage1frame008 | db 1
  ds    12

.RightJumpStraightStartframe:
  dw dhalsimpage0frame008 | db 0
.RightJumpStraightanimationTable:
  db    00 | dw dhalsimpage0frame009 | db 0
  db    09 | dw dhalsimpage0frame010 | db 0
  db    13 | dw dhalsimpage0frame009 | db 0
  db    27 | dw dhalsimpage0frame008 | db 0
  ds    12

.RightJumpLeftStartframe:
  dw dhalsimpage0frame008 | db 0
.RightJumpLeftanimationTable: ;face right, jump left
  db    00 | dw dhalsimpage0frame009 | db 0
  db    09 | dw dhalsimpage0frame010 | db 0
  db    13 | dw dhalsimpage0frame009 | db 0
  db    27 | dw dhalsimpage0frame008 | db 0
  ds    12
  
.RightJumpRightStartframe:
  dw dhalsimpage0frame008 | db 0
.RightJumpRightanimationTable:;face right, jump right
  db    00 | dw dhalsimpage0frame009 | db 0
  db    09 | dw dhalsimpage0frame010 | db 0
  db    13 | dw dhalsimpage0frame009 | db 0
  db    27 | dw dhalsimpage0frame008 | db 0
  ds    12

.jumptable:                  ;pointer, y movement
  db    0,  -12,-11,-10,-09,-08,-08,-07,-06,-05,-04,-03
  db    -02,-01,-00,-00,+01,+02,+03,+04,+05,+06
  db    +07,+08,+08,+09,+10,+11,+12
  db    +00,+00,+00,+128      ;end jumptable with 3x 0 otherwise "landing" sfx will not be player
  ds    13

.HorSpeedJumpSlowTable:       ;lenght table, pointer, movement speed
  db    5,0,   2,2,2,2,2
.HorSpeedJumpFastTable:       ;lenght table, pointer, movement speed
  db    5,0,   4,2,2,2,2

;player SoftStandPunching
.StandSoftPunchLeftFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SPL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SPL:
  dw dhalsimpage1frame003 | db 1
  dw dhalsimpage1frame011 | db 1
  dw dhalsimpage1frame011 | db 1

.StandSoftPunchRightFrame:    ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SPR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SPR:
  dw dhalsimpage0frame003 | db 0
  dw dhalsimpage0frame011 | db 0
  dw dhalsimpage0frame011 | db 0

;player HardStandPunching
.StandHardPunchLeftFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HPL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,3,0                 ;animation every 2,5 frames
.AnimationTable_HPL:
  dw dhalsimpage1frame012 | db 1
  dw dhalsimpage1frame013 | db 1
  dw dhalsimpage1frame012 | db 1

.StandHardPunchRightFrame:    ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HPR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,3,0                 ;animation every 2,5 frames
.AnimationTable_HPR:
  dw dhalsimpage0frame012 | db 0
  dw dhalsimpage0frame013 | db 0
  dw dhalsimpage0frame012 | db 0

;player SoftStandKicking
.StandSoftKickLeftFrame:      ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SKL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SKL:
  dw dhalsimpage1frame003 | db 1
  dw dhalsimpage1frame017 | db 1
  dw dhalsimpage1frame017 | db 1
  ds  3
.StandSoftKickRightFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SKR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SKR:
  dw dhalsimpage0frame003 | db 0
  dw dhalsimpage0frame017 | db 0
  dw dhalsimpage0frame017 | db 0
  ds  3
;player HardStandKicking
.StandHardKickLeftFrame:      ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HKL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.AnimationTable_HKL:
  dw dhalsimpage1frame018 | db 1
  dw dhalsimpage1frame019 | db 1
  dw dhalsimpage1frame018 | db 1
  ds  9
.StandHardKickRightFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HKR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.AnimationTable_HKR:
  dw dhalsimpage0frame018 | db 0
  dw dhalsimpage0frame019 | db 0
  dw dhalsimpage0frame018 | db 0
    ds  9
;player SoftSitPunching
.SitSoftPunchLeftFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SPL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SPL:
  dw dhalsimpage1frame008 | db 1
  dw dhalsimpage1frame014 | db 1
  dw dhalsimpage1frame014 | db 1

.SitSoftPunchRightFrame:      ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SPR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SPR:
  dw dhalsimpage0frame008 | db 0
  dw dhalsimpage0frame014 | db 0
  dw dhalsimpage0frame014 | db 0

;player HardSitPunching
.SitHardPunchLeftFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_HPL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.SitAnimationTable_HPL:
  dw dhalsimpage1frame015 | db 1
  dw dhalsimpage1frame016 | db 1
  dw dhalsimpage1frame015 | db 1

.SitHardPunchRightFrame:      ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_HPR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.SitAnimationTable_HPR:
  dw dhalsimpage0frame015 | db 0
  dw dhalsimpage0frame016 | db 0
  dw dhalsimpage0frame015 | db 0

;player SoftSitKicking
.SitSoftKickLeftFrame:        ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SKL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SKL:
  dw dhalsimpage1frame008 | db 1
  dw dhalsimpage1frame020 | db 1
  dw dhalsimpage1frame020 | db 1

.SitSoftKickRightFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SKR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SKR:
  dw dhalsimpage0frame008 | db 0
  dw dhalsimpage0frame020 | db 0
  dw dhalsimpage0frame020 | db 0

;player HardSitKicking
.SitHardKickLeftFrame:        ;current spriteframe, total animationsteps
  db    0,5
.SitAnimationSpeed_HKL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.SitAnimationTable_HKL:
  dw dhalsimpage1frame021 | db 1
  dw dhalsimpage1frame021 | db 1
  dw dhalsimpage1frame008 | db 1
  dw dhalsimpage1frame008 | db 1
  dw dhalsimpage1frame008 | db 1
  db  6                       ;movement speed-> move horizontally while performing hard kick ?

.SitHardKickRightFrame:       ;current spriteframe, total animationsteps
  db    0,5
.SitAnimationSpeed_HKR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.SitAnimationTable_HKR:
  dw dhalsimpage0frame021 | db 0
  dw dhalsimpage0frame021 | db 0
  dw dhalsimpage0frame008 | db 0
  dw dhalsimpage0frame008 | db 0
  dw dhalsimpage0frame008 | db 0
  db  6                       ;movement speed-> move horizontally while performing hard kick ?

.LeftSoftJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;animation every 2,5 frames
  dw    dhalsimpage1frame023 | db 1
  dw    dhalsimpage1frame023 | db 1
  dw    dhalsimpage1frame010 | db 1  
.RightSoftJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;animation every 2,5 frames
  dw    dhalsimpage0frame023 | db 0
  dw    dhalsimpage0frame023 | db 0
  dw    dhalsimpage0frame010 | db 0
.LeftHardJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;animation every 2,5 frames
  dw    dhalsimpage1frame023 | db 1
  dw    dhalsimpage1frame024 | db 1
  dw    dhalsimpage1frame023 | db 1  
.RightHardJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;animation every 2,5 frames
  dw    dhalsimpage0frame023 | db 0
  dw    dhalsimpage0frame024 | db 0
  dw    dhalsimpage0frame023 | db 0
.LeftSoftJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;animation every 2,5 frames
  dw    dhalsimpage1frame023 | db 1
  dw    dhalsimpage1frame023 | db 1
  dw    dhalsimpage1frame010 | db 1  
.RightSoftJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;animation every 2,5 frames
  dw    dhalsimpage0frame023 | db 0
  dw    dhalsimpage0frame023 | db 0
  dw    dhalsimpage0frame010 | db 0
.LeftHardJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;animation every 2,5 frames
  dw    dhalsimpage1frame023 | db 1
  dw    dhalsimpage1frame024 | db 1
  dw    dhalsimpage1frame023 | db 1  
.RightHardJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;animation every 2,5 frames
  dw    dhalsimpage0frame023 | db 0
  dw    dhalsimpage0frame024 | db 0
  dw    dhalsimpage0frame023 | db 0
.LeftSoftJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;animation every 2,5 frames
  dw    dhalsimpage1frame022 | db 1
  dw    dhalsimpage1frame022 | db 1
  dw    dhalsimpage1frame010 | db 1  
.RightSoftJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;animation every 2,5 frames
  dw    dhalsimpage0frame022 | db 0
  dw    dhalsimpage0frame022 | db 0
  dw    dhalsimpage0frame010 | db 0
.LeftHardJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;animation every 2,5 frames
  dw    dhalsimpage1frame018 | db 1
  dw    dhalsimpage1frame019 | db 1
  dw    dhalsimpage1frame018 | db 1  
.RightHardJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;animation every 2,5 frames
  dw    dhalsimpage0frame018 | db 0
  dw    dhalsimpage0frame019 | db 0
  dw    dhalsimpage0frame018 | db 0
.LeftSoftJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;animation every 2,5 frames
  dw    dhalsimpage1frame022 | db 1
  dw    dhalsimpage1frame022 | db 1
  dw    dhalsimpage1frame010 | db 1  
.RightSoftJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;animation every 2,5 frames
  dw    dhalsimpage0frame022 | db 0
  dw    dhalsimpage0frame022 | db 0
  dw    dhalsimpage0frame010 | db 0
.LeftHardJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;animation every 2,5 frames
  dw    dhalsimpage1frame018 | db 1
  dw    dhalsimpage1frame019 | db 1
  dw    dhalsimpage1frame018 | db 1   
.RightHardJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;animation every 2,5 frames
  dw    dhalsimpage0frame018 | db 0
  dw    dhalsimpage0frame019 | db 0
  dw    dhalsimpage0frame018 | db 0
  
.LeftStandDefendFrame:
  dw    dhalsimpage1frame025 | db 1
.RightStandDefendFrame:
  dw    dhalsimpage0frame025 | db 0
.LeftBendDefendFrame:
  dw    dhalsimpage3frame000 | db 3
.RightBendDefendFrame:
  dw    dhalsimpage2frame000 | db 2
 
.LeftStandHitFrame:
  dw    dhalsimpage3frame001 | db 3
.RightStandHitFrame:
  dw    dhalsimpage2frame001 | db 2
.LeftBendHitFrame:
  dw    dhalsimpage3frame002 | db 3
.RightBendHitFrame:
  dw    dhalsimpage2frame002 | db 2
.LeftJumpHitFrame:
  dw    dhalsimpage3frame003 | db 3
.RightJumpHitFrame:
  dw    dhalsimpage2frame003 | db 2

.HeavilyHitLeftFrame:         ;current spriteframe, total animationsteps
  db    0,13
.HeavilyHitLeftAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.HeavilyHitLeftAnimationTable:
  dw dhalsimpage3frame003 | db 3
  dw dhalsimpage3frame003 | db 3
  dw dhalsimpage3frame003 | db 3
  dw dhalsimpage3frame003 | db 3
  dw dhalsimpage3frame003 | db 3
  dw dhalsimpage3frame004 | db 3
  dw dhalsimpage3frame004 | db 3
  dw dhalsimpage3frame004 | db 3
  dw dhalsimpage3frame004 | db 3
  dw dhalsimpage3frame004 | db 3
  dw dhalsimpage3frame004 | db 3
  dw dhalsimpage3frame004 | db 3
  dw dhalsimpage3frame004 | db 3

.HeavilyHitRightFrame:        ;current spriteframe, total animationsteps
  db    0,13
.HeavilyHitRightAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.HeavilyHitRightAnimationTable:
  dw dhalsimpage2frame003 | db 2
  dw dhalsimpage2frame003 | db 2
  dw dhalsimpage2frame003 | db 2
  dw dhalsimpage2frame003 | db 2
  dw dhalsimpage2frame003 | db 2
  dw dhalsimpage2frame004 | db 2
  dw dhalsimpage2frame004 | db 2
  dw dhalsimpage2frame004 | db 2
  dw dhalsimpage2frame004 | db 2
  dw dhalsimpage2frame004 | db 2
  dw dhalsimpage2frame004 | db 2
  dw dhalsimpage2frame004 | db 2
  dw dhalsimpage2frame004 | db 2
  
.JumpHitLeftFrame:        ;current spriteframe, total animationsteps
  db    0,13
.JumphitLeftAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.JumphitLeftAnimationTable:
  dw dhalsimpage3frame003 | db 3
  dw dhalsimpage3frame003 | db 3
  dw dhalsimpage3frame003 | db 3
  dw dhalsimpage3frame003 | db 3
  dw dhalsimpage3frame003 | db 3
  dw dhalsimpage3frame001 | db 3
  dw dhalsimpage3frame001 | db 3
  dw dhalsimpage1frame009 | db 1
  dw dhalsimpage1frame009 | db 1
  dw dhalsimpage1frame009 | db 1
  dw dhalsimpage1frame009 | db 1
  dw dhalsimpage1frame009 | db 1
  dw dhalsimpage1frame009 | db 1

.JumpHitRightFrame:       ;current spriteframe, total animationsteps
  db    0,13
.JumphitRightAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.JumphitRightAnimationTable:
  dw dhalsimpage2frame003 | db 2
  dw dhalsimpage2frame003 | db 2
  dw dhalsimpage2frame003 | db 2
  dw dhalsimpage2frame003 | db 2
  dw dhalsimpage2frame003 | db 2
  dw dhalsimpage2frame001 | db 2
  dw dhalsimpage2frame001 | db 2
  dw dhalsimpage0frame009 | db 0
  dw dhalsimpage0frame009 | db 0
  dw dhalsimpage0frame009 | db 0
  dw dhalsimpage0frame009 | db 0
  dw dhalsimpage0frame009 | db 0
  dw dhalsimpage0frame009 | db 0  

.KnockDownRecoverLeftFrame:
  db    0,3
.AnimationSpeed_KDARR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_KDARR:
  dw dhalsimpage3frame005 | db 3
  dw dhalsimpage3frame005 | db 3
  dw dhalsimpage3frame006 | db 3
  ds  6

.KnockDownRecoverRightFrame:
  db    0,3
.AnimationSpeed_KDARL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_KDARL:
  dw dhalsimpage2frame005 | db 2
  dw dhalsimpage2frame005 | db 2
  dw dhalsimpage2frame006 | db 2
  ds  6

.TossLeftFrame:
  db    0,2
.AnimationSpeed_TossL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,9,0                 ;animation every 2,5 frames
.AnimationTable_TossL:
  dw dhalsimpage3frame007 | db 3
  dw dhalsimpage3frame008 | db 3

.TossRightFrame:
  db    0,2
.AnimationSpeed_TossR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,9,0                 ;animation every 2,5 frames
.AnimationTable_TossR:
  dw dhalsimpage2frame007 | db 2
  dw dhalsimpage2frame008 | db 2

.VictoryLeftFrame:
  db    0,3
.AnimationSpeed_VictL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_VictL:
  dw dhalsimpage3frame009 | db 3
  dw dhalsimpage3frame009 | db 3
  dw dhalsimpage3frame009 | db 3

.VictoryRightFrame:
  db    0,3
.AnimationSpeed_VictR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_VictR:
  dw dhalsimpage2frame009 | db 2
  dw dhalsimpage2frame031 | db 2
  dw dhalsimpage2frame032 | db 2

;joga fire
.Special1MovementTablePointer:
  db    0
.Special1DurationTimer:
  db    60                    ;Amount of frames that Special move takes
.Special1MovementTable:      ;movement(y,x)
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, -00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
;joga flame part one
.Special2MovementTablePointer:
  db    0
.Special2DurationTimer:
  db    18                    ;Amount of frames that Special move takes
.Special2MovementTable:      ;movement(y,x)
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, -00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
;joga flame part two  
.Special3MovementTablePointer:
  db    0
.Special3DurationTimer:
  db    60                    ;Amount of frames that Special move takes
.Special3MovementTable:      ;movement(y,x)
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, -00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
;joga piledriver
.Special4MovementTablePointer:
  db    0
.Special4DurationTimer:
  db    60                    ;Amount of frames that Special move takes
.Special4MovementTable:      ;movement(y,x)
  db    +04,+05, +06,+05, +04,+05, +06,+05, +04,+05, +06,+05, +04,+05, +06,+05, +04,+05, +06,+05, +04,+05, +06,+05, +04,+05, +06,+05, +04,+05 
  db    +06,+05, +04,+05, +06,+05, +04,+05, +06,+05, +04,+05, +06,+05, +04,+05, +06,+05, +04,+05, +06,+05, +04,+05, +06,+05, +04,+05, +06,+05
;joga mummy
.Special5MovementTablePointer:
  db    0
.Special5DurationTimer:
  db    60                    ;Amount of frames that Special move takes
.Special5MovementTable:      ;movement(y,x)
  db    +02,+04, +04,+04, +02,+04, +04,+04, +02,+04, +04,+04, +02,+04, +04,+04, +02,+04, +04,+04, +02,+04, +04,+04, +02,+04, +04,+04, +02,+04
  db    +04,+04, +02,+04, +04,+04, +02,+04, +04,+04, +02,+04, +04,+04, +02,+04, +04,+04, +02,+04, +04,+04, +02,+04, +04,+04, +02,+04, +04,+04
;joga fire
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
;joga flame part one
.VariableTableSpecial2:                 ;ch=charge, d=down, u=up, b=back, f=foreward, p=punch, k=kick, r=repeat
  db    7                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    1                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    3                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    0                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;joga flame part two
.VariableTableSpecial3:
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
;joga piledriver
.VariableTableSpecial4:
  db    3                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    0                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    0                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    0                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;joga mummy
.VariableTableSpecial5:
  db    4                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    0                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    0                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    0                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;joga fire
.Special1LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;current speed step, ani. speed, ani. speed half frame
  dw dhalsimpage3frame010 | db 3
  dw dhalsimpage3frame011 | db 3
  dw dhalsimpage3frame011 | db 3
  dw dhalsimpage3frame011 | db 3
.Special1RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;current speed step, ani. speed, ani. speed half frame
  dw dhalsimpage2frame010 | db 2
  dw dhalsimpage2frame011 | db 2
  dw dhalsimpage2frame011 | db 2
  dw dhalsimpage2frame011 | db 2
;joga flame part one
.Special2LeftFrame:
  db    0,2                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;current speed step, ani. speed, ani. speed half frame
  dw dhalsimpage3frame010 | db 3
  dw dhalsimpage3frame011 | db 3
  ds    6
.Special2RightFrame:
  db    0,2                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;current speed step, ani. speed, ani. speed half frame
  dw dhalsimpage2frame010 | db 2
  dw dhalsimpage2frame011 | db 2
  ds    6
;joga flame part two
.Special3LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,0                 ;current speed step, ani. speed, ani. speed half frame
  dw dhalsimpage3frame016 | db 3
  dw dhalsimpage3frame017 | db 3
  dw dhalsimpage3frame016 | db 3
  dw dhalsimpage3frame011 | db 3
.Special3RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,0                 ;current speed step, ani. speed, ani. speed half frame
  dw dhalsimpage2frame017 | db 2
  dw dhalsimpage2frame016 | db 2
  dw dhalsimpage2frame017 | db 2
  dw dhalsimpage2frame011 | db 2
;joga piledriver
.Special4LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,2,0                 ;current speed step, ani. speed, ani. speed half frame
  dw dhalsimpage3frame019 | db 3
  dw dhalsimpage3frame020 | db 3
  dw dhalsimpage3frame021 | db 3
  dw dhalsimpage3frame022 | db 3
.Special4RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,2,0                 ;current speed step, ani. speed, ani. speed half frame
  dw dhalsimpage2frame019 | db 2
  dw dhalsimpage2frame020 | db 2
  dw dhalsimpage2frame021 | db 2
  dw dhalsimpage2frame022 | db 2
;joga mummy
.Special5LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,2,0                 ;current speed step, ani. speed, ani. speed half frame
  dw dhalsimpage3frame023 | db 3
  dw dhalsimpage3frame024 | db 3
  dw dhalsimpage3frame025 | db 3
  dw dhalsimpage3frame026 | db 3
.Special5RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,2,0                 ;current speed step, ani. speed, ani. speed half frame
  dw dhalsimpage2frame023 | db 2
  dw dhalsimpage2frame024 | db 2
  dw dhalsimpage2frame025 | db 2
  dw dhalsimpage2frame026 | db 2

.GettingTossedLeftFrame:      ;current spriteframe, total animationsteps
  db    0,4
.GettingTossedLeftAnimationSpeed:
  db    0,9,1                 ;current speed step, ani. speed, ani. speed half frame
.GettingTossedLeftAnimationTable:
  dw dhalsimpage3frame002 | db 3
  dw dhalsimpage3frame006 | db 3
  dw dhalsimpage3frame005 | db 3
  dw dhalsimpage3frame005 | db 3

.GettingTossedRightFrame:     ;current spriteframe, total animationsteps
  db    0,4
.GettingTossedRightAnimationSpeed:
  db    0,9,1                 ;current speed step, ani. speed, ani. speed half frame
.GettingTossedRightAnimationTable:
  dw dhalsimpage2frame002 | db 2
  dw dhalsimpage2frame006 | db 2
  dw dhalsimpage2frame005 | db 2
  dw dhalsimpage2frame005 | db 2

.DamageTabel: ;SoftStandPunch, HardStandPunch, SoftStandKick, HardStandKick, SoftSitPunch, HardSitPunch, 
              ;SoftSitKick, HardSitKick, JumpSoftPunch, JumpHardPunch, JumpSoftKick, JumpHardKick, Special1-5, Toss
  db    12,12,12,12,12,12,12,18, 12,16,12,16,  0,0,20,12,12, 20
.endDamageTabel:

.ProjectileLeftFrame:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,1,0                 ;current speed step, ani. speed, ani. speed half frame
  dw dhalsimpage3frame012 | db 3
  dw dhalsimpage3frame013 | db 3
  dw dhalsimpage3frame030 | db 3
  ds  3
.ProjectileRightFrame:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,1,0                 ;current speed step, ani. speed, ani. speed half frame
  dw dhalsimpage2frame012 | db 2
  dw dhalsimpage2frame013 | db 2
  dw dhalsimpage2frame030 | db 2  
  ds  3  
.ProjectileLeftEndFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,1                 ;current speed step, ani. speed, ani. speed half frame
  dw dhalsimpage3frame027 | db 3
  dw dhalsimpage3frame028 | db 3
  dw dhalsimpage3frame029 | db 3
  dw dhalsimpage3frame014 | db 3
.ProjectileRightEndFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,1                 ;current speed step, ani. speed, ani. speed half frame
  dw dhalsimpage2frame027 | db 2
  dw dhalsimpage2frame028 | db 2
  dw dhalsimpage2frame029 | db 2
  dw dhalsimpage2frame014 | db 2

.DiedLeftFrame:
  dw dhalsimpage3frame005 | db 3
.DiedRightFrame:
  dw dhalsimpage2frame005 | db 2