extends PlayersManager

func _ready():
	active = true
	add_to_group('players')
	Players.player_one = self
	Players._players.append(self)
	display_name = 'Player One'
	start_button = 'player_one_start'
	b_button = 'player_one_b'
	player_number = '1'

func register_player_inputs():
	child.move_left = 'player_one_move_left'
	child.move_right = 'player_one_move_right'
	child.move_jump = 'player_one_move_jump'
	child.move_up = 'player_one_move_up'
	child.move_down = 'player_one_move_down'
	child.attack_input = 'player_one_attack'

func register_collisions():

#	register player into his player-specific collision layer
#	this allows the game to differentiate which player is being hit at a given time
	child.set_collision_layer_bit(6, true)
#	make players fist ignore himself
	child.left_hand.get_node("Hitbox").set_collision_mask_bit(6, false)
	child.right_hand.get_node("Hitbox").set_collision_mask_bit(6, false)
	child.get_node('TopOfHeadArea').set_collision_mask_bit(6, false)


	#set all other players to be collideable with this player
	child.set_collision_mask_bit(7, true)
	child.set_collision_mask_bit(8, true)
	child.set_collision_mask_bit(9, true)