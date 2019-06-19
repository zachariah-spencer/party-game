extends Item
onready var impulse_timer := $ImpulseTimer
onready var hit_cooldown := $HitCooldownTimer
onready var punch_area := $PunchedArea
onready var runaway_area := $RunawayArea
export var random_speed : float
export var runaway_speed := Globals.CELL_SIZE * 0.5
var player_near_ball : Player
var can_be_hit := true

signal player_got_a_punch

func _ready():
	connect('player_got_a_punch',get_parent(),'_increase_local_score')
	_weight = 10
	bounce = .6

func _physics_process(delta):
	if player_near_ball:
		_handle_runaway(delta)

func _handle_runaway(delta : float):
	var runaway_velocity : Vector2 = Vector2.ZERO
	
	if player_near_ball:
		runaway_velocity = ( (player_near_ball.global_position - global_position).normalized() ) * Globals.CELL_SIZE / 3
		apply_central_impulse(-runaway_velocity)

func _handle_random_motion():
	var impulse_vector : Vector2
	var do_flip_x := randi() % 2
	var do_flip_y := randi() % 2
	
	impulse_vector.x = rand_range(Globals.CELL_SIZE * 25, Globals.CELL_SIZE * 50)
	impulse_vector.y = rand_range(Globals.CELL_SIZE * 25, Globals.CELL_SIZE * 50)
	
	if do_flip_x:
		impulse_vector.x *= -1
	if do_flip_y:
		impulse_vector.y *= -1
	
	apply_central_impulse(impulse_vector)

func _on_ImpulseTimer_timeout():
	if !player_near_ball:
		_handle_random_motion()


func _on_PunchedArea_body_entered(body):
	var player_fist = body if body.is_in_group('fist') else null
	var attacking_player = body.get_parent().get_parent().get_parent().get_parent()
	
	print(attacking_player.child.is_attacking)
	
	if can_be_hit && attacking_player.child.is_attacking:
		var impulse_vector : Vector2
		var do_flip_x := randi() % 2
		var do_flip_y := randi() % 2
	
		impulse_vector.x = rand_range(Globals.CELL_SIZE * 40, Globals.CELL_SIZE * 80)
		impulse_vector.y = rand_range(Globals.CELL_SIZE * 40, Globals.CELL_SIZE * 80)
	
		if do_flip_x:
			impulse_vector.x *= -1
		if do_flip_y:
			impulse_vector.y *= -1
		
		
		can_be_hit = false
		hit_cooldown.start()
		modulate.a = .5
		apply_central_impulse(impulse_vector * 3)
		
		if player_fist && !get_parent().game_over:
			emit_signal('player_got_a_punch', attacking_player, 1)

func hit(by : Node, damage : int, knockback :Vector2):
	
	if can_be_hit && by.is_attacking:
		var knockback_velocity : Vector2 = Vector2.ZERO
	
		knockback_velocity = (knockback) * Globals.CELL_SIZE / 2
		apply_central_impulse(-knockback_velocity)
		
		can_be_hit = false
		hit_cooldown.start()
		modulate.a = .5
		if !get_parent().game_over:
			emit_signal('player_got_a_punch', by, 1)

func _on_HitCooldownTimer_timeout():
	can_be_hit = true
	modulate.a = 1

func _on_RunawayArea_body_entered(body):
	player_near_ball = body as Player


func _on_RunawayArea_body_exited(body):
	player_near_ball = null
