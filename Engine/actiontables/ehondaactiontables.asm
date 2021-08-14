EhondaActions:
.LeftIdleFrame:                ;current spriteframe, total animationsteps
  db    0,4
.LeftIdleAnimationSpeed:      ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.LeftIdleTable:
  dw ehondapage1frame001 | db 1 | dw ehondapage1frame000 | db 1
  dw ehondapage1frame001 | db 1 | dw ehondapage1frame002 | db 1
  ds  12
.RightIdleFrame:              ;current spriteframe, total animationsteps
  db    0,4
.RightIdleAnimationSpeed:     ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.rightIdleTable:
  dw ehondapage0frame001 | db 0 | dw ehondapage0frame000 | db 0
  dw ehondapage0frame001 | db 0 | dw ehondapage0frame002 | db 0
  ds  12  
.LeftBendFrame:
  dw    ehondapage1frame007 | db 1
.RightBendFrame:
  dw    ehondapage0frame007 | db 0

;player facing left walking left
.LeftWalkLeftFrame:            ;current spriteframe, total animationsteps
  db    0,6
.LeftWalkLeftAnimationSpeed:  ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.LeftWalkLeftTable:
  dw ehondapage1frame005 | db 1 | dw ehondapage1frame006 | db 1
  dw ehondapage1frame005 | db 1 | dw ehondapage1frame004 | db 1
  dw ehondapage1frame003 | db 1 | dw ehondapage1frame004 | db 1  
  ds  6
.LeftWalkLeftstartingframenumber:
  db    4
.LeftWalkLeftstartingframe:
  dw ehondapage1frame003 | db 1
  
;player facing left walking right
.LeftWalkRightFrame:          ;current spriteframe, total animationsteps
  db    0,6
.LeftWalkRightAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.LeftWalkRightTable:
  dw ehondapage1frame005 | db 1 | dw ehondapage1frame006 | db 1
  dw ehondapage1frame005 | db 1 | dw ehondapage1frame004 | db 1
  dw ehondapage1frame003 | db 1 | dw ehondapage1frame004 | db 1
  ds  6
.LeftWalkRightstartingframenumber:
  db    4
.LeftWalkRightstartingframe:
  dw ehondapage1frame003 | db 1

;player facing right walking left
.RightWalkLeftFrame:          ;current spriteframe, total animationsteps
  db    0,6
.RightWalkLeftAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.RightWalkLeftTable:
  dw ehondapage0frame005 | db 0 | dw ehondapage0frame006 | db 0
  dw ehondapage0frame005 | db 0 | dw ehondapage0frame004 | db 0
  dw ehondapage0frame003 | db 0 | dw ehondapage0frame004 | db 0  
  ds  6
.RightWalkLeftstartingframenumber:
  db    4
.RightWalkLeftstartingframe:
  dw ehondapage0frame003 | db 0
 
;player facing right walking right
.RightWalkRightFrame:         ;current spriteframe, total animationsteps
  db    0,6
.RightWalkRightAnimationSpeed:;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.RightWalkRightTable:
  dw ehondapage0frame005 | db 0 | dw ehondapage0frame006 | db 0
  dw ehondapage0frame005 | db 0 | dw ehondapage0frame004 | db 0
  dw ehondapage0frame003 | db 0 | dw ehondapage0frame004 | db 0  
  ds  6
.RightWalkRightstartingframenumber:
  db    4
.RightWalkRightstartingframe:
  dw ehondapage0frame003 | db 0

.HorSpeedWalkSlowTable:       ;lenght table, pointer, movement speed
  db    5,0,   2,2,2,2,2
.HorSpeedWalkFastTable:       ;lenght table, pointer, movement speed
  db    5,0,   2,4,2,4,2

.LeftJumpStraightStartframe:
  dw ehondapage1frame007 | db 1
.LeftJumpStraightanimationTable:
  db    00 | dw ehondapage1frame008 | db 1
  db    06 | dw ehondapage1frame009 | db 1
  db    18 | dw ehondapage1frame008 | db 1
  db    24 | dw ehondapage1frame007 | db 1
  ds    12

