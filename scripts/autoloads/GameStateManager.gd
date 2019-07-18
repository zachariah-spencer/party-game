extends Node

#a list of all the minigames that can be played
onready var GAMES = [
	preload('res://scenes/minigames/mg_sumo/MG_Sumo.tscn'),
	preload('res://scenes/minigames/mg_goafk/MG_GoAFK.tscn'),
	preload('res://scenes/minigames/mg_race_tower/MG_RaceTower.tscn'),
	preload('res://scenes/minigames/mg_punchball/MG_Punchball.tscn'),
	preload('res://scenes/minigames/mg_territories/MG_Territories.tscn'),
	preload('res://scenes/minigames/mg_horseshoes/MG_Horseshoes.tscn'),
	preload('res://scenes/minigames/mg_raining_explosives/MG_RainingExplosives.tscn'),
]

onready var rotation := []
#the world node under the root
var world_node : Node
#the canvaslayer instance that will move in front of the playarea while the minigames switch
var transition_scene : PackedScene = preload('res://scenes/Transition.tscn')

#a quick and dirty reference to the name of a minigame
#this differs from the node name
var minigame_name : String

#rotation will loop if set to true
var repeats := false

var shuffle := true

onready var lobby := preload('res://scenes/minigames/mg_lobby/MG_Lobby.tscn')
onready var winning_cutscene := preload('res://scenes/minigames/mg_winning_cutscene/MG_WinningCutscene.tscn')

#manages how many minigames will be rotated before declaring a winner and going back to lobby
var rounds_to_play := 10

var rounds_played := 0

#the current minigame at any given playtime
var current_minigame : Minigame

signal minigame_change

var player_spawns : Array = [0,1,2,3]

func _ready():
	set_rotation()
	world_node = get_parent().get_node('World')
	randomize()
	_start_new_minigame(lobby)

func set_rotation(exclude := []) :
	for game in GAMES:
		if not exclude.has(game) :
			rotation.append(game)


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
	rounds_played += 1

	if repeats:
		var next_minigame
		next_minigame = _select_random_minigame()
		_start_new_minigame(next_minigame)
	else:
		if rounds_played <= rounds_to_play:
			var next_minigame
			next_minigame = _select_random_minigame()
			_start_new_minigame(next_minigame)
		else:
			_start_new_minigame(winning_cutscene)


func _select_random_minigame():
	if rotation.empty():
		if rounds_played <= rounds_to_play:
			set_rotation()
	#mixes up the order, this means a possiblity of the same game back to back with repeats
	if shuffle : rotation.shuffle()

	#cycles through for if not shuffling
	rotation.push_back(rotation.pop_front())
	return rotation.front()