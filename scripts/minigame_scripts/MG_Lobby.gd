extends Minigame

const GAME_NAME : String = 'lobby'
const GAME_TIME : int = 99999999999999999999
var player_one_ready : bool = false
var player_two_ready : bool = false
var player_three_ready : bool = false
var player_four_ready : bool = false
var is_starting : bool = false

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


func _physics_process(delta):
	_check_ready_ups()

func _check_ready_ups():
	if Input.is_action_just_pressed('player_one_start'):
		player_one_ready = true
	if Input.is_action_just_pressed('player_two_start'):
		player_two_ready = true
	if Input.is_action_just_pressed('player_three_start'):
		player_three_ready = true
	if Input.is_action_just_pressed('player_four_start'):
		player_four_ready = true

	if player_one_ready:
		if !is_starting:
			Manager._on_game_times_up()
			is_starting = true