extends Minigame

func _ready():
	add_to_group('minigames')
	Manager.minigame_name = 'goafk'

func _insert_players():
	._insert_players()
	
	for p in Players._get_alive_players():
		p.child.disable_movement = true
		p.child.disable_knockback = true

func _physics_process(delta):
	_run_minigame_loop()

func _run_minigame_loop():
	if game_active:
		_check_game_win_conditions()
