extends Node2D


var direction = Vector2.DOWN
var delay = 1
var duration = 0
var sound

const MAX_RANGE = 10000
var DURATION_TIME = 1
var DAMAGE = 1

onready var cast = $ray
onready var sprite = $sprite
onready var hitParticles = $HitParticles
onready var preParticles = $PreParticles
onready var hurtbox = $Hurtbox
var has_hit = []

onready var delay_timer = Timer.new()
onready var active_timer = Timer.new()

func _ready():
	sprite.visible = false
	cast.cast_to.y = MAX_RANGE
	rotation = direction.angle() - PI/2
	preParticles.process_material = preParticles.process_material.duplicate()

	active_timer.autostart = false
	active_timer.one_shot = true
	add_child(active_timer)
	active_timer.connect("timeout", self, "_fade")

	delay_timer.autostart = false
	delay_timer.one_shot = true
	add_child(delay_timer)
	delay_timer.start(delay)
	delay_timer.connect("timeout", self, "_fire")
	preParticles.emitting = true

func _process(delta):
	if cast.is_colliding() :
		var contact_distance = cast.get_collision_point().distance_to(global_position)
		sprite.rect_size.y = contact_distance
		preParticles.process_material.emission_box_extents.x = contact_distance/2
		preParticles.position.y = contact_distance/2
		hitParticles.position.y = contact_distance
#		hurtbox.position.y = contact_distance/2
		$Hurtbox/CollisionShape2D.shape.extents.y = contact_distance

		if not active_timer.is_stopped() :
			for body in hurtbox.get_overlapping_bodies() :
				if not body in has_hit and body.has_method('hit'):
					body.hit(self, 100, Vector2.ZERO, Damage.FIRE)
					has_hit.append(body)
#			var hit = cast.get_collider()
#			if hit.has_method('hit'):
#				hit.hit(self, 100, Vector2.ZERO, Damage.FIRE)


func _fire() :
	print($Hurtbox/CollisionShape2D.shape.extents)
	preParticles.emitting = false
	preParticles.visible = false
	hurtbox.monitoring = true
	cast.cast_to.y = MAX_RANGE
	if cast.is_colliding() :
		var contact = cast.get_collision_point()
		sprite.rect_size.y = position.distance_to(contact)
		hitParticles.position = contact
		hitParticles.emitting = true
	else :
		sprite.rect_size.y = position.distance_to(cast.cast_to)

	active_timer.start(duration)
#	sprite.visible = true
	hitParticles.emitting = true



func _fade():
	self.queue_free()
#	some outro sounds/fade effect? scale down?
