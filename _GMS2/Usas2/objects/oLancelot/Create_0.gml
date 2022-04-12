/// @description Insert description here
// You can write your code in this editor
enemyHitCounter = 0;
life = 255;
nx = 16; // width
ny = 32; // height
movementDirection = "right";
movementSpeed = 0.5;
explosionsprite = sExplosionSmall;
SnapPlayer = false;
enemyisfacingplayer = false;
blinkshieldtimer = 0;

instance_create_layer(x, y+9, "Instances", oLancelotSword);