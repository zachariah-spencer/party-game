extends Area2D

func _ready():
	connect('body_entered',self,'on_body_entered')
	connect('body_exited',self,'on_body_exited')

func on_body_entered(body):
	var player = body as Player

	if player:
		player._set_gravity(Vector2.UP)

func on_body_exited(body):
	var player = body as Player

	if player:
		player._set_gravity(Vector2.DOWN)