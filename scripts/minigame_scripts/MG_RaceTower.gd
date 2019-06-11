extends Minigame

var winning_player : PlayersManager

func _ready():
	add_to_group('minigames')
	Manager.minigame_name = 'race_tower'
	game_instructions = "Race to\nEscape the Lava!"
	game_time = 60
	$Cam.current = true
	$Lava.connect('body_entered',self,'_on_Lava_body_entered')
	$VictoryArea.connect('body_entered',self,'_on_VictoryArea_body_entered')
	

func _physics_process(delta):
	_run_minigame_loop()

func _run_minigame_loop():
	if game_active:
		$Lava.position.y -= 2
		_check_game_win_conditions()

func _game_won(no_winner = false):
	game_over = true
	game_active = false
	if !no_winner:
		Players._get_alive_players()[0].score += 1
		$CanvasLayer/HUD._update_scores()
		$CanvasLayer/HUD/TimeLeft/Instructions.text = Players._get_alive_players()[0].display_name + ' Won!'
	elif no_winner:
		$CanvasLayer/HUD/TimeLeft/Instructions.text = 'Nobody Won!'
	
	

func _on_VictoryArea_body_entered(player):
	winning_player = player.get_parent()

func _check_game_win_conditions():
	if is_instance_valid(winning_player):
		_game_won()
	elif game_time == 0 || Players._get_alive_players().size() == 0:
		_game_won(true)


func _on_Lava_body_entered(player):
	player.hit_points = 0
