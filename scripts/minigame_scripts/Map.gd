extends Node

class_name Map

# -1 means any # of players / don't calculate for that
# 2-4 will discriminate against said map based on # of active players
export var optimal_player_count := -1

# -1 means that this minigame won't need map indexing to run properly
# values 1-inf will represent which map this map is for this minigame
# this really is only necessary if a map instances parts inside of it
# ex. the race tower minigame instances different sets of chunks for each map
export var map_index := -1

onready var spawn_one : Position2D = $SpawnPoints/PlayerOneSpawn
onready var spawn_two : Position2D = $SpawnPoints/PlayerTwoSpawn
onready var spawn_three : Position2D = $SpawnPoints/PlayerThreeSpawn
onready var spawn_four : Position2D = $SpawnPoints/PlayerFourSpawn

func _ready():
	add_to_group('maps')
