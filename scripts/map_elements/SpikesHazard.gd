extends Hazard

class_name SpikesHazard

onready var anim := $AnimatedSprite
onready var area := $Hurtbox
var active := false
onready var spike_sfx := $Spike
onready var active_timer := Timer.new()
export var active_time := .5

func _ready():
	active_timer.autostart = false
	active_timer.one_shot = true
	add_child(active_timer)
	active_timer.connect("timeout", self, "retract")

func activate():
	active_timer.start(active_time)
	active = true
	anim.play('extend')
	spike_sfx.play()

func retract():
	anim.play('retract')
	spike_sfx.play()
	active = false

func _physics_process(delta):
	if active:
		for body in area.get_overlapping_bodies():
			if body is Player:
				body.hit(self,100,Vector2(0,-100),Damage.ENVIRONMENTAL)