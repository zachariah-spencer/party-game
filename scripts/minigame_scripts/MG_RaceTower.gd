extends Minigame

#ACTIVE_PLAY_AREA_SIZE: 3584 OR 56 Blocks(56*64)
#INDIVIDUAL_CHUNK_SIZE: 1792

var current_chunk_num := 1
onready var chunk_one_area = $ActiveChunkOne/ActiveChunkOneArea
onready var chunk_two_area = $ActiveChunkTwo/ActiveChunkTwoArea
onready var chunk_one = $ActiveChunkOne
onready var chunk_two = $ActiveChunkTwo

func _ready():
	add_to_group('minigames')
	Manager.minigame_name = 'race_tower'
	game_instructions = "Race to\nEscape the Lava!"
	game_time = 60
	$Cam.current = true
	$Lava.connect('body_entered',self,'_on_Lava_body_entered')
	
	yield(get_tree().create_timer(3),'timeout')
	chunk_one_area.connect('body_entered',self,'chunk_one_entered')
	chunk_two_area.connect('body_entered',self,'chunk_two_entered')
	

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

func chunk_one_entered(player):
	chunk_two_area.position.y -= 3896

func chunk_two_entered(player):
	chunk_one_area.position.y -= 3896