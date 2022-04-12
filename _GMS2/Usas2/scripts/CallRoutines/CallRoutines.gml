// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

//Windows Key Binding	macOS Key Binding	Scope	Description
//CTRL + M	CMD + M	General	Fold all open regions
//CTRL + U	CMD + U	General	Unfold all regions

//player
#region // HorizontalMovement
function HorizontalMovement() 
{
	horizontal_collision = false; // reset horizontal collision
	if (hsp = -1) movementTablePointer -= 1;		
	if (movementTablePointer = -1) movementTablePointer = 0;
	if (hsp = +1) movementTablePointer += 1;		
	if (movementTablePointer = movementTableLenght) movementTablePointer = movementTableLenght-1;
	if (hsp = 0)
	{	
		if (movementTablePointer < movementTableMiddle) movementTablePointer += 1;		
		if (movementTablePointer > movementTableMiddle) movementTablePointer -= 1;	
	}
	x += movement_table[movementTablePointer];
	//moving right
	if (movement_table[movementTablePointer]) > 0
	{	
		if (tilemap_get_at_pixel(tilemap,bbox_right,bbox_top) < 256) and (tilemap_get_at_pixel(tilemap,bbox_right,bbox_top) > 51)
		or (tilemap_get_at_pixel(tilemap,bbox_right,bbox_top+16) < 256) and (tilemap_get_at_pixel(tilemap,bbox_right,bbox_top+16) > 51)
		or (tilemap_get_at_pixel(tilemap,bbox_right,bbox_bottom-1) < 256) and (tilemap_get_at_pixel(tilemap,bbox_right,bbox_bottom-1) > 51)
		{	
			x = x - (x mod 8); // Snap x Position
			movementTablePointer = movementTableMiddle;
			horizontal_collision = true;
		}
	}
	//moving left
	if (movement_table[movementTablePointer]) < 0
	{	
		if (tilemap_get_at_pixel(tilemap,bbox_left,bbox_top) < 256) and (tilemap_get_at_pixel(tilemap,bbox_left,bbox_top) > 51)
		or (tilemap_get_at_pixel(tilemap,bbox_left,bbox_top+16) < 256) and (tilemap_get_at_pixel(tilemap,bbox_left,bbox_top+16) > 51)
		or (tilemap_get_at_pixel(tilemap,bbox_left,bbox_bottom-1) < 256) and (tilemap_get_at_pixel(tilemap,bbox_left,bbox_bottom-1) > 51)
		{	
			x = x - (x mod 8) + 8; // Snap x Position
			movementTablePointer = movementTableMiddle;
			horizontal_collision = true;
		}
	}
}
#endregion

#region // VerticalMovement
function VerticalMovement() 
{
	jump_speed +=0.25;
	if (vsp != -1) and (jump_speed < 0) jump_speed +=0.25;
	if (jump_speed > 7) jump_speed = 7;
	y += jump_speed;

// check collision when jumping up
	if (jump_speed < 0)
	{
		if (tilemap_get_at_pixel(tilemap,bbox_left+1,bbox_top) < 256) and (tilemap_get_at_pixel(tilemap,bbox_left+1,bbox_top) > 51)		
		or (tilemap_get_at_pixel(tilemap,bbox_right-1,bbox_top) < 256) and (tilemap_get_at_pixel(tilemap,bbox_right-1,bbox_top) > 51)			
			y = y - (y mod 8) + 8; // Snap y Position
	}
	if (jump_speed > 0)
	{
		// check collision foreground when falling
		if (tilemap_get_at_pixel(tilemap,bbox_left+1,bbox_bottom) < 256) and (tilemap_get_at_pixel(tilemap,bbox_left+1,bbox_bottom) > 51)		
		or (tilemap_get_at_pixel(tilemap,bbox_right-1,bbox_bottom) < 256) and (tilemap_get_at_pixel(tilemap,bbox_right-1,bbox_bottom) > 51)			
		{
			pose = "standing"; // foreground tile found when jumping down. change to standing pose
			audio_play_sound(sndLand2, 2, false);
			y = y - (y mod 8); // Snap y Position
		}
		// check collision ladder when falling
		else
		if (tilemap_get_at_pixel(tilemap,bbox_left+1,bbox_bottom) < 32)		
		or (tilemap_get_at_pixel(tilemap,bbox_right-1,bbox_bottom) < 32)		
		{
			// while falling a ladder tile is found at player's feet. 
			// check 16 pixels left of this ladder tile for a foreground tile. If yes then check the tile above that for a background tile. If yes SnapToPlatformBelow  
			if (tilemap_get_at_pixel(tilemap,bbox_left+1-16,bbox_bottom) < 256) and (tilemap_get_at_pixel(tilemap,bbox_left+1-16,bbox_bottom) > 51)
			and (tilemap_get_at_pixel(tilemap,bbox_left+1-16,bbox_bottom-8) > 255)
			// check 16 pixels right of this ladder tile for a foreground tile. If yes then check the tile above that for a background tile. If yes SnapToPlatformBelow  
			or (tilemap_get_at_pixel(tilemap,bbox_right-1+16,bbox_bottom) < 256) and (tilemap_get_at_pixel(tilemap,bbox_right-1+16,bbox_bottom) > 51)
			and (tilemap_get_at_pixel(tilemap,bbox_right-1+16,bbox_bottom-8) > 255)
			{
				pose = "standing"; // foreground tile found when jumping down. change to standing pose
				audio_play_sound(sndLand2, 2, false);
				y = y - (y mod 8); // Snap y Position
			}
		}			
	}
}
#endregion

