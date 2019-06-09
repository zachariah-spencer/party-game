extends Node

#a list of all the minigames that can be played
const GAMES : Dictionary = {

	'lobby' : preload('res://scenes/minigames/MG_Lobby.tscn'),
	'sumo' : preload('res://scenes/minigames/MG_Sumo.tscn'),
	'goafk' : preload('res://scenes/minigames/MG_GoAFK.tscn'),
	'race_tower' : preload('res://scenes/minigames/MG_Race_Tower.tscn')

}
#the world node under the root
var world_node : Node
#the canvaslayer instance that will move in front of the playarea while the minigames switch
var transition_scene : PackedScene = preload('res://scenes/Transition.tscn')

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

#make this minigame
var current_minigame : Node

signal minigame_change

var player_spawns : Array = [0,1,2,3]

func _ready():
	
	world_node = get_parent().get_node('World')
	randomize()
	_start_new_minigame(GAMES['lobby'])

#warning-ignore:unused_argument
func _start_new_minigame(new_minigame : PackedScene):
	if is_instance_valid(current_minigame) :
		var transition = transition_scene.instance()
		world_node.add_child(transition)
		yield(transition, "covered")
		current_minigame.queue_free()
		yield(current_minigame, "tree_exited")
		current_minigame = new_minigame.instance()
		emit_signal("minigame_change")
		world_node.add_child(current_minigame)
		transition.fade_out()
	else :
		current_minigame = new_minigame.instance()
		world_node.add_child(current_minigame)

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

#func _process(delta):
#	if current_game_name != 'lobby':
##		if Input.is_action_just_pressed('player_one_start') && !Players.player_one.active:
##			Players._activate_player(Players.player_one, '1')
##		elif Input.is_action_just_pressed('player_one_b') && Players.player_one.active:
##			Players._deactivate_player(Players.player_one, '1')
##			_force_back_to_lobby()
#
#		if Input.is_action_just_pressed('player_two_start') && !Players.player_two.active:
#			Players._activate_player(Players.player_two, '2')
#		elif Input.is_action_just_pressed('player_two_b') && Players.player_two.active:
#			Players._deactivate_player(Players.player_two, '2')
#			_force_back_to_lobby()
#
#		if Input.is_action_just_pressed('player_three_start') && !Players.player_three.active:
#			Players._activate_player(Players.player_three, '3')
#		elif Input.is_action_just_pressed('player_three_b') && Players.player_three.active:
#			Players._deactivate_player(Players.player_three, '3')
#			_force_back_to_lobby()
#
#		if Input.is_action_just_pressed('player_four_start') && !Players.player_four.active:
#			Players._activate_player(Players.player_four, '4')
#		elif Input.is_action_just_pressed('player_four_b') && Players.player_four.active:
#			Players._deactivate_player(Players.player_four, '4')
#			_force_back_to_lobby()
		
		

func _force_back_to_lobby():
	Players._update_active_players()
	if Players.active_players.size() < 2:
		_start_new_minigame(GAMES['lobby'])

