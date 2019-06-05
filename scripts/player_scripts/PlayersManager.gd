extends Node
class_name PlayersManager

onready var child : Node = $Player
onready var respawn_timer : Node = $RespawnTimer

var is_dead : bool = false
var display_name : String

func _physics_process(delta):
	_check_is_dead()

func register_player_inputs():
	pass

func register_collisions():
	pass

func _check_is_dead():
	is_dead = !is_instance_valid(child)

func is_dead():
	return !is_instance_valid(child)

func _respawn(respawn_delay : float = 3):
	child.queue_free()
	respawn_timer.start(respawn_delay)
