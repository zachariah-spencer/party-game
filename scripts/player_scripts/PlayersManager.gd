extends Node2D
class_name PlayersManager

onready var RAGDOLL = preload("res://scenes/PlayerDead.tscn")
onready var player_scene : PackedScene = preload('res://scenes/player/Player.tscn')
var child : Player
var ragdoll
onready var respawn_timer : Node = Timer.new()
var display_name : String
var score : int = 0
var local_score := 0
var dead := true
var active := false
var b_button : String
var start_button : String
var player_number : String
var ready = false
var bit := 0

func _ready():
	set_process_input(true)
	Manager.connect('minigame_change', self, "_minigame_change")
	respawn_timer.wait_time = 3
	respawn_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	respawn_timer.one_shot = true
	add_child(respawn_timer)
	respawn_timer.connect('timeout', self, '_on_respawn_timeout')

func _process(delta):
	if !dead :
		$Sounds.position = child.position
	elif ragdoll :
		$Sounds.position = ragdoll.position

#plays a node via it's path from Sounds
func play_sound(sound : String) :
	var play_node = $Sounds.get_node(sound)
	if play_node :
		play_node.play()

#plays a random subnode of the specified node
func play_random(node : String) :
	var play_node = $Sounds.get_node(node)
	if play_node :
		play_node.get_child( rand_range(0, play_node.get_child_count())).play()

func _minigame_change():
	_clear_children()

func _clear_children():
	respawn_timer.stop()
	for child in get_children() :
		if child.is_in_group('player') :
			child.queue_free()
			ragdoll = null
			child = null

func register_collisions():
	pass

func is_dead():
	return dead

func _respawn(respawn_delay : float = 3):
	respawn_timer.start(respawn_delay)

func _on_respawn_timeout():
	spawn()

func _ragdoll():
	var add_rag = RAGDOLL.instance()
	add_rag.position = child.position
	var parts = add_rag.get_children()
#	# don't hardcode arrays like this if you can help it
#	var parts = ["Left Hand",
#				 "Body",
#				 "Head",
#				 "Right Hand",
#				 "Right Foot",
#				 "Left Foot"]
	for p in parts:
		if add_rag is RigidBody2D :
			add_rag.get_node(p).linear_velocity = child.velocity*2
	ragdoll = add_rag
	add_child(add_rag)

func die(respawn := false):
	if dead :
		return
	#plays a random child of the "death" node
	play_random("Death")
	child.drop()
	dead = true
	_clear_children()
	_ragdoll()
	if respawn :
		_respawn()

func _activate_player(instant := false ):
	active = true
	if instant :
		spawn()
	else :
		dead = true
	Players._update_active_players()
	Globals.HUD._update_hud()

func _deactivate_player():
	active = false
	die()
	Players._update_active_players()
	Globals.HUD._update_hud()


func _input(event):
	#Player activation/deactivation
	if event.is_action_pressed(start_button):
		if !active :
			_activate_player(Manager.current_minigame.instant_player_insertion)
		elif !ready :
			ready = true
	if event.is_action_pressed(b_button):
		if ready && Manager.current_minigame.readyable :
			ready = false
		elif active :
			_deactivate_player()
		Globals.HUD._update_hud()

func spawn(spawn_position : Vector2 = Players.select_spawn_point()):
#	if there is a player or ragdoll, ensures it's freed before a new instance is created
	_clear_children()

	if !active :
		return

#	instances the player at a spawn point
	var add = player_scene.instance()
	add.position = Vector2.ZERO
	position = spawn_position
	add.hit_points = 100
	child = add
	add_child(add)
	dead = false

	register_player_inputs()
#	register_collisions()

func register_player_inputs():

	var player_string : String

	match player_number:
		'1':
			player_string = 'one'
			bit = 64
		'2':
			player_string = 'two'
			bit = 128
		'3':
			player_string = 'three'
			bit = 256
		'4':
			player_string = 'four'
			bit = 512

	child.collision_layer += bit
	child.collision_mask += Players.player_bits - bit
	child.left_hand.get_node("Hitbox").collision_mask -= bit
	child.right_hand.get_node("Hitbox").collision_mask -= bit
	child.get_node('TopOfHeadArea').collision_mask -= bit

	child.move_left = 'player_' + player_string + '_move_left'
	child.move_right = 'player_' + player_string + '_move_right'
	child.move_jump = 'player_' + player_string + '_move_jump'
	child.move_up = 'player_' + player_string + '_move_up'
	child.move_down = 'player_' + player_string + '_move_down'
	child.attack_input = 'player_' + player_string + '_attack'

	child.rs_left = 'player_' + player_string + '_rs_left'
	child.rs_right = 'player_' + player_string + '_rs_right'
	child.rs_up = 'player_' + player_string + '_rs_up'
	child.rs_down = 'player_' + player_string + '_rs_down'