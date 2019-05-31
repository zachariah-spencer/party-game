extends Minigame

const GAME_NAME = 'lobby'
const GAME_TIME = 60

onready var spawn_points = $SpawnPoints

func _ready():
	Manager.current_game_name = GAME_NAME
	Manager.current_game_reference = self
	Manager.current_game_time = GAME_TIME
	call_deferred('_insert_players')

func _insert_players():
	Manager._randomize_spawn_positions()
	
	for i in get_tree().get_nodes_in_group('players'):
		var x = 0
		if i != null:
			if i.is_inside_tree():
				i.position = spawn_points.get_child(Manager.player_spawns[x]).position
		x += 1