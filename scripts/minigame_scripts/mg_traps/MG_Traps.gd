extends Minigame

onready var trapper_spawn := map.get_node('TrapperSpawn')
var trapper : PlayersManager
var runners := []
var completed_level := 0

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
	trapper = player_array[0]
	trapper.spawn(trapper_spawn.position)
	trapper.child.invincible = true
	
	for player in Players._get_alive_players() :
		if player != trapper :
			runners.append(player)

func _run_minigame_loop():
	if game_active:
		_check_special_win_conditions()

func _on_level_completed():
	completed_level += 1

func _check_special_win_conditions():
	if Players._get_alive_players().size() == 1 && Players._get_alive_players()[0] == trapper || game_time == 0:
		_special_game_over('trapper')
	elif completed_level == (Players._get_alive_players().size() - 1) :
		_special_game_over('runners')

func _special_game_over(winning_team : String):
	game_over = true
	game_active = false
	if winning_team == 'trapper':
		print('trapper won')
	elif winning_team == 'runners':
		print('runners won')