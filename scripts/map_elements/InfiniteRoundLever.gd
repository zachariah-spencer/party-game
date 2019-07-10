extends Node2D

var infinite_state := false
var player_nearby : Player = null
var can_flip := true

onready var infinite_label := $'../InfiniteLabel'
onready var rounds_label := $'../RoundsLabel'
onready var desc_label := $'../DescLabel'
onready var switch := $Switch
onready var animation_player := $AnimationPlayer
onready var cooldown_timer := $Cooldown
onready var parent = get_parent()

func _ready():
	infinite_label.text = 'Infinite: ' + _get_infinite_state()
	Manager.repeats = false

func interact(by : Player):
	if player_nearby != null && can_flip && player_nearby == by:
		animation_player.play('flip_lever')
		can_flip = false
		cooldown_timer.start()
		
		infinite_state = !infinite_state
		Manager.repeats = infinite_state
		infinite_label.text = String('Infinite: ' + _get_infinite_state())
		rounds_label.visible = false if infinite_state else true
		
		if !infinite_state:
			parent.num_rounds = 10
			rounds_label.text = String(parent.num_rounds)

func _get_infinite_state():
	return 'on' if infinite_state else 'off'

func _on_NearbyArea_body_entered(body):
	player_nearby = body as Player


func _on_NearbyArea_body_exited(body):
	player_nearby = null


func _on_Cooldown_timeout():
	can_flip = true
