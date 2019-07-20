extends Node2D

onready var beam_sfx := $Beam
var direction = Vector2.DOWN
var delay := 1.0
var duration := 0.0

const MAX_RANGE = 10000
var damage = 100

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
	$Hurtbox/CollisionShape2D.shape = $Hurtbox/CollisionShape2D.shape.duplicate()


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
	var dist = MAX_RANGE
	if cast.is_colliding() :
		dist = cast.get_collision_point().distance_to(global_position)
		if not active_timer.is_stopped() :
			for body in hurtbox.get_overlapping_bodies() :
				if not body in has_hit and body.has_method('hit'):
					body.hit(self, damage, Vector2.ZERO, Damage.FIRE)
					has_hit.append(body)

	sprite.rect_size.y = dist
	preParticles.process_material.emission_box_extents.x = dist/2
	preParticles.position.y = dist/2
	hitParticles.position.y = dist

	hurtbox.position.y = dist/2
	$Hurtbox/CollisionShape2D.shape.extents.y = dist/2


func _fire() :
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
	sprite.visible = true
	hitParticles.emitting = true



func _fade():
	self.queue_free()
