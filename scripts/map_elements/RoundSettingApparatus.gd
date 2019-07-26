extends Node2D
export var num_rounds := 10
export var min_rounds := 1
export var max_rounds := 100

onready var rounds_label = $RoundsLabel
onready var infinite_label = $InfiniteLabel

var infinite := false

func increment(amount):
	num_rounds = clamp(num_rounds + amount, min_rounds, max_rounds)
	rounds_label.text = String(num_rounds)

func toggle_infinite():
	infinite = !infinite
	Manager.repeats = infinite
	rounds_label.visible = !infinite
	if infinite :
		infinite_label.text = "Infinite : On"
	else :
		infinite_label.text = "Infinite : Off"