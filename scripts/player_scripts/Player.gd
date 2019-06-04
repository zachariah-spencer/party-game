extends KinematicBody2D
#warning-ignore-all:unused_class_variable
const UP : Vector2 = Vector2.UP
const SLOPE_STOP : int = 64
const DROP_THRU_BIT : int = 4
const WALL_JUMP_VELOCITY : Vector2 = Vector2(900, -1200)

var velocity : Vector2
var target_velocity : float
var move_direction : int
var facing_direction : int = 1
var wall_direction : int = 1
var move_speed : float = 14 * Globals.CELL_SIZE
var gravity : float
var hit_points : int = 100

var is_grounded : bool
var is_jumping : bool = false
var can_attack = true

var max_jump_velocity : float
var min_jump_velocity : float
var max_jump_height : float = 7.25 * Globals.CELL_SIZE
var min_jump_height : float = 0.8 * Globals.CELL_SIZE
var jump_duration : float = 0.4

var move_left : String
var move_right : String
var move_down : String
var move_jump : String
var attack_input : String

onready var hit_points_label : Node = $StateMachine/HitPoints
onready var attack_area : Node = $AttackArea
onready var wall_slide_cooldown : Node = $WallSlideCooldown
onready var raycasts : Node = $GroundRaycasts
onready var left_wall_raycasts : Node = $WallRaycasts/LeftWallRaycasts
onready var right_wall_raycasts : Node = $WallRaycasts/RightWallRaycasts
onready var wall_slide_sticky_timer : Node = $WallSlideStickyTimer
onready var attack_timer : Node = $AttackTimer
onready var attack_cooldown_timer : Node = $AttackCooldown
onready var right_fist: Node = get_node('StateMachine/Sprites/Right Hand')
onready var left_fist: Node = get_node('StateMachine/Sprites/Left Hand')


func _ready():
	hit_points_label.text = String(hit_points)
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)


func _apply_gravity(delta : float):
	velocity.y += gravity * delta


func _cap_gravity_wall_slide():
	var max_velocity : float = 4 * Globals.CELL_SIZE if !Input.is_action_pressed(move_down) else 16 * Globals.CELL_SIZE
	velocity.y = min(velocity.y, max_velocity)


func _apply_movement():
	if is_jumping && velocity.y >= 0:
		is_jumping = false
	velocity = move_and_slide(velocity, UP, SLOPE_STOP)
	is_grounded = !is_jumping && _check_is_grounded()


func jump():
	velocity.y = max_jump_velocity
	is_jumping = true


func wall_jump():
	var wall_jump_velocity : Vector2 = WALL_JUMP_VELOCITY
	wall_jump_velocity.x *= -wall_direction
	velocity.y = 0
	velocity += wall_jump_velocity


func _update_move_direction():
	move_direction = -int(Input.is_action_pressed(move_left)) + int(Input.is_action_pressed(move_right))
	if move_direction != 0:
		facing_direction = move_direction
	if facing_direction < 0:
		attack_area.position.x = -35
	elif facing_direction > 0:
		attack_area.position.x = 35


func _handle_move_input():
	target_velocity = move_speed * move_direction
	velocity.x = lerp(velocity.x, target_velocity, _get_h_weight())
#	if move_direction != 0:
#		$Body.scale.x = move_direction

func _handle_wall_slide_sticking():
	if move_direction != 0 && move_direction != wall_direction:
		if wall_slide_sticky_timer.is_stopped():
			wall_slide_sticky_timer.start()
	else:
		wall_slide_sticky_timer.stop()


func _get_h_weight():
	if is_on_floor():
		return 0.2
	else:
		if move_direction == 0:
			return 0.02
		elif move_direction == sign(velocity.x) && abs(velocity.x) > move_speed:
			return 0.0
		else:
			return 0.1


func _check_is_grounded():
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true

	# If loop completes then raycast was not detected so return false
	return false


func _update_wall_direction():
	var is_near_wall_left : bool = _check_is_valid_wall(left_wall_raycasts)
	var is_near_wall_right : bool = _check_is_valid_wall(right_wall_raycasts)

	if is_near_wall_left && is_near_wall_right:
		wall_direction = move_direction
	else:
		wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)


func _check_is_valid_wall(wall_raycasts : Node):
	for raycast in wall_raycasts.get_children():
		if raycast.is_colliding():
			var dot : float = acos(Vector2.UP.dot(raycast.get_collision_normal()))
			if dot > PI * 0.35 && dot < PI * 0.55:
				return true
	return false


func _on_FallingThroughPlatformArea_body_exited():
	set_collision_mask_bit(DROP_THRU_BIT, true)

func attack():
	attack_timer.start()
	attack_area.monitoring = true
	can_attack = false

func _is_attack_over():
	if attack_timer.is_stopped():
		return true
	else:
		return false

func _on_AttackTimer_timeout():
	attack_area.monitoring = false
	attack_cooldown_timer.start()

func _on_AttackCooldown_timeout():
	can_attack = true

func _on_AttackArea_body_entered(body):
	#determine attack type from gamemode and handle attack interaction accordingly
	match Manager.current_game_attack_mode:
		'nonlethal':
			bump_player(body)
		'lethal':
			bump_player(body)
			hurt_player(body)

#func handle_player_attacked(body):
#	#determine attack type from gamemode and handle attack interaction accordingly
#	match Manager.current_game_attack_mode:
#		'nonlethal':
#			bump_player(body)
#		'lethal':
#			bump_player(body)
#			hurt_player(body)

func bump_player(affected_player):
	var bump_velocity : Vector2 = Vector2(0,-500)
	bump_velocity.x = (50 * Globals.CELL_SIZE) * facing_direction
	affected_player.velocity = bump_velocity

func hurt_player(affected_player):
	affected_player.get_node('StateMachine/AnimationPlayer').play('hurt')
	affected_player.hit_points -= 20

func die():
	#remove controllable player instance
	queue_free()
	#instance ragdoll player
		#CODE GOES HERE
	#begin respawntimer
	get_parent().respawn_timer.start()

func die_no_respawn():
	queue_free()

func _update_player_stats():
	hit_points_label.text = String(hit_points)
	if hit_points == 0:
		if Manager.current_game_allow_respawns == true:
			die()
		elif Manager.current_game_allow_respawns == false:
			die_no_respawn()


#BOTH OF THESE FUNCTIONS ARE MEANT TO POTENTIALLY REPLACE THE ATTACKAREA NODE BUT STILL NEED SOME WORK DONE SO THAT THE HANDS DONT COLLIDE WITH THE ORIGINAL PLAYER
func _on_Right_Hand_body_entered(body):
	if $StateMachine.state == $StateMachine.states.attack:
#		handle_player_attacked(body)
		pass
func _on_Left_Hand_body_entered(body):
	if $StateMachine.state == $StateMachine.states.attack:
#		handle_player_attacked(body)
		pass
