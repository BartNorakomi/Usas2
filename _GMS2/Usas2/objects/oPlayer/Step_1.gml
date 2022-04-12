/// @description Movement
// You can write your code in this editor

key_up = keyboard_check(vk_up);
key_down = keyboard_check(vk_down);
key_left = keyboard_check(vk_left);
key_right = keyboard_check(vk_right);
key_space = keyboard_check(vk_space);
hsp = key_right - key_left;
vsp = key_down - key_up;
tilemap = layer_tilemap_get_id("ForegroundTiles"); //assign ForegroundTiles to our tilemap. we use this for collision detection

if(pose = "sitting") // sitting
{
	FacePlayerLeftOrRight(); //  face player left or right by scaling x (horizontal mirroring)
	hsp = 0;
//	HorizontalMovement(); // move sprite horizontally		
	movementTablePointer = movementTableMiddle;	
	sprite_index = sPlayerSit;
	pose = "standing"; // if not moving, go to standing pose
	CheckSit(); // check if down is pressed. if so -> sit
	CheckLadderBelow(); // check if down is pressed and if there is a ladder below player. if so -> climb down 
	CheckSitPunch(); // check if trig A is pressed. if so -> sitpunch
	CheckStandingOnPlatform(); // check if player is standing on platform. if not -> fall
	CheckRoll(); // check if trig B is pressed. if so -> Roll
	CheckCharge(); // check if trig C is pressed. if so -> charge
}

if(pose = "jumping") // jumping
{
	FacePlayerLeftOrRight(); //  face player left or right by scaling x (horizontal mirroring)
	HorizontalMovement(); // move player horizontally
	VerticalMovement(); // move player vertically
	CheckKickWhileJump(); // check if trig a is pressed. if so, kick while jump
	CheckLadderAbove(); // check if up is pressed and if there is a ladder above player. if so -> climb up
	CheckLadderBelowMidAir(); // check if down is pressed and if there is a ladder below player. if so -> climb down 
	CheckDoubleJump(); // check if up is pressed while jumping and if double jump is available, if so, double jump


	// set sprite kick if kicking
	if (kickwhilejump != 0) 
	{
		if (kickwhilejump = kickwhilejumpduration)
		{
			if (jump_speed < 0) sprite_index = sPlayerKickUp;
			else sprite_index = sPlayerKickDown;
		}
		kickwhilejump -= 1;
	}
	// else set sprite rolling if double jumping
	else 
	if (doublejumpobtained = true) and (doublejumpavailable = false) sprite_index = sPlayerRollWhileJump;
	// else set sprite jumping if double jumping
	else	
	{
		sprite_index = sPlayerJump;
		// animate sprite while jumping
		image_index = 1; // player in mid air
		if (jump_speed < -1) image_index = 0; //  player jumping up
		if (jump_speed > 1) image_index = 2; // player jumping down
	}
}

if(pose = "walking") // walking
{	
	HorizontalMovement(); // move sprite horizontally
	FacePlayerLeftOrRight(); //  face player left or right by scaling x (horizontal mirroring)
	if (hsp = 0)
		pose = "standing"; // if not moving, go to standing pose
	else
	if (horizontal_collision = false)
	{
		sprite_index = sPlayerRun; // set walking sprite
//		image_index += 0; // animate sprite
	}
	if (horizontal_collision = true)
		pose = "standing"; // if colliding with wall, go to standing pose	
	CheckStandPunch(); // check if trig A is pressed. If so -> standpunch
	CheckSit(); // check if down is pressed. If so -> Sit
	CheckStandingOnPlatform(); // check if player is standing on platform. If not -> fall
	CheckJump(); // check if up is pressed. If so -> Jump
	CheckRoll(); // check if trig B is pressed. If so -> Roll
	CheckCharge(); // check if trig C is pressed. if so -> charge
	CheckLadderAbove(); // check if up is pressed and if there is a ladder above player. if so -> climb up
}

if(pose = "standing") // standing
{
	doublejumpavailable = true; // player can only double jump once when jumping
	sprite_index = sPlayerStand;
	if (hsp !=0) pose = "walking"; else HorizontalMovement(); // move sprite horizontally		
	CheckJump(); // check if up is pressed. If so -> Jump
	CheckStandPunch(); // check if trig A is pressed. If so -> standpunch
	CheckSit(); // check if down is pressed. If so -> Sit
	CheckStandingOnPlatform(); // check if player is standing on platform. If not -> fall
	CheckRoll(); // check if trig B is pressed. if so -> roll
	CheckCharge(); // check if trig C is pressed. if so -> charge
	CheckLadderAbove(); // check if up is pressed and if there is a ladder above player. if so -> climb up
}

if(pose = "standpunch") // standpunch
{
	sprite_index = sPlayerStandPunch;
//	image_index += 0; // animate sprite
	movementTablePointer = movementTableMiddle;	
}

