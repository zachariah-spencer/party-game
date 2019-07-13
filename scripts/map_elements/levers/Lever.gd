extends Area2D

class_name Lever

var can_flip := true
export var switch_cooldown := .25

onready var switch := $Switch
onready var animation_player := $AnimationPlayer
onready var cooldown_timer := $Cooldown
onready var parent = get_parent()

func _ready():
	cooldown_timer.connect("timeout", self, "_on_Cooldown_timeout")

func interact(by : Player):
	yield(get_tree(), "idle_frame")
	if can_flip :
		for body in get_overlapping_bodies() :
			if body == by :
				flip()

func  flip():
	animation_player.play('flip_lever')
	can_flip = false
	cooldown_timer.start(switch_cooldown)

func _on_Cooldown_timeout():
	can_flip = true
