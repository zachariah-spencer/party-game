extends Minigame

const GAME_NAME : String = 'fighter'
const GAME_TIME : int = 60

func _ready():
	add_to_group('minigames')
	Manager.current_game_name = GAME_NAME
	Manager.current_game_reference = self
	Manager.current_game_time = GAME_TIME
	$Cam.current = true
	call_deferred('_insert_players')
	call_deferred('_set_hud_position')

func _set_hud_position():
	var hud_node : Node = get_tree().get_nodes_in_group('HUD')[0]
	var extents = $Area/Size.shape.extents

	hud_node.margin_right = (extents.x * 2)
	hud_node.margin_bottom = (extents.y * 2)