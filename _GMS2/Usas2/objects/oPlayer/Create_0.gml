pose = "standing";

//tilemap = layer_tilemap_get_id("ForegroundTiles");

//layerID = layer_get_id("ForegroundTiles");
//tilemap = layer_tilemap_get_id(layerID);

RoomX = 0;
RoomY = 2;
global.map_array[0,0] = Room1A; global.map_array[0,1] = Room1B;
global.map_array[1,0] = Room2A; global.map_array[1,1] = Room2B;
global.map_array[2,0] = Room3A
global.map_array[3,0] = Room4A


movement_table = [-1.6, -1.4, -1.2, -1.0, -0.8, -0.6, -0.4, -0.2, +0.0, +0.2, +0.4, +0.6, +0.8, +1.0, +1.2, +1.4, +1.6];
movementTableMiddle = 8;
movementTablePointer = movementTableMiddle;
movementTableLenght = 17;

audio_play_sound(sndWolftune1, 10, true);
audio_play_sound(sndWolftune1, 10, true);
audio_play_sound(sndWolftune1, 10, true);
audio_play_sound(sndWolftune1, 10, true);