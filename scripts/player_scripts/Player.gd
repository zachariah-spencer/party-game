extends KinematicBody2D

class_name Player

#warning-ignore-all:unused_class_variable
const UP : Vector2 = Vector2.UP
const SLOPE_STOP : int = 64
const DROP_THRU_BIT : int = 4
const WALL_JUMP_INWARD_VELOCITY : Vector2 = Vector2(1000, -1200)
const WALL_JUMP_OUTWARD_VELOCITY : Vector2 = Vector2(600, -1000)
const PUNCH_DISTANCE := 800

var can_wall_jump := true
var can_jump := true
var velocity : Vector2
var target_velocity : float
var move_direction := Vector2.ZERO
var aim_direction := Vector2.ZERO
var facing_direction := 1.0
var wall_direction := 1.0
var move_speed : float = 14 * Globals.CELL_SIZE
var gravity : float
var hit_points : int = 100
var held_item
var holding_item := false

var is_grounded : bool
var is_jumping : bool = false
var can_attack := true
var is_attacking := false
var punch_arm := 'left'

var max_jump_velocity : float
var min_jump_velocity : float
var max_jump_height : float = 8.25 * Globals.CELL_SIZE
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
var move_up : String
var attack_input : String
var rs_left : String
var rs_right : String
var rs_down : String
var rs_up : String

var state = null setget set_state
var previous_state = null
var states : Dictionary = {}
var wall_action : String

onready var local_score := $LocalScore
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
onready var jump_cooldown := $JumpCooldownTimer
onready var fall_through_timer := $FallThroughTimer
onready var fall_through_area := $FallingThroughPlatformArea

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
	var max_velocity : float 
	
	if Input.is_action_pressed(move_down):
		max_velocity = 16 * Globals.CELL_SIZE
	else:
		max_velocity = 4 * Globals.CELL_SIZE
	velocity.y = min(velocity.y, max_velocity)

func _apply_movement():
	if is_jumping && velocity.y >= 0:
		is_jumping = false

	velocity = move_and_slide(velocity, UP, SLOPE_STOP)
	is_grounded = !is_jumping && _check_is_grounded()

	if !can_jump && is_on_floor() || !can_jump && state == states.wall_slide:
		if jump_cooldown.is_stopped():
			jump_cooldown.start()

func jump():
	velocity.y = max_jump_velocity
	can_jump = false
	is_jumping = true

func wall_jump():
	is_jumping = true
	can_jump = false
	var wall_jump_velocity : Vector2
	if sign(facing_direction) == sign(wall_direction):
		wall_jump_velocity = WALL_JUMP_INWARD_VELOCITY
	elif sign(facing_direction) != sign(wall_direction):
		wall_jump_velocity = WALL_JUMP_OUTWARD_VELOCITY
	wall_jump_velocity.x *= -wall_direction
	velocity.y = 0
	velocity += wall_jump_velocity

func throw():
	if holding_item :
		holding_item = false
		var dir
		var pos = global_position + Vector2.UP * 20
		if aim_direction.length() > .2 :
			dir = aim_direction
			pos += aim_direction * 50
		else :
			dir = facing_direction*Vector2.RIGHT
			pos += facing_direction*Vector2.RIGHT * 20

		# throwing and item slightly changes velocity if it has weight
		if held_item._weight > 0 :
			velocity = Vector2.ZERO
			velocity -= dir.normalized()*held_item._weight*100

		held_item.throw(dir*1600, pos, self)

func drop():
	if holding_item :
		holding_item = false
		held_item.throw(velocity, global_position+Vector2.DOWN*10 ,self)

func attack():
	if can_attack:
		var hand = null
		var vel = Vector2(0,0)
		var body_part = $StateMachine/Sprites/Body
		var head = $StateMachine/Sprites/Head
		parent.play_sound("Punch")

		# dictate punch direction based on the head direction
		var dir = 1
		var scale = $StateMachine/Sprites/Head/Sprite.scale.x
		if scale > 0: dir = 1
		else: dir = -1
		#actually use move_direction

		# change hands for each punch
		if punch_arm == 'right':
			punch_arm = 'left'
			hand = left_hand
		else:
			punch_arm = 'right'
			hand = right_hand

		# set hitbox
		attack_area = hand.get_node('Hitbox')
		# launch hand at an angle if there's a decent move_input, or just use facing
		if aim_direction != Vector2.ZERO:
			vel = hand.get_gravity_scale()*PUNCH_DISTANCE*aim_direction.normalized()
		else :
			vel = Vector2(hand.get_gravity_scale()*PUNCH_DISTANCE*dir,0)
		hand.apply_central_impulse(vel)
		# launch body
		body_part.apply_torque_impulse(3000*dir)

		$StateMachine/AnimationPlayer.play('attack_'+punch_arm)

		attack_area.monitoring = true
		is_attacking = true
		attack_timer.start()
		attack_cooldown_timer.start()

