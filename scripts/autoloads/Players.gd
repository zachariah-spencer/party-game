extends Node

onready var player_scene : PackedScene = preload('res://scenes/player/Player.tscn')
var active_players : Array

func _ready():
	active_players = get_tree().get_nodes_in_group('players')


func spawn(player : Node, spawn_position : Vector2 = select_spawn_point()):
	var player_ref : Node = player.get_node('Player') 
	remove_child(player_ref)
	
	player.position = Vector2.ZERO
	player_ref.position = spawn_position
	
	add_child(player_ref)


func select_spawn_point():
	var spawn_points = get_tree().get_nodes_in_group('spawnpoints')[0]
	Manager._randomize_spawn_positions()
	Manager._randomize_spawn_positions()
	return spawn_points.get_children()[Manager.player_spawns[0]].position