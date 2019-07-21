extends Lever

export var new_gravity = Vector2.DOWN
export(NodePath) var path

func flop():
	.flop()
	get_node(path).set_gravity_vector(new_gravity)
