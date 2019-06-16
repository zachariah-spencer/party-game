extends Node

class_name Minigame

enum attack_modes {non_lethal, lethal}

export var game_time : int
export var game_instructions : String
export(attack_modes) var attack_mode = attack_modes.non_lethal
export var allow_respawns : bool = false
export var instant_player_insertion : bool = false
export var readyable : bool = false
export var has_timer : bool = true
export var has_countdown : bool = true
var game_active : bool = false
var game_over : bool = false
var minigame_timer : Timer
var spawn_points : Array

onready var hud : Node = $CanvasLayer/HUD

signal game_times_up

func _ready():
	Manager.current_minigame = self

	spawn_points = $SpawnPoints.get_children()
	spawn_points.shuffle()

	minigame_timer = Timer.new()
	minigame_timer.connect('timeout', self, '_handle_minigame_time')
	add_child(minigame_timer)
	minigame_timer.set_autostart(true)
	minigame_timer.set_one_shot(false)
	minigame_timer.start(1)

	call_deferred('_insert_players')
	call_deferred('_pregame')

	connect('game_times_up', Manager, '_on_game_times_up')

func _insert_players():
	Players._update_active_players()
	for player in Players.active_players :
		player.spawn(spawn_points[int(player.player_number)-1].position)

func _pregame(has_countdown : bool = true):
	#if game has a countdown
	if Manager.minigame_name != 'lobby':
		if has_countdown:
			Players._update_active_players()
			for player in Players.active_players:
				player.child.set_state(player.child.states.disabled)

			yield(Globals.HUD,'begin_game')

			Players._update_active_players()
			for player in Players.active_players:
				player.child.set_state(player.child.states.idle)

			game_active = true
		else:
		#if game has no countdown then don't disable players (WIP)
			yield(Globals.HUD,'begin_game')
			game_active = true
	else:
		game_active = true

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