.LeftJumpLeftStartframe:
  dw ehondapage1frame007 | db 1
.LeftJumpLeftanimationTable:  ;face left, jump left
  db    00 | dw ehondapage1frame010 | db 1
  db    05 | dw ehondapage1frame011 | db 1
  db    08 | dw ehondapage1frame012 | db 1
  db    11 | dw ehondapage1frame013 | db 1
  db    14 | dw ehondapage1frame014 | db 1
  db    18 | dw ehondapage1frame008 | db 1
  db    24 | dw ehondapage1frame007 | db 1

.LeftJumpRightStartframe:
  dw ehondapage1frame007 | db 1
.LeftJumpRightanimationTable: ;face left, jump right
  db    00 | dw ehondapage1frame008 | db 1
  db    06 | dw ehondapage1frame009 | db 1
  db    18 | dw ehondapage1frame008 | db 1
  db    24 | dw ehondapage1frame007 | db 1
  ds    12

.RightJumpStraightStartframe:
  dw ehondapage0frame007 | db 0
.RightJumpStraightanimationTable:
  db    00 | dw ehondapage0frame008 | db 0
  db    06 | dw ehondapage0frame009 | db 0
  db    18 | dw ehondapage0frame008 | db 0
  db    24 | dw ehondapage0frame007 | db 0
  ds    12

.RightJumpLeftStartframe:
  dw ehondapage0frame007 | db 0
.RightJumpLeftanimationTable: ;face right, jump left
  db    00 | dw ehondapage0frame008 | db 0
  db    06 | dw ehondapage0frame009 | db 0
  db    18 | dw ehondapage0frame008 | db 0
  db    24 | dw ehondapage0frame007 | db 0
  ds    12
  
.RightJumpRightStartframe:
  dw ehondapage0frame007 | db 0
.RightJumpRightanimationTable:;face right, jump right
  db    00 | dw ehondapage0frame010 | db 0
  db    05 | dw ehondapage0frame011 | db 0
  db    08 | dw ehondapage0frame012 | db 0
  db    11 | dw ehondapage0frame013 | db 0
  db    14 | dw ehondapage0frame014 | db 0
  db    18 | dw ehondapage0frame008 | db 0
  db    24 | dw ehondapage0frame007 | db 0


.jumptable:                  ;pointer, y movement
  db    0,  -12,-10,-09,-08,-07,-06,-05,-04,-03,-02,-01
  db    -00,+01,+02,+03,+04,+05,+06,+07,+08,+09
  db    +10,+12
  db    +00,+00,+00,+128      ;end jumptable with 3x 0 otherwise "landing" sfx will not be player
  ds    18

.HorSpeedJumpSlowTable:       ;lenght table, pointer, movement speed
  db    5,0,   4,2,4,2,4
.HorSpeedJumpFastTable:       ;lenght table, pointer, movement speed
  db    5,0,   4,4,2,4,2



;player SoftStandPunching
.StandSoftPunchLeftFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SPL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SPL:
  dw ehondapage1frame002 | db 1
  dw ehondapage3frame000 | db 3
  dw ehondapage3frame000 | db 3

.StandSoftPunchRightFrame:    ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SPR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SPR:
  dw ehondapage0frame002 | db 0
  dw ehondapage2frame000 | db 2
  dw ehondapage2frame000 | db 2

;player HardStandPunching
.StandHardPunchLeftFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HPL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,3,0                 ;animation every 2,5 frames
.AnimationTable_HPL:
  dw ehondapage1frame002 | db 1
  dw ehondapage3frame000 | db 3
  dw ehondapage3frame000 | db 3

.StandHardPunchRightFrame:    ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HPR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,3,0                 ;animation every 2,5 frames
.AnimationTable_HPR:
  dw ehondapage0frame002 | db 0
  dw ehondapage2frame000 | db 2
  dw ehondapage2frame000 | db 2

;player SoftStandKicking
.StandSoftKickLeftFrame:      ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SKL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SKL:
  dw ehondapage3frame004 | db 3
  dw ehondapage3frame005 | db 3
  dw ehondapage3frame004 | db 3
  ds  3
.StandSoftKickRightFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_SKR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,2,0                 ;animation every 2,5 frames
.AnimationTable_SKR:
  dw ehondapage2frame004 | db 2
  dw ehondapage2frame005 | db 2
  dw ehondapage2frame004 | db 2
  ds  3
;player HardStandKicking
.StandHardKickLeftFrame:      ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HKL:          ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.AnimationTable_HKL:
  dw ehondapage3frame004 | db 3
  dw ehondapage3frame005 | db 3
  dw ehondapage3frame004 | db 3
  ds  9
.StandHardKickRightFrame:     ;current spriteframe, total animationsteps
  db    0,3
.AnimationSpeed_HKR:          ;current speed step, ani. speed, ani. speed half frame
  db    0,4,0                 ;animation every 2,5 frames
.AnimationTable_HKR:
  dw ehondapage2frame004 | db 2
  dw ehondapage2frame005 | db 2
  dw ehondapage2frame004 | db 2
    ds  9
;player SoftSitPunching
.SitSoftPunchLeftFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SPL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SPL:
  dw ehondapage1frame007 | db 1
  dw ehondapage3frame006 | db 3
  dw ehondapage3frame006 | db 3

.SitSoftPunchRightFrame:      ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SPR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SPR:
  dw ehondapage0frame007 | db 0
  dw ehondapage2frame006 | db 2
  dw ehondapage2frame006 | db 2

;player HardSitPunching
.SitHardPunchLeftFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_HPL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,3,0                 ;animation every 2,5 frames
.SitAnimationTable_HPL:
  dw ehondapage3frame006 | db 3
  dw ehondapage3frame006 | db 3
  dw ehondapage1frame007 | db 1

.SitHardPunchRightFrame:      ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_HPR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,3,0                 ;animation every 2,5 frames
.SitAnimationTable_HPR:
  dw ehondapage2frame006 | db 2
  dw ehondapage2frame006 | db 2
  dw ehondapage0frame007 | db 0

;player SoftSitKicking
.SitSoftKickLeftFrame:        ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SKL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SKL:
  dw ehondapage3frame004 | db 3
  dw ehondapage3frame005 | db 3
  dw ehondapage3frame004 | db 3

.SitSoftKickRightFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_SKR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,2,1                 ;animation every 2,5 frames
.SitAnimationTable_SKR:
  dw ehondapage2frame004 | db 2
  dw ehondapage2frame005 | db 2
  dw ehondapage2frame004 | db 2

;player HardSitKicking
.SitHardKickLeftFrame:        ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_HKL:       ;current speed step, ani. speed, ani. speed half frame
  db    0,4,1                 ;animation every 2,5 frames
.SitAnimationTable_HKL:
  dw ehondapage3frame004 | db 3
  dw ehondapage3frame005 | db 3
  dw ehondapage3frame004 | db 3
  ds  6
  db  0                       ;movement speed-> move horizontally while performing hard kick ?

.SitHardKickRightFrame:       ;current spriteframe, total animationsteps
  db    0,3
.SitAnimationSpeed_HKR:       ;current speed step, ani. speed, ani. speed half frame
  db    0,4,1                 ;animation every 2,5 frames
.SitAnimationTable_HKR:
  dw ehondapage2frame004 | db 2
  dw ehondapage2frame005 | db 2
  dw ehondapage2frame004 | db 2
  ds  6
  db  0                       ;movement speed-> move horizontally while performing hard kick ?

.LeftSoftJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,0                 ;animation every 2,5 frames
  dw    ehondapage3frame008 | db 3
  dw    ehondapage3frame008 | db 3
  dw    ehondapage3frame008 | db 3
.RightSoftJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,0                 ;animation every 2,5 frames
  dw    ehondapage2frame008 | db 2
  dw    ehondapage2frame008 | db 2
  dw    ehondapage2frame008 | db 2
.LeftHardJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,0                 ;animation every 2,5 frames
  dw    ehondapage3frame009 | db 3
  dw    ehondapage3frame009 | db 3
  dw    ehondapage1frame008 | db 1  