func _update_move_direction():


	move_direction.y = -Input.get_action_strength(move_up) + Input.get_action_strength(move_down)
	move_direction.x = -Input.get_action_strength(move_left) + Input.get_action_strength(move_right)
	aim_direction.y = -Input.get_action_strength(rs_up) + Input.get_action_strength(rs_down)
	aim_direction.x = -Input.get_action_strength(rs_left) + Input.get_action_strength(rs_right)
	#if no right stick input, use left stick

	#deadzones
	var deadzone = .25
	if aim_direction.length_squared() < deadzone :
		aim_direction = Vector2.ZERO
	else :
		aim_direction = aim_direction.normalized() * (aim_direction.length() - deadzone) / (1-deadzone)

	if move_direction.length_squared() < deadzone :
		move_direction = Vector2.ZERO
	else :
		move_direction = move_direction.normalized() * (move_direction.length() - deadzone) / (1-deadzone)



	if aim_direction == Vector2.ZERO :
		aim_direction = move_direction
	$RayCast2D.cast_to = aim_direction.normalized() * 300

	if move_direction.x != 0:
		# all nodes in here will be mirrored when changing directions
		# these range from simple sprites to feet that require mirroring the parent node, not the sprites themselves
		var mirror_group = [get_node("StateMachine/Sprites/Right Foot"),
				get_node("StateMachine/Sprites/Left Foot"),
				get_node("StateMachine/Sprites/Body/Body"),
				get_node("StateMachine/Sprites/Head/Sprite"),
				get_node("StateMachine/Sprites/Head/Face"),
				get_node("StateMachine/Sprites/Right Hand/Sprite"),
				get_node("StateMachine/Sprites/Left Hand/Sprite")]
		#could implement face rotation here
		for i in mirror_group:
			var s = i.get_scale()
			if (s.x > 0 and move_direction.x < 0) or (s.x < 0 and move_direction.x > 0) : s.x *= -1
			i.set_scale(Vector2(s.x,s.y))
		facing_direction = move_direction.x

func _handle_move_input():
	target_velocity = move_speed * move_direction.x
	velocity.x = lerp(velocity.x, target_velocity, _get_h_weight())

func _handle_wall_slide_sticking():
	if !Input.is_action_pressed(wall_action):
#	if move_direction.x != 0 && move_direction.x != wall_direction:
		if wall_slide_sticky_timer.is_stopped() && !Input.is_action_pressed(move_jump):
			wall_slide_sticky_timer.start()
	else:
		wall_slide_sticky_timer.stop()

func _get_h_weight():
	if is_on_floor():
		return 0.2
	else:
		if move_direction.x == 0:
			return 0.02
		elif sign(move_direction.x) == sign(velocity.x) && abs(velocity.x) > move_speed:
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
		wall_direction = move_direction.x
	else:
		wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)

func _check_is_valid_wall(wall_raycasts : Node):
	for raycast in wall_raycasts.get_children():
		if raycast.is_colliding():
			var dot : float = acos(Vector2.UP.dot(raycast.get_collision_normal()))
			if dot > PI * 0.35 && dot < PI * 0.55:
				return true
	return false

func _set_face():
	# this function will get called every time we need a new face
	# used for punching, but can also be used for more personality during the game
	# just leave this to me - TheMikirog
	var face = $StateMachine/Sprites/Head/Face

	# for now it's just the punching, but I plan to implement more
	face.set_texture(face_textures[0][1])

func _on_AttackTimer_timeout():
	hit_exceptions = []
	attack_area.monitoring = false
	is_attacking = false

func _on_AttackCooldown_timeout():
	can_attack = true

func hit(by : Node, damage : int, knockback :Vector2) :
	var x = 40* Globals.CELL_SIZE
	var y = 500
	velocity = (Vector2.UP * y + x * sign(knockback.x)*Vector2.RIGHT )
	$Shockwave.set_emitting(true)

	match Manager.current_minigame.attack_mode:
		Manager.current_minigame.attack_modes.non_lethal:
			pass
		Manager.current_minigame.attack_modes.lethal:
			hit_points -= damage
			$StateMachine/AnimationPlayer.play('hurt')
			parent.play_random("Hit")

