extends PlayersManager

var test = false

func _ready():
	add_to_group('players')
	Players.player_one = self
	Players._players.append(self)
	display_name = 'Player One'
	player_number = '1'