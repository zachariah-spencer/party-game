extends PlayersManager

func _ready():
	add_to_group('players')
	Players.player_four = self
	Players._players.append(self)
	display_name = 'Player Four'
	player_number = '4'
