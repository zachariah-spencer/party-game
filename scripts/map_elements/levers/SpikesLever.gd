extends Lever

var hazards := []

func _ready():
	for child in get_children():
		if child is SpikesHazard || child is BeamHazard:
			hazards.append(child)

func flip():
	.flip()
	for hazard in hazards :
		hazard._activate()