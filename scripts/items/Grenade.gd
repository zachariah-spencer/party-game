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
	angular_velocity = 0
	linear_velocity = Vector2.ZERO
	rotation = 0
	mode = RigidBody2D.MODE_STATIC
	exploding = true
	fuse_timer.stop()
	if is_instance_valid(_owner) and _owner is Player and _owner.held_item == self:
		_owner.drop()
	$Obj/Sprite.visible = false
	yield(get_tree(), "idle_frame")
	var victims = $ExplosionArea.get_overlapping_bodies()
	for body in victims :
		var distance = body.global_position - global_position
		#hits players and bodies
		if body.is_in_group("player") :
			if body is Player :
				body.hit(self, damage, distance.normalized(), Damage.EXPLOSION)
			#add code to interact with ragdolls
		if body  is Item and body != self :
			body.hit(self, damage, distance.normalized(), Damage.EXPLOSION)
	$Explosion.emitting = true
	$Smoke.emitting	= true
	$Core.emitting = true
	$ExplosionSFX.play()
	yield(get_tree().create_timer($Explosion.lifetime), "timeout")
	$ExplosionArea.collision_mask = 0
	yield(get_tree().create_timer($Smoke.lifetime - $Explosion.lifetime), "timeout")
	queue_free()

func _integrate_forces(state):
	if exploding :
		angular_velocity = 0
		linear_velocity = Vector2.ZERO


func hit(by : Node, damage : int, knockback : Vector2, type := Damage.ENVIORMENTAL):
	if type == Damage.EXPLOSION or type == Damage.FIRE :
		durability -= damage
		if durability <= 0 and !exploding:
			fuse_timer.start(.1)
		elif !exploding :
			fuse_timer.start(.5)
		apply_central_impulse(knockback * 400)