extends Minigame

func _ready():
	add_to_group('minigames')
	Manager.minigame_name = 'sumo'
	game_instructions = "Punch The Other\nPlayers Off!"
	game_time = 15
	$Cam.current = true

	$DeathBoundary.connect("body_entered", self, 'on_out_of_bounds')

func _physics_process(delta):
	_run_minigame_loop()

func _run_minigame_loop():

	if game_active:
		_check_game_win_conditions()

func on_out_of_bounds(body):
	if body.get_parent().is_in_group('players'):
		body.hit_points = 0

func _game_won(no_winner = false):
	game_active = false
	game_over = true
	if !no_winner:
		Players._get_alive_players()[0].score += 1
		$CanvasLayer/HUD._update_scores()
		$CanvasLayer/HUD/TimeLeft/Instructions.text = Players._get_alive_players()[0].display_name + ' Won!'
	else:
		$CanvasLayer/HUD/TimeLeft/Instructions.text = 'Nobody Won!'