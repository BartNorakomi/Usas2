/// @description Insert description here
// You can write your code in this editor
tilemap = layer_tilemap_get_id("ForegroundTiles"); //assign ForegroundTiles to our tilemap. we use this for collision detection

FaceEnemyLeftOrRight(); //  face enemy left or right by scaling x (horizontal mirroring)
CheckCollisionPlayerEnemy(); // Check if player gets hit by enemy
CheckEnemyGetsHit(); // Check if enemy gets hit by player
if (enemyHitCounter mod 8 > 3) sprite_index = sFireEyeHit;
	else sprite_index = sFireEye;	
if (random(100) > 97)
{
	var inst = instance_create_layer(x, y-7, "Instances", oFireEyeBullet);
//	with (inst)
//	{
//		movementDirection = other.movementDirection;
//	}
}	
