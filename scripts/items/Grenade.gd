extends Item

onready var fuse_timer := Timer.new()
var damage = 30

func _ready():
	fuse_timer.one_shot = true
	fuse_timer.autostart = false
	add_child(fuse_timer)
	fuse_timer.connect("timeout", self, "_fuse_timeout")
	#probably stick this in Item
	connect("grabbed", self, "_on_grab")
	connect("thrown", self, "_on_throw")

func _on_grab():
	#this doesn't work as well as I'd like
	fuse_timer.start(1.4)

func _on_throw():
#	fuse_timer.start(.7)
	pass

func _fuse_timeout() :
	$Sprite.visible = false
	mode = RigidBody2D.MODE_STATIC
	var victims = $ExplosionArea.get_overlapping_bodies()
	for body in victims :
		var distance = body.global_position - global_position

		#hits players and bodies
		if body.is_in_group("player") :
			if body is Player :
				body.velocity += Vector2.UP*100
				body.velocity += distance.normalized() * 2500
				body.hit_points -= damage
			#add code to interact with ragdolls
		if body  is Item :
			body.hit(damage)
			body.apply_central_impulse(Vector2.UP*100)
			body.apply_central_impulse(distance.normalized() * 1000)
	$Explosion.emitting = true
	yield(get_tree().create_timer(.8), "timeout")
	queue_free()

func hit(damage : int):
	fuse_timer.start(.5)