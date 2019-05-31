extends Node

const GAMES = {
	
	'lobby' : preload('res://scenes/Minigames/MG_Lobby.tscn'),
	'fighter' : preload('res://scenes/Minigames/MG_Fighter.tscn')
	
}

var current_game = 'lobby'

func _instance_minigame(new_minigame):
	#check if a minigame is loaded
	#remove old minigame
	#instance new minigame
	pass

#func _select_random_minigame():
#	var selected = rand_range(0, GAMES.size())
#	var games_array = GAMES.values()
#	return games_array[selected]