if(pose = "sitpunch") // sitpunch
{
	sprite_index = sPlayerSitPunch;
//	image_index += 0; // animate sprite
	movementTablePointer = movementTableMiddle;	
}

if(pose = "rolling") // rolling
{
	HorizontalMovement(); // move sprite horizontally
	FacePlayerLeftOrRight(); //  face player left or right by scaling x (horizontal mirroring)
	sprite_index = sPlayerRoll;
//	image_index += 0; // animate sprite
	animationcounter += 1;
	if (animationcounter = 100) pose = "standing";
	CheckStandingOnPlatform(); // check if player is standing on platform. If not -> fall
	CheckJump(); // check if up is pressed. If so -> Jump
}

if(pose = "climbdown") // from standing to climbing down the ladder
{
	y += 1;
	animationcounter += 1;
	if (animationcounter > 7) sprite_index = sPlayerClimb;
	if (animationcounter = 32) pose = "climb";
}

if(pose = "climb") // climbing
{
	doublejumpavailable = true; // player can only double jump once when jumping
//	show_debug_message(tilemap_get_at_pixel(tilemap,bbox_right+7,bbox_bottom));
	movementTablePointer = movementTableMiddle;	
	sprite_index = sPlayerClimb;
	image_speed = 1; // animate sprite when moving up/down
	if (vsp != 0) y += vsp;
	else image_speed = 0; // stop animate sprite when not moving up/down

	if (keyboard_check_pressed(vk_left) + keyboard_check_pressed(vk_right) != 0)
	{	
		pose = "jumping";
		jump_speed = +0.25;
		image_speed = 1; // animate sprite when moving up/down
	}

	// check collision platform when climbing down
	if (tilemap_get_at_pixel(tilemap,bbox_left+1,bbox_bottom) < 256) and (tilemap_get_at_pixel(tilemap,bbox_left+1,bbox_bottom) > 51)		
	or (tilemap_get_at_pixel(tilemap,bbox_right-1,bbox_bottom) < 256) and (tilemap_get_at_pixel(tilemap,bbox_right-1,bbox_bottom) > 51)			
	{
		pose = "standing"; // foreground tile found when climbing down. change to standing pose
		y = y - (y mod 8); // Snap y Position
	}

	//check for end ladder when climbing up. If no ladder is found, jump off the top of the ladder
	if (tilemap_get_at_pixel(tilemap,bbox_left+1,bbox_top+12) > 31)
	{	
		pose = "climbup"; // jump off the top of the ladder
		animationcounter = 0;
	}
}

if(pose = "climbup") // jump off the top of the ladder
{
	sprite_index = sPlayerClimbJumpUp;
	animationcounter += 1;
	y += climbup_table[animationcounter];
}

if(pose = "beinghit") // being hit
{
	vsp = -1;
	VerticalMovement(); // move player vertically

	movementTablePointer = (movementTablePointer_stored - 8) * -1 + 8;
	HorizontalMovement(); // move player vertically

	animationcounter += 1;
	if (animationcounter < 25) sprite_index = sPlayerBeingHit1;
	if (animationcounter < 16) sprite_index = sPlayerBeingHit2;
	if (animationcounter < 9) sprite_index = sPlayerBeingHit1;
	if (animationcounter = 24) 
	{
		pose = "jumping";
		jump_speed = 1;
		animationcounter = 0;
	}
}

if(pose = "dying") // player died
{
	sprite_index = sPlayerDead;
}

if(pose = "charging") // player charging
{
	sprite_index = sPlayerCharge;
	if (image_xscale = -1) movementTablePointer = movementTableStart; // face player left or right by scaling x (horizontal mirroring)
	if (image_xscale = 1) movementTablePointer = movementTableEnd; // face player left or right by scaling x (horizontal mirroring)
	
	if (image_index > 3)
	{
		HorizontalMovement(); // move player horizontally	
		if (horizontal_collision = true) pose = "standing"; // if colliding with wall, go to standing pose		
		HorizontalMovement(); // move player horizontally	
		if (horizontal_collision = true) pose = "standing"; // if colliding with wall, go to standing pose		
		HorizontalMovement(); // move player horizontally	
		if (horizontal_collision = true) pose = "standing"; // if colliding with wall, go to standing pose		
	}
}

if(pose = "bouncingback") // player bouncing back after charging into a enemy which didn't die
{
	sprite_index = sPlayerRoll;
	vsp = -1; // force up being pressed
	VerticalMovement(); // move player vertically	
	if (image_xscale = 1) movementTablePointer = movementTableStart; // face player left or right by scaling x (horizontal mirroring)
	if (image_xscale = -1) movementTablePointer = movementTableEnd; // face player left or right by scaling x (horizontal mirroring)
	HorizontalMovement(); // move player horizontally	
	
}

PlayerSnapToPlatform = false;
