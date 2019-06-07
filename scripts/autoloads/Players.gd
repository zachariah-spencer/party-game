extends Node

onready var player_scene : PackedScene = preload('res://scenes/player/Player.tscn')

var player_one : PlayersManager
var player_two : PlayersManager
var player_three : PlayersManager
var player_four : PlayersManager
var _players = []
var active_players : Array

func _ready():
	pass

func spawn(player : PlayersManager, spawn_position : Vector2 = select_spawn_point()):
#	if there is a player, ensures it's freed before a new instance is created
	if is_instance_valid(player.child) :
		player.child.queue_free()
		yield(player.child, "tree_exited")
	if is_instance_valid(player.ragdoll) :
		player.ragdoll.queue_free()
	if !player.active :
		return

#	instances the player at a spawn point
	var add = player_scene.instance()
	add.position = Vector2.ZERO
	player.position = spawn_position
	add.hit_points = 100
	player.child = add
	player.add_child(add)
	player.dead = false

	player.register_player_inputs()
	player.register_collisions()


func _get_alive_players():
	var alive_players = []
	for player in active_players:
		if !player.is_dead():
			alive_players.append(player)

	return alive_players


func select_spawn_point():
	var spawn_points = get_tree().get_nodes_in_group('spawnpoints')[0]
	Manager._randomize_spawn_positions()
	Manager._randomize_spawn_positions()
	return spawn_points.get_children()[Manager.player_spawns[0]].position

func _activate_player(player_manager : Node, player_num : String, instant := false ):

	var player_tmp
	match player_num:
		'1':
			player_tmp = player_one
		'2':
			player_tmp = player_two
		'3':
			player_tmp = player_three
		'4':
			player_tmp = player_four
	player_tmp.active = true
	if instant :
		spawn(player_tmp)
	_update_active_players()
	Globals.HUD._update_hud()

func _deactivate_player(player_manager : Node, player_num : String):
	var player_tmp
	match player_num:
		'1':
			player_tmp = player_one
		'2':
			player_tmp = player_two
		'3':
			player_tmp = player_three
		'4':
			player_tmp = player_four
	player_tmp.active = false
	player_tmp.die()
	_update_active_players()

func _update_active_players():
	active_players = []
	for player in _players :
		if player.active : active_players.append(player)
