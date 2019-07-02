extends Node2D

onready var cooldown_timer := $Cooldown
onready var switch := $Switch
onready var rounds_label := $RoundsLabel

var num_rounds := 10

func _on_Cooldown_timeout():
	switch.set_collision_mask_bit(3, true)


func _on_IncreaseArea_body_entered(body):
	switch.set_collision_mask_bit(3, false)
	cooldown_timer.start()
	num_rounds += 1
	
	rounds_label.text = String(num_rounds)


func _on_DecreaseArea_body_entered(body):
	switch.set_collision_mask_bit(3, false)
	cooldown_timer.start()
	num_rounds -= 1
	
	rounds_label.text = String(num_rounds)