#region // CheckJump
function CheckJump()
{	
	if keyboard_check_pressed(vk_up)
	{
		pose = "jumping";
		jump_speed = -6.25;
//		audio_play_sound(sndJump, 1, false);
		audio_play_sound(sndLand1, 3, false);
		doublejumpavailable = true; // player can only double jump once when jumping
	}
}	
#endregion

#region // CheckCharge
function CheckCharge()
{	
	if keyboard_check_pressed(ord("N")) 
	{
		pose = "charging";
		image_index = 0; // first frame of charging
		audio_play_sound(sndWhoosh, 10, false);
	}
}	
#endregion

#region // CheckDoubleJump
function CheckDoubleJump() // check if up is pressed while jumping and if double jump is available, if so, double jump
{	
	if keyboard_check_pressed(vk_up) and (doublejumpobtained = true) and (doublejumpavailable = true)
	{
		jump_speed = -6.25;
		audio_play_sound(sndLand1, 3, false);
		doublejumpavailable = false; // player can only double jump once when jumping
	}
}	
#endregion

#region // CheckKickWhileJump
function CheckKickWhileJump()
{	
	if keyboard_check_pressed(vk_space)
	{
		kickwhilejump = kickwhilejumpduration;
	}
}	
#endregion

#region // CheckSit
function CheckSit()  // check if down is pressed. if so -> sit
{	
	if keyboard_check(vk_down)
		pose = "sitting";
}	
#endregion

#region // FacePlayerLeftOrRight
function FacePlayerLeftOrRight() // face player left or right by scaling x (horizontal mirroring)
{	
	if (hsp != 0)
		image_xscale = hsp;	// face player left or right by scaling x (horizontal mirroring)
}	
#endregion

#region // CheckStandingOnPlatform
function CheckStandingOnPlatform() // check if player is standing on platform. if not -> fall
{	
		if (PlayerSnapToPlatform = false)
		{
			if (tilemap_get_at_pixel(tilemap,bbox_left+1,bbox_bottom) < 256)
			or (tilemap_get_at_pixel(tilemap,bbox_right-1,bbox_bottom) < 256)
			{}else
			{	
				pose = "jumping";
				jump_speed = +0.25;
			}
		}
}	
#endregion

#region // CheckStandPunch
function CheckStandPunch() // check if trig A is pressed. if so -> standpunch
{
	if keyboard_check_pressed(vk_space)
	{
		pose = "standpunch";
		image_index = 0;
	}
}
#endregion

#region // CheckSitPunch
function CheckSitPunch() // check if trig A is pressed. if so -> sitpunch
{
	if keyboard_check_pressed(vk_space)
	{
		pose = "sitpunch";
		image_index = 0;
	}
}
#endregion

#region // CheckRoll
function CheckRoll() // check if trig B is pressed. if so -> Roll
{
	//	show_debug_message(keyboard_string);
	if keyboard_check_pressed(vk_lcontrol) or  keyboard_check_pressed(vk_alt) or keyboard_check_pressed(ord("M"))
	{
		pose = "rolling";
		animationcounter = 0;
		image_index = 0;
		audio_play_sound(sndRolling, 10, false);
	}
}
#endregion

