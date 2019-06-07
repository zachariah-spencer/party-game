extends Minigame

const GAME_NAME : String = 'race_tower'
const GAME_TIME : int = 60
var winning_player : PlayersManager

func _ready():
	add_to_group('minigames')
	Manager.current_game_name = GAME_NAME
	Manager.current_game_reference = self
	Manager.current_game_time = GAME_TIME
	Manager.current_game_attack_mode = 'nonlethal'
	Manager.current_game_allow_respawns = false
	$Cam.current = true
	call_deferred('_insert_players')
	
	yield(get_tree().create_timer(.5),"timeout")
	
	game_active = true

func _physics_process(delta):
	_run_minigame_loop()

func _run_minigame_loop():
	alive_players = _check_alive_players(Players.active_players)
	if game_active:
		_check_game_win_conditions(alive_players)

func _game_won(no_winner = false):
	game_active = false
	if !no_winner:
		Manager.current_game_time = 0
		$HUD/Instructions.text = alive_players[0].display_name + ' Won!'
	elif no_winner:
		Manager.current_game_time = 0
		$HUD/Instructions.text = 'Nobody Won!'

func _on_VictoryArea_body_entered(player):
	winning_player = player.get_parent()

func _check_game_win_conditions(alive_players):
	if is_instance_valid(winning_player):
		_game_won()
	elif Manager.current_game_time == 0 || alive_players.size() == 0:
		_game_won(true)


func _on_Lava_body_entered(player):
	player.hit_points = 0
