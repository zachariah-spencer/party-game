extends Minigame

func _init():
	maps = [
	preload('res://scenes/minigames/mg_horseshoes/maps/Any_HorseshoesMap1.tscn')
	]


func _ready():
	add_to_group('minigames')
	Manager.minigame_name = 'horseshoes'
	game_instructions = 'Land a horseshoe, get a grenade,\nkill the other players!'

func _physics_process(delta):
	_run_minigame_loop()

func _run_minigame_loop():
	
	if game_active:
		_check_game_win_conditions()