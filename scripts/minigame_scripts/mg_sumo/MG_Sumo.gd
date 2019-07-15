extends Minigame

onready var drop_timer := $DropTimer
onready var blocks_array := map.get_node('Terrain').get_children()
onready var terrain_group := map.get_node('Terrain')
onready var falling_group := map.get_node('FallingTerrain')

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
		var side_to_drop := 1#randi() % 2
		var num_to_drop := int(rand_range(2,4))
		var passed_array := []
		
		# 0 = left
		# 1 = right
		if side_to_drop == 0:
			for i in range(0,num_to_drop):
				passed_array.append(blocks_array[i])
		else:
			for i in range(blocks_array.size() - num_to_drop, blocks_array.size()):
				passed_array.append(blocks_array[i])
		
		if blocks_array.size() - passed_array.size() >= 2:
			_drop(passed_array)

func _drop(blocks := []):
	var anims = map.get_node('AnimationPlayer')
	
	for block in blocks:
		terrain_group.remove_child(block)
		falling_group.add_child(block)
		block.set_owner(falling_group)
		
	
	anims.play('shake')
	
	yield(anims, 'animation_finished')
	
	for block in blocks:
		block.mode = block.MODE_RIGID
		block.set_collision_mask_bit(0,false)
		block.apply_central_impulse(Vector2(0,-80))
		blocks_array.remove(blocks_array.find(block))




