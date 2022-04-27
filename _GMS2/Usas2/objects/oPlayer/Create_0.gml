pose = "standing";

//tilemap = layer_tilemap_get_id("ForegroundTiles");

//layerID = layer_get_id("ForegroundTiles");
//tilemap = layer_tilemap_get_id(layerID);

RoomX = 2;
RoomY = 5;
global.map_array[0,0] = A01; global.map_array[0,1] = B01; global.map_array[0,2] = C01; global.map_array[0,3] = D01; global.map_array[0,4] = E01; global.map_array[0,5] = F01; global.map_array[0,6] = G01;
global.map_array[1,0] = A02; global.map_array[1,1] = B02; global.map_array[1,2] = C02; global.map_array[1,3] = D02; global.map_array[1,4] = E02; global.map_array[1,5] = F02; global.map_array[1,6] = G02;
global.map_array[2,0] = A03; global.map_array[2,1] = B03; global.map_array[2,2] = C03; global.map_array[2,3] = D03; global.map_array[2,4] = E03; global.map_array[2,5] = F03; global.map_array[2,6] = G03;
global.map_array[3,0] = A04; global.map_array[3,1] = B04; global.map_array[3,2] = C04; global.map_array[3,3] = XXX; global.map_array[3,4] = XXX; global.map_array[3,5] = XXX; global.map_array[3,6] = XXX;
global.map_array[4,0] = A05; global.map_array[4,1] = B05; global.map_array[4,2] = C05; global.map_array[4,3] = XXX; global.map_array[4,4] = XXX; global.map_array[4,5] = XXX; global.map_array[4,6] = XXX;
global.map_array[5,0] = A06; global.map_array[5,1] = B06; global.map_array[5,2] = C06; global.map_array[5,3] = D06; global.map_array[5,4] = E06; global.map_array[5,5] = F06; global.map_array[5,6] = G06;
global.map_array[6,0] = A07; global.map_array[6,1] = B07; global.map_array[6,2] = C07; global.map_array[6,3] = D07; global.map_array[6,4] = E07; global.map_array[6,5] = F07; global.map_array[6,6] = G07;
global.map_array[7,0] = A08; global.map_array[7,1] = B08; global.map_array[7,2] = C08; global.map_array[7,3] = D08; global.map_array[7,4] = E08; global.map_array[7,5] = F08; global.map_array[7,6] = G08;
global.map_array[8,0] = A09; global.map_array[8,1] = B09; global.map_array[8,2] = C09; global.map_array[8,3] = D09; global.map_array[8,4] = E09; global.map_array[8,5] = F09; global.map_array[8,6] = G09;
global.map_array[9,0] = A10; global.map_array[9,1] = B10; global.map_array[9,2] = C10; global.map_array[9,3] = D10; global.map_array[9,4] = E10; global.map_array[9,5] = XXX; global.map_array[9,6] = XXX;
global.map_array[10,0] = A11; global.map_array[10,1] = B11; global.map_array[10,2] = C11; global.map_array[10,3] = D11; global.map_array[10,4] = E11; global.map_array[10,5] = XXX; global.map_array[10,6] = XXX;
global.map_array[11,0] = A12; global.map_array[11,1] = B12; global.map_array[11,2] = C12; global.map_array[11,3] = D12; global.map_array[11,4] = E12; global.map_array[11,5] = XXX; global.map_array[11,6] = XXX;
global.map_array[12,0] = XXX; global.map_array[12,1] = B13; global.map_array[12,2] = C13; global.map_array[12,3] = D13; global.map_array[12,4] = E13; global.map_array[12,5] = XXX; global.map_array[12,6] = XXX;

room_goto(global.map_array[RoomY,RoomX]);

doublejumpobtained = true; // has double jump ability been collected in game?
doublejumpavailable = true; // player can only double jump once when jumping
jump_speed = 0;
kickwhilejump = 0;
kickwhilejumpduration = 10;
framecounter = 0;
climbup_table = [-0,-0,-0,-1,-1,-1,-2,-2,-2,-3,-3,-3,-3,-2,-1,0,0,+1,+2,+2,+2,0,0,0,0,0,0,0];
movement_table = [-1.6, -1.4, -1.2, -1.0, -0.8, -0.6, -0.4, -0.2, +0.0, +0.2, +0.4, +0.6, +0.8, +1.0, +1.2, +1.4, +1.6];
movementTablePointer_stored = 0;
movementTableStart = 0;
movementTableMiddle = 8;
movementTableEnd = 16;
movementTablePointer = movementTableMiddle;
movementTableLenght = 17;
PlayerInvulnerable = 0;
PlayerSnapToPlatform = false;
stored_image_index = 0;

audio_play_sound(sndWolftune1, 10, true);
audio_play_sound(sndWolftune1, 10, true);
audio_play_sound(sndWolftune1, 10, true);
audio_play_sound(sndWolftune1, 10, true);

instance_create_layer(x, y, "Instances", oPlayerPunchBox);