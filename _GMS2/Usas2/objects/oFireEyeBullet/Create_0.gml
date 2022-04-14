/// @description Insert description here
// You can write your code in this editor
nx = 15; // width
ny = 4; // height
movementDirection = "right";
movementSpeed = random_range(-2, 2);
SnapPlayer = false;
fallspeed = -3;
phase = 0; // (0=moving, 1=static on floor, 3=fading out)
waittimer = 0;