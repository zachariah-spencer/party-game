extends Item
onready var impulse_timer := $ImpulseTimer
onready var punch_area := $PunchedArea
onready var hit_cooldown := $HitCooldownTimer
onready var nearby_player_area := $NearbyPlayerArea
onready var raycasts := $Raycasts.get_children()
onready var bottom_raycast := $Raycasts/BottomCast
onready var top_raycast := $Raycasts/TopCast
onready var left_raycast := $Raycasts/LeftCast
onready var right_raycast := $Raycasts/RightCast
var random_impulse_speed : float
var runaway_speed := Globals.CELL_SIZE * 0.5
var max_runaway_speed := Globals.CELL_SIZE * 5
var runaway_vector : Vector2 = Vector2.ZERO
var can_be_hit := true
signal player_got_a_punch

func _ready():
	connect('player_got_a_punch',get_parent(),'_increase_local_score')
	_weight = 10
	bounce = .5

func _on_ImpulseTimer_timeout():
	var impulse_vector : Vector2
	var do_flip_x := randi() % 2
	var do_flip_y := randi() % 2
	
	impulse_vector.x = rand_range(Globals.CELL_SIZE * 40, Globals.CELL_SIZE * 80)
	impulse_vector.y = rand_range(Globals.CELL_SIZE * 40, Globals.CELL_SIZE * 80)
	
	if do_flip_x:
		impulse_vector.x *= -1
	if do_flip_y:
		impulse_vector.y *= -1
	
	apply_central_impulse(impulse_vector)


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


func _on_HitCooldownTimer_timeout():
	can_be_hit = true
	modulate.a = 1