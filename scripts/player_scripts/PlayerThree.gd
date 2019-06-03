extends Node2D

onready var child : Node = $Player

func _ready():
	add_to_group('players')
	Globals.player_three = self
	child.move_left = 'player_three_move_left'
	child.move_right = 'player_three_move_right'
	child.move_jump = 'player_three_move_jump'
	child.move_down = 'player_three_move_down'
	child.attack_input = 'player_three_attack'
	register_collisions()

func register_collisions():
	
	#register player into his player-specific collision layer
	#this allows the game to differentiate which player is being hit at a given time
	child.set_collision_layer_bit(8, true)
	#make players fist ignore himself
	child.get_node('AttackArea').set_collision_mask_bit(8, false)
	
	#set all other players to be collideable with this player
	child.set_collision_mask_bit(6, true)
	child.set_collision_mask_bit(7, true)
	child.set_collision_mask_bit(9, true)