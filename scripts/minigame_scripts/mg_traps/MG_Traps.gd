extends Minigame

onready var trapper_spawn := map.get_node('TrapperSpawn')
var trapper : PlayersManager

func _init():
	maps = [
	preload('res://scenes/minigames/mg_traps/maps/Any_TrapsMap1.tscn'),
	]

func _ready():
	Manager.minigame_name = 'traps'
	game_instructions = 'Trapper: Kill the other players!\nRunners: Make it to the end!'
	

func _insert_players():
	._insert_players()
	var player_array = Players._update_active_players()
	player_array.shuffle()
	player_array[0].spawn(trapper_spawn.position)