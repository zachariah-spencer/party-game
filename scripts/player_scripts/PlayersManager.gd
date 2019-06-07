extends Node
class_name PlayersManager

onready var RAGDOLL = preload("res://scenes/PlayerDead.tscn")
onready var child : Node = $Player
var ragdoll
onready var respawn_timer : Node = Timer.new()
var display_name : String


func _ready():
	respawn_timer.wait_time = 3
	respawn_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	respawn_timer.one_shot = true
	add_child(respawn_timer)
	respawn_timer.connect('timeout', self, '_on_respawn_timeout')

func register_player_inputs():
	pass

func register_collisions():
	pass

func is_dead():
	return !is_instance_valid(child)

func _respawn(respawn_delay : float = 3):
	respawn_timer.start(respawn_delay)

func _on_respawn_timeout():
	if is_instance_valid(ragdoll) :
		ragdoll.queue_free()
	Players.spawn(self)

func _ragdoll():
	if is_instance_valid(ragdoll) :
		ragdoll.queue_free()
	var add_rag = RAGDOLL.instance()
	add_rag.position = child.position
	ragdoll = add_rag
	add_child(add_rag)

func die(respawn := true):
	_ragdoll()
	child.queue_free()
	if respawn :
		_respawn()