#region // CheckLadderBelow
function CheckLadderBelow() // check if down is pressed and if there is a ladder below player. if so -> climb down 
{
	if keyboard_check(vk_down)
	{
		//check if there is a ladder tile below left foot AND right foot
		if (tilemap_get_at_pixel(tilemap,bbox_left+6,bbox_bottom) < 32)
		and (tilemap_get_at_pixel(tilemap,bbox_right-7,bbox_bottom) < 32)
			{
				x = x - (x mod 8); // Snap x Position
				pose = "climbdown";
				animationcounter = 0;
				//after snapping player could be 1 tile too much to the left. check again for ladder under left foot. If not, then move 1 tile to the right
				if (tilemap_get_at_pixel(tilemap,bbox_left,bbox_bottom) > 31) x += 8;
			}
	}
}
#endregion

#region // CheckLadderBelowMidAir
function CheckLadderBelowMidAir() // check if down is pressed and if there is a ladder below player. if so -> climb down 
{
	if keyboard_check_pressed(vk_down)
	{
		//check if there is a ladder tile below left foot AND right foot
		if (tilemap_get_at_pixel(tilemap,bbox_left+6,bbox_bottom) < 32)
		and (tilemap_get_at_pixel(tilemap,bbox_right-7,bbox_bottom) < 32)
			{
				x = x - (x mod 8); // Snap x Position
				pose = "climb";
				//after snapping player could be 1 tile too much to the left. check again for ladder under left foot. If not, then move 1 tile to the right
				if (tilemap_get_at_pixel(tilemap,bbox_left,bbox_bottom) > 31) x += 8;
			}
	}
}
#endregion

#region // CheckLadderAbove
function CheckLadderAbove() // check if up is pressed and if there is a ladder above player. if so -> climb up
{
	if keyboard_check_pressed(vk_up)
	{
		//check if there is a ladder tile below left foot AND right foot
		show_debug_message(x);

		if (tilemap_get_at_pixel(tilemap,bbox_left+6,bbox_top) < 32)
		and (tilemap_get_at_pixel(tilemap,bbox_right-7,bbox_top) < 32)
			{
				x = x - (x mod 8); // Snap x Position
				//after snapping player could be 1 tile too much to the left. check again for ladder left side. If not found, then move 1 tile to the right
				if (tilemap_get_at_pixel(tilemap,bbox_left,bbox_top) > 32) x += 8;
				pose = "climb";
				animationcounter = 0;				
			}
	}
}
#endregion

//enemies
#region // FaceEnemyLeftOrRight
function FaceEnemyLeftOrRight() // face player left or right by scaling x (horizontal mirroring)
{	
	if (movementDirection = "right")
		image_xscale = 1;	// face player left or right by scaling x (horizontal mirroring)
	if (movementDirection = "left")
		image_xscale = -1;	// face player left or right by scaling x (horizontal mirroring)
}	
#endregion

#region // MoveEnemyHorizontallyIncludeSlowDownFactorWhenHit
function MoveEnemyHorizontallyIncludeSlowDownFactorWhenHit()
{
	if (movementDirection = "right")
	{	
		if (enemyHitCounter > 0) x += movementSpeed * slowdownfactorwhenhit; // move slow when hit
		else x += movementSpeed; // move normally when not hit
	}	
	if (movementDirection = "left")
	{	
		if (enemyHitCounter > 0) x -= movementSpeed * slowdownfactorwhenhit; // move slow when hit
		else x -= movementSpeed; // move normally when not hit
	}
}
#endregion

#region // MoveEnemyHorizontally
function MoveEnemyHorizontally()
{
	if (movementDirection = "right") 
	{
		x += movementSpeed; // move normally
		if (SnapPlayer = true)
			oPlayer.x += movementSpeed;
	}
	if (movementDirection = "left")
	{
		x -= movementSpeed; // move normally
		if (SnapPlayer = true)
			oPlayer.x -= movementSpeed;
}
	
}
#endregion

#region // EnemyFallingVertically
function EnemyFallingVertically()
{
	y += fallspeed; // fall normally
	fallspeed += 0.25;
	if (fallspeed > 7) fallspeed = 7;
}
#endregion

#region // CheckZombieStandingOnPlatform
function CheckZombieStandingOnPlatform() // check if enemy is standing on platform. if not -> fall
{	
		if (tilemap_get_at_pixel(tilemap,bbox_left+1,bbox_bottom) < 256)
		or (tilemap_get_at_pixel(tilemap,bbox_right-1,bbox_bottom) < 256)
		{}else
		{	
			phase = 2; // (0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)
		}
}	
#endregion

