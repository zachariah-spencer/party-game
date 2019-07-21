extends Minigame

signal gravity_flopped

func _ready():
	Manager.minigame_name = 'lethal_gravity'
	game_instructions = "Force other players \n to their death!"

