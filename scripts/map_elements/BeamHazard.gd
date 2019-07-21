extends Node2D

class_name BeamHazard

var active := false
onready var area := $Area2D
onready var color_rect := $ColorRect
onready var color_rect_2 := $ColorRect2
onready var active_timer := $ActiveTimer
onready var charging_timer := $ChargingTimer
onready var particles := $Particles2D

func activate():
	if !active:
		particles.emitting = true
		charging_timer.start()

func _physics_process(delta):
	if active:
		for body in area.get_overlapping_bodies():
			if body is Player:
				body.hit(self,100,Vector2(0,-100),Damage.ENVIRONMENTAL)

func _on_ActiveTimer_timeout():
	active = false
	color_rect.visible = false
	color_rect_2.visible = false


func _on_ChargingTimer_timeout():
	particles.emitting = false
	active = true
	color_rect.visible = true
	color_rect_2.visible = true
	active_timer.start()
