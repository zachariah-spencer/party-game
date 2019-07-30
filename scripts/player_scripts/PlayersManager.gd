extends Node2D
class_name PlayersManager

var child : Player
var ragdoll
var display_name : String
var score : int = 0
var local_score := 0
var dead := true
var active := false
var select_button : String
var start_button : String
var player_number : String
var ready = false
var bit := 0
var single_bit := 0
var player_string : String
var controller_index := 0

onready var RAGDOLL = preload("res://scenes/player/PlayerDead.tscn")
onready var player_scene : PackedScene = preload('res://scenes/player/Player.tscn')
onready var respawn_timer : Node = Timer.new()

signal paused_game

func _ready():
	set_process_input(true)
	Manager.connect('minigame_change', self, "_minigame_change")
	respawn_timer.wait_time = 3
	respawn_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	respawn_timer.one_shot = true
	add_child(respawn_timer)
	respawn_timer.connect('timeout', self, '_on_respawn_timeout')
	
	yield(get_tree().get_root(), 'ready')
	connect('paused_game', Globals.pause_menu, 'toggle_pause_game')


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
		_respawn(Manager.current_minigame.respawn_time)

func _activate_player(instant := false ):
	active = true
	if instant :
		spawn()
	else :
		dead = true
	Players._update_active_players()
	Globals.HUD._update_hud()

func _deactivate_player():
	ready = false
	active = false
	die()
	Players._update_active_players()
	Globals.HUD._update_hud()


func _input(event):
	#Player activation/deactivation
	if event.is_action_pressed(start_button):
		if !active :
			_activate_player(Manager.current_minigame.instant_player_insertion)
		elif active && Manager.minigame_name != 'lobby':
			emit_signal('paused_game', self)
		elif !ready :
			ready = true
	if event.is_action_pressed(select_button):
		if ready && Manager.current_minigame.readyable :
			ready = false
		elif active :
			_deactivate_player()
		Globals.HUD._update_hud()

func spawn(spawn_position : Vector2 = Players.select_spawn_point(), init_hp := Manager.current_minigame.initial_hp, is_hp_visible := Manager.current_minigame.visible_hp):
#	if there is a player or ragdoll, ensures it's freed before a new instance is created
	_clear_children()

	if !active :
		return

#	instances the player at a spawn point
	var add = player_scene.instance()
	add.position = Vector2.ZERO
	position = spawn_position
	add.hit_points = init_hp
	add.visible_hp = is_hp_visible
	child = add
	add_child(add)
	dead = false

	register_player_inputs()

func register_player_inputs():

	match player_number:
		'1':
			player_string = 'one'
			bit = Globals.P1_BIT
			single_bit = 6
		'2':
			player_string = 'two'
			bit = Globals.P2_BIT
			single_bit = 7
		'3':
			player_string = 'three'
			bit = Globals.P3_BIT
			single_bit = 8
		'4':
			player_string = 'four'
			bit = Globals.P4_BIT
			single_bit = 9

	start_button = 'player_' + player_string + '_start'
	select_button = 'player_' + player_string + '_select'

	if child:
		child.collision_layer += bit
		child.collision_mask += Globals.PLAYER_BITS - bit
		child.left_hand.get_node("Hitbox").collision_mask += -bit + Globals.ITEM_BIT
		child.right_hand.get_node("Hitbox").collision_mask += -bit + Globals.ITEM_BIT
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

		child.taunt_input1 = 'player_' + player_string + '_taunt_1'
		child.taunt_input2 = 'player_' + player_string + '_taunt_2'
		child.taunt_input3 = 'player_' + player_string + '_taunt_3'
		child.taunt_input4 = 'player_' + player_string + '_taunt_4'
	else :
		_setup_controller_config(player_string)

func _setup_controller_config(player_string : String):
	var current_action := ''

	current_action = _map_controller_action('_move_left', 0.0)
	_map_controller_event_to_action(current_action, true, JOY_AXIS_0, -1.0)

	current_action = _map_controller_action('_move_right', 0.0)
	_map_controller_event_to_action(current_action, true, JOY_AXIS_0, 1.0)

	current_action = _map_controller_action('_move_up', 0.0)
	_map_controller_event_to_action(current_action, true, JOY_AXIS_1, -1.0)

	current_action = _map_controller_action('_move_down', 0.0)
	_map_controller_event_to_action(current_action, true, JOY_AXIS_1, 1.0)

	current_action = _map_controller_action('_rs_left', 0.0)
	_map_controller_event_to_action(current_action, true, JOY_AXIS_2, -1.0)

	current_action = _map_controller_action('_rs_right', 0.0)
	_map_controller_event_to_action(current_action, true, JOY_AXIS_2, 1.0)

	current_action = _map_controller_action('_rs_up', 0.0)
	_map_controller_event_to_action(current_action, true, JOY_AXIS_3, -1.0)

	current_action = _map_controller_action('_rs_down', 0.0)
	_map_controller_event_to_action(current_action, true, JOY_AXIS_3, 1.0)

	current_action = _map_controller_action('_move_jump')
	_map_controller_event_to_action(current_action, false, JOY_BUTTON_0)
	_map_controller_event_to_action(current_action, false, JOY_BUTTON_6)

	current_action = _map_controller_action('_attack')
	_map_controller_event_to_action(current_action, false, JOY_BUTTON_2)
	_map_controller_event_to_action(current_action, false, JOY_BUTTON_7)

	current_action = _map_controller_action('_taunt_1')
	_map_controller_event_to_action(current_action, false, JOY_DPAD_LEFT)

	current_action = _map_controller_action('_taunt_2')
	_map_controller_event_to_action(current_action, false, JOY_DPAD_UP)

	current_action = _map_controller_action('_taunt_3')
	_map_controller_event_to_action(current_action, false, JOY_DPAD_RIGHT)

	current_action = _map_controller_action('_taunt_4')
	_map_controller_event_to_action(current_action, false, JOY_DPAD_DOWN)

	current_action = _map_controller_action('_start')
	_map_controller_event_to_action(current_action, false, JOY_START)

	current_action = _map_controller_action('_select')
	_map_controller_event_to_action(current_action, false, JOY_SELECT)

func _map_controller_action(action_suffix : String, deadzone := 0.5):
	var action_string := 'player_' + player_string + action_suffix
	if not InputMap.has_action(action_string) :
		InputMap.add_action(action_string)
		InputMap.action_set_deadzone(action_string, deadzone)
	return action_string

func _map_controller_event_to_action(current_action : String, button_or_axis := false, mapping := JOY_BUTTON_0, value := 0.0):

	if button_or_axis:
		var axis_ev := InputEventJoypadMotion.new()
		axis_ev.set_axis(mapping)
		axis_ev.set_axis_value(value)
		axis_ev.device = controller_index
		InputMap.action_add_event(current_action, axis_ev)
	else:
		var button_ev := InputEventJoypadButton.new()
		button_ev.set_button_index(mapping)
		button_ev.device = controller_index
		InputMap.action_add_event(current_action, button_ev)
