extends Area2D

onready var vfx := $Particles
onready var shoot_time := $ShootTime
var launch_speed := 80

func _physics_process(delta):
	vfx.modulate.a -= .02
	if vfx.modulate.a <= 0:
		queue_free()

func _on_PushBeam_body_entered(body):
		var player = body as Player
		var item = body as Item
		var launch_dir := Vector2.RIGHT.rotated(rotation)
		
		if player:
			player._set_state(player.states.hitstun)
			player.hurt_cooldown_timer.start()
			player.velocity = launch_dir * (launch_speed * Globals.CELL_SIZE)
	#		boost_sfx.pitch_scale = 1.5
	#		boost_sfx.play()
		if item:
	#		boost_sfx.pitch_scale = 3
	#		boost_sfx.play()
			item.apply_central_impulse(launch_dir * (launch_speed * Globals.CELL_SIZE))
