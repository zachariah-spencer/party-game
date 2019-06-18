extends RigidBody2D
class_name Item

var _held
var _owner : Player
onready var sprite = $Obj/Sprite
var _weight := 0
export var throwable := true
export var grabbable := true

signal grabbed
signal thrown


func _ready():
	connect("body_entered" , self, "_on_body_entered")
	$Pickup_area.add_to_group("item")

func _on_body_entered(body):
	pass


func grab(by : Player):
	if grabbable:
		_owner = by
		sprite.modulate = _owner.modulate
		emit_signal("grabbed")
		mode = MODE_STATIC
		set_collision_layer_bit(0, false)
		set_collision_layer_bit(4, false)
		$Pickup_area.monitorable = false

func throw(direction : Vector2, pos : Vector2 , by : Player):
	if throwable:
		_owner = by
		sprite.modulate = _owner.get_parent().modulate
		emit_signal("thrown")
		mode = MODE_RIGID
		get_parent().remove_child(self)
		global_position = pos
		Manager.current_minigame.add_child(self)
		$Pickup_area.monitorable = true
		set_collision_layer_bit(0, true)
		set_collision_layer_bit(4, true)
		apply_central_impulse(direction)

func _deown():
	sprite.modulate = Color.white
	_owner = null

func hit(damage : int):
	pass