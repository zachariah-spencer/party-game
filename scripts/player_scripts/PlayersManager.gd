extends Node
class_name PlayersManager

onready var child : Node = $Player
onready var respawn_timer : Node = Timer.new()

var is_dead : bool = false
var display_name : String

func _ready():
	respawn_timer.wait_time = 3
	respawn_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	respawn_timer.one_shot = true
	add_child(respawn_timer)
	respawn_timer.connect('timeout', self, '_on_respawn_timeout')


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

func _on_respawn_timeout():
	Players.spawn(self)
	register_player_inputs()
	register_collisions()