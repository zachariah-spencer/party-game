extends Node

class_name Minigame

const PLAY_AREA_WIDTH : int = 1536
const PLAY_AREA_HEIGHT : int = 896
var alive_players : Array
var is_game_won : bool = false
var game_active = false

func _run_minigame_loop():
	pass

func _insert_players():
	Manager._randomize_spawn_positions()
	Manager._randomize_spawn_positions()

	var spawn_points : Node = get_tree().get_nodes_in_group('spawnpoints')[0]
	var x : int = 0

	while x < Players.active_players.size():
		Players.spawn(Players.active_players[x], spawn_points.get_children()[Manager.player_spawns[x]].position)
		x += 1

func _check_alive_players(active_players):
	var players_to_add : Array = []
	var players_to_remove : Array = []
	for player in active_players:
		if !player.is_dead() && !alive_players.has(player):
			players_to_add.append(player)
		elif player.is_dead() && alive_players.has(player):
			players_to_remove.append(player)
	
	for player in players_to_add:
		alive_players.append(player)
	
	for player in players_to_remove:
		alive_players.remove(alive_players.find(player))
	
	return alive_players

func _check_game_win_conditions(alive_players):
	if alive_players.size() == 1:
		_game_won()
	elif alive_players.size() == 0:
		_game_won(true)

func _game_won(no_winner = false):
	pass

func _pregame_timer():
	pass