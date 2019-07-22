extends Node2D

class_name Hazard

export var base_damage := 10
export var base_type := 4


func _hurtbox_entered(body, damage := base_damage, type = base_type):
	if body.has_method("hit") :
		body.hit(self, damage, self.position, type)


func activate():
	pass