extends Node

class_name HUD

signal game_times_up

func _ready():
	Globals.current_HUD = self
	
	#warning-ignore:return_value_discarded
	connect('game_times_up', Manager, '_on_game_times_up')