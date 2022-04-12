/// @description Insert description here
// You can write your code in this editor
tilemap = layer_tilemap_get_id("ForegroundTiles"); //assign ForegroundTiles to our tilemap. we use this for collision detection

FaceEnemyLeftOrRight(); //  face enemy left or right by scaling x (horizontal mirroring)
TurnAtEndPlatform();
TurnWhenHitWall();
CheckCollisionPlayerEnemy(); // Check if player gets hit by enemy
CheckEnemyGetsHit(); // Check if enemy gets hit by player

if (phase = 0) // (0=walking, 1=attacking)
{
	MoveEnemyHorizontally();
	sprite_index = sKnifethrower;
	if (random(100) > 99)
	{
		phase = 1;
		image_index = 0;
	}
}

if (phase = 1) // (0=walking, 1=attacking)
{
	sprite_index = sKnifethrowerAttack;
	//This code creates a new instance of the object "KnifethrowerKnife" and stores the instance id in a variable. This variable is then used to assign direction to the new instance.
	if (image_index = 3)
	{
		var inst = instance_create_layer(x, y+3, "Instances", oKnifethrowerKnife);
		with (inst)
		{
			movementDirection = other.movementDirection;
		}
	}
	if (image_index = 6)
	{
		var inst = instance_create_layer(x, y+7, "Instances", oKnifethrowerKnife);
		with (inst)
		{
			movementDirection = other.movementDirection;
		}
	}

}



//show_debug_message(y);