extends Node2D

class_name ItemSpawner

export var item_path := "res://scenes/items/"
export var propulsion_factor := 13
var item : PackedScene
onready var dispense_sound := $Dispense
onready var spawn_pos := $Position2D
onready var parent := get_parent()

func _ready():
	item = load(item_path)

func _spawn_item():
	dispense_sound.play()
	var item_inst = item.instance()
	item_inst.position = spawn_pos.position
	if item_inst is Grenade:
		item_inst.prelit = true
	call_deferred('add_child', item_inst)
	item_inst.apply_central_impulse(Vector2(0,-100 * propulsion_factor).rotated(rotation))