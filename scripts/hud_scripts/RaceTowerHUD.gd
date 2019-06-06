extends HUD

#DEV NOTE: needs to go inside camera

func _ready():
	pass

func _physics_process(delta):
	pass
	#set so that the hud centers on the Y position of the camera's center


func _on_Timer_timeout():
	_every_second()