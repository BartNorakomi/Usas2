/// @description Insert description here
// You can write your code in this editor
enemyHitCounter = 0;
life = 1;
nx = 16; // width
ny = 16; // height
//movementDirection = "right";
movementSpeed = 0.0;
explosionsprite = sExplosionSmall;
phase = 0; // (0=hanging, 1=attacking)
waittimer = 0;
SnapPlayer = false;

if (x <(304/2)) movementDirection = "right";
else movementDirection = "left";
