/// @description Insert description here
// You can write your code in this editor


	visible = false;

if (oPlayer.pose = "standpunch") // standpunch
{
	visible = true;	
	y = oPlayer.y + 6;
	if (oPlayer.image_xscale = 1) // check player facing player left (-1) or right (1)
		x = oPlayer.x + 12;
	else
		x = oPlayer.x - 12;
}

if (oPlayer.pose = "sitpunch") // standpunch
{
	visible = true;	
	y = oPlayer.y + 8;
	if (oPlayer.image_xscale = 1) // check player facing player left (-1) or right (1)
		x = oPlayer.x + 10;
	else
		x = oPlayer.x - 10;
}

if (oPlayer.sprite_index = sPlayerKickUp)
{
	visible = true;	
	y = oPlayer.y + 2;
	if (oPlayer.image_xscale = 1) // check player facing player left (-1) or right (1)
		x = oPlayer.x + 12;
	else
		x = oPlayer.x - 12;
}

if (oPlayer.sprite_index = sPlayerKickDown)
{
	visible = true;	
	y = oPlayer.y + 8;
	if (oPlayer.image_xscale = 1) // check player facing player left (-1) or right (1)
		x = oPlayer.x + 12;
	else
		x = oPlayer.x - 12;
}
