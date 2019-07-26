extends Minigame

onready var top_spawn := map.get_node('Top')
onready var bottom_spawn := map.get_node('Bottom')
var top_players := []
var bottom_players := []


func _init():
	maps = [
	preload('res://scenes/minigames/mg_mirrored_paths/maps/any_mirroredpathsmap1/Any_MirroredPathsMap1.tscn'),
	]

func _ready():
	Manager.minigame_name = 'mirrored_paths'
	game_instructions = 'Work together to kill\nthe other path!'

func _insert_players():
	._insert_players()
	
	if Players.active_players.size() == 2:
		Players.active_players[0].spawn(map.spawn_one.position)
		Players.active_players[1].spawn(map.spawn_three.position)
	
	for p in Players.active_players:
		match p.position:
			map.spawn_one.position:
				top_players.append(p)
			map.spawn_two.position:
				top_players.append(p)
			map.spawn_three.position:
				bottom_players.append(p)
			map.spawn_four.position:
				bottom_players.append(p)

func _run_minigame_loop():
	if game_active:
		_check_empty_paths()
		_check_game_win_conditions()

func _check_empty_paths():
	for p in top_players:
		if p.dead == true:
			top_players.remove(top_players.find(p))
	
	for p in bottom_players:
		if p.dead == true:
			bottom_players.remove(bottom_players.find(p))
	
	if top_players.empty() && !map.top_empty:
		map.top_empty = true
		game_instructions = 'Now betray your friend!'
		hud._update_game_timer()
	if bottom_players.empty() && !map.bottom_empty:
		map.bottom_empty = true
		game_instructions = 'Now betray your friend!'
		hud._update_game_timer()