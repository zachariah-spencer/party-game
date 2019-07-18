extends Minigame

func _init():
	maps = [
	preload('res://scenes/minigames/mg_traps/maps/Any_TrapsMap1.tscn'),
	]

func _ready():
	Manager.minigame_name = 'traps'
	game_instructions = 'Trapper: Kill the other players!\nRunners: Make it to the end!'