/// @description
// You can write your code in this editor


CheckChangeRoom(); // Check if Player is at the edge of the room. If so -> Change room
	
if (PlayerInvulnerable != 0) PlayerInvulnerable -= 1; 

if (PlayerInvulnerable mod 4 = 1) visible = false;
else visible = true;

framecounter = (framecounter + 1) mod 256;

//	show_debug_message(framecounter);
