extends Node2D

onready var child : Node = $Player

func _ready():
	add_to_group('players')
	Globals.player_two = self
	child.move_left = 'player_two_move_left'
	child.move_right = 'player_two_move_right'
	child.move_jump = 'player_two_move_jump'
	child.move_down = 'player_two_move_down'