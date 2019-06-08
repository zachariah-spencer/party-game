extends Node
class_name PlayersManager

onready var RAGDOLL = preload("res://scenes/PlayerDead.tscn")
onready var child : Node = $Player
var ragdoll
onready var respawn_timer : Node = Timer.new()
var display_name : String
var score : int = 0
var dead := true
var active := false

func _ready():
	Manager.connect('minigame_change', self, "_minigame_change")
	respawn_timer.wait_time = 3
	respawn_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	respawn_timer.one_shot = true
	add_child(respawn_timer)
	respawn_timer.connect('timeout', self, '_on_respawn_timeout')

func _minigame_change():
	if is_instance_valid(ragdoll) :
		ragdoll.queue_free()

func register_player_inputs():
	pass

func register_collisions():
	pass

func is_dead():
	return dead

func _respawn(respawn_delay : float = 3):
	respawn_timer.start(respawn_delay)

func _on_respawn_timeout():
	if is_instance_valid(ragdoll) :
		ragdoll.queue_free()
	dead = false
	Players.spawn(self)

func _ragdoll():
	if is_instance_valid(ragdoll) :
		ragdoll.queue_free()
	var add_rag = RAGDOLL.instance()
	add_rag.position = child.position
	ragdoll = add_rag
	add_child(add_rag)

func die(respawn := false):
	if dead :
		return
	dead = true
	_ragdoll()
	child.set_physics_process(false)
	child.state_machine.set_physics_process(false)
	child.queue_free()
	if respawn :
		_respawn()