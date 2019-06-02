extends KinematicBody2D
#warning-ignore-all:unused_class_variable
const UP : Vector2 = Vector2.UP
const SLOPE_STOP : int = 64
const DROP_THRU_BIT : int = 4
const WALL_JUMP_VELOCITY : Vector2 = Vector2(900, -1200)

var velocity : Vector2
var target_velocity : float
var move_direction : int
var wall_direction : int = 1
var move_speed : float = 14 * Globals.CELL_SIZE
var gravity : float

var is_grounded : bool
var is_jumping : bool = false

var max_jump_velocity : float
var min_jump_velocity : float
var max_jump_height : float = 7.25 * Globals.CELL_SIZE
var min_jump_height : float = 0.8 * Globals.CELL_SIZE
var jump_duration : float = 0.4

var move_left : String
var move_right : String
var move_down : String
var move_jump : String

onready var wall_slide_cooldown : Node = $WallSlideCooldown
onready var raycasts : Node = $GroundRaycasts
onready var left_wall_raycasts : Node = $WallRaycasts/LeftWallRaycasts
onready var right_wall_raycasts : Node = $WallRaycasts/RightWallRaycasts
onready var wall_slide_sticky_timer : Node = $WallSlideStickyTimer



func _ready():
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
