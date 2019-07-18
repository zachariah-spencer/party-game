extends Node2D

class_name ItemSpawner

export var item_path := "res://scenes/items/"
export var propulsion_factor := 13
export var repeat_on_timer := false
export var timer_duration := 5.0
export var rotating := false
export var rot_speed := .05
var item : PackedScene
onready var dispense_sound := $Dispense
onready var spawn_pos := $Position2D
onready var parent := get_parent()
onready var timer := $Timer

func _ready():
	item = load(item_path)
	timer.wait_time = timer_duration
	if repeat_on_timer:
		timer.start()

func _spawn_item():
	dispense_sound.play()
	var item_inst = item.instance()
	item_inst.position = spawn_pos.position
	if item_inst is Grenade:
		var variable_fuse_time := rand_range(2.2,2.8)
		item_inst.prelit_fuse_time = variable_fuse_time
		item_inst.prelit = true
	call_deferred('add_child', item_inst)
	item_inst.apply_central_impulse(Vector2(0,-100 * propulsion_factor).rotated(rotation))

func _physics_process(delta):
	if rotating:
		rotation += rot_speed

func _on_Timer_timeout():
	_spawn_item()
