extends Node

class_name Minigame

const PLAY_AREA_WIDTH : int = 1536
const PLAY_AREA_HEIGHT : int = 896
var is_game_won : bool = false
var game_active : bool = false
var game_instructions : String
var has_timer : bool = true
var game_over : bool = false
var minigame_timer : Timer
onready var hud : Node = $CanvasLayer/HUD

signal game_times_up

func _run_minigame_loop():
	pass

func _insert_players():
	Manager._randomize_spawn_positions()
	Manager._randomize_spawn_positions()
	var i := 0
	var spawn_points : Array = get_tree().get_nodes_in_group('spawnpoints')[0].get_children()
	for player in Players.active_players :
		Players.spawn(player, spawn_points[Manager.player_spawns[i]].position)
		i += 1
#	var x : int = 0
#
#	while x < Players._get_active_players().size():
#		Players.spawn(Players._get_active_players()[x], spawn_points.get_children()[Manager.player_spawns[x]].position)
#		x += 1

func _check_game_win_conditions():
	if Players._get_alive_players().size() == 1:
		_game_won()
	elif Players._get_alive_players().size() == 0 || Manager.current_game_time == -1:
		_game_won(true)

func _game_won(no_winner = false):
	pass

func _pregame_timer():
	pass

func _ready():
	minigame_timer = Timer.new()
	minigame_timer.connect('timeout', self, '_handle_minigame_time')
	add_child(minigame_timer)
	minigame_timer.set_autostart(true)
	minigame_timer.set_one_shot(false)
	minigame_timer.start(1)
	
	connect('game_times_up', Manager, '_on_game_times_up')

func _handle_minigame_time():
	#a wip for moving time handling out of the HUD and into the GSM.
	if game_active:
	#if game is active then count time down
		if Manager.current_game_time != -1:
			Manager.current_game_time -= 1
	elif !game_active && game_over:
		#if game_won is then call the end game function
		_end_game()
	
func _end_game():
	#stop the minigame timer
	minigame_timer.stop()
	#wait 3 seconds
	yield(get_tree().create_timer(3), 'timeout')
	
	#PUT STUFF TO DO DURING THE WAITING PERIOD AT THE END OF A MINIGAME HERE
	
	#Tell GSM to transition minigames
	emit_signal('game_times_up')