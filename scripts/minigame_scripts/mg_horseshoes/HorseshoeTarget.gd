extends Node2D

onready var area_shape = $Area/Shape
onready var item_spawn_pos = $Area/Position
onready var sprite = $Sprite
var stack : Array = []
var time := PI/2


func _physics_process(delta):
	time += delta
	position.x += sin(time)*.2