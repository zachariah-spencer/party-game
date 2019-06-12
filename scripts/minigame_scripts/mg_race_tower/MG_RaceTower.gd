extends Minigame

#When a new map chunk scene to be randomly generated is created, adding it to this list
#should insert it into the procedural rotation
const CHUNKS : Dictionary = {
	'chunk_one' : preload('res://scenes/minigames/mg_race_tower/TowerChunkOne.tscn'),
	'chunk_two' : preload('res://scenes/minigames/mg_race_tower/TowerChunkTwo.tscn'),
	'chunk_three' : preload('res://scenes/minigames/mg_race_tower/TowerChunkThree.tscn'),
}

var loaded_chunks : Array = []
signal updated_chunks

func _ready():
	add_to_group('minigames')
	Manager.minigame_name = 'race_tower'
	game_instructions = "Race to\nEscape the Lava!"
	game_time = 60
	$Cam.current = true
	$Lava.connect('body_entered',self,'_on_Lava_body_entered')

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
		for player in Players._get_alive_players():
			player.score += 1
		$CanvasLayer/HUD._update_scores()
		$CanvasLayer/HUD/TimeLeft/Instructions.text = 'Winners:\n'
		for player in Players._get_alive_players():
			$CanvasLayer/HUD/TimeLeft/Instructions.text = $CanvasLayer/HUD/TimeLeft/Instructions.text +  player.display_name + '\n'
	elif no_winner:
		$CanvasLayer/HUD/TimeLeft/Instructions.text = 'Nobody Won!'
	
	

func _check_game_win_conditions():
	if game_time == 0 || Players._get_alive_players().size() == 0:
		_game_won()
	elif Players._get_alive_players().size() == 0:
		_game_won(true)


func _on_Lava_body_entered(player):
	player.hit_points = 0

func update_chunk(chunk_pos : Vector2, old_chunk : Node2D):
	#This instancing is causing extreme lag
	#Unsure if this is a code problem or merely 
	#a node-count issue as we are using individual 
	#nodes for each 64x64 block of terrain
	
	#let all active chunks know that more are being loaded
	emit_signal('updated_chunks')
	var new_chunk
	
	#do-while to randomize the pieces of map that are loading and ensure you never get the same piece twice
	#also an edge case that stops the 'bottom tower' map chunk from being randomly selected
	new_chunk = CHUNKS[CHUNKS.keys()[int(rand_range(1,CHUNKS.size()))]]
	while new_chunk == old_chunk:
		new_chunk = CHUNKS[CHUNKS.keys()[int(rand_range(1,CHUNKS.size()))]]
	
	#instance and set new chunk above players on the top of the tower
	new_chunk = new_chunk.instance()
	new_chunk.position = chunk_pos
	new_chunk.position.y -= 4096
	
	#add to tree
	call_deferred('add_child', new_chunk)