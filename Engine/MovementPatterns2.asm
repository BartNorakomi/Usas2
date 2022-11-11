;BossGoat

PutSf2Object5Frames:
  ld    a,(HugeObjectFrame)
  inc   a
  cp    5
  jr    nz,.SetFrame
  xor   a
  .SetFrame:
  ld    (HugeObjectFrame),a
  or    a
  jr    z,.Part1
  dec   a
  jr    z,.Part2
  dec   a
  jr    z,.Part3
  dec   a
  jr    z,.Part4

  .Part5:
  call  restoreBackgroundObject5
  ld    a,(ix+enemies_and_objects.v7)
  add   a,4
  call  SetFrameBoss
  call  PutSF2Object5                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  jp    switchpageSF2Engine

  .Part4:
  call  restoreBackgroundObject4
  ld    a,(ix+enemies_and_objects.v7)
  add   a,3
  call  SetFrameBoss
  jp    PutSF2Object4                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
  .Part3:
  call  restoreBackgroundObject3
  ld    a,(ix+enemies_and_objects.v7)
  add   a,2
  call  SetFrameBoss
  jp    PutSF2Object3                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
  .Part2:
  call  restoreBackgroundObject2
  ld    a,(ix+enemies_and_objects.v7)
;  add   a,1
  inc   a
  call  SetFrameBoss
  jp    PutSF2Object2                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
  .Part1:
  call  restoreBackgroundObject1
  ld    a,(ix+enemies_and_objects.v7)
;  add   a,0
  call  SetFrameBoss
  jp    PutSF2Object                        ;in: b=frame list block, c=sprite data block. CHANGES IX 


PutSf2Object4Frames:
  ld    a,(HugeObjectFrame)
  inc   a
  cp    4
  jr    nz,.SetFrame
  xor   a
  .SetFrame:
  ld    (HugeObjectFrame),a

  or    a  
  jr    z,.Part1
  dec   a
  jr    z,.Part2
  dec   a
  jr    z,.Part3

  .Part4:
  call  restoreBackgroundObject4
  ld    a,(ix+enemies_and_objects.v7)
  add   a,3
  call  SetFrameBoss
  call  PutSF2Object4                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  jp    switchpageSF2Engine

  .Part3:
  call  restoreBackgroundObject3
  ld    a,(ix+enemies_and_objects.v7)
  add   a,2
  call  SetFrameBoss
  jp    PutSF2Object3                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
  .Part2:
  call  restoreBackgroundObject2
  ld    a,(ix+enemies_and_objects.v7)
  inc   a
  call  SetFrameBoss
  jp    PutSF2Object2                       ;in: b=frame list block, c=sprite data block. CHANGES IX 
  
  .Part1:
  call  restoreBackgroundObject1
  ld    a,(ix+enemies_and_objects.v7)
  call  SetFrameBoss
  jp    PutSF2Object                        ;in: b=frame list block, c=sprite data block. CHANGES IX 

;Idle 
BossGoatIdleAndWalk00:   dw GoatIdleAndWalkframe000 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk01:   dw GoatIdleAndWalkframe001 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk02:   dw GoatIdleAndWalkframe002 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk03:   dw GoatIdleAndWalkframe003 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk04:   dw GoatIdleAndWalkframe004 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk05:   dw GoatIdleAndWalkframe000 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk06:   dw GoatIdleAndWalkframe001 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk07:   dw GoatIdleAndWalkframe002 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk08:   dw GoatIdleAndWalkframe003 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk09:   dw GoatIdleAndWalkframe004 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk10:   dw GoatIdleAndWalkframe000 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk11:   dw GoatIdleAndWalkframe001 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk12:   dw GoatIdleAndWalkframe002 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk13:   dw GoatIdleAndWalkframe003 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk14:   dw GoatIdleAndWalkframe004 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk15:   dw GoatIdleAndWalkframe000 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk16:   dw GoatIdleAndWalkframe001 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk17:   dw GoatIdleAndWalkframe002 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk18:   dw GoatIdleAndWalkframe003 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk19:   dw GoatIdleAndWalkframe004 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk20:   dw GoatIdleAndWalkframe000 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk21:   dw GoatIdleAndWalkframe001 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk22:   dw GoatIdleAndWalkframe002 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk23:   dw GoatIdleAndWalkframe003 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk24:   dw GoatIdleAndWalkframe004 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk25:   dw GoatIdleAndWalkframe005 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk26:   dw GoatIdleAndWalkframe006 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk27:   dw GoatIdleAndWalkframe007 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk28:   dw GoatIdleAndWalkframe008 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk29:   dw GoatIdleAndWalkframe009 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk30:   dw GoatIdleAndWalkframe010 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk31:   dw GoatIdleAndWalkframe011 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk32:   dw GoatIdleAndWalkframe012 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk33:   dw GoatIdleAndWalkframe013 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk34:   dw GoatIdleAndWalkframe014 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk35:   dw GoatIdleAndWalkframe015 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk36:   dw GoatIdleAndWalkframe016 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk37:   dw GoatIdleAndWalkframe017 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk38:   dw GoatIdleAndWalkframe018 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk39:   dw GoatIdleAndWalkframe019 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk40:   dw GoatIdleAndWalkframe020 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk41:   dw GoatIdleAndWalkframe021 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk42:   dw GoatIdleAndWalkframe022 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk43:   dw GoatIdleAndWalkframe023 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk44:   dw GoatIdleAndWalkframe024 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk45:   dw GoatIdleAndWalkframe025 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk46:   dw GoatIdleAndWalkframe026 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk47:   dw GoatIdleAndWalkframe027 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk48:   dw GoatIdleAndWalkframe028 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk49:   dw GoatIdleAndWalkframe029 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

