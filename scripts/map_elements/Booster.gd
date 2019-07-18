extends Node2D

onready var area = $Area
onready var boost_sfx := $Boost

export var launch_speed = 60

func _ready():
	area.connect('body_entered', self, 'on_body_entered')


func on_body_entered(body):
	var player = body as Player
	var item = body as Item

	if player:
		player.velocity.y = -launch_speed * Globals.CELL_SIZE
		boost_sfx.pitch_scale = 1.5
		boost_sfx.play()
	if item:
		boost_sfx.pitch_scale = 3
		boost_sfx.play()
		item.apply_central_impulse(Vector2(0,-launch_speed * Globals.CELL_SIZE))