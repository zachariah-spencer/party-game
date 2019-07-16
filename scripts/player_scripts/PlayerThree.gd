extends PlayersManager

func _ready():
	add_to_group('players')
	Players.player_three = self
	Players._players.append(self)
	display_name = 'Player Three'
	player_number = '3'
	controller_index = 2
	register_player_inputs()
