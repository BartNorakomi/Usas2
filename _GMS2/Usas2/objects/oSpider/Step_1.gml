/// @description Insert description here
// You can write your code in this editor
tilemap = layer_tilemap_get_id("ForegroundTiles"); //assign ForegroundTiles to our tilemap. we use this for collision detection

FaceEnemyLeftOrRight(); //  face enemy left or right by scaling x (horizontal mirroring)
MoveEnemyHorizontally();
TurnAtEndPlatform();
TurnWhenHitWall();
CheckCollisionPlayerEnemy(); // Check if player gets hit by enemy
CheckEnemyGetsHit(); // Check if enemy gets hit by player

	if (enemyHitCounter mod 8 > 3) sprite_index = sSpiderHit;
	else sprite_index = sSpider;