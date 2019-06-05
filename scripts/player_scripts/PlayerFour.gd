extends PlayersManager

func _ready():
	add_to_group('players')
	Globals.player_four = self
	display_name = 'Player Four'
	is_dead = false
	register_player_inputs()
	register_collisions()

func register_player_inputs():
	child = $Player
	child.move_left = 'player_four_move_left'
	child.move_right = 'player_four_move_right'
	child.move_jump = 'player_four_move_jump'
	child.move_down = 'player_four_move_down'
	child.attack_input = 'player_four_attack'

func register_collisions():

	#register player into his player-specific collision layer
	#this allows the game to differentiate which player is being hit at a given time
	child.set_collision_layer_bit(9, true)
	#make players fist ignore himself
	child.get_node('AttackArea').set_collision_mask_bit(9, false)

	#set all other players to be collideable with this player
	child.set_collision_mask_bit(6, true)
	child.set_collision_mask_bit(7, true)
	child.set_collision_mask_bit(8, true)

func _on_RespawnTimer_timeout():
	var instance_of_player = player_scene.instance()
	add_child(instance_of_player)
	register_player_inputs()
	register_collisions()

	var spawn_point : Node = select_spawn_point()
	self.position = Vector2.ZERO
	instance_of_player.position = spawn_point.position