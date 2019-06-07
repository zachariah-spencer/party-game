extends Node

onready var player_scene : PackedScene = preload('res://scenes/player/Player.tscn')
var active_players : Array

func _ready():
	active_players = get_tree().get_nodes_in_group('players')


func spawn(player : PlayersManager, spawn_position : Vector2 = select_spawn_point()):
#	if there is a player, ensures it's freed before a new instance is created
	if is_instance_valid(player.child) :
		player.child.queue_free()
		yield(player.child, "tree_exited")

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
	for player in active_players:
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

func print_scores():
	print('p1: ' + String(Globals.player_one.score))
	print('p2: ' + String(Globals.player_two.score))