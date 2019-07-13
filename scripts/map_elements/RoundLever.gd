extends Lever

export var increment_amount := 1

onready var rounds_label := $'../RoundsLabel'
onready var desc_label := $'../DescLabel'

func _ready():
	rounds_label.text = String(parent.num_rounds)
	parent.num_rounds = 10

func  flip():
	.flip()
	animation_player.play('flip_lever')
	can_flip = false
	cooldown_timer.start()
	if _check_limits() :
		parent.num_rounds += increment_amount
		rounds_label.text = String(parent.num_rounds)

func _check_limits():
	var test_rounds = parent.num_rounds + increment_amount
	if test_rounds >= parent.min_rounds && test_rounds <= parent.max_rounds:
		return true
	else:
		return false

func _on_Cooldown_timeout():
	can_flip = true
