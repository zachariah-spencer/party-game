extends Lever

export var new_gravity = Vector2.DOWN
export(NodePath) var path
onready var delay_timer = Timer.new()
export var delay := .2
onready var charge_sfx := $Charge
onready var gravity_change_sfx := $GravityChange

func flop():
	.flop()
	Manager.current_minigame.emit_signal('gravity_flopped')
	gravity_change_sfx.play()

	get_node(path).set_gravity_vector(new_gravity)

func flip():
	charge_sfx.play()
	.flip()