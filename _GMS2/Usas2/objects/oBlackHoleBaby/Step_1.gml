/// @description Insert description here
// You can write your code in this editor
tilemap = layer_tilemap_get_id("ForegroundTiles"); //assign ForegroundTiles to our tilemap. we use this for collision detection

if (phase = 0) // (0=walking, 1=jumping)
{
	sprite_index = sBlackHoleBaby;
	FaceEnemyLeftOrRight(); //  face enemy left or right by scaling x (horizontal mirroring)
	CheckEnemyGetsHit(); // Check if enemy gets hit by player
	CheckCollisionPlayerEnemy(); // Check if player gets hit by enemy
	MoveEnemyHorizontally();
	TurnWhenHitWall();
	TurnAtEndPlatform();
	if (random(100) > 98)
	{
		phase = 1;
//		image_index = 0;
		fallspeed = -4;
}	
}

if (phase = 1) // (0=walking, 1=jumping)
{
	FaceEnemyLeftOrRight(); //  face enemy left or right by scaling x (horizontal mirroring)
	CheckEnemyGetsHit(); // Check if enemy gets hit by player
	CheckCollisionPlayerEnemy(); // Check if player gets hit by enemy
	MoveEnemyHorizontally();
	EnemyFallingVertically(); // fall and accelerate fall speed
//	CheckZombieFallingOnPlatform();
	CheckEnemyOutOfScreen(); // Check if enemy is out of screen, if so -> destroy


	if (tilemap_get_at_pixel(tilemap,bbox_left+1,bbox_bottom) < 256)
	or (tilemap_get_at_pixel(tilemap,bbox_right-1,bbox_bottom) < 256)
	{
		phase = 0; // (0=walking, 1=jumping)
		y = y - (y mod 8); // Snap y Position
	}
}	

