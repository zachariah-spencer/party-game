extends Node2D

func _ready():
	add_to_group('players')
	Globals.player_three = self