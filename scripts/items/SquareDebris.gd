extends Item

onready var image := $ColorRect


func _ready():
	bounce = .5
	var rand_color = rand_range(0.2,0.7)
	var rand_scale = rand_range(1,2)
	image.color = Color(rand_color,rand_color,rand_color, 1)
	scale = Vector2(rand_scale, rand_scale)