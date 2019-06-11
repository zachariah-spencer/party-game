extends Minigame




func _ready():
	add_to_group('minigames')
	Manager.minigame_name = 'goafk'
	game_instructions = "DON'T MOVE!!!"
	game_time = 5
	has_countdown = false
	$Cam.current = true
	call_deferred('_insert_players')
	
	yield(get_tree().create_timer(.2),'timeout')
	
	game_active = true

func _physics_process(delta):
	_run_minigame_loop()

func _run_minigame_loop():
	if game_active:
		_test_if_players_move()
		_check_game_win_conditions()

func _test_if_players_move():
	for player in Players._get_alive_players():
		if !player.is_dead():
			var player_state_ref = player.child
			if player_state_ref.state == player_state_ref.states.run || player_state_ref.state == player_state_ref.states.jump:
				player.child.hit_points = 0


func _game_won(no_winner = false):
	game_over = true
	game_active = false
	if !no_winner:
		for player in Players._get_alive_players():
			player.score += 1
		$CanvasLayer/HUD._update_scores()
		$CanvasLayer/HUD/TimeLeft/Instructions.text = 'Winners:\n'
		for player in Players._get_alive_players():
			$CanvasLayer/HUD/TimeLeft/Instructions.text = $CanvasLayer/HUD/TimeLeft/Instructions.text +  player.display_name + '\n'


	else:
		$CanvasLayer/HUD/TimeLeft/Instructions.text = 'Nobody Won!'


func _check_game_win_conditions():
	if Players._get_alive_players().size() == 1:
		_game_won()
	elif Players._get_alive_players().size() >= 1 && game_time == 0:
		_game_won()
	elif Players._get_alive_players().size() == 0 || game_time == 0:
		_game_won(true)

