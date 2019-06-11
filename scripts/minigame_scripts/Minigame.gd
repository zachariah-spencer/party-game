extends Node

class_name Minigame

export var game_time : int
export var game_instructions : String
export var attack_mode : String = 'nonlethal'
export var allow_respawns : bool = false
export var instant_player_insertion : bool = false
export var readyable : bool = false
export var has_timer : bool = true
export var has_countdown : bool = true
var game_active : bool = false
var game_over : bool = false
var minigame_timer : Timer

onready var hud : Node = $CanvasLayer/HUD

signal game_times_up

func _ready():
	Manager.current_minigame = self
	
	minigame_timer = Timer.new()
	minigame_timer.connect('timeout', self, '_handle_minigame_time')
	add_child(minigame_timer)
	minigame_timer.set_autostart(true)
	minigame_timer.set_one_shot(false)
	minigame_timer.start(1)
	
	connect('game_times_up', Manager, '_on_game_times_up')

func _insert_players():
	Manager._randomize_spawn_positions()
	Manager._randomize_spawn_positions()
	Players._update_active_players()
	var i := 0
	var spawn_points : Array = get_tree().get_nodes_in_group('spawnpoints')[0].get_children()
	for player in Players.active_players :
		Players.spawn(player, spawn_points[Manager.player_spawns[i]].position)
		i += 1

func _pregame_timer():
	pass

func _run_minigame_loop():
	pass

func _check_game_win_conditions():
	if Players._get_alive_players().size() == 1:
		_game_won()
	elif Players._get_alive_players().size() == 0 || game_time == 0:
		_game_won(true)

func _game_won(no_winner = false):
	pass

func _end_game():
	#stop the minigame timer
	minigame_timer.stop()
	#wait 3 seconds
	yield(get_tree().create_timer(3), 'timeout')
	
	#PUT STUFF TO DO DURING THE WAITING PERIOD AT THE END OF A MINIGAME HERE
	
	#Tell GSM to transition minigames
	emit_signal('game_times_up')

func _handle_minigame_time():
	#a wip for moving time handling out of the HUD and into the GSM.
	if game_active:
	#if game is active then count time down
		if game_time > 0:
			game_time -= 1
	elif !game_active && game_over:
		#if game_won is then call the end game function
		_end_game()