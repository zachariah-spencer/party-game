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
	game_instructions = 'MIRRORED PATHS TEST'

func _insert_players():
	._insert_players()
	
	var j := 0
	if Players.active_players.size() == 2:
		for player in Players.active_players:
			player.spawn(spawns_unshuffled[j].position)
			j += 2

func _run_minigame_loop():
	if game_active:
		_check_game_win_conditions()