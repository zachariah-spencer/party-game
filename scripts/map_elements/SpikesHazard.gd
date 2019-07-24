extends Hazard

class_name SpikesHazard

onready var anim := $AnimatedSprite
onready var area := $Hurtbox
var active := false
onready var spike_sfx := $Spike
onready var active_timer := Timer.new()
export var active_time := .5

func _ready():
	$AnimatedSprite.material.set_shader_param("outline_color", outline_color)
	active_timer.autostart = false
	active_timer.one_shot = true
	add_child(active_timer)
	active_timer.connect("timeout", self, "retract")

func activate():
	active_timer.start(active_time)
	$Hurtbox.monitoring = true
	active = true
	anim.play('extend')
	spike_sfx.play()

func retract():
	$Hurtbox.monitoring = false
	anim.play('retract')
	spike_sfx.play()
	active = false
