extends Control

onready var time_display = $TimeLeft

signal game_times_up

func _ready():
	Globals.HUD = self
	
	#warning-ignore:return_value_discarded
	connect('game_times_up', Manager, '_on_game_times_up')

func _on_Timer_timeout():
	if Manager.current_game_time != 0:
		Manager.current_game_time -= 1
		time_display.text = String(Manager.current_game_time)
	elif Manager.current_game_time == 0:
		emit_signal('game_times_up')
