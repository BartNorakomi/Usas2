/// @description Insert description here
// You can write your code in this editor
enemyHitCounter = 0;
life = 1;
nx = 16; // width
ny = 10; // height
movementDirection = "right";
movementSpeed = 0.3;
explosionsprite = sExplosionSmall;
phase = 0; // (0=moving, 1=waiting, 2=duck, 3=unduck)
waittimer = 0;
SnapPlayer = false;