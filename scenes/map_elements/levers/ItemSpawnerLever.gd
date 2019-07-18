extends Lever

var spawners := []

func _ready():
	for child in get_children():
		if child is ItemSpawner :
			spawners.append(child)

func flip():
	.flip()
	for spawner in spawners :
		spawner._spawn_item()