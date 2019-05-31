extends Node

const GAMES = {
	
	'lobby' : preload('res://scenes/Minigames/MG_Lobby.tscn'),
	'fighter' : preload('res://scenes/Minigames/MG_Fighter.tscn'),
	
}

var current_game_name
var current_game_time
var current_game_reference

var player_spawns = [0,1,2,3]

func _ready():
	randomize()
	var game_to_play_next = _select_random_minigame()
	game_to_play_next.instance()

func _instance_minigame(new_minigame):
	#check if a minigame is loaded
	#remove old minigame
	#instance new minigame
	pass

func _select_random_minigame():
	var selected_num = int(rand_range(0, GAMES.size()))
	var selected_game = GAMES.values()[selected_num]
	return selected_game

func _randomize_spawn_positions():
	player_spawns.shuffle()