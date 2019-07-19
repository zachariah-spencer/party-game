extends "res://scripts/items/Item.gd"

var Laser = preload("res://scenes/map_elements/Laser.tscn")
onready var fire_timer = Timer.new()
export var start_delay := 5
export var frequency := 5
export var directions = [ Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
export var size := 30

func _ready():
	add_child(fire_timer)
	fire_timer.connect("timeout", self, "_fire")
	fire_timer.start(start_delay)

func _fire():
	for dir in directions :
		var laser_add = Laser.instance()
		laser_add.direction = dir
		laser_add.position = dir * size
		add_child(laser_add)
		fire_timer.start(frequency)