extends Minigame

var ordered_players : Array = Players._update_active_players()

func _ready():
	Manager.minigame_name = 'winning_cutscene'
	
	yield(get_tree().create_timer(.1),'timeout')
	for player in Players._update_active_players():
		player.child.remove_from_group('focus')
		player.child.can_jump = false

func _on_begin_game():
	._on_begin_game()
	for player in Players._update_active_players():
		player.child.disable_jumping = true
		player.child.disable_movement = true

func _physics_process(delta):
	_run_minigame_loop()

func _run_minigame_loop():

	if game_active:
		_check_game_win_conditions()

func _insert_players():
	_order_players()
	
	var i := 0
	for player in Players.active_players :
		player.spawn(spawn_points[i].position)
		i += 1

func _order_players():
	ordered_players.sort_custom(Score_Sort, 'sort_by_score')
	
	for player in ordered_players:
		print(player.name + ' ' + String(player.score))