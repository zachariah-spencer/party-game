extends Position2D

var scroll_speed := .7
export var scroll_accel := .0
export var end_pos := 3450

func _physics_process(delta):
	var far_players = 0
	for body in $FasterScrollArea.get_overlapping_bodies() :
		if body is Player : far_players += 1
	
	scroll_speed += scroll_accel * delta
	
	if Manager.current_minigame.game_active && position.x < end_pos:
		if far_players == 0 :
			position.x += scroll_speed * .8
		elif far_players == 1 :
			position.x +=  scroll_speed * 1.2
		else :
			position.x += scroll_speed * 1.8