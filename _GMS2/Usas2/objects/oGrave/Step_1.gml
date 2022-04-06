/// @description Insert description here
// You can write your code in this editor

ZombieSpawnTimer += 1;
if (ZombieSpawnTimer = 200) 
{
	instance_create_layer(x, y, "Instances", oZombie);
	ZombieSpawnTimer = 0;
}

