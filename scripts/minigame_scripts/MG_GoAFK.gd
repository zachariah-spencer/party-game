extends Minigame

const GAME_NAME : String = 'goafk'
const GAME_TIME : int = 5




func _ready():
	add_to_group('minigames')
	Manager.current_game_name = GAME_NAME
	Manager.current_game_reference = self
	Manager.current_game_time = GAME_TIME
	Manager.current_game_attack_mode = 'lethal'
	Manager.current_game_allow_respawns = false
	game_instructions = "DON'T MOVE!!!"
	$Cam.current = true
	call_deferred('_insert_players')

	yield(get_tree().create_timer(1),"timeout")

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
			var player_state_ref = player.child.get_node('StateMachine')
			if player_state_ref.state == player_state_ref.states.run || player_state_ref.state == player_state_ref.states.jump:
				player.child.hit_points = 0


func _game_won(no_winner = false):
	game_over = true
	game_active = false
	if !no_winner:
		Manager.current_game_time = 0
		for player in Players._get_alive_players():
			player.score += 1
		$CanvasLayer/HUD._update_hud()
		$CanvasLayer/HUD/TimeLeft/Instructions.text = 'Winners:\n'
		for player in Players._get_alive_players():
			$CanvasLayer/HUD/TimeLeft/Instructions.text = $CanvasLayer/HUD/TimeLeft/Instructions.text +  player.display_name + '\n'
		

	else:
		Manager.current_game_time = 0
		$CanvasLayer/HUD/TimeLeft/Instructions.text = 'Nobody Won!'


func _check_game_win_conditions():
	if Players._get_alive_players().size() == 1:
		_game_won()
	elif Players._get_alive_players().size() >= 1 && Manager.current_game_time == 0:
		_game_won()
	elif Players._get_alive_players().size() == 0 || Manager.current_game_time == 0:
		_game_won(true)

