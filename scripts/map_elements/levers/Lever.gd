extends Area2D

class_name Lever

var can_flip := true
export var switch_cooldown := .25

onready var flip_sound := $Flip
onready var switch := $Switch
onready var animation_player := $AnimationPlayer
onready var cooldown_timer := $Cooldown
onready var parent = get_parent()
onready var flip_delay_timer = Timer.new()
export var flip_delay := .2

signal flip
signal flop

func _ready():
	flip_delay_timer.wait_time = flip_delay
	flip_delay_timer.autostart = false
	flip_delay_timer.one_shot = true
	add_child(flip_delay_timer)
	flip_delay_timer.connect("timeout", self, "flop")
	cooldown_timer.connect("timeout", self, "_on_Cooldown_timeout")

func interact(by : Player):
	yield(get_tree(), "idle_frame")
	if can_flip :
		for body in get_overlapping_bodies() :
			if body == by :
				flip()

func  flip():
	emit_signal("flip")
	flip_sound.play()
	animation_player.play('flip_lever')
	can_flip = false
	flip_delay_timer.start(flip_delay)

func flop():
	emit_signal("flop")
	animation_player.play('flop')
	cooldown_timer.start(switch_cooldown)

func _on_Cooldown_timeout():
	can_flip = true