var hit_exceptions = []

func _on_AttackArea_body_entered(body):
	if body.has_method("hit") and not hit_exceptions.has(body):
		body.hit(self, 20, (body.global_position - global_position).normalized())
		hit_exceptions.append(body)

func _update_player_stats():
	hit_points_label.text = String(hit_points)
	if hit_points == 0:
		if !parent.is_dead():
			parent.die(Manager.current_minigame.allow_respawns)

func _on_TopOfHeadArea_body_entered(affected_player):
	if not affected_player.is_in_group("player") :
		return
	var affected_player_feet = affected_player.get_node('StateMachine/Sprites/Feet/CollisionShape2D')
	if affected_player.state == affected_player.states.fall:
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
	add_state('disabled')
	anim_tree.active = true
	anim_tree['parameters/playback'].start("Airborne")
	anim_tree['parameters/playback'].start("Grounded")
	anim_tree['parameters/Grounded/playback'].start("Idle")
#	call_deferred('set_state', states.idle)
	set_state(states.idle)

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
	_handle_jumping()

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
			elif abs(move_direction.x) != 0:
				return states.run
		states.run:
			if !is_on_floor():
				if velocity.y < 0:
					return states.jump
				elif velocity.y >= 0:
					return states.fall
			elif abs(move_direction.x) == 0:
				return states.idle
		states.jump:
#			if wall_direction != 0  && wall_slide_cooldown.is_stopped() && Input.is_action_pressed(wall_action):
#				return states.wall_slide
			if is_on_floor():
				return states.idle
			elif velocity.y >= 0:
				return states.fall
		states.fall:
			if move_direction.y  > 0 :
				set_collision_mask_bit(DROP_THRU_BIT, false)
			elif !is_in_platform() :
				set_collision_mask_bit(DROP_THRU_BIT, true)
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
#			elif !Input.is_action_pressed(wall_action) && wall_slide_sticky_timer.is_stopped():
#				return states.fall

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
			set_collision_mask_bit(DROP_THRU_BIT, false)
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
	if wall_direction < 0 : wall_action = move_left
	if wall_direction > 0 : wall_action = move_right
	return wall_action

func _on_WallSlideStickyTimer_timeout():
	if state == states.wall_slide:
		set_state(states.fall)

func _pickup_item():
	var items = $PickupRange.get_overlapping_areas()
	var item = null
	for temp in items : if temp.is_in_group("item") : item = temp.get_parent()

	if item && item.grabbable:
		holding_item = true
		item.grab(self)
		held_item = item
		item.get_parent().remove_child(item)
		item.position = Vector2.ZERO
		right_hand.add_child(item)
	return holding_item

#for handling individual press events
func _input(event : InputEvent):
	if event.is_action_pressed(attack_input) && attack_cooldown_timer.is_stopped() && state != states.wall_slide && can_attack:
		if state == states.disabled :
			pass
		elif holding_item :
			throw()
		elif !_pickup_item() :
			attack()
	elif state == states.jump:
		#VARIABLE JUMP
		if event.is_action_released(move_jump) && velocity.y < min_jump_velocity:
			velocity.y = min_jump_velocity

func _stop_movement():
	velocity.x = 0

func _handle_jumping():
	if move_direction.y > 0 && fall_through_timer.is_stopped() && [states.idle, states.run].has(state):
		fall_through_timer.start()
	elif Input.is_action_just_released(move_down):
		fall_through_timer.stop()

	if [states.idle, states.run].has(state) && state != states.wall_slide:
		#JUMP
		if Input.is_action_pressed(move_jump):
			if move_direction.y > 0:
				set_collision_mask_bit(DROP_THRU_BIT, false)
			elif can_jump:
				jump()
	elif state == states.wall_slide:

		if Input.is_action_pressed(move_jump) && can_jump:

			set_state(states.jump)
			wall_jump()

func _on_JumpCooldownTimer_timeout():
	can_jump = true

func _on_FallThroughTimer_timeout():
	set_collision_mask_bit(DROP_THRU_BIT, false)

func is_in_platform():
	var is_in_platform := false
	for body in fall_through_area.get_overlapping_bodies():
		if ( body.get_collision_layer_bit(DROP_THRU_BIT) == true ):
			return true

	return false
