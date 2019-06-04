extends Minigame

const GAME_NAME : String = 'fighter'
const GAME_TIME : int = 15

func _ready():
	add_to_group('minigames')
	Manager.current_game_name = GAME_NAME
	Manager.current_game_reference = self
	Manager.current_game_time = GAME_TIME
	Manager.current_game_attack_mode = 'lethal'
	Manager.current_game_allow_respawns = true
	$Cam.current = true
	call_deferred('_insert_players')