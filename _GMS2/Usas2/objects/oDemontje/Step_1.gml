/// @description Insert description here
// You can write your code in this editor
tilemap = layer_tilemap_get_id("ForegroundTiles"); //assign ForegroundTiles to our tilemap. we use this for collision detection

if (phase = 0) // (0=hanging, 1=attacking)
{
	sprite_index = sDemontje;
	FaceEnemyLeftOrRight(); //  face enemy left or right by scaling x (horizontal mirroring)
	waittimer = 50;
	CheckCollisionPlayerEnemy(); // Check if player gets hit by enemy
	CheckEnemyGetsHit(); // Check if enemy gets hit by player
	if (random(100) > 99)
	{
		phase = 1;
		var inst = instance_create_layer(x, y+3, "Instances", oDemontjeBullet);
		with (inst)
		{
			movementDirection = other.movementDirection;
		}
	}	
}

if (phase = 1) // (0=hanging, 1=attacking)
{
	sprite_index = sDemontjeAttack;
	waittimer -= 1;
	if (waittimer = 0) phase = 0;
}