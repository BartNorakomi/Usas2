/// @description Insert description here
// You can write your code in this editor
tilemap = layer_tilemap_get_id("ForegroundTiles"); //assign ForegroundTiles to our tilemap. we use this for collision detection

if (phase = 0) //(0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)
{
	CheckEnemyGetsHit(); // Check if enemy gets hit by player
}

if (phase = 1) // (0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)
{
	sprite_index = sZombieWalking;
	FaceEnemyLeftOrRight(); //  face enemy left or right by scaling x (horizontal mirroring)
	CheckEnemyGetsHit(); // Check if enemy gets hit by player
	CheckCollisionPlayerEnemy(); // Check if player gets hit by enemy
	MoveEnemyHorizontally();
	TurnWhenHitWall();
	CheckZombieStandingOnPlatform();
//	CheckEnemyOutOfScreen(); // Check if enemy is out of screen, if so -> destroy
}

if (phase = 2) // (0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)
{
	sprite_index = sZombieFalling;
	FaceEnemyLeftOrRight(); //  face enemy left or right by scaling x (horizontal mirroring)
	CheckEnemyGetsHit(); // Check if enemy gets hit by player
	CheckCollisionPlayerEnemy(); // Check if player gets hit by enemy
	EnemyFallingVertically(); // fall and accelerate fall speed
	CheckZombieFallingOnPlatform();
	CheckEnemyOutOfScreen(); // Check if enemy is out of screen, if so -> destroy
}

if (phase = 4) // (0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)
{
	sprite_index = sZombieSitting;
	FaceEnemyLeftOrRight(); //  face enemy left or right by scaling x (horizontal mirroring)
	CheckEnemyGetsHit(); // Check if enemy gets hit by player
	CheckCollisionPlayerEnemy(); // Check if player gets hit by enemy
}