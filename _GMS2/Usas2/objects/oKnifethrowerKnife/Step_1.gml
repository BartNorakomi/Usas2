/// @description Insert description here
// You can write your code in this editor
tilemap = layer_tilemap_get_id("ForegroundTiles"); //assign ForegroundTiles to our tilemap. we use this for collision detection

FaceEnemyLeftOrRight(); //  face enemy left or right by scaling x (horizontal mirroring)
CheckCollisionPlayerEnemy(); // check if player gets hit by enemy
MoveEnemyHorizontally();

movementDirectionOld = movementDirection;
TurnWhenHitWall();
if (movementDirection != movementDirectionOld)
{
	instance_destroy();
	// x position of explosion is x - 16 + (nx/2)
	// y position of explosion is y + ny - 24 (is 16 in msx version)      
	//instance_create_layer(x -16 + (nx / 2), y + ny -24, "Instances", oExplosion);
	var inst = instance_create_layer(x, y + (ny/2) - 16 + 4, "Instances", oExplosion);
	with (inst)
	{
		sprite_index = sExplosionSmall2;
	}
}
		