extends Timer

var spikes = []
var walls = []
var curr_spike := 0
var curr_wall := 0
export var use_walls := false

func _ready():
	for wall in get_parent().get_children() :
		if wall is Node2D :
			for spike in wall.get_children() :
				spikes.append(spike)
			walls.append(wall)
	connect("timeout", self, "_timeout")

func _timeout():
	if use_walls :
		var wall = walls[curr_wall]
		for child in wall.get_children() :
			child._activate()
		if curr_wall >= 3 :
			curr_wall = 0
		else :
			curr_wall += 1
	else :
		spikes[curr_spike]._activate()
		curr_spike += 1
		if curr_spike == spikes.size():
			curr_spike = 0