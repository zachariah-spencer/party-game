extends Node

class_name Minigame

const PLAY_AREA_WIDTH : int = 1536
const PLAY_AREA_HEIGHT : int = 896

func _insert_players():
	Manager._randomize_spawn_positions()
	Manager._randomize_spawn_positions()
	var spawn_points = get_tree().get_nodes_in_group('spawnpoints')[0]
	print('spawn players')
	
	var active_players : Array = get_tree().get_nodes_in_group('players')
	var x : int = 0
	while x < active_players.size():
			active_players[x].position = spawn_points.get_children()[Manager.player_spawns[x]].position
			x += 1