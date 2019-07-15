extends Minigame

onready var drop_timer := $DropTimer
onready var blocks_array := map.get_node('Terrain').get_children()

func _ready():
	add_to_group('minigames')
	Manager.minigame_name = 'sumo'
	game_instructions = "Punch The Other\nPlayers Off!"
	

func _on_begin_game():
	._on_begin_game()
	drop_timer.start()

func _physics_process(delta):
	_run_minigame_loop()

func _run_minigame_loop():

	if game_active:
		_check_game_win_conditions()

func _drop_timeout():
	if !game_over:
		var rand := randi() % 2
		var passed_array := []
		
		# 0 = left
		# 1 = right
		if rand == 0:
			passed_array.append(blocks_array[0])
		else:
			passed_array.append(blocks_array[blocks_array.size() - 1])
		
		_drop(passed_array)

func _drop(blocks := []):
	for block in blocks:
		block.mode = block.MODE_RIGID
		block.apply_central_impulse(Vector2(0,-80))
		blocks_array.remove(blocks_array.find(block))




