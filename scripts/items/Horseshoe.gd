extends Item

onready var shot_landed_area := $ShotLandedArea
onready var fall_timer := $FallTimer
var landed := false
var frame_count := 0
var landed_pos : Vector2
var has_been_moved := false

func _ready():
	connect("thrown", self, "_on_throw")
	_weight = 4

func _integrate_forces(state):
	
	if landed && !has_been_moved:
		var t = state.get_transform()
		
		t.origin.x = landed_pos.x
		
		t.origin.y = landed_pos.y
		
		angular_velocity = 0
		rotation = 0
		
		
		linear_velocity.x = 0
		
		state.set_transform(t)
		has_been_moved = true

func _on_ShotLandedArea_area_entered(area):
	var target = area.get_parent()
	
	if !landed:
		landed = true
		fall_timer.start()
		target.stack.append(self)
		landed_pos = target.get_node('Area/Position').get_global_position()
		grabbable = false
		
		if target.stack.size() > 4:
			target.item_spawn_pos.position.y -= 20
			target.area_shape.position.y -= 12
			target.sprite.position.y -= 14

func _on_FallTimer_timeout():
	mode = RigidBody2D.MODE_KINEMATIC
