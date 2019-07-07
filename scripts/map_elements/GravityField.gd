extends Area2D

func _ready():

	var mat : ParticlesMaterial = $Particles2D.process_material.duplicate()
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
	mat.gravity = Vector3(gravity_vec.normalized().x * 100, gravity_vec.normalized().y * 100, 0)

	$Particles2D.amount = area/100
	$Particles2D.process_material = mat


#	connect('body_entered',self,'on_body_entered')
	connect('body_exited',self,'on_body_exited')

func _physics_process(delta):
	for player in get_overlapping_bodies():
		if player is Player:
			player._set_gravity(gravity_vec)

#func on_body_entered(body):
#	var player = body as Player
#
#	if player:
#		player._set_gravity(gravity_vec)

func on_body_exited(body):
	var player = body as Player

	if player:
		player._set_gravity(Vector2.DOWN)