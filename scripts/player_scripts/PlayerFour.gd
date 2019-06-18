extends PlayersManager

func _ready():
	add_to_group('players')
	Players.player_four = self
	Players._players.append(self)
	display_name = 'Player Four'
	start_button = 'player_four_start'
	b_button = 'player_four_b'
	player_number = '4'
