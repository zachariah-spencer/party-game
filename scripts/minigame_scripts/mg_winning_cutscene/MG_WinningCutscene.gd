extends Minigame

var going_to_lobby := false
var ordered_players : Array = Players._update_active_players()
var can_return := false

onready var cutscene_over_timer := $CutsceneOverTimer
onready var ordered_spawns : Array = $WinningCutsceneMap/SpawnPoints.get_children()

func _ready():
	Manager.minigame_name = 'winning_cutscene'
	game_instructions = 'Press 1 to\ngo back!'
	
	Globals.HUD.instructions.text = game_instructions
	
	yield(get_tree().create_timer(.05),'timeout')
	for player in Players._update_active_players():
		player.child.remove_from_group('focus')
		player.child.disable_jumping = true
		player.child.disable_movement = true

func _insert_players():
	ordered_players.sort_custom(ScoringSort, 'sort')
	
	var i := 0
	for player in ordered_players :
		player.spawn(ordered_spawns[i].position)
		i += 1

class ScoringSort:
	static func sort(a, b):
		if a.score < b.score:
			return a < b
		return b < a

func _on_CutsceneOverTimer_timeout():
	can_return = true

func _input(event):
	if can_return:
		if event.is_action_pressed('player_one_start'):
			Players.reset_players_data()
			Manager._start_new_minigame(Manager.GAMES[0])
