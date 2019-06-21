extends Minigame

func _ready():
	add_to_group('minigames')
	Manager.minigame_name = 'sumo'
	game_instructions = "Punch The Other\nPlayers Off!"
	game_time = 15
	win_condition = win_conditions.last_alive_allow_no_winners

func _physics_process(delta):
	_run_minigame_loop()

func _run_minigame_loop():

	if game_active:
		_check_game_win_conditions()