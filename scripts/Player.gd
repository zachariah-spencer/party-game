extends KinematicBody2D

# TODO: implement mirroring on turning (without glitching out the arms)

var gravity
var velocity
export var max_speed : int
export var acceleration : float
export var deceleration : float
export var jump_height : int


func _ready():
    velocity = Vector2(0,0)
    gravity = Globals.GRAVITY
    $AnimationTree.set_active(true)
    
    #scaling variables
    jump_height *= 100
    max_speed *= 10
    

func _physics_process(delta):
    
    #gravity
    if is_on_floor():
        if velocity.y != 0: $AnimationTree['parameters/playback'].travel('Grounded') #change animation on landing
        velocity.y = 0
    else:
        if Input.is_action_pressed('ui_right') or Input.is_action_pressed('ui_left'):
            $AnimationTree['parameters/Grounded/playback'].travel('Run')
        else:
            $AnimationTree['parameters/Grounded/playback'].travel('Idle')
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
        $AnimationTree['parameters/playback'].travel('Airborne') #set animation on jump
        velocity.y = -jump_height
    
    #set jumping/falling animation depending on the vertical velocity
    $AnimationTree['parameters/Airborne/blend_position'] = velocity.y / 300
    
    move_and_slide(velocity, Globals.UP)