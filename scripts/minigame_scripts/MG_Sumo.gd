extends Minigame

const GAME_NAME : String = 'sumo'
const GAME_TIME : int = 15

func _ready():
	add_to_group('minigames')
	Manager.current_game_name = GAME_NAME
	Manager.current_game_reference = self
	Manager.current_game_time = GAME_TIME
	Manager.current_game_attack_mode = 'nonlethal'
	Manager.current_game_allow_respawns = false
	game_instructions = "Punch The Other\nPlayers Off!"
	$Cam.current = true
	call_deferred('_insert_players')

	yield(get_tree().create_timer(.5),"timeout")

	game_active = true

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
		Manager.current_game_time = 0
		Players._get_alive_players()[0].score += 1
		$CanvasLayer/HUD._update_scores()
		$CanvasLayer/HUD/TimeLeft/Instructions.text = Players._get_alive_players()[0].display_name + ' Won!'
	else:
		Manager.current_game_time = 0
		$CanvasLayer/HUD/TimeLeft/Instructions.text = 'Nobody Won!'