.RightHardJumpPunchStraightup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,0                 ;animation every 2,5 frames
  dw    ehondapage2frame009 | db 2
  dw    ehondapage2frame009 | db 2
  dw    ehondapage0frame008 | db 0

.LeftSoftJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,0                 ;animation every 2,5 frames
  dw    ehondapage3frame008 | db 3
  dw    ehondapage3frame008 | db 3
  dw    ehondapage3frame008 | db 3
.RightSoftJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,0                 ;animation every 2,5 frames
  dw    ehondapage2frame008 | db 2
  dw    ehondapage2frame008 | db 2
  dw    ehondapage2frame008 | db 2
.LeftHardJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,0                 ;animation every 2,5 frames
  dw    ehondapage3frame009 | db 3
  dw    ehondapage3frame009 | db 3
  dw    ehondapage1frame008 | db 1
.RightHardJumpPunchDiagonalup:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,0                 ;animation every 2,5 frames
  dw    ehondapage2frame009 | db 2
  dw    ehondapage2frame009 | db 2
  dw    ehondapage0frame008 | db 0
    
.LeftSoftJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;animation every 2,5 frames
  dw    ehondapage3frame007 | db 3
  dw    ehondapage3frame007 | db 3
  dw    ehondapage3frame007 | db 3
.RightSoftJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;animation every 2,5 frames
  dw    ehondapage2frame007 | db 2
  dw    ehondapage2frame007 | db 2
  dw    ehondapage2frame007 | db 2
.LeftHardJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,0                 ;animation every 2,5 frames
  dw    ehondapage3frame007 | db 3
  dw    ehondapage3frame007 | db 3
  dw    ehondapage1frame008 | db 1
.RightHardJumpKickDiagonalUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,6,0                 ;animation every 2,5 frames
  dw    ehondapage2frame007 | db 2
  dw    ehondapage2frame007 | db 2
  dw    ehondapage0frame008 | db 0
  
.LeftSoftJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;animation every 2,5 frames
  dw    ehondapage3frame007 | db 3
  dw    ehondapage3frame007 | db 3
  dw    ehondapage3frame007 | db 3
.RightSoftJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,8,0                 ;animation every 2,5 frames
  dw    ehondapage2frame007 | db 2
  dw    ehondapage2frame007 | db 2
  dw    ehondapage2frame007 | db 2
.LeftHardJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,5,1                 ;animation every 2,5 frames
  dw    ehondapage3frame007 | db 3
  dw    ehondapage3frame007 | db 3
  dw    ehondapage1frame008 | db 1
.RightHardJumpKickStraightUp:
  db    0,3                   ;current spriteframe, total animationsteps
  db    0,5,1                 ;animation every 2,5 frames
  dw    ehondapage2frame007 | db 2
  dw    ehondapage2frame007 | db 2
  dw    ehondapage0frame008 | db 0
  
.LeftStandDefendFrame:
  dw    ehondapage3frame010 | db 3
.RightStandDefendFrame:
  dw    ehondapage2frame010 | db 2
.LeftBendDefendFrame:
  dw    ehondapage3frame011 | db 3
.RightBendDefendFrame:
  dw    ehondapage2frame011 | db 2
 
.LeftStandHitFrame:
  dw    ehondapage3frame012 | db 3
.RightStandHitFrame:
  dw    ehondapage2frame012 | db 2
.LeftBendHitFrame:
  dw    ehondapage3frame012 | db 3
.RightBendHitFrame:
  dw    ehondapage2frame012 | db 2
.LeftJumpHitFrame:
  dw    ehondapage3frame012 | db 3
.RightJumpHitFrame:
  dw    ehondapage2frame012 | db 2

.HeavilyHitLeftFrame:         ;current spriteframe, total animationsteps
  db    0,13
.HeavilyHitLeftAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.HeavilyHitLeftAnimationTable:
  dw ehondapage3frame014 | db 3
  dw ehondapage3frame014 | db 3
  dw ehondapage3frame014 | db 3
  dw ehondapage3frame014 | db 3
  dw ehondapage1frame014 | db 1
  dw ehondapage1frame014 | db 1
  dw ehondapage1frame013 | db 1
  dw ehondapage1frame013 | db 1
  dw ehondapage1frame013 | db 1
  dw ehondapage1frame013 | db 1
  dw ehondapage1frame013 | db 1
  dw ehondapage1frame013 | db 1
  dw ehondapage1frame013 | db 1

.HeavilyHitRightFrame:        ;current spriteframe, total animationsteps
  db    0,13
.HeavilyHitRightAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.HeavilyHitRightAnimationTable:
  dw ehondapage2frame014 | db 2
  dw ehondapage2frame014 | db 2
  dw ehondapage2frame014 | db 2
  dw ehondapage2frame014 | db 2
  dw ehondapage0frame014 | db 0
  dw ehondapage0frame014 | db 0
  dw ehondapage0frame013 | db 0
  dw ehondapage0frame013 | db 0
  dw ehondapage0frame013 | db 0
  dw ehondapage0frame013 | db 0
  dw ehondapage0frame013 | db 0
  dw ehondapage0frame013 | db 0
  dw ehondapage0frame013 | db 0
  
.JumpHitLeftFrame:        ;current spriteframe, total animationsteps
  db    0,13
.JumphitLeftAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.JumphitLeftAnimationTable:
  dw ehondapage3frame012 | db 3
  dw ehondapage3frame012 | db 3
  dw ehondapage1frame014 | db 1
  dw ehondapage1frame014 | db 1
  dw ehondapage1frame013 | db 1
  dw ehondapage1frame012 | db 1
  dw ehondapage1frame011 | db 1
  dw ehondapage1frame010 | db 1
  dw ehondapage1frame010 | db 1
  dw ehondapage1frame010 | db 1
  dw ehondapage1frame010 | db 1
  dw ehondapage1frame010 | db 1
  dw ehondapage1frame010 | db 1

.JumpHitRightFrame:       ;current spriteframe, total animationsteps
  db    0,13
.JumphitRightAnimationSpeed:
  db    0,2,1                 ;current speed step, ani. speed, ani. speed half frame
.JumphitRightAnimationTable:
  dw ehondapage2frame012 | db 2
  dw ehondapage2frame012 | db 2
  dw ehondapage0frame014 | db 0
  dw ehondapage0frame014 | db 0
  dw ehondapage0frame013 | db 0
  dw ehondapage0frame012 | db 0
  dw ehondapage0frame011 | db 0
  dw ehondapage0frame010 | db 0
  dw ehondapage0frame010 | db 0
  dw ehondapage0frame010 | db 0
  dw ehondapage0frame010 | db 0
  dw ehondapage0frame010 | db 0
  dw ehondapage0frame010 | db 0  

.KnockDownRecoverLeftFrame:
  db    0,3
.AnimationSpeed_KDARR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_KDARR:
  dw ehondapage3frame015 | db 3
  dw ehondapage3frame015 | db 3
  dw ehondapage1frame013 | db 1
  dw ehondapage1frame012 | db 1
  dw ehondapage1frame011 | db 1

.KnockDownRecoverRightFrame:
  db    0,5
.AnimationSpeed_KDARL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_KDARL:
  dw ehondapage2frame015 | db 2
  dw ehondapage2frame015 | db 2
  dw ehondapage0frame013 | db 0
  dw ehondapage0frame012 | db 0
  dw ehondapage0frame011 | db 0

.TossLeftFrame:
  db    0,2
.AnimationSpeed_TossL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,9,0                 ;animation every 2,5 frames
.AnimationTable_TossL:
  dw ehondapage3frame016 | db 3
  dw ehondapage1frame015 | db 1

.TossRightFrame:
  db    0,2
.AnimationSpeed_TossR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,9,0                 ;animation every 2,5 frames
.AnimationTable_TossR:
  dw ehondapage2frame016 | db 2
  dw ehondapage0frame015 | db 0

.VictoryLeftFrame:
  db    0,3
