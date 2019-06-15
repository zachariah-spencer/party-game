extends Minigame

func _ready():
	add_to_group('minigames')
	Manager.minigame_name = 'dodgeball'
	game_instructions = "Hit the other players!"
	game_time = 30
	$Cam.current = true

func _physics_process(delta):
	_run_minigame_loop()

func _run_minigame_loop():

	if game_active:
		_check_game_win_conditions()


