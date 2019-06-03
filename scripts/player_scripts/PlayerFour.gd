extends Node2D

onready var child : Node = $Player

func _ready():
	add_to_group('players')
	Globals.player_four = self
	child.move_left = 'player_four_move_left'
	child.move_right = 'player_four_move_right'
	child.move_jump = 'player_four_move_jump'
	child.move_down = 'player_four_move_down'