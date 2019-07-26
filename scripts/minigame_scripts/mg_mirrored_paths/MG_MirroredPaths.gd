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
	
	var j := 0
	if Players.active_players.size() == 2:
		for player in Players.active_players:
			player.spawn(spawns_unshuffled[j].position)
			j += 2
	
	for point in spawn_index.keys():
		if [spawns_unshuffled[0], spawns_unshuffled[1]].has(point):
			top_players.append(spawn_index[point])
		elif [spawns_unshuffled[2], spawns_unshuffled[3]].has(point):
			bottom_players.append(spawn_index[point])
	
	for p in top_players:
		print(p.name)
	

func _run_minigame_loop():
	if game_active:
		_check_game_win_conditions()