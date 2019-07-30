extends Minigame

export var damage_multiplier := 5.0
var total_owned_flags := 0.0
var countdown_time := 5
onready var flags_array := map.get_node('Flags').get_children()
onready var countdown_timer := $CountdownTimer
onready var countdown_label := $CanvasLayer/Countdown/CountdownLabel

func _init():
	maps = [
	preload('res://scenes/minigames/mg_territories/maps/4_TerritoriesMap1.tscn'),
	preload('res://scenes/minigames/mg_territories/maps/3_TerritoriesMap2.tscn'),
	preload('res://scenes/minigames/mg_territories/maps/2_TerritoriesMap3.tscn'),
	preload('res://scenes/minigames/mg_territories/maps/Any_TerritoriesMap4.tscn'),
	preload('res://scenes/minigames/mg_territories/maps/Any_TerritoriesMap5.tscn')
	]

func _ready():
	add_to_group('minigames')
	Manager.minigame_name = 'territories'

	for flag in flags_array:
		if flag.owned_by:
			total_owned_flags += 1

func _on_begin_game():
	._on_begin_game()
	countdown_timer.start()
	countdown_label.text = String(countdown_time)

func _physics_process(delta):
	_run_minigame_loop()

func _run_minigame_loop():

	if game_active:
		_check_game_win_conditions()

func _end_game():
	._end_game()
	countdown_timer.stop()

func _on_CountdownTimer_timeout():

	if countdown_time > 1:
		countdown_time -= 1
		countdown_label.text = String(countdown_time)
	else:
		#Damage players
		#Damage players
		var most_flags_player : PlayersManager
		var most_flags := 0
		for p in Players._get_alive_players():
			var flags_owned := 0
			
			for flag in flags_array:
				if p == flag.owned_by:
					flags_owned += 1
			
			if flags_owned > most_flags:
				most_flags_player = p
				most_flags = flags_owned
			elif flags_owned == most_flags:
				most_flags_player = null
		
		for p in Players._get_alive_players():
			if p != most_flags_player:
				p.child.hit(self, int(1), Vector2(0, 500), Damage.ENVIRONMENTAL)
		
		countdown_time = 5
		countdown_label.text = String(countdown_time)
