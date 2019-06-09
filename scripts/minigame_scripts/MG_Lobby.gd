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
	Manager.current_game_instant_player_inserting = true
	has_timer = false
	game_instructions = "Press '1'\nto Start!"
	$Cam.current = true

	Globals.HUD.get_node('Scorecards/Statuses/P1Ready').text = 'Not Ready'
	Globals.HUD.get_node('Scorecards/Statuses/P2Ready').text = 'Not Ready'
	Globals.HUD.get_node('Scorecards/Statuses/P3Ready').text = 'Not Ready'
	Globals.HUD.get_node('Scorecards/Statuses/P4Ready').text = 'Not Ready'

	call_deferred('_insert_players')


func _process(delta):
	_check_ready_ups()

func _check_ready_ups():
	Players._update_active_players()
	var num_of_players = Players.active_players.size()
	
	if Input.is_action_just_pressed('player_one_start') && Players.player_one.active && !player_one_ready:
		player_one_ready = true
		Globals.HUD.get_node('Scorecards/Statuses/P1Ready').text = 'Ready'
		num_of_ready_ups += 1
	elif Input.is_action_just_pressed('player_one_b') && Players.player_one.active && player_one_ready:
		#something needs to happen here still to stop the player managers from deactivating upon hitting this.
		player_one_ready = false
		Globals.HUD.get_node('Scorecards/Statuses/P1Ready').text = 'Not Ready'
		num_of_ready_ups -= 1
	#PRETEND THIS WAS HERE FOR PLAYERS 2, 3, & 4
	
#	_check_activates()
#	_check_deactivates()
#^^^ THESE ARE BOTH THE OLD FUNCTIONS FOR HANDLING THE READY SYSTEM ALL INSIDE OF MGLOBBY.gd
	
	if num_of_players >= 2 && num_of_ready_ups == num_of_players:
		if !is_starting:
			_game_won(true)
			is_starting = true

func _check_activates():
	if Input.is_action_just_pressed('player_one_start'):
		if Players.player_one.active && !player_one_ready:
			player_one_ready = true
			Globals.HUD.get_node('Scorecards/Statuses/P1Ready').text = 'Ready'
			num_of_ready_ups += 1
		elif !Players.player_one.active:
			Players.player_one._activate_player(Players.player_one, '1', true)
	
	if Input.is_action_just_pressed('player_two_start'):
		if Players.player_two.active && !player_two_ready:
			player_two_ready = true
			Globals.HUD.get_node('Scorecards/Statuses/P2Ready').text = 'Ready'
			num_of_ready_ups += 1
		elif !Players.player_two.active:
			Players.player_two._activate_player(Players.player_two, '2', true)
	
	if Input.is_action_just_pressed('player_three_start'):
		if Players.player_three.active && !player_three_ready:
			player_three_ready = true
			Globals.HUD.get_node('Scorecards/Statuses/P3Ready').text = 'Ready'
			num_of_ready_ups += 1
		elif !Players.player_three.active:
			Players.player_three._activate_player(Players.player_three, '3', true)
	
	if Input.is_action_just_pressed('player_four_start'):
		if Players.player_four.active && !player_four_ready:
			player_four_ready = true
			Globals.HUD.get_node('Scorecards/Statuses/P4Ready').text = 'Ready'
			num_of_ready_ups += 1
		elif !Players.player_four.active:
			Players.player_four._activate_player(Players.player_four, '4', true)

func _check_deactivates():
	if Input.is_action_just_pressed('player_one_b'):
		if Players.player_one.active && player_one_ready:
			player_one_ready = false
			Globals.HUD.get_node('Scorecards/Statuses/P1Ready').text = 'Not Ready'
			num_of_ready_ups -= 1
		elif Players.player_one.active && !player_one_ready:
			Players.player_one._deactivate_player(Players.player_one, '1')
	
	if Input.is_action_just_pressed('player_two_b'):
		if Players.player_two.active && player_two_ready:
			player_two_ready = false
			Globals.HUD.get_node('Scorecards/Statuses/P2Ready').text = 'Not Ready'
			num_of_ready_ups -= 1
		elif Players.player_two.active && !player_two_ready:
			Players.player_two._deactivate_player(Players.player_two, '2')
	
	if Input.is_action_just_pressed('player_three_b'):
		if Players.player_three.active && player_three_ready:
			player_three_ready = false
			Globals.HUD.get_node('Scorecards/Statuses/P3Ready').text = 'Not Ready'
			num_of_ready_ups -= 1
		elif Players.player_three.active && !player_three_ready:
			Players.player_three._deactivate_player(Players.player_three, '3')
	
	if Input.is_action_just_pressed('player_four_b'):
		if Players.player_four.active && player_four_ready:
			player_four_ready = false
			Globals.HUD.get_node('Scorecards/Statuses/P4Ready').text = 'Not Ready'
			num_of_ready_ups -= 1
		elif Players.player_four.active && !player_four_ready:
			Players.player_four._deactivate_player(Players.player_four, '3')


func _game_won(no_winner : bool = false):
	Globals.HUD._update_hud()
	Manager._on_game_times_up()