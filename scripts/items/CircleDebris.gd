extends RigidBody2D

onready var image := $Sprite


func _ready():
	bounce = .5
	var rand_color = rand_range(0.2,0.7)
	var rand_scale = rand_range(1,2)
	image.modulate = Color(rand_color,rand_color,rand_color, 1)
	scale.x = rand_scale
	scale.y = rand_scale