extends "res://scripts/items/Item.gd"

var Laser = preload("res://scenes/map_elements/Laser.tscn")
onready var fire_timer = Timer.new()
onready var impulse_timer := $ImpulseTimer
export var start_delay := 5
export var frequency := 5
export var duration := .25
export var laser_delay := 1.5
export var directions = [ Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
export var size := 30
export var random_speed := 200

func _ready():
	add_child(fire_timer)
	fire_timer.connect("timeout", self, "_fire")
	fire_timer.start(start_delay)

func _fire():
	for dir in directions :
		var laser_add = Laser.instance()
		laser_add.direction = dir
		laser_add.position = dir * size
		match dir:
			Vector2.LEFT:
				laser_add.position.x -= 1
			Vector2.RIGHT:
				laser_add.position.x += 1
			Vector2.DOWN:
				laser_add.position.y += 1
			Vector2.UP:
				laser_add.position.y -= 1
		laser_add.duration = duration
		laser_add.delay = laser_delay
		add_child(laser_add)
		fire_timer.start(frequency)
	impulse_timer.start()

func _handle_random_motion():
	var impulse_vector : Vector2
	var torque_force := 250 * 10
	var do_flip_x := randi() % 2
	var do_flip_y := randi() % 2

	impulse_vector.x = rand_range(random_speed, random_speed * 2)
	impulse_vector.y = rand_range(random_speed, random_speed * 2)

	if do_flip_x:
		impulse_vector.x *= -1
	if do_flip_y:
		impulse_vector.y *= -1
	apply_torque_impulse(torque_force)
	apply_central_impulse(impulse_vector)

func _on_ImpulseTimer_timeout():
	_handle_random_motion()
