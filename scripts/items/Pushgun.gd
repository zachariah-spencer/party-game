extends Weapon

export var launch_speed := 60
onready var shoot_cd := $ShootCooldown
onready var beam_pos := $BeamPos
onready var projectile := preload('res://scenes/items/PushBeam.tscn')

func attack():
	if shoot_cd.is_stopped():
		var add = projectile.instance()
		add.set_collision_mask_bit(_owner.parent.single_bit, false)
		get_tree().get_root().add_child(add)
		add.global_position = beam_pos.global_position
		add.rotation = rotation
		print(add.position)
		shoot_cd.start()