extends Node

const GAMES : Dictionary = {
	
	'lobby' : preload('res://scenes/minigames/MG_Lobby.tscn'),
	'fighter' : preload('res://scenes/minigames/MG_Fighter.tscn'),
	
}
var world_node

var transition_scene : PackedScene = preload('res://scenes/Transition.tscn')
var finish_transition_instance

#warning-ignore:unused_class_variable
var current_game_name : String
#warning-ignore:unused_class_variable
var current_game_time : int
#warning-ignore:unused_class_variable
var current_game_reference : Node

var player_spawns : Array = [0,1,2,3]

func _ready():
	world_node = get_parent().get_node('World')
	
	randomize()
	_start_new_minigame(GAMES['lobby'])

#warning-ignore:unused_argument
func _start_new_minigame(new_minigame : PackedScene):
	#check if a minigame is loaded
	if !get_tree().get_nodes_in_group('minigames').empty():
		#remove old minigame
		print('game currently active')
		var instance_of_transition = transition_scene.instance()
		add_child_below_node(world_node, instance_of_transition)
		finish_transition_instance = new_minigame.instance()
	else:
		var instance_of_new_minigame = new_minigame.instance()
		add_child(instance_of_new_minigame)

func _on_game_times_up():
	_start_new_minigame(GAMES['fighter'])

func _select_random_minigame():
	var selected_num : int = int(rand_range(0, GAMES.size()))
	var selected_game : PackedScene = GAMES.values()[selected_num]
	return selected_game

func _randomize_spawn_positions():
	player_spawns.shuffle()