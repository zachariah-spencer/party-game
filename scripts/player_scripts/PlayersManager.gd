extends Node
class_name PlayersManager

onready var child : Node = $Player
onready var respawn_timer : Node = $RespawnTimer
onready var player_scene : PackedScene = preload('res://scenes/player/Player.tscn')
var is_dead : bool
var display_name : String

func _physics_process(delta):
	_check_is_dead()

func register_player_inputs():
	pass

func register_collisions():
	pass

func select_spawn_point():
	var spawn_points = get_tree().get_nodes_in_group('spawnpoints')[0]
	Manager._randomize_spawn_positions()
	Manager._randomize_spawn_positions()
	return spawn_points.get_children()[Manager.player_spawns[0]]

func _check_is_dead():
	if $Player == null:
		is_dead = true
	else:
		is_dead = false

func _transform_player_position(player_instance):
	var spawn_point : Node = select_spawn_point()
	var ragdoll_body_parts : Array = get_tree().get_nodes_in_group('ragdolls')
	
	self.position = Vector2.ZERO
	player_instance.position = spawn_point.position