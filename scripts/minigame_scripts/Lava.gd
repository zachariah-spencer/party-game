extends Area2D

func _physics_process(delta):
	if get_parent().game_active:
		position.y -= 2