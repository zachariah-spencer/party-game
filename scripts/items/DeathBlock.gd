extends Item

onready var static_timer := $StaticTimer
var static_timer_time := .2
var can_static := true

func _ready():
	Manager.current_minigame.connect('gravity_flopped', self, '_on_gravity_flop')

func _on_gravity_flop():
	static_timer.start()
	can_static = false
	sleeping = false

func _on_DeathBlock_body_entered(body):
	var terrain = body if body.get_collision_layer_bit(0) == true else null
	
	if terrain && can_static:
		print('here')
		sleeping = true


func _on_StaticTimer_timeout():
	can_static = true
