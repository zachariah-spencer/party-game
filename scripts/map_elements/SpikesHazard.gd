extends Node2D

class_name SpikesHazard

onready var anim := $AnimatedSprite
onready var area := $Area2D
var active := false
onready var spike_sfx := $Spike
onready var active_timer := Timer.new()
export var active_time := .5

func _ready():
	active_timer.autostart = false
	active_timer.one_shot = true
	add_child(active_timer)
	active_timer.connect("timeout", self, "retract")

func _activate():
	active_timer.start(active_time)
	active = true
	anim.play('extend')
#	anim.play('active')
	spike_sfx.play()

func retract():
	anim.play('extend', true)
	active = false
#
#func _on_AnimatedSprite_animation_finished():
#	active = false
#	anim.play('idle')

func _physics_process(delta):
	if active:
		for body in area.get_overlapping_bodies():
			if body is Player:
				body.hit(self,100,Vector2(0,-100),Damage.ENVIRONMENTAL)