extends Position2D

func _physics_process(delta):
	if Manager.current_minigame.game_active && position.x < 3450:
		position.x += 0.5