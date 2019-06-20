extends PopupMenu

func _ready():
	for game in Manager.GAMES :
		var g = game.instance()
		add_item(g.visible_name)

func _input(event):
	if event.is_action_pressed("debug") :
		if not visible :
			popup()
		else :
			hide()


func _on_Debug_menu_id_pressed(ID):
	Manager._start_new_minigame(Manager.GAMES[ID])