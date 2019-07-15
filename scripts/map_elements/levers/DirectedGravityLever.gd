extends Lever

export var new_gravity = Vector2.DOWN
export(NodePath) var path

func flip() :
	get_node(path).set_gravity_vector(new_gravity)
#	get_parent().set_gravity_vector(new_gravity)