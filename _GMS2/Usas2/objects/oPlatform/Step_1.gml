/// @description Insert description here
// You can write your code in this editor
tilemap = layer_tilemap_get_id("ForegroundTiles"); //assign ForegroundTiles to our tilemap. we use this for collision detection
image_index = 0; // first sprite pose
SnapPlayer = false;

if place_meeting(x, y, oPlayer)
{
	if (oPlayer.pose != "dying")
	{
		// check collision top part of object		
		if (oPlayer.jump_speed > 0) and (bbox_top - oPlayer.bbox_bottom > -8) 
		{
			oPlayer.y = y - 24;
			SnapPlayer = true;
			oPlayer.PlayerSnapToPlatform = true;
			if (oPlayer.pose = "jumping") oPlayer.pose = "standing";
			image_index = 1; // first sprite pose
		}
		// check collision left side of object	
		else if (bbox_left - oPlayer.bbox_right > -8) oPlayer.x = x - 24;
		// check collision right side of object	
		else if (bbox_right - oPlayer.bbox_left < 8) oPlayer.x = x + nx - 8;
		// check collision bottom part of object
		else if (bbox_bottom - oPlayer.bbox_top < 8) oPlayer.y = y + ny + 8;	
		// if there is collision, but not at the edges of the object, player got smushed between 2 objects and dies
//		else oPlayer.pose = "dying";
	}
}	
MoveEnemyHorizontally();
TurnWhenHitWall();


