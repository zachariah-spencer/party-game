extends Weapon

export var launch_speed := 60
var active := false

onready var shoot_time := $ShootTime
onready var shoot_cd := $ShootCooldown
onready var attack_area := $AttackArea
onready var vfx := $Particles
var readied := false

func _ready():
	readied = true

func _on_grab():
	if !readied:
		yield(self,'ready')
	attack_area.set_collision_mask_bit(_owner.parent.single_bit, false)

func _on_throw():
	attack_area.set_collision_mask_bit(_owner.parent.single_bit, true)

func attack():
	if shoot_cd.is_stopped():
		vfx.emitting = true
		active = true
		shoot_time.start()
		shoot_cd.start()

func _physics_process(delta):
	if active:
		attack_area.monitoring = true
	else:
		attack_area.monitoring = false

func _on_Area2D_body_entered(body):
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


func _on_ShootTime_timeout():
	vfx.emitting = false
	active = false