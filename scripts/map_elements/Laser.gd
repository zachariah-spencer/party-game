extends Node2D

var direction = Vector2.DOWN
var delay := 1.0
var duration := 0.0

const MAX_RANGE = 10000
var damage = 1

var width_scale := 1

onready var cast = $ray
onready var sprite = $sprite
onready var hitParticles = $StaticEffect/HitParticles
onready var preParticles = $PreParticles
onready var hurtbox = $Hurtbox
var has_hit = []
var ray_mask = Globals.TERRAIN_BIT + Globals.PLATFORM_BIT + Globals.BEAM_BIT

onready var delay_timer = Timer.new()
onready var active_timer = Timer.new()
onready var hit_timer = $HitTimer

func _ready():
	damage = get_parent().base_damage
	$Hurtbox/CollisionShape2D.shape.extents.x = 32 * width_scale
	sprite.rect_size.x = 64 * width_scale
	sprite.rect_position.x = (-1 * sprite.rect_size.x) / 2
	sprite.visible = false
	cast.cast_to.y = MAX_RANGE
	rotation = direction.angle() - PI/2
	preParticles.process_material = preParticles.process_material.duplicate()
	$Hurtbox/CollisionShape2D.shape = $Hurtbox/CollisionShape2D.shape.duplicate()

	$ray.collision_mask = ray_mask
	hitParticles.position.y = MAX_RANGE
	hitParticles.lifetime = duration
	hitParticles.emitting = false

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

	hit_timer.connect("timeout", self, "queue_free")

func _process(delta):
	var dist = MAX_RANGE
	if cast.is_colliding() :
		dist = cast.get_collision_point().distance_to(global_position)
		if not active_timer.is_stopped() :
			for body in hurtbox.get_overlapping_bodies() :
				if not body in has_hit and body.has_method('hit'):
					body.hit(self, damage, Vector2.ZERO, Damage.FIRE)
					has_hit.append(body)
		hitParticles.position = cast.get_collision_point()
		hitParticles.rotation = global_rotation - PI/2

	sprite.rect_size.y = dist
	preParticles.process_material.emission_box_extents.x = dist/2
	preParticles.position.y = dist/2

	hurtbox.position.y = dist/2
	$Hurtbox/CollisionShape2D.shape.extents.y = dist/2
	hitParticles.self_modulate.a = hit_timer.time_left


func _fire() :
	preParticles.emitting = false
	preParticles.visible = false
	hurtbox.monitoring = true
	cast.cast_to.y = MAX_RANGE
	if cast.is_colliding() :
		var contact = cast.get_collision_point()
		sprite.rect_size.y = position.distance_to(contact)
		hitParticles.global_position = contact
		hitParticles.emitting = true
		hitParticles.visible = true
	else :
		sprite.rect_size.y = position.distance_to(cast.cast_to)

	hit_timer.start(duration + hitParticles.lifetime)
	active_timer.start(duration)
	sprite.visible = true


func _fade():
	cast.enabled = false
	sprite.visible = false
	preParticles.visible = false
	hurtbox.monitoring = false