extends RigidBody2D
class_name Item

var _held

signal grabbed
signal thrown

func _ready():
	$Pickup_area.add_to_group("item")

func grab():
	emit_signal("grabbed")
	mode = MODE_STATIC
	set_collision_layer_bit(0, false)
	set_collision_layer_bit(4, false)
	$Pickup_area.monitorable = false

func throw(direction : Vector2, pos : Vector2):
	emit_signal("thrown")
	mode = MODE_RIGID
	get_parent().remove_child(self)
	global_position = pos
	Manager.current_minigame.add_child(self)
	$Pickup_area.monitorable = true
	set_collision_layer_bit(0, true)
	set_collision_layer_bit(4, true)
	apply_central_impulse(direction)

func hit(damage : int):
	pass