extends Minigame

func _init():
	maps = [
	preload('res://scenes/minigames/mg_mirrored_paths/maps/Any_MirroredPathsMap1.tscn'),
	]

func _ready():
	Manager.minigame_name = 'mirrored_paths'
	game_instructions = 'MIRRORED PATHS TEST'

func _run_minigame_loop():
	if game_active:
		_check_game_win_conditions()