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
var b_button : String
var start_button : String
var player_number : String
var ready = false

func _ready():
	set_process_input(true)
	Manager.connect('minigame_change', self, "_minigame_change")
	respawn_timer.wait_time = 3
	respawn_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	respawn_timer.one_shot = true
	add_child(respawn_timer)
	respawn_timer.connect('timeout', self, '_on_respawn_timeout')

func _minigame_change():
	respawn_timer.stop()
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

func _activate_player(player_manager : PlayersManager, instant := false ):
	player_manager.active = true
	if instant :
		Players.spawn(player_manager)
	else :
		player_manager.dead = true
	Players._update_active_players()
	Globals.HUD._update_hud()

func _deactivate_player(player_manager : PlayersManager):
	player_manager.active = false
	player_manager.die()
	Players._update_active_players()
	Globals.HUD._update_hud()


func _input(event):
	if event.is_action_pressed(start_button):
		if !active :
			_activate_player(self, Manager.current_game_instant_player_inserting)
		elif !ready :
			ready = true
	if event.is_action_pressed(b_button):
		if ready && Manager.current_game_readyable :
			ready = false
		elif active :
			_deactivate_player(self)
		Globals.HUD._update_hud()