;Walk
BossGoatIdleAndWalk50:   dw GoatIdleAndWalkframe030 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk51:   dw GoatIdleAndWalkframe031 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk52:   dw GoatIdleAndWalkframe032 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk53:   dw GoatIdleAndWalkframe033 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk54:   dw GoatIdleAndWalkframe034 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk55:   dw GoatIdleAndWalkframe035 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk56:   dw GoatIdleAndWalkframe036 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk57:   dw GoatIdleAndWalkframe037 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk58:   dw GoatIdleAndWalkframe038 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk59:   dw GoatIdleAndWalkframe039 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk60:   dw GoatIdleAndWalkframe040 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk61:   dw GoatIdleAndWalkframe041 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk62:   dw GoatIdleAndWalkframe042 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk63:   dw GoatIdleAndWalkframe043 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk64:   dw GoatIdleAndWalkframe044 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk65:   dw GoatIdleAndWalkframe045 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk66:   dw GoatIdleAndWalkframe046 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk67:   dw GoatIdleAndWalkframe047 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk68:   dw GoatIdleAndWalkframe048 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk69:   dw GoatIdleAndWalkframe049 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk70:   dw GoatIdleAndWalkframe050 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk71:   dw GoatIdleAndWalkframe051 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk72:   dw GoatIdleAndWalkframe052 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk73:   dw GoatIdleAndWalkframe053 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk74:   dw GoatIdleAndWalkframe054 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk75:   dw GoatIdleAndWalkframe055 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk76:   dw GoatIdleAndWalkframe056 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk77:   dw GoatIdleAndWalkframe057 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk78:   dw GoatIdleAndWalkframe058 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk79:   dw GoatIdleAndWalkframe059 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk80:   dw GoatIdleAndWalkframe060 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk81:   dw GoatIdleAndWalkframe061 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk82:   dw GoatIdleAndWalkframe062 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk83:   dw GoatIdleAndWalkframe063 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk84:   dw GoatIdleAndWalkframe064 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk85:   dw GoatIdleAndWalkframe065 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk86:   dw GoatIdleAndWalkframe066 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk87:   dw GoatIdleAndWalkframe067 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk88:   dw GoatIdleAndWalkframe068 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk89:   dw GoatIdleAndWalkframe069 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk90:   dw GoatIdleAndWalkframe070 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk91:   dw GoatIdleAndWalkframe071 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk92:   dw GoatIdleAndWalkframe072 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk93:   dw GoatIdleAndWalkframe073 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk94:   dw GoatIdleAndWalkframe074 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatIdleAndWalk95:   dw GoatIdleAndWalkframe075 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk96:   dw GoatIdleAndWalkframe076 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk97:   dw GoatIdleAndWalkframe077 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk98:   dw GoatIdleAndWalkframe078 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock
BossGoatIdleAndWalk99:   dw GoatIdleAndWalkframe079 | db BossGoatIdleAndWalkframelistblock, BossGoatIdleAndWalkspritedatablock

BossGoatWalkAndAttack100:   dw GoatWalkAndAttackframe000 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack101:   dw GoatWalkAndAttackframe001 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack102:   dw GoatWalkAndAttackframe002 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack103:   dw GoatWalkAndAttackframe003 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack104:   dw GoatWalkAndAttackframe004 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock

BossGoatWalkAndAttack105:   dw GoatWalkAndAttackframe005 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack106:   dw GoatWalkAndAttackframe006 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack107:   dw GoatWalkAndAttackframe007 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack108:   dw GoatWalkAndAttackframe008 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack109:   dw GoatWalkAndAttackframe009 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock

