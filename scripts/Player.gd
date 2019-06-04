 extends KinematicBody2D

const UP = Vector2.UP
const SLOPE_STOP = 64
const DROP_THRU_BIT = 4
const WALL_JUMP_VELOCITY = Vector2(900, -1200)

var velocity = Vector2()
var target_velocity = Vector2()
var move_direction
var wall_direction = 1
var move_speed = 14 * Globals.CELL_SIZE
var gravity

var is_grounded
var is_jumping = false
var can_punch = true
var punch_arm = 'left'

var max_jump_velocity
var min_jump_velocity
var max_jump_height = 7.25 * Globals.CELL_SIZE
var min_jump_height = 0.8 * Globals.CELL_SIZE
var jump_duration = 0.4
                                    

onready var body = $StateMachine/Sprites
onready var raycasts = $GroundRaycasts
onready var left_wall_raycasts = $WallRaycasts/LeftWallRaycasts
onready var right_wall_raycasts = $WallRaycasts/RightWallRaycasts
onready var wall_slide_cooldown = $WallSlideCooldown
onready var wall_slide_sticky_timer = $WallSlideStickyTimer

func _ready():
    gravity = 2 * max_jump_height / pow(jump_duration, 2)
    max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
    min_jump_velocity = -sqrt(2 * gravity * min_jump_height)

func _apply_gravity(delta):
    velocity.y += gravity * delta


func _cap_gravity_wall_slide():
    var max_velocity = 4 * Globals.CELL_SIZE if !Input.is_action_pressed('down') else 16 * Globals.CELL_SIZE
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
    var wall_jump_velocity = WALL_JUMP_VELOCITY
    wall_jump_velocity.x *= -wall_direction
    velocity.y = 0
    velocity += wall_jump_velocity
    
func punch():
    if can_punch:
        var hand = null
        var vel = Vector2(0,0)
        var body_part = $StateMachine/Sprites/Body
        var head = $StateMachine/Sprites/Head
        
        # dictate punch direction based on the head direction
        var dir = 1
        var scale = $StateMachine/Sprites/Head/Sprite.scale.x
        if scale > 0: dir = 1
        else: dir = -1
        # change hands for each punch
        if punch_arm == 'right':
            punch_arm = 'left'
            hand = get_node("StateMachine/Sprites/Left Hand")
        else:
            punch_arm = 'right'
            hand = get_node("StateMachine/Sprites/Right Hand")
            
        # launch hand
        vel = Vector2(hand.get_gravity_scale()*400*dir,0)
        hand.apply_central_impulse(vel)
        # launch body
        body_part.apply_torque_impulse(3000*dir)
        
        $StateMachine/AnimationPlayer.play('attack_'+punch_arm)
        
        can_punch = false
        $PunchCooldown.start()

func _punch_cooldown_reset(): can_punch = true

func _update_move_direction():
    move_direction = -int(Input.is_action_pressed('move_left')) + int(Input.is_action_pressed('move_right'))
    
    if move_direction != 0:
        # all nodes in here will be mirrored when changing directions
        # these range from simple sprites to feet that require mirroring the parent node, not the sprites themselves
        var mirror_group = [get_node("StateMachine/Sprites/Right Foot"),
                            get_node("StateMachine/Sprites/Left Foot"),
                            get_node("StateMachine/Sprites/Body/Body"),
                            get_node("StateMachine/Sprites/Head/Sprite"),
                            get_node("StateMachine/Sprites/Head/Face"),
                            get_node("StateMachine/Sprites/Right Hand/Sprite"),
                            get_node("StateMachine/Sprites/Left Hand/Sprite")]
        for i in mirror_group:
            var scale = i.get_scale()
            match move_direction:
                1: if scale.x < 0: scale.x *= -1
                -1: if scale.x > 0: scale.x *= -1
            i.set_scale(Vector2(scale.x,scale.y))


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
    var is_near_wall_left = _check_is_valid_wall(left_wall_raycasts)
    var is_near_wall_right = _check_is_valid_wall(right_wall_raycasts)

    if is_near_wall_left && is_near_wall_right:
        wall_direction = move_direction
    else:
        wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)


func _check_is_valid_wall(wall_raycasts):
    for raycast in wall_raycasts.get_children():
        if raycast.is_colliding():
            var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
            if dot > PI * 0.35 && dot < PI * 0.55:
                return true
    return false


func _on_FallingThroughPlatformArea_body_exited(body):
    set_collision_mask_bit(DROP_THRU_BIT, true)
