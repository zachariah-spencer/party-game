extends Node2D

class_name Hazard

export var outline_color := Color(255,255,255, 255)
export var base_damage := 1
export var base_type := 4
export var base_knockback := Vector2.ONE * 100

func _hurtbox_entered(body, damage := base_damage, type = base_type):
	if body.has_method("hit") :
		body.hit(self, damage, base_knockback, type)

func activate():
	pass
