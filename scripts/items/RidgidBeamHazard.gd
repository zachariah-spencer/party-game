extends Item

var Laser = preload("res://scenes/map_elements/Laser.tscn")
onready var fire_timer = Timer.new()
onready var impulse_timer := $ImpulseTimer
onready var shoot_timer := $ShootDelayTimer
onready var beam_sfx := $Beam
onready var charging_sfx := $Charging
export var start_delay := 5
export var frequency := 5
export var duration := .25
export var laser_delay := 1.5
export var directions = [ Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
export var size := 31
export var random_speed := 200
var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	add_child(fire_timer)
	fire_timer.connect("timeout", self, "_fire")
	fire_timer.start(start_delay)

func _fire():
	charging_sfx.play()
	for dir in directions :
		var laser_add = Laser.instance()
		laser_add.direction = dir
		laser_add.position = dir * size
		laser_add.duration = duration
		laser_add.delay = laser_delay
		add_child(laser_add)
		fire_timer.start(frequency)
	impulse_timer.start()
	shoot_timer.start()

func _handle_random_motion():
	var impulse_vector : Vector2
	var torque_force := 250 * 10
	var do_flip_x := rng.randi() % 2
	var do_flip_y := rng.randi() % 2

	impulse_vector.x = rng.randf_range(random_speed, random_speed * 2)
	impulse_vector.y = rng.randf_range(random_speed, random_speed * 2)

	if do_flip_x:
		impulse_vector.x *= -1
	if do_flip_y:
		impulse_vector.y *= -1
	apply_torque_impulse(torque_force)
	apply_central_impulse(impulse_vector)

func _on_ImpulseTimer_timeout():
	_handle_random_motion()


func _on_ShootDelayTimer_timeout():
	if !beam_sfx.playing:
		beam_sfx.play()
