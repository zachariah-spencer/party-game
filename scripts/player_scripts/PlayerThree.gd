extends PlayersManager

func _ready():
	add_to_group('players')
	Players.player_three = self
	Players._players.append(self)
	display_name = 'Player Three'
	start_button = 'player_three_start'
	b_button = 'player_three_b'
	player_number = '3'

