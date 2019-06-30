extends Item

onready var fuse_timer := Timer.new()
var damage = 30
var durability = 20
var exploding := false

func _ready():
	fuse_timer.one_shot = true
	fuse_timer.autostart = false
	add_child(fuse_timer)
	fuse_timer.connect("timeout", self, "_fuse_timeout")
	#probably stick this in Item
	connect("grabbed", self, "_on_grab")
	connect("thrown", self, "_on_throw")

func _on_grab():
	pass

func _on_throw():
	fuse_timer.start(1.5)

func _fuse_timeout() :
	exploding = true
	if _owner :
		_owner.drop()
	$Obj/Sprite.visible = false
	mode = RigidBody2D.MODE_STATIC
	var victims = $ExplosionArea.get_overlapping_bodies()
	for body in victims :
		var distance = body.global_position - global_position
		#hits players and bodies
		if body.is_in_group("player") :
			if body is Player :
				body.hit(self, damage, distance.normalized())
			#add code to interact with ragdolls
		if body  is Item and body != self :
			body.hit(self, damage, distance.normalized())
	$Explosion.emitting = true
	yield(get_tree().create_timer(.8), "timeout")
	queue_free()

func hit(by : Node, damage : int, knockback : Vector2):
	durability -= damage
	if durability <= 0 and !exploding:
		fuse_timer.start(.1)
	elif !exploding :
		fuse_timer.start(.5)
	apply_central_impulse(knockback * 400)