/// @description Insert description here
// You can write your code in this editor


	visible = false;

if (oPlayer.pose = "standpunch") // standpunch
{
	visible = true;	
	y = oPlayer.y + 6;
	x = oPlayer.image_xscale * 12 + oPlayer.x;
}

if (oPlayer.pose = "sitpunch") // standpunch
{
	visible = true;	
	y = oPlayer.y + 8;
	x = oPlayer.image_xscale * 10 + oPlayer.x;
}

if (oPlayer.pose = "rolling") // rolling
{
	visible = true;	
	y = oPlayer.y + 6;
	x = oPlayer.image_xscale * 6 + oPlayer.x;
}

if (oPlayer.sprite_index = sPlayerKickUp)
{
	visible = true;	
	y = oPlayer.y + 2;
	x = oPlayer.image_xscale * 12 + oPlayer.x;
}

if (oPlayer.sprite_index = sPlayerKickDown)
{
	visible = true;	
	y = oPlayer.y + 8;
	x = oPlayer.image_xscale * 12 + oPlayer.x;
}
