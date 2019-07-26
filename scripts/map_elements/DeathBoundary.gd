extends Area2D

#These objects should only be placed as direct children of a Map 
#otherwise their signals won't properly connect

func _ready():
	connect("body_entered", self, 'on_out_of_bounds')

func on_out_of_bounds(body):
	if body is Player:
		body.hit(self, 3, Vector2.ZERO, Damage.ENVIRONMENTAL)