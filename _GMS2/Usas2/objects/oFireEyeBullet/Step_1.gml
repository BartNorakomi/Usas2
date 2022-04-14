/// @description Insert description here
// You can write your code in this editor
tilemap = layer_tilemap_get_id("ForegroundTiles"); //assign ForegroundTiles to our tilemap. we use this for collision detection



if (phase = 0) // (0=moving, 1=static on floor, 3=fading out)
{
	//FaceEnemyLeftOrRight(); //  face enemy left or right by scaling x (horizontal mirroring)
	CheckCollisionPlayerEnemy(); // check if player gets hit by enemy
	MoveEnemyHorizontally();
	EnemyFallingVerticallySlow(); // fall and accelerate fall speed
	movementDirectionOld = movementDirection;
	TurnWhenHitWall();
	if (movementDirection != movementDirectionOld)
	{
		phase = 1;
		y = y - (y mod 8); // Snap y Position
	}
}

if (phase = 1) // (0=moving, 1=static on floor, 3=fading out)
{
	waittimer += 1;
	if (waittimer < 41)	CheckCollisionPlayerEnemy(); // check if player gets hit by enemy
	if (waittimer > 40)
	{
		if (waittimer mod 8 > 3) visible = false;
		else visible = true;
	}
	if (waittimer = 80) instance_destroy();
}
		