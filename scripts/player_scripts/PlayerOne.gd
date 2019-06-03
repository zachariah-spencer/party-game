extends Node2D

onready var child : Node = $Player

func _ready():
	add_to_group('players')
	Globals.player_one = self
	child.move_left = 'player_one_move_left'
	child.move_right = 'player_one_move_right'
	child.move_jump = 'player_one_move_jump'
	child.move_down = 'player_one_move_down'