extends Item
class_name Grenade

onready var fuse_timer := Timer.new()
var damage = 50
var durability = 20
var exploding := false
export var fuse_time := 1.5
export var prelit_fuse_time := 2.5
var prelit := false

func _ready():
	bounce = 1
	fuse_timer.one_shot = true
	fuse_timer.autostart = false
	add_child(fuse_timer)
	fuse_timer.connect("timeout", self, "_fuse_timeout")
	
	if prelit:
		fuse_timer.start(prelit_fuse_time)

func _on_grab():
	pass

func _on_throw():
	if fuse_timer.is_stopped():
		fuse_timer.start(fuse_time)

func _fuse_timeout() :
	exploding = true
	fuse_timer.stop()
	if _owner :
		_owner.drop()
	$Obj/Sprite.visible = false
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


func _integrate_forces(state):
	if exploding : state.linear_velocity = Vector2.ZERO

func hit(by : Node, damage : int, knockback : Vector2):
	durability -= damage
	if durability <= 0 and !exploding:
		fuse_timer.start(.1)
	elif !exploding :
		fuse_timer.start(.5)
	apply_central_impulse(knockback * 400)