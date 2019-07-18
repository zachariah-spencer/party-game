extends Minigame

var countdown_time := 5
var new_countdown_time := 5
var cumulative_countdowns := 0
onready var countdown_timer := $CountdownTimer
onready var countdown_label := $CanvasLayer/Countdown/CountdownLabel
onready var barrage_one := get_tree().get_nodes_in_group('barrage_one')
onready var barrage_two := get_tree().get_nodes_in_group('barrage_two')
onready var barrage_three := get_tree().get_nodes_in_group('barrage_three')
onready var barrage_four := get_tree().get_nodes_in_group('barrage_four')
onready var barrage_five := get_tree().get_nodes_in_group('barrage_five')
onready var barrage_six := get_tree().get_nodes_in_group('barrage_six')

func _init():
	maps = [
	preload('res://scenes/minigames/mg_raining_explosives/maps/Any_RainingExplosivesMap1.tscn')
	]

func _ready():
	Manager.minigame_name = 'raining_explosives'

func _on_begin_game():
	._on_begin_game()
	countdown_timer.start()
	countdown_label.text = String(countdown_time)

func _physics_process(delta):
	_run_minigame_loop()

func _run_minigame_loop():
	._run_minigame_loop()

	if game_active:
		_check_game_win_conditions()

func _end_game():
	countdown_timer.stop()

func _on_CountdownTimer_timeout():

	if countdown_time > 1:
		countdown_time -= 1
		countdown_label.text = String(countdown_time)
	else:
		#on countdown timer out
		cumulative_countdowns += 1
		match cumulative_countdowns:
			2:
				new_countdown_time -= 1
			6:
				new_countdown_time -= 1
			12:
				new_countdown_time -= 1
			20:
				new_countdown_time -= 1
		
		var barrage_select := int(rand_range(1.0,6.99))
		#drop grenades
		match barrage_select:
			1:
				for spawner in barrage_one:
					spawner._spawn_item()
			2:
				for spawner in barrage_two:
					spawner._spawn_item()
			3:
				for spawner in barrage_three:
					spawner._spawn_item()
			4:
				for spawner in barrage_four:
					spawner._spawn_item()
			5:
				for spawner in barrage_five:
					spawner._spawn_item()
			6:
				for spawner in barrage_six:
					spawner._spawn_item()
		
		countdown_time = new_countdown_time
		countdown_label.text = String(countdown_time)