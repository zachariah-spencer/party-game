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
	$Cam.current = true
	call_deferred('_insert_players')
	
	yield(get_tree().create_timer(2),"timeout")
	
	game_active = true

func _physics_process(delta):
	alive_players = _check_alive_players(Players.active_players)
	if game_active:
		_test_if_players_move(alive_players)
		_check_game_win_conditions(alive_players)



func _test_if_players_move(alive_players):
	for player in alive_players:
		if !player.is_dead:
			var player_state_ref = player.child.get_node('StateMachine')
			if player_state_ref.state == player_state_ref.states.run || player_state_ref.state == player_state_ref.states.jump:
				player.child.hit_points = 0


func _game_won(no_winner = false):
	game_active = false
	if !no_winner:
		Manager.current_game_time = 0
		$HUD/Instructions.text = alive_players[0].display_name + ' Won!'
	else:
		Manager.current_game_time = 0
		$HUD/Instructions.text = 'Nobody Won!'
