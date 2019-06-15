extends PlayersManager

func _ready():
	add_to_group('players')
	Players.player_three = self
	Players._players.append(self)
	display_name = 'Player Three'
	start_button = 'player_three_start'
	b_button = 'player_three_b'
	player_number = '3'

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
