extends Node

const GAMES : Dictionary = {
	
	'lobby' : preload('res://scenes/minigames/MG_Lobby.tscn'),
	'fighter' : preload('res://scenes/minigames/MG_Fighter.tscn'),
	'goafk' : preload('res://scenes/minigames/MG_GoAFK.tscn')
	
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
#warning-ignore:unused_class_variable
var current_game_attack_mode : String
#warning-ignore:unused_class_variable
var current_game_allow_respawns : bool
#warning-ignore:unused_class_variable
var current_game_spawns : Node

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
		var instance_of_transition = transition_scene.instance()
		add_child_below_node(world_node, instance_of_transition)
		finish_transition_instance = new_minigame.instance()
	else:
		var instance_of_new_minigame = new_minigame.instance()
		add_child(instance_of_new_minigame)

func _on_game_times_up():
	var next_minigame
	next_minigame = _select_random_minigame()
	_start_new_minigame(next_minigame)


func _select_random_minigame():
	#DO
	var selected_num : int = int(rand_range(0, GAMES.size()))
	#WHILE
	while GAMES.keys()[selected_num] == current_game_name || GAMES.keys()[selected_num] == 'lobby':
		selected_num = int(rand_range(0, GAMES.size()))

	var selected_game : PackedScene = GAMES.values()[selected_num]

	return selected_game

func _randomize_spawn_positions():
	player_spawns.shuffle()