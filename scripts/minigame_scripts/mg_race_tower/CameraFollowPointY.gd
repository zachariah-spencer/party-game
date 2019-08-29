extends Position2D

var scroll_speed := .7
export var scroll_accel := .0

func _physics_process(delta):
	var far_players = 0
	for body in $FasterScrollArea.get_overlapping_bodies() :
		if body is Player : far_players += 1
	
	scroll_speed += scroll_accel * delta
	
	if Manager.current_minigame.game_active:
		if far_players == 0 :
			position.y -= scroll_speed * .8
		elif far_players == 1 :
			position.y -=  scroll_speed * 1
		else :
			position.y -= scroll_speed * 1.5