extends Node2D

export var increment_amount := 1
var player_nearby : Player = null
var can_flip := true

onready var rounds_label := $'../RoundsLabel'
onready var desc_label := $'../DescLabel'
onready var switch := $Switch
onready var animation_player := $AnimationPlayer
onready var cooldown_timer := $Cooldown
onready var parent = get_parent()

func _ready():
	rounds_label.text = String(parent.num_rounds)

func interact(by : Player):
	if player_nearby != null && can_flip && player_nearby == by:
		animation_player.play('flip_lever')
		can_flip = false
		cooldown_timer.start()
		
		if _check_limits():
			parent.num_rounds += increment_amount
			rounds_label.text = String(parent.num_rounds)

func _check_limits():
	if parent.num_rounds + increment_amount >= parent.min_rounds && parent.num_rounds + increment_amount <= parent.max_rounds:
		return true
	else:
		return false

func _on_NearbyArea_body_entered(body):
	player_nearby = body as Player


func _on_NearbyArea_body_exited(body):
	player_nearby = null


func _on_Cooldown_timeout():
	can_flip = true
