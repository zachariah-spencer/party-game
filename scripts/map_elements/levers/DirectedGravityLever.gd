extends Lever

export var new_gravity = Vector2.DOWN
export(NodePath) var path
onready var delay_timer = Timer.new()
export var delay := .2

func flop():
	.flop()
	
	Manager.current_minigame.emit_signal('gravity_flopped')
	
	get_node(path).set_gravity_vector(new_gravity)