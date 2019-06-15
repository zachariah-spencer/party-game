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

func _game_won(no_winner = false):
	game_active = false
	game_over = true
	if !no_winner:
		Players._get_alive_players()[0].score += 1
		$CanvasLayer/HUD._update_scores()
		$CanvasLayer/HUD/TimeLeft/Instructions.text = Players._get_alive_players()[0].display_name + ' Won!'
	else:
		$CanvasLayer/HUD/TimeLeft/Instructions.text = 'Nobody Won!'

func _check_game_win_conditions():
	if Players._get_alive_players().size() == 1:
		_game_won()
	elif Players._get_alive_players().size() >= 1 && game_time == 0:
		_game_won()
	elif Players._get_alive_players().size() == 0 || game_time == 0:
		_game_won(true)


