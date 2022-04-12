/// @description Insert description here
// You can write your code in this editor
tilemap = layer_tilemap_get_id("ForegroundTiles"); //assign ForegroundTiles to our tilemap. we use this for collision detection

FaceEnemyLeftOrRight(); //  face enemy left or right by scaling x (horizontal mirroring)
MoveEnemyHorizontally();
TurnAtEndPlatform();
TurnWhenHitWall();
CheckCollisionPlayerEnemy(); // check if player gets hit by enemy
CheckEnemyGetsHit(); // check if enemy gets hit by player

CheckEnemyFacingPlayer(); // check if enemy is facing player, if so set enemyisfacingplayer = true;
if (life != 255)
{
	if (enemyisfacingplayer = true)
	// if lancelot is hit from the front he dies
	{
		instance_destroy();
		oLancelotSword.destroy = true;
		// x position of explosion is x - 16 + (nx/2)
		// y position of explosion is y + ny - 24 (is 16 in msx version)      
		instance_create_layer(x, y + (ny/2) - 16, "Instances", oExplosion);
		//instance_create_layer(x -16 + (nx / 2), y + ny -24, "Instances", oExplosion);
		oExplosion.sprite_index = explosionsprite;
	}
	// if lancelot is hit from behind he doesn't die and shield blinks
	if (enemyisfacingplayer = false)
	{
		life = 255;
		blinkshieldtimer = 50;
	}

}

sprite_index = sLancelot;
if (blinkshieldtimer != 0)
{
		blinkshieldtimer -= 1;
		if (blinkshieldtimer mod 8 > 3) sprite_index = sLancelotWhiteShield;	
}

oLancelotSword.movementDirection = movementDirection;
if (movementDirection = "right") oLancelotSword.x = x + 20;
else oLancelotSword.x = x - 20;

//show_debug_message(y);