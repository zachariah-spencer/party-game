extends Minigame

var countdown_time := 5
var new_countdown_time := 5
var cumulative_countdowns := 0
onready var countdown_timer := $CountdownTimer
onready var countdown_label := $CanvasLayer/Countdown/CountdownLabel

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
		
		#drop grenades
		
		
		countdown_time = new_countdown_time
		countdown_label.text = String(countdown_time)