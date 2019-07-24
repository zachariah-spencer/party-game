extends Position2D

var scroll_speed := .7

func _physics_process(delta):
	var far_players = 0
	for body in $FasterScrollArea.get_overlapping_bodies() :
		if body is Player : far_players += 1


	if Manager.current_minigame.game_active && position.x < 3450:
		if far_players == 0 :
			position.x += scroll_speed
		elif far_players == 1 :
			position.x +=  scroll_speed * 1.5
		else :
			position.x += scroll_speed * 2