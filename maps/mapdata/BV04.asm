 .amountofobjects: db  0 |
 
;Big Statue Mouth
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object0: db 1,        0|dw BigStatueMouth    |db 8*09+4|dw 8*09|db 11,14|dw CleanOb1,0 db 0,0,0,                     +014,+00,+00,+00,+00,+00,+00,+00,+00, 0|db 000,movepatblo1| ds fill-1
;Cute Mini Bat
       ;alive?,Sprite?,Movement Pattern,               y,      x,   ny,nx,spnrinspat,spataddress,nrsprites,nrspr,nrS*16,v1, v2, v3, v4, v5, v6, v7, v8, v9,Hit?,life 
.object2:db -0,        1|dw CuteMiniBat         |db 8*14|dw 8*27|db 16,16|dw 12*16,spat+(12*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+90+5,+01,+00, 0|db 001,movepatblo1| ds fill-1
.object3:db -0,        1|dw CuteMiniBat         |db 8*14|dw 8*27|db 16,16|dw 14*16,spat+(14*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,180,+01,+00, 0|db 001,movepatblo1| ds fill-1
.object4:db -0,        1|dw CuteMiniBat         |db 8*14|dw 8*27|db 16,16|dw 16*16,spat+(16*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+45,+01,+00, 0|db 001,movepatblo1| ds fill-1
.object5:db -0,        1|dw CuteMiniBat         |db 8*14|dw 8*27|db 16,16|dw 18*16,spat+(18*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,160,+01,+00, 0|db 001,movepatblo1| ds fill-1
.object6:db -0,        1|dw CuteMiniBat         |db 8*14|dw 8*27|db 16,16|dw 20*16,spat+(20*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,+25+5,+01,+00, 0|db 001,movepatblo1| ds fill-1
.object7:db -0,        1|dw CuteMiniBat         |db 8*14|dw 8*27|db 16,16|dw 22*16,spat+(22*2)|db 72-(02*6),02  ,02*16,+00,+00,+00,+00,+00,+00,110,+01,+00, 0|db 001,movepatblo1| ds fill-1
;==================================================================================================================