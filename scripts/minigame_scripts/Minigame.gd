extends Node

class_name Minigame

const PLAY_AREA_WIDTH : int = 1536
const PLAY_AREA_HEIGHT : int = 896
var alive_players : Array
var is_game_won : bool = false

func _insert_players():
	Manager._randomize_spawn_positions()
	Manager._randomize_spawn_positions()

	var spawn_points : Node = get_tree().get_nodes_in_group('spawnpoints')[0]
	var x : int = 0

	while x < Players.active_players.size():
		if !Players.active_players[x].is_dead:

			Players.spawn(Players.active_players[x], spawn_points.get_children()[Manager.player_spawns[x]].position)
			x += 1

func _check_last_alive(active_players):
	for player in active_players:
		if !player.is_dead && !alive_players.has(player):
			alive_players.append(player)
		elif player.is_dead && alive_players.has(player):
			alive_players.remove(alive_players.find(player))

	if alive_players.size() == 1:
		is_game_won = true
		Manager.current_game_time = 3
		$HUD/Instructions.text = alive_players[0].display_name + ' Won!'

func _game_won():
	pass