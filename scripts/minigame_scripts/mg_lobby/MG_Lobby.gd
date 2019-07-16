extends Minigame

onready var round_settings := $LobbyMap/RoundSettingApparatus

var player_one_ready : bool = false
var player_two_ready : bool = false
var player_three_ready : bool = false
var player_four_ready : bool = false
var is_starting : bool = false
var is_readyable := true
var num_of_ready_ups = 0

onready var ambience_sfx := $AmbienceSFX
onready var fade_tween := $Tween

func _ready():
	add_to_group('minigames')
	Manager.minigame_name = 'lobby'
	game_instructions = "Press '1'\nto ready up!"
	game_time = 999999999999999999999
	has_countdown = false
	has_timer = false
	readyable = true
	win_condition = win_conditions.lobby_readied
	instant_player_insertion = true
	
	fade_tween.interpolate_property(ambience_sfx, 'volume_db', -100, -12, 3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	fade_tween.start()
	
	ambience_sfx.play()
	

	Globals.HUD.get_node('Scorecards/Statuses/P1Ready').text = 'Not Ready'
	Globals.HUD.get_node('Scorecards/Statuses/P2Ready').text = 'Not Ready'
	Globals.HUD.get_node('Scorecards/Statuses/P3Ready').text = 'Not Ready'
	Globals.HUD.get_node('Scorecards/Statuses/P4Ready').text = 'Not Ready'




func _physics_process(delta):
	print(ambience_sfx.volume_db)
	_check_ready_ups()

func _check_ready_ups():
	Players._update_active_players()

	var active = 0
	var ready = 0

	for player in Players.active_players :
		var readying = Globals.HUD.get_node("Scorecards/Statuses/P" + player.player_number + "Ready")
		active += 1
		if player.ready :
			ready += 1
			readying.text = "Ready "
		else :
			readying.text = "Not Ready"

	if active >= 2 && active == ready:
		if !is_starting:
			Manager.rounds_played = 0
			Manager.rounds_to_play = round_settings.num_rounds
			_game_won(true)
			
			fade_tween.interpolate_property(ambience_sfx, 'volume_db', -12, -100, 2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			fade_tween.start()
			
			is_starting = true