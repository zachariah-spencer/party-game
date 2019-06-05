extends Minigame

const GAME_NAME : String = 'goafk'
const GAME_TIME : int = 5
var has_buffered : bool = false



func _ready():
	add_to_group('minigames')
	Manager.current_game_name = GAME_NAME
	Manager.current_game_reference = self
	Manager.current_game_time = GAME_TIME
	Manager.current_game_attack_mode = 'lethal'
	Manager.current_game_allow_respawns = false
	$Cam.current = true
	call_deferred('_insert_players')

	yield(get_tree().create_timer(.4),"timeout")

	has_buffered = true

func _physics_process(delta):
	_check_last_alive(Players.active_players)

	if !is_game_won && has_buffered:
		_test_if_players_move(Players.active_players)



func _test_if_players_move(active_players):
	for player in active_players:
		if !player.is_dead():
			var player_state_ref = player.child.get_node('StateMachine')
			if player_state_ref.state == player_state_ref.states.run || player_state_ref.state == player_state_ref.states.jump:
				player.child.hit_points = 0

func _check_last_alive(active_players):
	for player in active_players:
		if !player.is_dead() && !alive_players.has(player):
			alive_players.append(player)
		elif player.is_dead() && alive_players.has(player):
			alive_players.remove(alive_players.find(player))
	if has_buffered:
		if alive_players.size() == 1:
			is_game_won = true
			_game_won()
		elif alive_players.size() == 0:
			is_game_won = true
			_game_won(true)


func _game_won(no_winner = false):
	if !no_winner:
		Manager.current_game_time = 0
		$HUD/Instructions.text = alive_players[0].display_name + ' Won!'
	else:
		Manager.current_game_time = 0
		$HUD/Instructions.text = 'Nobody Won!'
