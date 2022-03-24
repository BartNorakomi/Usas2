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

if(pose = "standing") // standing
{
	sprite_index = sPlayerStand;
	if (hsp !=0) pose = "walking"; else HorizontalMovement(); // move sprite horizontally		
	CheckJump(); // check if up is pressed. If so -> Jump
	CheckStandPunch(); // check if trig A is pressed. If so -> standpunch
	CheckSit(); // check if down is pressed. If so -> Sit
	CheckStandingOnPlatform(); // check if player is standing on platform. If not -> fall
	CheckRoll(); // check if trig B is pressed. If so -> Roll
}

if(pose = "sitting") // sitting
{
	FacePlayerLeftOrRight(); //  face player left or right by scaling x (horizontal mirroring)
	hsp = 0;
//	HorizontalMovement(); // move sprite horizontally		
	movementTablePointer = movementTableMiddle;	
	sprite_index = sPlayerSit;
	pose = "standing"; // if not moving, go to standing pose
	CheckSit(); // check if down is pressed. If so -> Sit
	CheckSitPunch(); // check if trig A is pressed. If so -> sitpunch
	CheckStandingOnPlatform(); // check if player is standing on platform. If not -> fall
	CheckRoll(); // check if trig B is pressed. If so -> Roll
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
		image_index += 0; // animate sprite
	}
	if (horizontal_collision = true)
		pose = "standing"; // if colliding with wall, go to standing pose	
	CheckStandPunch(); // check if trig A is pressed. If so -> standpunch
	CheckSit(); // check if down is pressed. If so -> Sit
	CheckStandingOnPlatform(); // check if player is standing on platform. If not -> fall
	CheckJump(); // check if up is pressed. If so -> Jump
	CheckRoll(); // check if trig B is pressed. If so -> Roll
}

if(pose = "jumping") // jumping
{
	sprite_index = sPlayerJump;
	FacePlayerLeftOrRight(); //  face player left or right by scaling x (horizontal mirroring)
	HorizontalMovement(); // move player horizontally
	VerticalMovement(); // move player vertically
}

if(pose = "standpunch") // standpunch
{
	sprite_index = sPlayerStandPunch;
	image_index += 0; // animate sprite
	movementTablePointer = movementTableMiddle;	
}

if(pose = "sitpunch") // sitpunch
{
	sprite_index = sPlayerSitPunch;
	image_index += 0; // animate sprite
	movementTablePointer = movementTableMiddle;	
}

if(pose = "rolling") // rolling
{
	HorizontalMovement(); // move sprite horizontally
	FacePlayerLeftOrRight(); //  face player left or right by scaling x (horizontal mirroring)
	sprite_index = sPlayerRoll;
	image_index += 0; // animate sprite
	animationcounter += 1;
	if (animationcounter = 100) pose = "standing";
	CheckStandingOnPlatform(); // check if player is standing on platform. If not -> fall
	CheckJump(); // check if up is pressed. If so -> Jump
}