.AnimationSpeed_VictL:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_VictL:
  dw ehondapage3frame000 | db 3
  dw ehondapage3frame000 | db 3
  dw ehondapage3frame000 | db 3

.VictoryRightFrame:
  db    0,3
.AnimationSpeed_VictR:        ;current speed step, ani. speed, ani. speed half frame
  db    0,3,1                 ;animation every 2,5 frames
.AnimationTable_VictR:
  dw ehondapage2frame000 | db 2
  dw ehondapage2frame000 | db 2
  dw ehondapage2frame000 | db 2

;Sumo Smash
.Special1MovementTablePointer:
  db    0
.Special1DurationTimer:
  db    32                    ;Amount of frames that Special move takes
.Special1MovementTable:      ;movement(y,x)
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+08, -03,+08, -07,+08, -11,+08, -13,+08, -17,+06
  db    -15,+08 | ds 28
;Hundred Hand Slap
.Special2MovementTablePointer:
  db    0
.Special2DurationTimer:
  db    60                    ;Amount of frames that Special move takes
.Special2MovementTable:      ;movement(y,x)
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, -00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
;Sumo Headbutt  
.Special3MovementTablePointer:
  db    0
.Special3DurationTimer:
  db    60                    ;Amount of frames that Special move takes
.Special3MovementTable:      ;movement(y,x)
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+10, +00,+10, +00,+10, +00,+10, +00,+10, +00,+10
  db    +00,+10, +00,+10, +00,+10, +00,+10, +00,+10, +00,+10, +00,+10, +00,+10, +00,+10, +00,+10, +00,+10, +00,+10, +00,+10, +00,+10, +00,+10
;Sumo Smash part 2
.Special4MovementTablePointer:
  db    0
.Special4DurationTimer:
  db    60                    ;Amount of frames that Special move takes
.Special4MovementTable:      ;movement(y,x)
  db    -11,+06, -07,+06, -03,+06, -00,+04, -00,+02, +03,+00, +06,+00, +09,+00, +12,+00, +15,+00, +16,+00, +16,+00, +16,+00, +16,+00, +16,+00
  db    +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00, +00,+00
;Sumo Headbutt part 2
.Special5MovementTablePointer:
  db    0
.Special5DurationTimer:
  db    24                    ;Amount of frames that Special move takes
.Special5MovementTable:      ;movement(y,x)
  db    +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02
  db    +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02, +00,-02
;Sumo Smash
.VariableTableSpecial1:
  db    1                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    1                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    4                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    0                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;Hundred Hand Slap
.VariableTableSpecial2:                 ;ch=charge, d=down, u=up, b=back, f=foreward, p=punch, k=kick, r=repeat
  db    3                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    1                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    0                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    0                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    2                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    1                     ;can move horizontally (slowly) during special attack ?
  db    0                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;Sumo Headbutt
.VariableTableSpecial3:
  db    2                     ;attack type ? 1=ch-d,u+k | 2=ch-b,f+p | 3=rp | 4=rk | 5=d,f+p | 6=d,b+k | 7=f,d,f+p
  db    1                     ;1=execute only on ground, 2=execute only in air (0=both)
  db    5                     ;initiate another special attack at end ? (0=no, 1,2,3,4... = special attack number)
  db    1                     ;attack knocks you down ? (counts as being heavily hit)
  db    0                     ;shoot projectile at frame x of this special attack ? (0=no)
  db    0                     ;can execute while punching/kicking ? AND can this special attack be performed WHILE special attack x is busy ?
  db    0                     ;can move horizontally (slowly) during special attack ?
  db    5                     ;initiate another special attack on enemy impact ?  (blanka roll)
  db    0                     ;initiate another special attack or loop if a certain key combi is given
  db    0                     ;direction of attack (hurricane kick chunli/ken)
;Sumo Smash part 2
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
;Sumo Headbutt part 2
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
;Sumo Smash
.Special1LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,4,0                 ;current speed step, ani. speed, ani. speed half frame
  dw ehondapage1frame005 | db 1
  dw ehondapage3frame010 | db 3
  dw ehondapage3frame013 | db 3
  dw ehondapage3frame009 | db 3
