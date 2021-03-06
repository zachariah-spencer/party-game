extends Item
onready var impulse_timer := $ImpulseTimer
onready var hit_cooldown := $HitCooldownTimer
onready var runaway_area := $RunawayArea
export var random_speed := 200
export var runaway_speed := 32
export var knockback_speed := 100
var player_near_ball : Player
var can_be_hit := true
var painful := false
var players_hit := []

onready var pain_area := $PainfulArea

signal player_got_a_punch

func _ready():
	connect('player_got_a_punch',get_parent().get_parent(),'_increase_local_score')
	$Hover.play()
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

func hit(by : Node2D, damage : int, knockback := Vector2.ZERO, type := Damage.ENVIRONMENTAL):
	if can_be_hit :
		$Hit.play()
		$Hover.pitch_scale += 2
		var knockback_velocity : Vector2 = Vector2.ZERO
		var dist = global_position - by.global_position
		
		knockback_velocity.x = sign(dist.x)  * knockback_speed
		knockback_velocity.y = sign(dist.y) * knockback_speed
		apply_central_impulse(knockback_velocity)

		can_be_hit = false
		painful = true
		hit_cooldown.start()
		$Obj/Sprite.modulate = Color.darkred

func _on_HitCooldownTimer_timeout():
	$Hover.pitch_scale -= 2
	painful = false
	can_be_hit = true
	$Obj/Sprite.modulate = Color.white

	set_collision_mask_bit(1, true)
	set_collision_mask_bit(2, true)

	for player in Players._get_alive_players():
		pain_area.set_collision_mask_bit(player.single_bit, true)
		player.child.modulate.a = 1

func _on_RunawayArea_body_entered(body):
	player_near_ball = body as Player


func _on_RunawayArea_body_exited(body):
	player_near_ball = null


func _on_PainfulArea_body_entered(body):
	var player = body as Player
	if player && painful:
		player.hit(self, 50, linear_velocity.length() * Vector2.ONE, Damage.ENVIRONMENTAL)
		pain_area.set_collision_mask_bit(player.parent.single_bit, false)
		player.modulate.a = .5
		players_hit.append(player)


func _on_Punchball_body_entered(body):
	$Collision.play()
