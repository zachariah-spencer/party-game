extends KinematicBody2D
#warning-ignore-all:unused_class_variable
const UP : Vector2 = Vector2.UP
const SLOPE_STOP : int = 64
const DROP_THRU_BIT : int = 4
const WALL_JUMP_VELOCITY : Vector2 = Vector2(900, -1200)
const PUNCH_DISTANCE := 600

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
var can_attack := true
var punch_arm := 'left'

var max_jump_velocity : float
var min_jump_velocity : float
var max_jump_height : float = 7.25 * Globals.CELL_SIZE
var min_jump_height : float = 0.8 * Globals.CELL_SIZE
var jump_duration : float = 0.4

var face_textures = [['normal',preload("res://assets/player/face_v.png")],
					 ['punch',preload("res://assets/player/face_punch.png")],
					 ['ecstasy',preload("res://assets/player/face_ecstasy.png")],
					 ['dead',preload("res://assets/player/face_dead.png")]]

var move_left : String
var move_right : String
var move_down : String
var move_jump : String
var attack_input : String

var state = null setget set_state
var previous_state = null
var states : Dictionary = {}
var wall_action : String

onready var state_label : Label = $StateMachine/StateLabel
onready var anim_tree : AnimationTree = $StateMachine/AnimationTree
onready var state_machine := $StateMachine
onready var parent : Node = get_parent()
onready var hit_points_label : Node = $StateMachine/HitPoints
onready var attack_area : Area2D
onready var wall_slide_cooldown : Node = $WallSlideCooldown
onready var raycasts : Node = $GroundRaycasts
onready var left_wall_raycasts : Node = $WallRaycasts/LeftWallRaycasts
onready var right_wall_raycasts : Node = $WallRaycasts/RightWallRaycasts
onready var wall_slide_sticky_timer : Node = $WallSlideStickyTimer
onready var attack_timer : Node = $AttackTimer
onready var attack_cooldown_timer : Node = $AttackCooldown
onready var right_hand := $'StateMachine/Sprites/Right Hand'
onready var left_hand := $'StateMachine/Sprites/Left Hand'


func _ready():
	_state_machine_ready()
	right_hand.get_node('Hitbox').connect("body_entered", self, "_on_AttackArea_body_entered")
	left_hand.get_node('Hitbox').connect("body_entered", self, "_on_AttackArea_body_entered")
	hit_points_label.text = String(hit_points)
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)
	_set_face()

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

func attack():
	if can_attack:
		var hand = null
		var vel = Vector2(0,0)
		var body_part = $StateMachine/Sprites/Body
		var head = $StateMachine/Sprites/Head
		$Sounds/Punch.play()

		# dictate punch direction based on the head direction
		var dir = 1
		var scale = $StateMachine/Sprites/Head/Sprite.scale.x
		if scale > 0: dir = 1
		else: dir = -1
		# change hands for each punch
		if punch_arm == 'right':
			punch_arm = 'left'
			hand = left_hand
		else:
			punch_arm = 'right'
			hand = right_hand

		# set hitbox
		attack_area = hand.get_node('Hitbox')
		# launch hand
		vel = Vector2(hand.get_gravity_scale()*PUNCH_DISTANCE*dir,0)
		hand.apply_central_impulse(vel)
		# launch body
		body_part.apply_torque_impulse(3000*dir)

		$StateMachine/AnimationPlayer.play('attack_'+punch_arm)

		attack_area.monitoring = true
		attack_timer.start()

func _update_move_direction():
	move_direction = -int(Input.is_action_pressed(move_left)) + int(Input.is_action_pressed(move_right))
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
		facing_direction = move_direction

func _handle_move_input():
	target_velocity = move_speed * move_direction
	velocity.x = lerp(velocity.x, target_velocity, _get_h_weight())

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
	if is_instance_valid(raycasts):
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
	if !is_instance_valid(wall_raycasts) :
		return false
	for raycast in wall_raycasts.get_children():
		if raycast.is_colliding():
			var dot : float = acos(Vector2.UP.dot(raycast.get_collision_normal()))
			if dot > PI * 0.35 && dot < PI * 0.55:
				return true
	return false


func _on_FallingThroughPlatformArea_body_exited(body):
	set_collision_mask_bit(DROP_THRU_BIT, true)

func _set_face():
	# this function will get called every time we need a new face
	# used for punching, but can also be used for more personality during the game
	# just leave this to me - TheMikirog
	var face = $StateMachine/Sprites/Head/Face

	# for now it's just the punching, but I plan to implement more
	face.set_texture(face_textures[0][1])

func _on_AttackTimer_timeout():
	attack_area.monitoring = false
	attack_cooldown_timer.start()

func _on_AttackCooldown_timeout():
	can_attack = true

func _on_AttackArea_body_entered(body):
	#determine attack type from gamemode and handle attack interaction accordingly
	match Manager.current_minigame.attack_mode:
		Manager.current_minigame.attack_modes.non_lethal:
			bump_player(body)
		Manager.current_minigame.attack_modes.lethal:
			bump_player(body)
			hurt_player(body)

func bump_player(affected_player):
	var bump_velocity : Vector2 = Vector2(0,-500)
	bump_velocity.x = (25 * Globals.CELL_SIZE) * facing_direction
	affected_player.velocity = bump_velocity

func hurt_player(affected_player):
	affected_player.get_node('StateMachine/AnimationPlayer').play('hurt')
	affected_player.hit_points -= 20

func _update_player_stats():
	#hit_points_label.text = String(hit_points)
	if hit_points == 0:
		if !parent.is_dead():
			parent.die(Manager.current_minigame.allow_respawns)

