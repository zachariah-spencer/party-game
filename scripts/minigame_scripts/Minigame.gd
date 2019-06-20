extends Node

class_name Minigame

enum attack_modes {non_lethal, lethal}
enum win_conditions {timeout, last_alive_allow_no_winners, lobby_readied, highest_local_score}

export var game_time : int
export var game_instructions : String
export(attack_modes) var attack_mode = attack_modes.non_lethal
export(win_conditions) var win_condition = win_conditions.timeout
export var allow_respawns : bool = false
export var instant_player_insertion : bool = false
export var readyable : bool = false
export var has_timer : bool = true
export var has_countdown : bool = true
export var visible_name := ''
export var has_local_score := false
onready var camera = get_node("Cam")
var game_active : bool = false
var game_over : bool = false
var minigame_timer : Timer
var spawn_points : Array
onready var map = get_tree().get_nodes_in_group('maps')[0]

onready var hud : Node = $CanvasLayer/HUD

signal game_times_up

func _ready():
	Manager.current_minigame = self
	spawn_points = map.get_node('SpawnPoints').get_children()
#	elif Manager.minigame_name == 'lobby':
#		spawn_points = $SpawnPoints.get_children()
	spawn_points.shuffle()
	camera.current = true
	minigame_timer = Timer.new()
	minigame_timer.connect('timeout', self, '_handle_minigame_time')
	add_child(minigame_timer)
	minigame_timer.set_autostart(true)
	minigame_timer.set_one_shot(false)
	minigame_timer.start(1)
	
	call_deferred('_insert_players')
	call_deferred('_pregame')

	connect('game_times_up', Manager, '_on_game_times_up')

func _physics_process(delta):
	_handle_local_scoring()

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
				player.child._set_state(player.child.states.disabled)

			yield(Globals.HUD,'begin_game')

			Players._update_active_players()
			for player in Players.active_players:
				player.child._set_state(player.child.states.idle)

			game_active = true
		else:
		#if game has no countdown then don't disable players (WIP)
			yield(Globals.HUD,'begin_game')
			game_active = true
	else:
		game_active = true

func _run_minigame_loop():
	pass

#func _check_game_win_conditions():
#	if Players._get_alive_players().size() == 1:
#		_game_won()
#	elif Players._get_alive_players().size() == 0 || game_time == 0:
#		_game_won(true)

func _check_game_win_conditions():
	match win_condition:
		win_conditions.timeout:
			if game_time == 0 || Players._get_alive_players().size() == 1:
				if Players._get_alive_players().size() > 1:
					_game_won(false,true)
				else:
					_game_won()
			elif Players._get_alive_players().size() == 0:
				_game_won(true)


		win_conditions.last_alive_allow_no_winners:
			if Players._get_alive_players().size() == 1:
				_game_won()
			elif Players._get_alive_players().size() == 0 || game_time == 0:
				_game_won(true)
		
		win_conditions.highest_local_score:
			if game_time == 0:
				_game_won()



func _game_won(no_winner = false, multi_winner = false):
	match win_condition:
		win_conditions.timeout:
			game_over = true
			game_active = false
			if Players._get_alive_players() == Players._update_active_players():
				for player in Players._get_alive_players():
					player.score += 1
				$CanvasLayer/HUD._update_scores()
				$CanvasLayer/HUD/TimeLeft/Instructions.text = 'Everybody won!'
			elif !no_winner && multi_winner:
				for player in Players._get_alive_players():
					player.score += 1
				$CanvasLayer/HUD._update_scores()
				$CanvasLayer/HUD/TimeLeft/Instructions.text = 'Winners:\n'
				for player in Players._get_alive_players():
					$CanvasLayer/HUD/TimeLeft/Instructions.text = $CanvasLayer/HUD/TimeLeft/Instructions.text +  player.display_name + '\n'
			elif !no_winner && !multi_winner:
				Players._get_alive_players()[0].score += 1
				$CanvasLayer/HUD._update_scores()
				$CanvasLayer/HUD/TimeLeft/Instructions.text = Players._get_alive_players()[0].display_name + ' Won!'
			else:
				$CanvasLayer/HUD/TimeLeft/Instructions.text = 'Nobody won!'
		win_conditions.last_alive_allow_no_winners:
			game_over = true
			game_active = false
			if !no_winner:
				Players._get_alive_players()[0].score += 1
				$CanvasLayer/HUD._update_scores()
				$CanvasLayer/HUD/TimeLeft/Instructions.text = Players._get_alive_players()[0].display_name + ' Won!'
			else:
				$CanvasLayer/HUD/TimeLeft/Instructions.text = 'Nobody Won!'
		win_conditions.lobby_readied:
			game_over = true
			Globals.HUD._update_hud()
			Manager._on_game_times_up()
		win_conditions.highest_local_score:
			game_over = true
			game_active = false
			
			var winning_player : PlayersManager = null
			var winning_players : Array = []
			var highest_score := 0
			for player in Players._update_active_players():
				if player.local_score > highest_score:
					highest_score = player.local_score
					winning_player = player
				elif player.local_score == highest_score:
					if !winning_players.has(winning_player):
						winning_players.append(winning_player)
					if !winning_players.has(player):
						winning_players.append(player)
			if highest_score != 0:
				if winning_players.size() > 1:
					$CanvasLayer/HUD/TimeLeft/Instructions.text = 'Its a tie!\nWinners:\n'
					for player in winning_players:
						player.score += 1
						$CanvasLayer/HUD/TimeLeft/Instructions.text = $CanvasLayer/HUD/TimeLeft/Instructions.text +  player.display_name + '\n'
						$CanvasLayer/HUD._update_scores()
						
				else:
					winning_player.score += 1
					$CanvasLayer/HUD._update_scores()
					$CanvasLayer/HUD/TimeLeft/Instructions.text = winning_player.display_name + ' Won!'
			else:
				$CanvasLayer/HUD/TimeLeft/Instructions.text = 'Nobody Won!'

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

func _handle_local_scoring():
	for player in Players._update_active_players():
		if !player.dead:
			player.child.local_score.visible = true if has_local_score else false
			player.child.local_score.text = String(player.local_score)
		if !game_active && !game_over:
			player.local_score = 0

func _increase_local_score(player : PlayersManager, amount := 0):
	player.local_score += amount

func _decrease_local_score(player : PlayersManager, amount := 0):
	player.local_score -= amount