;attack
BossGoatWalkAndAttack110:   dw GoatWalkAndAttackframe010 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack111:   dw GoatWalkAndAttackframe011 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack112:   dw GoatWalkAndAttackframe012 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack113:   dw GoatWalkAndAttackframe013 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack114:   dw GoatWalkAndAttackframe014 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock

BossGoatWalkAndAttack115:   dw GoatWalkAndAttackframe015 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack116:   dw GoatWalkAndAttackframe016 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack117:   dw GoatWalkAndAttackframe017 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack118:   dw GoatWalkAndAttackframe018 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack119:   dw GoatWalkAndAttackframe019 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock

BossGoatWalkAndAttack120:   dw GoatWalkAndAttackframe020 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack121:   dw GoatWalkAndAttackframe021 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack122:   dw GoatWalkAndAttackframe022 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack123:   dw GoatWalkAndAttackframe023 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack124:   dw GoatWalkAndAttackframe024 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock

BossGoatWalkAndAttack125:   dw GoatWalkAndAttackframe025 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack126:   dw GoatWalkAndAttackframe026 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack127:   dw GoatWalkAndAttackframe027 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack128:   dw GoatWalkAndAttackframe028 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack129:   dw GoatWalkAndAttackframe029 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock

BossGoatWalkAndAttack130:   dw GoatWalkAndAttackframe030 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack131:   dw GoatWalkAndAttackframe031 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack132:   dw GoatWalkAndAttackframe032 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack133:   dw GoatWalkAndAttackframe033 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack134:   dw GoatWalkAndAttackframe034 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock

BossGoatWalkAndAttack135:   dw GoatWalkAndAttackframe035 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack136:   dw GoatWalkAndAttackframe036 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack137:   dw GoatWalkAndAttackframe037 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack138:   dw GoatWalkAndAttackframe038 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack139:   dw GoatWalkAndAttackframe039 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock

BossGoatWalkAndAttack145:   dw GoatWalkAndAttackframe040 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack146:   dw GoatWalkAndAttackframe041 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack147:   dw GoatWalkAndAttackframe042 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack148:   dw GoatWalkAndAttackframe043 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock
BossGoatWalkAndAttack149:   dw GoatWalkAndAttackframe044 | db BossGoatWalkAndAttackframelistblock, BossGoatWalkAndAttackspritedatablock

BossGoatAttack150:   dw GoatAttackframe000 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack151:   dw GoatAttackframe001 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack152:   dw GoatAttackframe002 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack153:   dw GoatAttackframe003 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack154:   dw GoatAttackframe004 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock

BossGoatAttack155:   dw GoatAttackframe005 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack156:   dw GoatAttackframe005 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack157:   dw GoatAttackframe006 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack158:   dw GoatAttackframe007 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack159:   dw GoatAttackframe008 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock

BossGoatAttack160:   dw GoatAttackframe009 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack161:   dw GoatAttackframe009 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack162:   dw GoatAttackframe009 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack163:   dw GoatAttackframe010 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack164:   dw GoatAttackframe011 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock

BossGoatAttack165:   dw GoatAttackframe012 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack166:   dw GoatAttackframe012 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack167:   dw GoatAttackframe012 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack168:   dw GoatAttackframe013 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack169:   dw GoatAttackframe014 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock

BossGoatAttack170:   dw GoatAttackframe015 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack171:   dw GoatAttackframe015 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack172:   dw GoatAttackframe015 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack173:   dw GoatAttackframe016 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack174:   dw GoatAttackframe017 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock

BossGoatAttack175:   dw GoatAttackframe018 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack176:   dw GoatAttackframe018 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack177:   dw GoatAttackframe018 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack178:   dw GoatAttackframe019 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack179:   dw GoatAttackframe020 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock

BossGoatAttack180:   dw GoatAttackframe021 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack181:   dw GoatAttackframe021 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack182:   dw GoatAttackframe021 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack183:   dw GoatAttackframe022 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock
BossGoatAttack184:   dw GoatAttackframe023 | db BossGoatAttackframelistblock, BossGoatAttackspritedatablock

BossGoatAttack2185:   dw GoatAttack2frame000 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2186:   dw GoatAttack2frame000 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2187:   dw GoatAttack2frame001 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2188:   dw GoatAttack2frame002 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2189:   dw GoatAttack2frame003 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock

