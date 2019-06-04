extends PlayersManager

func _ready():
	add_to_group('players')
	Globals.player_one = self
	register_player_inputs()
	register_collisions()

func _physics_process(delta):
	pass

func register_player_inputs():
	child = $Player
	child.move_left = 'player_one_move_left'
	child.move_right = 'player_one_move_right'
	child.move_jump = 'player_one_move_jump'
	child.move_down = 'player_one_move_down'
	child.attack_input = 'player_one_attack'

func register_collisions():

	#register player into his player-specific collision layer
	#this allows the game to differentiate which player is being hit at a given time
	child.set_collision_layer_bit(6, true)
	#make players fist ignore himself
	child.get_node('AttackArea').set_collision_mask_bit(6, false)

	#set all other players to be collideable with this player
	child.set_collision_mask_bit(7, true)
	child.set_collision_mask_bit(8, true)
	child.set_collision_mask_bit(9, true)


func _on_RespawnTimer_timeout():
	var instance_of_player = player_scene.instance()
	add_child(instance_of_player)
	register_player_inputs()
	register_collisions()
	_transform_player_position(instance_of_player)


func _transform_player_position(player_instance):
	var spawn_point : Node = select_spawn_point()
	var ragdoll_body_parts : Array = player_instance.get_node('StateMachine/Sprites').get_children().get_nodes_in_group('ragdolls')

	self.position = Vector2.ZERO
	player_instance.position = spawn_point.position
