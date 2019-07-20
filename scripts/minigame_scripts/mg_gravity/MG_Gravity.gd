extends Minigame

signal gravity_flopped
onready var spikes_array := map.get_node('Spikes').get_children()
var curr_spike := 0

func _ready():
	Manager.minigame_name = 'lethal_gravity'
	game_instructions = "Force other players \n to their death!"

func _on_SpikeTimer_timeout():
	spikes_array[curr_spike]._activate()
	curr_spike += 1
	if curr_spike == spikes_array.size():
		curr_spike = 0