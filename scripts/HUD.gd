extends Control

var current_game_time

onready var time_display = $TimeLeft

signal game_times_up

func _ready():
	Globals.HUD = self
	connect('game_times_up', get_parent(), '_on_game_times_up')

func _on_Timer_timeout():
	Manager.current_game_time -= 1
	time_display.text = String(Manager.current_game_time)
