extends PlayersManager

func _ready():
	add_to_group('players')
	Players.player_two = self
	Players._players.append(self)
	display_name = 'Player Two'
	player_number = '2'
	controller_index = 1
	register_player_inputs()
