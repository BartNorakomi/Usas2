/// @description Insert description here
// You can write your code in this editor
enemyHitCounter = 0;
life = 1;
nx = 20; // width
ny = 26; // height
movementDirection = "right";
movementSpeed = 0.4;
explosionsprite = sExplosionBig;
slowdownfactorwhenhit = 0.2; // if hit enemy moves slower
phase = 0; // (0=walking, 1=rattling, 2=attacking)
animationcounter = 0;
SnapPlayer = false;
enemyisfacingplayer = false;
distancecheckx = 28
distancechecky = 40
withindistanceplayer = false;
waitbeforeattacktimer = 50;