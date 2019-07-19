extends Node2D

onready var gravity_field := get_parent().get_parent()
onready var layer := get_parent()
onready var arrow := $Arrow
onready var tween := $Tween
var new_rotation_dir
var new_color

func _ready():
	gravity_field.connect('gravity_changed', self, '_on_grav_change')
	arrow.modulate = Color.red
	arrow.rotation = -PI / 2

func _on_grav_change(new_gravity : Vector2):
	match new_gravity:
		Vector2.UP:
			new_color = Color.blue
			new_rotation_dir = PI / 2
		Vector2.DOWN:
			new_color = Color.red
			new_rotation_dir = -PI / 2
		Vector2.RIGHT:
			new_color = Color.green
			new_rotation_dir = PI
		Vector2.LEFT:
			new_color = Color.yellow
			new_rotation_dir = 0
		
	tween.interpolate_property(arrow,'modulate',arrow.modulate, new_color,0.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.interpolate_property(arrow,'rotation',arrow.rotation,new_rotation_dir,.8,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	tween.start()