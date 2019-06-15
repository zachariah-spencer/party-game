extends Minigame

func _ready():
	add_to_group('minigames')
	Manager.minigame_name = 'goafk'
	visible_name = "Go AFK"
	game_instructions = "DON'T MOVE!!!"
	game_time = 5
	has_countdown = false
#	$Cam.current = true

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
