extends Node2D

class_name SpikesHazard

onready var anim := $AnimatedSprite
onready var area := $Area2D
var active := false

func _activate():
	active = true
	anim.play('active')

func _on_AnimatedSprite_animation_finished():
	active = false
	anim.play('idle')

func _physics_process(delta):
	if active:
		for body in area.get_overlapping_bodies():
			if body is Player:
				body.hit(self,100,Vector2(0,-100),Damage.ENVIRONMENTAL)