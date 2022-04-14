/// @description Insert description here
// You can write your code in this editor
tilemap = layer_tilemap_get_id("ForegroundTiles"); //assign ForegroundTiles to our tilemap. we use this for collision detection



//show_debug_message(y);
//	if (life !=255)
//	{
//		if (oPlayer.pose = "standpunch")
//			life =255;
//		else life = 1;
//	}
	


if (phase = 0) //(0=moving, 1=waiting, 2=duck, 3=unduck)
{
	sprite_index = sSlime;
	FaceEnemyLeftOrRight(); //  face enemy left or right by scaling x (horizontal mirroring)
	MoveEnemyHorizontally();
	// check if slime changed direction. If so change to Phase 1
	backupmovementdirection = movementDirection;
	TurnAtEndPlatform();
	TurnWhenHitWall();
	waittimer = 50;
	if (backupmovementdirection != movementDirection) phase = 1;
	CheckCollisionPlayerEnemy(); // Check if player gets hit by enemy

	if place_meeting(x, y, oPlayerPunchBox) and (oPlayerPunchBox.visible = true)	
	{
		if (oPlayer.pose = "standpunch")
		{
			phase = 2;
			image_index = 0;
		}
		else 
			CheckEnemyGetsHit(); // Check if enemy gets hit by player
	}
}

if (phase = 1) //(0=moving, 1=waiting, 2=duck, 3=unduck)
{
	waittimer -= 1;
	if (waittimer = 0) phase = 0;

}

if (phase = 2) //(0=moving, 1=waiting, 2=duck, 3=unduck)
{
	sprite_index = sSlimeDuck;
	if (oPlayer.pose = "standpunch") and (image_index = 3) image_index = 2;
	else
	if (image_index = 3) 
	{
		phase = 3;
		image_index = 0
	}
}

if (phase = 3) //(0=moving, 1=waiting, 2=duck, 3=unduck)
{
	sprite_index = sSlimeUnduck;
}