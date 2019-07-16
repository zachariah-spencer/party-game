extends Lever

export var new_gravity = Vector2.DOWN
export(NodePath) var path
onready var delay_timer = Timer.new()
export var delay := .2

func _ready():
	delay_timer.autostart = false
	delay_timer.one_shot = true
	add_child(delay_timer)
	delay_timer.connect("timeout", self, "delay_end")

func flip() :
	.flip()
	if delay_timer.is_stopped() :
		delay_timer.start()

func delay_end():
	get_node(path).set_gravity_vector(new_gravity)