extends RigidBody2D

func _integrate_forces(state):
	linear_velocity = linear_velocity.clamped(.5)