BossGoatAttack2190:   dw GoatAttack2frame004 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2191:   dw GoatAttack2frame004 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2192:   dw GoatAttack2frame005 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2193:   dw GoatAttack2frame006 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2194:   dw GoatAttack2frame007 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock

BossGoatAttack2195:   dw GoatAttack2frame008 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2196:   dw GoatAttack2frame009 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2197:   dw GoatAttack2frame010 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2198:   dw GoatAttack2frame011 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2199:   dw GoatAttack2frame012 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock

BossGoatAttack2200:   dw GoatAttack2frame013 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2201:   dw GoatAttack2frame014 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2202:   dw GoatAttack2frame015 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2203:   dw GoatAttack2frame016 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2204:   dw GoatAttack2frame017 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock

BossGoatAttack2205:   dw GoatAttack2frame018 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2206:   dw GoatAttack2frame019 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2207:   dw GoatAttack2frame020 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2208:   dw GoatAttack2frame021 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2209:   dw GoatAttack2frame022 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock

BossGoatAttack2210:   dw GoatAttack2frame023 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2211:   dw GoatAttack2frame023 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2212:   dw GoatAttack2frame024 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2213:   dw GoatAttack2frame025 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock
BossGoatAttack2214:   dw GoatAttack2frame026 | db BossGoatAttack2framelistblock, BossGoatAttack2spritedatablock

BossGoatAttackAndHit215:   dw GoatAttackAndHitframe000 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit216:   dw GoatAttackAndHitframe001 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit217:   dw GoatAttackAndHitframe002 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit218:   dw GoatAttackAndHitframe003 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit219:   dw GoatAttackAndHitframe004 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock

;Hit
BossGoatAttackAndHit220:   dw GoatAttackAndHitframe005 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit221:   dw GoatAttackAndHitframe006 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit222:   dw GoatAttackAndHitframe007 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit223:   dw GoatAttackAndHitframe008 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit224:   dw GoatAttackAndHitframe009 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock

BossGoatAttackAndHit225:   dw GoatAttackAndHitframe010 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit226:   dw GoatAttackAndHitframe011 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit227:   dw GoatAttackAndHitframe012 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit228:   dw GoatAttackAndHitframe013 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit229:   dw GoatAttackAndHitframe014 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock

BossGoatAttackAndHit230:   dw GoatAttackAndHitframe015 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit231:   dw GoatAttackAndHitframe016 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit232:   dw GoatAttackAndHitframe017 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit233:   dw GoatAttackAndHitframe018 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit234:   dw GoatAttackAndHitframe019 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock

BossGoatAttackAndHit235:   dw GoatAttackAndHitframe020 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit236:   dw GoatAttackAndHitframe021 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit237:   dw GoatAttackAndHitframe022 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit238:   dw GoatAttackAndHitframe023 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit239:   dw GoatAttackAndHitframe024 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock

BossGoatAttackAndHit240:   dw GoatAttackAndHitframe025 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit241:   dw GoatAttackAndHitframe026 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit242:   dw GoatAttackAndHitframe027 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit243:   dw GoatAttackAndHitframe028 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit244:   dw GoatAttackAndHitframe029 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock

BossGoatAttackAndHit245:   dw GoatAttackAndHitframe030 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit246:   dw GoatAttackAndHitframe031 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit247:   dw GoatAttackAndHitframe032 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit248:   dw GoatAttackAndHitframe033 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock
BossGoatAttackAndHit249:   dw GoatAttackAndHitframe034 | db BossGoatAttackAndHitframelistblock, BossGoatAttackAndHitspritedatablock

;Dying
BossGoatDying250:   dw GoatDyingframe000 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying251:   dw GoatDyingframe001 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying252:   dw GoatDyingframe002 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying253:   dw GoatDyingframe003 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying254:   dw GoatDyingframe004 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock

BossGoatDying255:   dw GoatDyingframe005 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying256:   dw GoatDyingframe006 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying257:   dw GoatDyingframe007 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying258:   dw GoatDyingframe008 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying259:   dw GoatDyingframe009 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock

BossGoatDying260:   dw GoatDyingframe010 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying261:   dw GoatDyingframe011 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying262:   dw GoatDyingframe012 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying263:   dw GoatDyingframe013 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying264:   dw GoatDyingframe014 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock

BossGoatDying265:   dw GoatDyingframe015 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying266:   dw GoatDyingframe016 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying267:   dw GoatDyingframe017 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying268:   dw GoatDyingframe018 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock
BossGoatDying269:   dw GoatDyingframe019 | db BossGoatDyingframelistblock, BossGoatDyingspritedatablock