#region // CheckZombieFallingOnPlatform
function CheckZombieFallingOnPlatform() // check if enemy fell platform. if so -> next phase
{	
		if (tilemap_get_at_pixel(tilemap,bbox_left+1,bbox_bottom) < 256)
		or (tilemap_get_at_pixel(tilemap,bbox_right-1,bbox_bottom) < 256)
		{
			phase = 4; // (0=rising from grave, 1=walking, 2=falling, 3=turning, 4=sitting)
			y = y - (y mod 8); // Snap y Position
			fallspeed = 0.5;
		}
}	
#endregion

#region // TurnAtEndPlatform
function TurnAtEndPlatform()
{	
	if (movementDirection = "right")
	{
		if (tilemap_get_at_pixel(tilemap,bbox_right-1,bbox_bottom-0) > 255)
			movementDirection = "left";
	}
	else
	if (movementDirection = "left")
	{
		if (tilemap_get_at_pixel(tilemap,bbox_left+1,bbox_bottom-0) > 255)
			movementDirection = "right";
	}

}
#endregion

#region // TurnWhenHitWall
function TurnWhenHitWall()
{	
	if (movementDirection = "right")
	{
		if (tilemap_get_at_pixel(tilemap,bbox_right,bbox_bottom-1) < 256)
			movementDirection = "left";
	}
	else
	if (movementDirection = "left")
	{
		if (tilemap_get_at_pixel(tilemap,bbox_left,bbox_bottom-1) < 256)
			movementDirection = "right";
	}

}
#endregion

#region // CheckCollisionPlayerEnemy
function CheckCollisionPlayerEnemy()
{	
	if place_meeting(x, y, oPlayer)
	{
		if (oPlayer.PlayerInvulnerable = 0) and (oPlayer.pose != "dying")
		{
			oPlayer.pose = "beinghit";
			oPlayer.jump_speed = -4;
			oPlayer.animationcounter = 0;
			oPlayer.PlayerInvulnerable = 100; // invulnerable frames after being hit
			oPlayer.movementTablePointer_stored = oPlayer.movementTablePointer;
			audio_play_sound(sndPlayerhit, 1, false);
			audio_play_sound(sndPlayerhit, 1, false);
		}
	}	
}
#endregion

#region // CheckEnemyGetsHit
function CheckEnemyGetsHit()
{	
	if (enemyHitCounter > 0) enemyHitCounter -= 1;
	else
	if place_meeting(x, y, oPlayerPunchBox)
	{
		if (oPlayerPunchBox.visible = true)
		{
			audio_play_sound(sndPlayerhit, 1, false);
			audio_play_sound(sndPlayerhit, 1, false);
			life -= 1;
			enemyHitCounter = 31; // blink duration when hit
			if (life = 0)
			{
				instance_destroy();
				// x position of explosion is x - 16 + (nx/2)
				// y position of explosion is y + ny - 24 (is 16 in msx version)      
				var inst = instance_create_layer(x, y + (ny/2) - 16, "Instances", oExplosion);
				with (inst)
				{
					sprite_index = other.explosionsprite;
				}
			}
			else
			if(oPlayer.pose = "charging") 
			{
				oPlayer.pose = "bouncingback";
				oPlayer.jump_speed = -5;			
			}
		}
	}	
}
#endregion

#region // CheckEnemyOutOfScreen
function CheckEnemyOutOfScreen()
{	
	// show_debug_message(y);	
	if (x < 10) or (x > 300) or (y < 4) or (y > 198) instance_destroy();
}
#endregion

#region // CheckEnemyFacingPlayer
function CheckEnemyFacingPlayer()
{	
	enemyisfacingplayer = false
	if (x < oPlayer.x)	// enemy is left of player
	{
		if (movementDirection = "right") and (oPlayer.image_xscale = -1) enemyisfacingplayer = true;
	}
	else
		if (movementDirection = "left") and (oPlayer.image_xscale = +1) enemyisfacingplayer = true;
}
#endregion


//objects
#region // CheckChangeRoom
function CheckChangeRoom()
{	
//show_debug_message(x);
//show_debug_message(y);
//show_debug_message(RoomX);
	if (x=296)
	{
		RoomX += 1;
		x=10;
		room_goto(global.map_array[RoomY,RoomX]);
	}
	if (x=8)
	{
		RoomX -= 1;
		x=294;
		room_goto(global.map_array[RoomY,RoomX]);		
	}
	if (y>194)
	{
		RoomY += 1;
		y=18;
		room_goto(global.map_array[RoomY,RoomX]);		
	}
	if (y<18)
	{
		RoomY -= 1;
		y=194;
		room_goto(global.map_array[RoomY,RoomX]);		
	}


}
#endregion
