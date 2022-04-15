/// @description Insert description here
// You can write your code in this editor
tilemap = layer_tilemap_get_id("ForegroundTiles"); //assign ForegroundTiles to our tilemap. we use this for collision detection

FaceEnemyLeftOrRight(); //  face enemy left or right by scaling x (horizontal mirroring)
CheckCollisionPlayerEnemy(); // Check if player gets hit by enemy
CheckEnemyGetsHit(); // Check if enemy gets hit by player
//show_debug_message(y);


	
if (phase = 0) // (0=walking, 1=attacking)
{
	MoveEnemyHorizontallyIncludeSlowDownFactorWhenHit();
	TurnAtEndPlatform();
	TurnWhenHitWall();
	if (enemyHitCounter != 0) and (random(100) > 95) phase = 1;
	if (enemyHitCounter mod 8 > 3)sprite_index = sTreemanHit;
		else sprite_index = sTreeman;	
	animationcounter = 0;
}

if (phase = 1) // (0=walking, 1=attacking)
{
	animationcounter += 1;
	if (animationcounter < 60) image_index = 0; 
	else 
	{
		image_index = 1; 
		movementdirectionbackup = movementDirection;
		MoveEnemyHorizontally();
		MoveEnemyHorizontally();
		TurnAtEndPlatform();
		TurnWhenHitWall();
		if (movementdirectionbackup != movementDirection) phase = 0; // if movement direction changed, end phase 1 
	}
	if (animationcounter > 80) image_index = 2; 
	if (animationcounter = 90) phase = 0; 
	if (enemyHitCounter mod 8 > 3) sprite_index = sTreemanAttackHit;
	else sprite_index = sTreemanAttack;	
}