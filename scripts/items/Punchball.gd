extends Item
onready var impulse_timer := $ImpulseTimer
onready var punch_area := $PunchedArea
onready var hit_cooldown := $HitCooldownTimer
var random_impulse_speed := 20 * Globals.CELL_SIZE
var can_be_hit := true
signal player_got_a_punch

func _ready():
	connect('player_got_a_punch',get_parent(),'_increase_local_score')
	_weight = 10
	bounce = .5

func _on_ImpulseTimer_timeout():
	var offset_vector : Vector2
	var impulse_vector : Vector2
	offset_vector.x = rand_range(-random_impulse_speed,random_impulse_speed)
	offset_vector.y = rand_range(-random_impulse_speed,random_impulse_speed)
	impulse_vector.x = rand_range(-random_impulse_speed,random_impulse_speed)
	impulse_vector.y = rand_range(-random_impulse_speed,random_impulse_speed)
	
	apply_impulse(offset_vector, impulse_vector)


func _on_PunchedArea_body_entered(body):
	var player_fist = body if body.is_in_group('fist') else null
	var attacking_player = body.get_parent().get_parent().get_parent().get_parent()
	
	print(attacking_player.child.is_attacking)
	
	if can_be_hit && attacking_player.child.is_attacking:
		var impulse_vector : Vector2
		impulse_vector.x = rand_range(-random_impulse_speed,random_impulse_speed)
		impulse_vector.y = rand_range(-random_impulse_speed,random_impulse_speed)
		
		
		can_be_hit = false
		hit_cooldown.start()
		modulate.a = .5
		apply_central_impulse(impulse_vector * 25)
		
		if player_fist:
			emit_signal('player_got_a_punch', attacking_player, 1)


func _on_HitCooldownTimer_timeout():
	can_be_hit = true
	modulate.a = 1
