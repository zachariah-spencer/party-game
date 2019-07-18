extends Lever

var spikes_hazards := []

func _ready():
	for child in get_children():
		if child is SpikesHazard :
			spikes_hazards.append(child)

func flip():
	.flip()
	for hazard in spikes_hazards :
		hazard._activate()