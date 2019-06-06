extends Node

class_name HUD

signal game_times_up

onready var time_display = $TimeLeft

func _ready():
	Globals.current_HUD = self
	
	#warning-ignore:return_value_discarded
	connect('game_times_up', Manager, '_on_game_times_up')


func _every_second():
	if !Manager.current_game_reference.is_game_won:
		if Manager.current_game_time != 0:
			Manager.current_game_time -= 1
			time_display.text = String(Manager.current_game_time)
		elif Manager.current_game_time == 0:
			emit_signal('game_times_up')
	else:
		time_display.text = '0'
		yield(get_tree().create_timer(3), 'timeout')
		emit_signal('game_times_up')