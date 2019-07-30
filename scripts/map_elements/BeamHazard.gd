extends Hazard

var Laser = preload("res://scenes/map_elements/Laser.tscn")
export var beam_duration := .7
export var beam_delay := 1.25
export var beam_width_scale := 1

func _ready():
	$Base.modulate = outline_color

func activate():
	var laser = Laser.instance()
	laser.duration = beam_duration
	laser.delay = beam_delay
	laser.position.y += 10
	laser.direction = Vector2.UP
	laser.ray_mask -= Globals.PLATFORM_BIT
	add_child(laser)

