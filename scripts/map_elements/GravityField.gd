extends Area2D

class_name GravityField

var mat : ParticlesMaterial
export var emitting := true
const particle_speed := 100

signal gravity_changed

func _ready():
	if emitting :
		mat = $Particles2D.process_material.duplicate()
		$Particles2D.emitting = true
		var circle = $CollisionShape2D.shape as CircleShape2D
		var rect = $CollisionShape2D.shape as RectangleShape2D
		var area = 0
		if circle :
			mat.emission_shape = ParticlesMaterial.EMISSION_SHAPE_SPHERE
			mat.emission_sphere_radius = circle.radius
			area = circle.radius*circle.radius * PI
		if rect :
			mat.emission_shape = ParticlesMaterial.EMISSION_SHAPE_BOX
			mat.emission_box_extents = Vector3(rect.extents.x, rect.extents.y, 0)
			area = rect.extents.x * rect.extents.y
		mat.gravity = Vector3(gravity_vec.normalized().x * particle_speed, gravity_vec.normalized().y * particle_speed, 0)

		$Particles2D.amount = area/100
		$Particles2D.process_material = mat
	else :
		$Particles2D.emitting = false

#	connect('body_entered',self,'on_body_entered')
	connect('body_exited',self,'on_body_exited')

func _physics_process(delta):
	for player in get_overlapping_bodies():
		if player is Player:
			player._set_gravity(gravity_vec)

func set_gravity_vector(new_gravity : Vector2) :
	emit_signal('gravity_changed', new_gravity)
	if emitting :
		mat.gravity = Vector3(new_gravity.x * particle_speed, new_gravity.y * particle_speed, 0)
	gravity_vec = new_gravity

func invert_gravity():
	if gravity_vec.x != 0 :
		gravity_vec.x *= -1
	if gravity_vec.y != 0 :
		gravity_vec.y *= -1
	set_gravity_vector(gravity_vec)

func on_body_exited(body):
	var player = body as Player

	if player:
		player._set_gravity(Vector2.DOWN)
