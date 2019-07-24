extends Minigame

onready var trapper_spawn := map.get_node('TrapperSpawn')
var trapper : PlayersManager
var runners := []
var completed_level := 0

func _init():
	maps = [
	preload('res://scenes/minigames/mg_mirrored_paths/maps/Any_MirroredPathsMap1.tscn'),
	]

func _ready():
	Manager.minigame_name = 'mirrored_paths'
	game_instructions = 'MIRRORED PATHS TEST'

func _insert_players():
	._insert_players()
	var player_array = Players._update_active_players()
	player_array.shuffle()
	trapper = player_array[0]
	trapper.spawn(trapper_spawn.position)
#	trapper.child.invincible = true

	for player in Players._get_alive_players() :
		if player != trapper :
			runners.append(player)
	print(runners)

func _run_minigame_loop():
	if game_active:
		_check_special_win_conditions()
#		_check_is_on_screen()

#func _check_is_on_screen():
#	for player in Players._get_alive_players():
#		if player != trapper:
#			if !player.child.visible_onscreen.is_on_screen():
#				player.child.hit(self, 100, Vector2.ZERO, Damage.ENVIRONMENTAL)

func _on_level_completed():
	completed_level += 1

func _check_special_win_conditions():
	if Players._get_alive_players().size() == 1 || game_time == 0:
		_special_game_over('trapper')
	elif completed_level == (Players._get_alive_players().size() - 1):
		_special_game_over('runners')

func _special_game_over(winning_team : String):
	game_over = true
	game_active = false
	if winning_team == 'trapper':
		print('trapper won')
		trapper.score += 1
		hud.instructions.text = trapper.display_name + ' Won!'
		hud._update_scores()
	elif winning_team == 'runners':
		print('runners won')
		hud.instructions.text = 'Winners:\n'
		for player in runners:
			player.score += 1
			hud.instructions.text = hud.instructions.text + player.display_name + '\n'
		hud._update_scores()