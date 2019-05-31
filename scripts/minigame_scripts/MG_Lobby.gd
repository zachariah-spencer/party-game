extends Minigame

const GAME_NAME : String = 'lobby'
const GAME_TIME : int = 60

onready var spawn_points : Node = $SpawnPoints

func _ready():
	Manager.current_game_name = GAME_NAME
	Manager.current_game_reference = self
	Manager.current_game_time = GAME_TIME
	call_deferred('_insert_players')

func _insert_players():
	Manager._randomize_spawn_positions()
	Manager._randomize_spawn_positions()
	
	var active_players : Array = get_tree().get_nodes_in_group('players')
	var x : int = 0
	while x < active_players.size():
			active_players[x].position = spawn_points.get_children()[Manager.player_spawns[x]].position
			x += 1