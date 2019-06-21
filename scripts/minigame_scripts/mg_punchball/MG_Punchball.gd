extends Minigame

func _init():
	maps = [
	preload('res://scenes/minigames/mg_punchball/maps/4_PunchballMap1.tscn'),
	preload('res://scenes/minigames/mg_punchball/maps/2_PunchballMap2.tscn'),
	preload('res://scenes/minigames/mg_punchball/maps/3_PunchballMap3.tscn')
	]

func _ready():
	add_to_group('minigames')
	Manager.minigame_name = 'punchball'
	game_instructions = "Hit the ball!"
	game_time = 30
	win_condition = win_conditions.highest_local_score
	has_local_score = true
	
	yield(Globals.HUD, 'begin_game')
	
	get_tree().get_nodes_in_group('punchball')[0].get_node('ImpulseTimer').start()

func _physics_process(delta):
	_run_minigame_loop()

func _run_minigame_loop():

	if game_active:
		_check_game_win_conditions()


