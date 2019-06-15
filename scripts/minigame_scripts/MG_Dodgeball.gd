extends Minigame

func _ready():
	add_to_group('minigames')
	Manager.minigame_name = 'dodgeball'
	game_instructions = "Hit the other players!"
	game_time = 30
	$Cam.current = true

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


