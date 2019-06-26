extends Node2D

onready var area = $Area

export var launch_speed = 60

func _ready():
	area.connect('body_entered', self, 'on_body_entered')


func on_body_entered(body):
	var player = body as Player
	
	if player:
		player.velocity.y = -launch_speed * Globals.CELL_SIZE