BossGoatDying2270:   dw GoatDying2frame000 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2271:   dw GoatDying2frame001 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2272:   dw GoatDying2frame002 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2273:   dw GoatDying2frame003 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2274:   dw GoatDying2frame004 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock

BossGoatDying2275:   dw GoatDying2frame005 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2276:   dw GoatDying2frame005 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2277:   dw GoatDying2frame006 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2278:   dw GoatDying2frame007 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2279:   dw GoatDying2frame008 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock

BossGoatDying2280:   dw GoatDying2frame009 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2281:   dw GoatDying2frame009 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2282:   dw GoatDying2frame009 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2283:   dw GoatDying2frame009 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2284:   dw GoatDying2frame010 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock

BossGoatDying2285:   dw GoatDying2frame011 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2286:   dw GoatDying2frame011 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2287:   dw GoatDying2frame011 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2288:   dw GoatDying2frame011 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2289:   dw GoatDying2frame012 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock

BossGoatDying2290:   dw GoatDying2frame013 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2291:   dw GoatDying2frame013 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2292:   dw GoatDying2frame013 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2293:   dw GoatDying2frame013 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2294:   dw GoatDying2frame014 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock

BossGoatDying2295:   dw GoatDying2frame015 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2296:   dw GoatDying2frame015 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2297:   dw GoatDying2frame015 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2298:   dw GoatDying2frame015 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2299:   dw GoatDying2frame016 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock

BossGoatDying2300:   dw GoatDying2frame017 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2301:   dw GoatDying2frame017 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2302:   dw GoatDying2frame017 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2303:   dw GoatDying2frame017 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock
BossGoatDying2304:   dw GoatDying2frame018 | db BossGoatDying2framelistblock, BossGoatDying2spritedatablock












BossGoat:
;v1-1=
;v1=repeating steps
;v2=pointer to movement table
;v3=Vertical Movement
;v4=Horizontal Movement
;v5=Snap Player to Object ? This byte gets set in the CheckCollisionObjectPlayer routine
;v6=active on which frame ?  
;v7=sprite frame
;v8=phase
;v9=timer until attack
;  call  CheckPlayerHitByZombieCaterpillar   ;Check if player gets hit by boss
  ;Check if boss gets hit by player
;  call  ZombieCaterpillarCheckIfHit         ;call gets popped if hit. Check if boss is hit, and if so set being hit phase
  ;Check if boss is dead
;  call  ZombieCaterpillarCheckIfDead        ;Check if boss is dead, and if so set dying phase
  
  call  .HandlePhase                        ;(0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)

  ld    de,BossGoatIdleAndWalk00
  jp    PutSf2Object5Frames                 ;CHANGES IX - puts object in 3 frames, Top, Middle and then Bottom

  .HandlePhase:                            ;(0=idle sitting, 1=idle flying, 2=attacking, 3=hit, 4=dead)
  ld    de,NonMovingObjectMovementTable
  call  MoveObjectWithStepTable             ;v1=repeating steps, v2=pointer to movement table, v3=y movement, v4=x movement. out: y->(Object1y), x->(Object1x). Movement x=8bit  

  ld    a,(HugeObjectFrame)
  cp    4
  ret   nz
  
  ld    a,(Bossframecounter)
  inc   a
  ld    (Bossframecounter),a

  ld    a,(ix+enemies_and_objects.v8)       ;v8=Phase (0=attack, 1=Idle, 2=diving underground, 3=moving underground towards player, 4=hit, 5=dead)
  or    a
  jp    z,BossGoatIdle                      ;0=attack
  dec   a
  ret
  
  BossGoatIdle:
;  ld    a,(Bossframecounter)
;  rrca
;  ret   c  

  call  .animate

;  dec   (ix+enemies_and_objects.v9)         ;v9=timer until attack
;  ret   nz
;  ld    (ix+enemies_and_objects.v8),2       ;v8=Phase (0=attack, 1=Idle, 2=diving underground, 3=moving underground towards player, 4=hit, 5=dead)
;  ld    (ix+enemies_and_objects.v7),18      ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  ret
  
  .animate:
  ld    a,(ix+enemies_and_objects.v7)       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  add   a,5                                 ;amount of frames per animation step
  ld    (ix+enemies_and_objects.v7),a       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  cp    220                                  ;(0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  ret   nz
  ld    (ix+enemies_and_objects.v7),110       ;v7=sprite frame (0= idle, 18=diving underground, 54=attacking, 96=hit, 111 = dying)
  ret  
  
  

