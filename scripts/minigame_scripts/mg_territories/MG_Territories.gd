extends Minigame

export var damage_multiplier := 5
var total_owned_flags := 0
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
	print(total_owned_flags)

func _on_begin_game():
	._on_begin_game()
	countdown_timer.start()
	countdown_label.text = String(countdown_time)

func _physics_process(delta):
	_run_minigame_loop()

func _run_minigame_loop():
	
	if game_active:
		_check_game_win_conditions()

func _on_CountdownTimer_timeout():
	
	if countdown_time > 1:
		countdown_time -= 1
		countdown_label.text = String(countdown_time)
	else:
		#Damage players
		
		for player in Players._get_alive_players():
			var flags_owned := 0
			var damage := 0
			
			for flag in flags_array:
				if flag.owned_by == player:
					flags_owned += 1
			
			if flags_owned != 0:
				damage = ( total_owned_flags / flags_owned ) * damage_multiplier
			else:
				damage = 100
			
			player.child.hit(self, damage, Vector2(0,-50), true)
		
		
		countdown_time = 5
		countdown_label.text = String(countdown_time)
