extends RigidBody2D
class_name Item

var _held

func _ready():
	$Pickup_area.add_to_group("item")


func grab():
	mode = MODE_STATIC
	set_collision_layer_bit(0, false)
	set_collision_layer_bit(4, false)
	$Pickup_area.monitorable = false

func throw(direction : Vector2, pos : Vector2):
	mode = MODE_RIGID
	get_parent().remove_child(self)
	global_position = pos
	Manager.current_minigame.add_child(self)
	$Pickup_area.monitorable = true
	set_collision_layer_bit(0, true)
	set_collision_layer_bit(4, true)
	apply_central_impulse(direction)