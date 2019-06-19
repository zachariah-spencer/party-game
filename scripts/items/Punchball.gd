extends Item
onready var impulse_timer := $ImpulseTimer
onready var hit_cooldown := $HitCooldownTimer
onready var punch_area := $PunchedArea
onready var runaway_area := $RunawayArea
export var random_speed := 200
export var runaway_speed := 32
export var knockback_speed := 5000
var player_near_ball : Player
var can_be_hit := true

signal player_got_a_punch

func _ready():
	connect('player_got_a_punch',get_parent(),'_increase_local_score')
	_weight = 10
	bounce = .6

func _physics_process(delta):
	if player_near_ball && can_be_hit:
		_handle_runaway(delta)

func _handle_runaway(delta : float):
	var runaway_velocity : Vector2 = Vector2.ZERO
	
	if player_near_ball:
		if runaway_velocity == Vector2.ZERO:
			runaway_velocity = ( ( (player_near_ball.global_position - global_position).normalized() ) * Globals.CELL_SIZE / 3 )* -1
		
		apply_central_impulse(runaway_velocity)

func _handle_random_motion():
	var impulse_vector : Vector2
	var do_flip_x := randi() % 2
	var do_flip_y := randi() % 2
	
	impulse_vector.x = rand_range(random_speed, random_speed * 2)
	impulse_vector.y = rand_range(random_speed, random_speed * 2)
	
	if do_flip_x:
		impulse_vector.x *= -1
	if do_flip_y:
		impulse_vector.y *= -1
	
	apply_central_impulse(impulse_vector)

func _on_ImpulseTimer_timeout():
	if !player_near_ball && can_be_hit:
		_handle_random_motion()

func hit(by : Node, damage : int, knockback :Vector2):
	print('ball hit function called')
	if can_be_hit && by.is_attacking:
		var knockback_velocity : Vector2 = Vector2.ZERO
	
		knockback_velocity.x = knockback.x * knockback_speed
		knockback_velocity.y = knockback.y * knockback_speed * 2
		apply_central_impulse(knockback_velocity)
	
		can_be_hit = false
	
		for i in range(6,9):
			set_collision_mask_bit(i, false)
	
		hit_cooldown.start()
		modulate.a = .5
		if !get_parent().game_over:
			emit_signal('player_got_a_punch', by.parent, 1)

func _on_HitCooldownTimer_timeout():
	for i in range(6,9):
		set_collision_mask_bit(i, true)
	
	can_be_hit = true
	modulate.a = 1

func _on_RunawayArea_body_entered(body):
	player_near_ball = body as Player


func _on_RunawayArea_body_exited(body):
	player_near_ball = null
