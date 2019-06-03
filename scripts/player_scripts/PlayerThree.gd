extends Node2D

onready var child : Node = $Player

func _ready():
	add_to_group('players')
	Globals.player_three = self
	child.move_left = 'player_three_move_left'
	child.move_right = 'player_three_move_right'
	child.move_jump = 'player_three_move_jump'
	child.move_down = 'player_three_move_down'