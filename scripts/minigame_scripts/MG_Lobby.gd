extends Minigame

const GAME_NAME : String = 'lobby'
const GAME_TIME : int = 99999999999999999999
var player_one_ready : bool = false
var player_two_ready : bool = false
var player_three_ready : bool = false
var player_four_ready : bool = false
var is_starting : bool = false
var num_of_ready_ups = 0

func _ready():
	add_to_group('minigames')
	Manager.current_game_name = GAME_NAME
	Manager.current_game_reference = self
	Manager.current_game_time = GAME_TIME
	Manager.current_game_attack_mode = 'nonlethal'
	Manager.current_game_allow_respawns = false
	has_timer = false
	game_instructions = "Press '1'\nto Start!"
	$Cam.current = true
	call_deferred('_insert_players')


func _process(delta):
	_check_ready_ups()

func _check_ready_ups():
	var num_of_players = Players._get_active_players().size()
	
	if Input.is_action_just_pressed('player_one_start'):
		if is_instance_valid(Globals.player_one) && !player_one_ready:
			player_one_ready = true
			Globals.HUD.get_node('Scorecards/P1Ready').text = 'Ready'
			num_of_ready_ups += 1
		else:
			Players._activate_player(Globals.player_one, '1', true)
	if Input.is_action_just_pressed('player_two_start') && !player_two_ready:
		if is_instance_valid(Globals.player_two):
			player_two_ready = true
			Globals.HUD.get_node('Scorecards/P2Ready').text = 'Ready'
			num_of_ready_ups += 1
		else:
			Players._activate_player(Globals.player_two, '2', true)
	if Input.is_action_just_pressed('player_three_start') && !player_three_ready:
		if is_instance_valid(Globals.player_three):
			player_three_ready = true
			Globals.HUD.get_node('Scorecards/P3Ready').text = 'Ready'
			num_of_ready_ups += 1
		else:
			Players._activate_player(Globals.player_three, '3', true)
	if Input.is_action_just_pressed('player_four_start') && !player_four_ready:
		if is_instance_valid(Globals.player_four):
			player_four_ready = true
			Globals.HUD.get_node('Scorecards/P4Ready').text = 'Ready'
			num_of_ready_ups += 1
		else:
			Players._activate_player(Globals.player_four, '4', true)
	
	
	
	if Input.is_action_just_pressed('player_one_b'):
		if is_instance_valid(Globals.player_one) && player_one_ready:
			player_one_ready = false
			Globals.HUD.get_node('Scorecards/P1Ready').text = 'Not Ready'
			num_of_ready_ups -= 1
		elif is_instance_valid(Globals.player_one) && !player_one_ready:
			Players._deactivate_player(Globals.player_one, '1')
			
	if Input.is_action_just_pressed('player_two_b'):
		if is_instance_valid(Globals.player_two) && player_two_ready:
			player_two_ready = false
			Globals.HUD.get_node('Scorecards/P2Ready').text = 'Not Ready'
			num_of_ready_ups -= 1
		elif is_instance_valid(Globals.player_two) && !player_two_ready:
			print(Globals.player_two.name)
			Players._deactivate_player(Globals.player_two, '2')
			
	if Input.is_action_just_pressed('player_three_b'):
		if is_instance_valid(Globals.player_three) && player_three_ready:
			player_three_ready = false
			Globals.HUD.get_node('Scorecards/P3Ready').text = 'Not Ready'
			num_of_ready_ups -= 1
		elif is_instance_valid(Globals.player_three) && !player_three_ready:
			Players._deactivate_player(Globals.player_three, '3')
			
	if Input.is_action_just_pressed('player_four_b'):
		if is_instance_valid(Globals.player_four) && player_four_ready:
			player_four_ready = false
			Globals.HUD.get_node('Scorecards/P4Ready').text = 'Not Ready'
			num_of_ready_ups -= 1
		elif is_instance_valid(Globals.player_four) && !player_four_ready:
			Players._deactivate_player(Globals.player_four, '4')
	
	
	
	if num_of_players >= 2 && num_of_ready_ups == num_of_players:
		if !is_starting:
			Manager._on_game_times_up()
			is_starting = true