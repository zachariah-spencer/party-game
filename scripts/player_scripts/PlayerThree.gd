extends PlayersManager

func _ready():
	add_to_group('players')
	Players.player_three = self
	Players._players.append(self)
	display_name = 'Player Three'

func register_player_inputs():
	child.move_left = 'player_three_move_left'
	child.move_right = 'player_three_move_right'
	child.move_jump = 'player_three_move_jump'
	child.move_down = 'player_three_move_down'
	child.attack_input = 'player_three_attack'

func register_collisions():

	#register player into his player-specific collision layer
	#this allows the game to differentiate which player is being hit at a given time
	child.set_collision_layer_bit(8, true)
	#make players fist ignore himself
	child.left_hand.get_node("Hitbox").set_collision_mask_bit(8, false)
	child.right_hand.get_node("Hitbox").set_collision_mask_bit(8, false)
	child.get_node('TopOfHeadArea').set_collision_mask_bit(8, false)

	#set all other players to be collideable with this player
	child.set_collision_mask_bit(6, true)
	child.set_collision_mask_bit(7, true)
	child.set_collision_mask_bit(9, true)