.Special1RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,4,0                 ;current speed step, ani. speed, ani. speed half frame
  dw ehondapage0frame005 | db 0
  dw ehondapage2frame010 | db 2
  dw ehondapage2frame013 | db 2
  dw ehondapage2frame009 | db 2
;Hundred Hand Slap
.Special2LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,1                 ;current speed step, ani. speed, ani. speed half frame
  dw ehondapage3frame001 | db 3
  dw ehondapage3frame002 | db 3
  dw ehondapage3frame001 | db 3
  dw ehondapage3frame003 | db 3
.Special2RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,1,1                 ;current speed step, ani. speed, ani. speed half frame
  dw ehondapage2frame001 | db 2
  dw ehondapage2frame002 | db 2
  dw ehondapage2frame001 | db 2
  dw ehondapage2frame003 | db 2
;Sumo Headbutt
.Special3LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,09,0                ;current speed step, ani. speed, ani. speed half frame
  dw ehondapage3frame010 | db 3
  dw ehondapage3frame013 | db 3
  dw ehondapage3frame013 | db 3
  dw ehondapage3frame013 | db 3
.Special3RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,9,0                 ;current speed step, ani. speed, ani. speed half frame
  dw ehondapage2frame010 | db 2
  dw ehondapage2frame013 | db 2
  dw ehondapage2frame013 | db 2
  dw ehondapage2frame013 | db 2
;Sumo Smash part 2
.Special4LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,5,0                 ;current speed step, ani. speed, ani. speed half frame
  dw ehondapage3frame009 | db 3
  dw ehondapage3frame008 | db 3
  dw ehondapage3frame008 | db 3
  dw ehondapage3frame008 | db 3
.Special4RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,5,0                 ;current speed step, ani. speed, ani. speed half frame
  dw ehondapage2frame009 | db 2
  dw ehondapage2frame008 | db 2
  dw ehondapage2frame008 | db 2
  dw ehondapage2frame008 | db 2
;Sumo Headbutt part 2
.Special5LeftFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;current speed step, ani. speed, ani. speed half frame
  dw ehondapage1frame011 | db 1
  dw ehondapage1frame012 | db 1
  dw ehondapage1frame013 | db 1
  dw ehondapage1frame014 | db 1
.Special5RightFrame:
  db    0,4                   ;current spriteframe, total animationsteps
  db    0,3,0                 ;current speed step, ani. speed, ani. speed half frame
  dw ehondapage0frame011 | db 0
  dw ehondapage0frame012 | db 0
  dw ehondapage0frame013 | db 0
  dw ehondapage0frame014 | db 0

.GettingTossedLeftFrame:      ;current spriteframe, total animationsteps
  db    0,4
.GettingTossedLeftAnimationSpeed:
  db    0,9,1                 ;current speed step, ani. speed, ani. speed half frame
.GettingTossedLeftAnimationTable:
  dw ehondapage3frame012 | db 3
  dw ehondapage3frame014 | db 3
  dw ehondapage1frame014 | db 1
  dw ehondapage1frame013 | db 1

.GettingTossedRightFrame:     ;current spriteframe, total animationsteps
  db    0,4
.GettingTossedRightAnimationSpeed:
  db    0,9,1                 ;current speed step, ani. speed, ani. speed half frame
.GettingTossedRightAnimationTable:
  dw ehondapage2frame012 | db 2
  dw ehondapage2frame014 | db 2
  dw ehondapage0frame014 | db 0
  dw ehondapage0frame013 | db 0

.DamageTabel: ;SoftStandPunch, HardStandPunch, SoftStandKick, HardStandKick, SoftSitPunch, HardSitPunch, 
              ;SoftSitKick, HardSitKick, JumpSoftPunch, JumpHardPunch, JumpSoftKick, JumpHardKick, Special1-5, Toss
  db    12,12,12,12,12,12,12,18, 12,16,12,16,  12,08,20,12,00, 20
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
  dw ehondapage3frame015 | db 3
.DiedRightFrame:
  dw ehondapage2frame015 | db 2
  
