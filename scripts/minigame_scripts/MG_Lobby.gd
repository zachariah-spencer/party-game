extends Minigame

const GAME_NAME : String = 'lobby'
const GAME_TIME : int = 99999999999999999999
var player_one_ready : bool = false
var player_two_ready : bool = false
var player_three_ready : bool = false
var player_four_ready : bool = false
var is_starting : bool = false
var is_readyable := true
var num_of_ready_ups = 0

func _ready():
	add_to_group('minigames')
	Manager.current_game_name = GAME_NAME
	Manager.current_game_reference = self
	Manager.current_game_readyable = is_readyable
	Manager.current_game_time = GAME_TIME
	Manager.current_game_attack_mode = 'nonlethal'
	Manager.current_game_allow_respawns = false
	Manager.current_game_instant_player_inserting = true
	has_countdown = false
	game_active = true
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
	
	var active = 0
	var ready = 0
	
	for player in Players.active_players :
		var readying = Globals.HUD.get_node("Scorecards/Statuses/P" + player.player_number + "Ready")
		active += 1
		if player.ready :
			ready += 1
			readying.text = "Ready "
		else :
			readying.text = "Not Ready"
	
	if active >= 2 && active == ready:
		if !is_starting:
			_game_won(true)
			is_starting = true

func _game_won(no_winner : bool = false):
	Globals.HUD._update_hud()
	Manager._on_game_times_up()