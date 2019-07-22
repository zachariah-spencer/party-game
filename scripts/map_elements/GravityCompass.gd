extends CanvasLayer

onready var arrow := $Rig/weight/Arrow
onready var tween := $Rig/Tween

func _ready():
	arrow.modulate = Color.red
#	arrow.rotation = -PI / 2

func on_gravity_changed(new_gravity : Vector2):
	var new_color
	$Rig/weight.apply_central_impulse(new_gravity.rotated(PI/2) * 100)
#	var new_rotation_dir = new_gravity.angle() + PI
	match new_gravity:
		Vector2.UP:
			new_color = Color.blue
		Vector2.DOWN:
			new_color = Color.red
		Vector2.RIGHT:
			new_color = Color.green
		Vector2.LEFT:
			new_color = Color.yellow

	#you need to clear previous tweeenssss
	tween.remove_all()
	tween.stop_all()
	tween.interpolate_property(arrow,'modulate',arrow.modulate, new_color,0.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
#	tween.interpolate_property(arrow,'rotation',arrow.rotation,new_rotation_dir,.8,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	tween.start()
