extends HUD

onready var time_display = $TimeLeft

func _ready():
	pass

func _on_Timer_timeout():
	if Manager.current_game_time != 0:
		Manager.current_game_time -= 1
		time_display.text = String(Manager.current_game_time)
	elif Manager.current_game_time == 0:
		emit_signal('game_times_up')
