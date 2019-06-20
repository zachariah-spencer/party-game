extends Minigame

func _ready():
	add_to_group('minigames')
	Manager.minigame_name = 'territories'

func _physics_process(delta):
	_run_minigame_loop()

func _run_minigame_loop():
	
	if game_active:
		_check_game_win_conditions()