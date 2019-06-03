extends Node
class_name PlayersManager

onready var child : Node = $Player
onready var respawn_timer : Node = $RespawnTimer
onready var player_scene : PackedScene = preload('res://scenes/player/Player.tscn')

func register_player_inputs():
	pass

func register_collisions():
	pass

func select_spawn_point():
	var spawn_points = get_tree().get_nodes_in_group('spawnpoints')[0]
	Manager._randomize_spawn_positions()
	Manager._randomize_spawn_positions()
	return spawn_points.get_children()[Manager.player_spawns[0]]