func _on_TopOfHeadArea_body_entered(affected_player):
	var affected_player_feet = affected_player.get_node('StateMachine/Sprites/Feet/CollisionShape2D')
	if affected_player.state != affected_player.states.jump:
		affected_player.set_state(affected_player.states.jump)
		affected_player.velocity.y = -30 * Globals.CELL_SIZE
		set_state(states.fall)
		velocity.y = 25 * Globals.CELL_SIZE


#statemachine code begins here
func _state_machine_ready():
	add_state('idle')
	add_state('run')
	add_state('jump')
	add_state('fall')
	add_state('wall_slide')
	add_state('attack')
	add_state('disabled')
	anim_tree.active = true
	anim_tree['parameters/playback'].start("Airborne")
	anim_tree['parameters/playback'].start("Grounded")
	anim_tree['parameters/Grounded/playback'].start("Idle")
	call_deferred('set_state', states.idle)

func _physics_process(delta):
	if state != null:
		_state_logic(delta)
		var transition = _get_transition(delta)
		if transition != null:
			set_state(transition)

func _state_logic(delta : float):
	
		_update_player_stats()
		if state != states.disabled:
			_update_move_direction()
		else:
			_stop_movement()
		_update_wall_direction()
		_update_wall_action()
		_apply_gravity(delta)
		if state != states.wall_slide:
			if state != states.disabled:
				_handle_move_input()
		if state == states.wall_slide:
			_cap_gravity_wall_slide()
			_handle_wall_slide_sticking()
		_apply_movement()
		
		anim_tree['parameters/Airborne/blend_position'] = velocity.y / 300

func _get_transition(delta : float):
	match state:
		states.idle:
			if !is_on_floor():
				if velocity.y < 0:
					return states.jump
				elif velocity.y >= 0:
					return states.fall
			elif abs(move_direction) != 0:
				return states.run
		states.run:
			if !is_on_floor():
				if velocity.y < 0:
					return states.jump
				elif velocity.y >= 0:
					return states.fall
			elif abs(move_direction) == 0:
				return states.idle
		states.jump:
			if wall_direction != 0  && wall_slide_cooldown.is_stopped() && Input.is_action_pressed(wall_action):
				return states.wall_slide
			elif is_on_floor():
				return states.idle
			elif velocity.y >= 0:
				return states.fall
		states.fall:
			if wall_direction != 0 && wall_slide_cooldown.is_stopped() && Input.is_action_pressed(wall_action):
				return states.wall_slide
			elif is_on_floor():
				return states.idle
			elif velocity.y < 0:
				return states.jump
		states.wall_slide:
			if is_on_floor():
				return states.idle
			elif wall_direction == 0:
				return states.fall
			elif !Input.is_action_pressed(wall_action):
				return states.fall
		states.attack:
			if attack_timer.is_stopped():
				return states.idle

	#Error in transitions if this is returned
	return null

func _enter_state(new_state, old_state):

	var state_name = null
	var _state = null
	var anim = null

	match new_state:
		states.idle:
			state_name = "Grounded"
			anim = "Idle"
			_state = anim_tree['parameters/Grounded/playback']
			state_label.text = 'idle'
		states.run:
			state_name = "Grounded"
			anim = "Run"
			_state = anim_tree['parameters/Grounded/playback']
			state_label.text = 'run'
		states.jump:
			state_name = "Airborne"
			state_label.text = 'jump'
		states.fall:
			state_name = "Airborne"
			state_label.text = 'fall'
		states.wall_slide:
			state_label.text = 'wall_slide'
		states.disabled:
			state_name = "Grounded"
			anim = "Idle"
			_state = anim_tree['parameters/Grounded/playback']
			state_label.text = 'disabled'

	if state_name :
		var playback = anim_tree['parameters/playback']
		if !playback.is_playing() :
			playback.start(state_name)
		else :
			playback.travel(state_name)
		if _state :
			if !_state.is_playing() :
				_state.start(anim)
			else :
				_state.travel(anim)



	pass

func _exit_state(old_state, new_state):
	match old_state:
		states.wall_slide:
			wall_slide_cooldown.start()

func set_state(new_state):
	previous_state = state
	state = new_state

	if previous_state != null:
		_exit_state(previous_state, new_state)
	if new_state != null:
		_enter_state(new_state, previous_state)

func add_state(state_name):
	states[state_name] = states.size()

func _update_wall_action():
	match wall_direction:
		-1:
			wall_action = move_left
		1:
			wall_action = move_right
	return wall_action

func _on_WallSlideStickyTimer_timeout():
	if state == states.wall_slide:
		set_state(states.fall)

func _input(event : InputEvent):

	if event.is_action_pressed(attack_input) && attack_timer.is_stopped() && state != states.wall_slide && can_attack:
		set_state(states.attack)
		attack()

	if [states.idle, states.run].has(state) && state != states.wall_slide:
		#JUMP
		if event.is_action_pressed(move_jump):
			if Input.is_action_pressed(move_down):
				set_collision_mask_bit(DROP_THRU_BIT, false)
			else:
				jump()
	elif state == states.wall_slide:

		if event.is_action_pressed(move_jump) && Input.is_action_pressed(wall_action):

			set_state(states.jump)
			wall_jump()

	elif state == states.jump:
		#VARIABLE JUMP
		if event.is_action_released(move_jump) && velocity.y < min_jump_velocity:
			velocity.y = min_jump_velocity

func _stop_movement():
	velocity.x = 0