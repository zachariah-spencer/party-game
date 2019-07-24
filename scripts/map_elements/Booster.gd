extends Node2D

onready var area = $Area
onready var particles := $Particles2D
onready var boost_sfx := $Boost
export var launch_speed = 60
export var active := true

func _ready():
	area.connect('body_entered', self, 'on_body_entered')

func _physics_process(delta):
	if active:
		particles.process_material.gravity = Vector3(0,-180000,0)
		particles.process_material.emission_sphere_radius = 1400
		particles.modulate.a = 1
	else:
		particles.process_material.gravity = Vector3(0,-80000,0)
		particles.process_material.emission_sphere_radius = 400
		particles.modulate.a = .08

func on_body_entered(body):
	if active:
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

func _invert_state():
	active = !active
