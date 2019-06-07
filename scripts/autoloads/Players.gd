extends Node

onready var player_scene : PackedScene = preload('res://scenes/player/Player.tscn')
onready var player_one_scene : PackedScene = preload('res://scenes/player/PlayerOne.tscn')
onready var player_two_scene : PackedScene = preload('res://scenes/player/PlayerTwo.tscn')
onready var player_three_scene : PackedScene = preload('res://scenes/player/PlayerThree.tscn')
onready var player_four_scene : PackedScene = preload('res://scenes/player/PlayerFour.tscn')
var active_players : Array

func _ready():
	active_players = get_tree().get_nodes_in_group('players')


func spawn(player : PlayersManager, spawn_position : Vector2 = select_spawn_point()):
#	if there is a player, ensures it's freed before a new instance is created
	if is_instance_valid(player.child) :
		player.child.queue_free()
		yield(player.child, "tree_exited")
	if is_instance_valid(player.ragdoll) :
		player.ragdoll.queue_free()

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
	var alive_players : Array
	var players_to_add : Array = []
	var players_to_remove : Array = []
	for player in _get_active_players():
		if !player.is_dead() && !alive_players.has(player):
			players_to_add.append(player)
		elif player.is_dead() && alive_players.has(player):
			players_to_remove.append(player)

	for player in players_to_add:
		alive_players.append(player)

	for player in players_to_remove:
		alive_players.remove(alive_players.find(player))

	return alive_players


func select_spawn_point():
	var spawn_points = get_tree().get_nodes_in_group('spawnpoints')[0]
	Manager._randomize_spawn_positions()
	Manager._randomize_spawn_positions()
	return spawn_points.get_children()[Manager.player_spawns[0]].position

func _activate_player(player_manager : Node, player_num : String, instant := false ):
	if !is_instance_valid(player_manager):
		var instance_of_player_manager
		match player_num:
			'1':
				instance_of_player_manager = player_one_scene.instance()
			'2':
				instance_of_player_manager = player_two_scene.instance()
			'3':
				instance_of_player_manager = player_three_scene.instance()
			'4':
				instance_of_player_manager = player_four_scene.instance()
		Manager.world_node.get_node('Players').add_child(instance_of_player_manager)
		Globals.HUD._update_hud()
		spawn(instance_of_player_manager)

func _deactivate_player(player_manager : Node, player_num : String):
	player_manager.queue_free()
	
	match player_num:
		'1':
			Globals.player_one = null
		'2':
			Globals.player_two = null
		'3':
			Globals.player_three = null
		'4':
			Globals.player_four = null

func _get_active_players():
	return get_tree().get_nodes_in_group('players')