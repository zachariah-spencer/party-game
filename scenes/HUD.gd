extends Control

var current_game_time

onready var time_display = $TimeLeft

signal game_times_up

func _ready():
	Globals.HUD = self
	connect('game_times_up', get_parent(), '_on_game_times_up')

func _update_time_limit(current_game_node):
	current_game_time = current_game_node.GAME_TIME
	time_display.text = String(current_game_time)


func _on_Timer_timeout():
	current_game_time -= 1
	time_display.text = String(current_game_time)
