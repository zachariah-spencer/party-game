extends Node

class_name Minigame

const PLAY_AREA_WIDTH : int = 1536
const PLAY_AREA_HEIGHT : int = 896

func _insert_players():
	print('called _insert_players()')
	Manager._randomize_spawn_positions()
	Manager._randomize_spawn_positions()
	var spawn_points : Node = get_tree().get_nodes_in_group('spawnpoints')[0]
	
	for i in spawn_points.get_children():
		print(i.name)
	
	var active_players : Array = get_tree().get_nodes_in_group('players')
	var x : int = 0
	while x < active_players.size():
		active_players[x].get_node('Player').position = Vector2(0,0)
		active_players[x].position = spawn_points.get_children()[Manager.player_spawns[x]].position
		print (active_players[x].name + String(active_players[x].position))
		x += 1
	print('players spawned')