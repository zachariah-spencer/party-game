extends KinematicBody2D

var gravity
var velocity
export var max_speed : int
export var acceleration : float
export var deceleration : float
export var jump_height : int


func _ready():
	velocity = Vector2(0,0)
	gravity = Globals.GRAVITY
	
	#scaling variables
	jump_height *= 100
	max_speed *= 10

func _physics_process(delta):
	
	#gravity
	if is_on_floor():
		velocity.y = 0
	else:
		velocity.y += gravity
	
	#left and right movement
	if Input.is_action_pressed('ui_right'):
		if velocity.x < max_speed:
			velocity.x += acceleration
		elif velocity.x > max_speed:
			velocity.x = max_speed
	elif Input.is_action_pressed('ui_left'):
		if velocity.x > -max_speed:
			velocity.x -= acceleration
		elif velocity.x < -max_speed:
			velocity.x = -max_speed
	else:
		if is_on_floor():
			velocity.x *= deceleration
	
	#jump movement
	if Input.is_action_pressed('ui_accept') && is_on_floor():
		velocity.y = -jump_height
	
	move_and_slide(velocity, Globals.UP)