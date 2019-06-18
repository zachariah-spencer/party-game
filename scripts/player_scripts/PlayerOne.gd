extends PlayersManager

func _ready():
	add_to_group('players')
	Players.player_one = self
	Players._players.append(self)
	display_name = 'Player One'
	start_button = 'player_one_start'
	b_button = 'player_one_b'
	player_number = '1'
