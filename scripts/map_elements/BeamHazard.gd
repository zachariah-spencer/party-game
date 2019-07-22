extends Hazard

var Laser = preload("res://scenes/map_elements/Laser.tscn")

func activate():
	var laser = Laser.instance()
	laser.position.y += 10
	laser.direction = Vector2.UP
	laser.ray_mask -= Globals.PLATFORM_BIT
	add_child(laser)

