extends Node

onready var player_scene : PackedScene = preload('res://scenes/player/Player.tscn')
var active_players : Array

func _ready():
	active_players = get_tree().get_nodes_in_group('players')


func spawn(player : PlayersManager, spawn_position : Vector2 = select_spawn_point()):
	if player.child != null :
		player.child.queue_free()
		yield(player.child, "tree_exited")

	var add = player_scene.instance()
	add.position = Vector2.ZERO
	player.position = spawn_position
	add.hit_points = 100
	player.child = add
	player.add_child(add)
	player.register_player_inputs()
	player.register_collisions()




func select_spawn_point():
	var spawn_points = get_tree().get_nodes_in_group('spawnpoints')[0]
	Manager._randomize_spawn_positions()
	Manager._randomize_spawn_positions()
	return spawn_points.get_children()[Manager.player_spawns[0]].position