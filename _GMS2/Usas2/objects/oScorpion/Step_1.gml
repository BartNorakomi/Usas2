/// @description Insert description here
// You can write your code in this editor
tilemap = layer_tilemap_get_id("ForegroundTiles"); //assign ForegroundTiles to our tilemap. we use this for collision detection

FaceEnemyLeftOrRight(); //  face enemy left or right by scaling x (horizontal mirroring)
CheckCollisionPlayerEnemy(); // Check if player gets hit by enemy
CheckEnemyGetsHit(); // Check if enemy gets hit by player
//show_debug_message(y);


	
if (phase = 0) // (0=walking, 1=rattling, 2=attacking)
{
	MoveEnemyHorizontallyIncludeSlowDownFactorWhenHit();
	TurnAtEndPlatform();
	TurnWhenHitWall();
	DistanceCheck(); // out: withindistanceplayer = true if within distance
	CheckEnemyFacingPlayer(); // out: enemyisfacingplayer = true if this is correct
	if (waitbeforeattacktimer != 0) waitbeforeattacktimer -= 1;
	if (withindistanceplayer = true) and (enemyisfacingplayer = true) and (waitbeforeattacktimer = 0) phase = 1;
	animationcounter = 0;
	sprite_index = sScorpion;
}

if (phase = 1) // (0=walking, 1=rattling, 2=attacking)
{
	sprite_index = sScorpionRattle;
	animationcounter += 1;
	if (animationcounter = 50) phase = 2; 
}

if (phase = 2) // (0=walking, 1=rattling, 2=attacking)
{ 
	waitbeforeattacktimer = 50;
	sprite_index = sScorpionAttack;
	animationcounter += 1;
	if (animationcounter < 91) image_index = 0;
	if (animationcounter < 80) image_index = 1;
	if (animationcounter < 60) image_index = 0;
	if (animationcounter = 90) phase = 0; 
}