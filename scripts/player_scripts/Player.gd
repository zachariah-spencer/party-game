extends KinematicBody2D

class_name Player
#warning-ignore-all:unused_class_variable


#variable declaration
const SLOPE_STOP := 64
const DROP_THRU_BIT := 4
const WALL_JUMP_INWARD_VELOCITY := Vector2(-1000, -1200)
const WALL_JUMP_OUTWARD_VELOCITY := Vector2(-600, -1000)
const PUNCH_DISTANCE := 800

var disable_jumping := false
var disable_movement := false
var disable_fists := false
var spawn_point : Node2D

var can_wall_jump := true
var can_jump := true
var velocity : Vector2
var adjusted_velocity : Vector2
var target_velocity : float
var move_direction := Vector2.ZERO
var move_direction_adjusted = Vector2.ZERO
var aim_direction := Vector2.ZERO
var facing_direction := 1.0
var wall_direction := 1.0
var move_speed := 14.0 * Globals.CELL_SIZE
var hit_points := 100
var held_item
var holding_item := false

var can_attack := true
var punch_arm := 'left'
var attack_area
var hit_exceptions := []

var max_jump_height := 8.25 * Globals.CELL_SIZE
var min_jump_height := 0.8 * Globals.CELL_SIZE
var jump_duration := 0.4

var face_textures := [['normal',preload("res://assets/player/face_v.png")],
					 ['punch',preload("res://assets/player/face_punch.png")],
					 ['ecstasy',preload("res://assets/player/face_ecstasy.png")],
					 ['dead',preload("res://assets/player/face_dead.png")],
					 ['taunt1-1',preload("res://assets/player/face_wacky_1.png")],
					 ['taunt1-2',preload("res://assets/player/face_wacky_2.png")]]

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
var taunt_input1 : String
var taunt_input2 : String
var taunt_input3 : String
var taunt_input4 : String

var state = null setget _set_state
var previous_state = null
var states : Dictionary = {}
var wall_action : Vector2

onready var parent := get_parent()
onready var local_score := $LocalScore
onready var state_label := $StateLabel
onready var hit_points_label := $HitPoints
onready var anim_tree := $Rig/AnimationTree

onready var jump_cooldown := $JumpCooldownTimer
onready var fall_through_timer := $FallThroughTimer
onready var wall_slide_cooldown := $WallSlideCooldown

onready var wall_slide_sticky_timer := $WallSlideStickyTimer
onready var attack_timer := $AttackTimer
onready var attack_cooldown_timer := $AttackCooldown
onready var hurt_cooldown_timer := $HurtCooldownTimer
onready var feet_timer := $WalkingFeetTimer

onready var fall_through_area := $FallingThroughPlatformArea
onready var left_wall_raycasts := $WallRaycasts/LeftWallRaycasts
onready var right_wall_raycasts := $WallRaycasts/RightWallRaycasts
onready var platform_raycasts := $GroundRaycasts
onready var right_hand := $'Rig/Right Hand'
onready var left_hand := $'Rig/Left Hand'
onready var gravity_magnitude := 2 * max_jump_height / pow(jump_duration, 2)
onready var gravity = Vector2.DOWN
onready var max_jump_velocity = -sqrt(2 * gravity_magnitude * max_jump_height)
onready var min_jump_velocity = -sqrt(2 * gravity_magnitude * min_jump_height)

signal interacted
signal dropped

func _set_gravity(new_gravity := Vector2.DOWN ):
	gravity = new_gravity
	for raycast in platform_raycasts.get_children():
		raycast.cast_to = gravity*10

func _ready():
	_set_gravity(Vector2.DOWN)
	#call state machines ready function
	_state_machine_ready()
	#set players hitpoints box equal to his health
	_update_player_stats()
	#set idle facial expression
	_set_face()

	var interactables = get_tree().get_nodes_in_group('interactable')

	if interactables.size() != 0:
		for interactable in interactables:
			connect('interacted',interactable, 'interact')

func _physics_process(delta):
	if state != null:
		_state_logic(delta)
		var transition = _get_transition(delta)
		if transition != null:
			_set_state(transition)

func _input(event : InputEvent):
	
	if state != states.wall_slide:
		if event.is_action_pressed(taunt_input1):
			_taunt1()
		if event.is_action_pressed(taunt_input2):
			_taunt2()
		if event.is_action_pressed(taunt_input3):
			_taunt3()
		if event.is_action_pressed(taunt_input4):
			_taunt4()
	
	if event.is_action_pressed(attack_input) && attack_cooldown_timer.is_stopped() && state != states.wall_slide:
		if state == states.disabled :
			pass
		elif holding_item :
			throw()
		elif !_pickup_item() :
			attack()
	elif state == states.jump:
		#VARIABLE JUMP
		if event.is_action_released(move_jump) && adjusted_velocity.y < min_jump_velocity:
			velocity = (velocity - velocity.project(gravity)) + (min_jump_velocity * Vector2.DOWN.rotated(gravity.angle() - PI/2))

func hit(by : Node, damage : int, knockback := Vector2.ZERO, type := Damage.ENVIRONMENTAL) :
	var x = 40* Globals.CELL_SIZE
	var y = 500
	if knockback != Vector2.ZERO :
		velocity = ((Vector2.UP * y) + (x * sign(knockback.x)*Vector2.RIGHT)).rotated(gravity.angle() -PI/2)
	$Shockwave.set_emitting(true)

	if holding_item :
		held_item.hit(by, damage, knockback, type)
	#set a special h weight here
	_set_state(states.hitstun)
	hurt_cooldown_timer.start()

	if type == Damage.PUNCHES:
		match Manager.current_minigame.attack_mode:
			Manager.current_minigame.attack_modes.non_lethal:
				parent.play_random("Hit")
			Manager.current_minigame.attack_modes.lethal:
				hit_points -= damage
				$Rig/AnimationPlayer.play('hurt')
				parent.play_random("Hit")
	else:
		hit_points -= damage
		$Rig/AnimationPlayer.play('hurt')
		parent.play_random("Hit")


func jump():
	if !disable_jumping:
		parent.play_sound('Jump')
		velocity = max_jump_velocity*gravity
		can_jump = false

func wall_jump():
	if !disable_jumping:
		parent.play_sound('Jump')
		can_jump = false
		var wall_jump_velocity : Vector2
		if sign(facing_direction) == sign(wall_direction):
			wall_jump_velocity = WALL_JUMP_INWARD_VELOCITY
		else :
			wall_jump_velocity = WALL_JUMP_OUTWARD_VELOCITY

		var rotated = wall_jump_velocity.rotated(gravity.angle() - PI/2)
		velocity = rotated.project(gravity) + ((rotated - rotated.project(gravity)) * wall_direction)

func throw():
	if holding_item :
		parent.play_sound('Throw')
		holding_item = false
		var dir
		var pos = global_position + Vector2.UP * 20
		if aim_direction != Vector2.ZERO :
			dir = aim_direction
			pos += aim_direction * 50
		else :
			dir = facing_direction*Vector2.RIGHT.rotated(gravity.angle() - PI/2)
			pos += facing_direction*Vector2.RIGHT.rotated(gravity.angle() - PI/2)  * 20

		# throwing and item slightly changes velocity if it has weight
		if held_item._weight > 0 :
			velocity = Vector2.ZERO
			velocity -= dir.normalized()*held_item._weight*100
		held_item.throw(dir*1600, pos, self)
		held_item = null

func drop():
	if holding_item :
		holding_item = false
		held_item.throw(velocity, global_position+Vector2.DOWN*10 ,self)

func attack():
	if !disable_fists:
		emit_signal('interacted', self)
		var hand = null
		var vel = Vector2(0,0)
		var body_part = $Rig/Body
		var head = $Rig/Head
		parent.play_sound("Punch")

		# dictate punch direction based on the head direction
		var dir = 1
		var scale = $Rig/Head/Sprite.scale.x
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
			vel = dir * Vector2.RIGHT.rotated(gravity.angle() - PI/2) * hand.get_gravity_scale()*PUNCH_DISTANCE
#			vel = Vector2(hand.get_gravity_scale()*PUNCH_DISTANCE*dir,0)
		hand.apply_central_impulse(vel)
		# launch body
		body_part.apply_torque_impulse(3000*dir)

		$Rig/AnimationPlayer.play('attack_'+punch_arm)

		attack_area.monitoring = true
		attack_timer.start()
		attack_cooldown_timer.start()

func _update_player_stats():
	if Manager.current_minigame.visible_hp:
		hit_points_label.visible = true

	hit_points_label.text = String(hit_points)
	if hit_points <= 0:
		if !parent.is_dead():
			parent.die(Manager.current_minigame.allow_respawns)

func _apply_gravity(delta : float):
	if rotation != gravity.angle() - PI/2 :
		rotation = lerp(rotation, gravity.angle() - PI/2, .1)
	velocity += gravity*gravity_magnitude * delta


func _apply_movement():
	adjusted_velocity = velocity.rotated(-(gravity.angle() - PI/2))

	velocity = move_and_slide(velocity, -gravity, SLOPE_STOP)

	if !can_jump && is_on_floor() || !can_jump && state == states.wall_slide:
		if jump_cooldown.is_stopped():
			jump_cooldown.start()

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
	move_direction_adjusted = move_direction.rotated(gravity.angle() - PI/2)

	$Cast.cast_to = aim_direction * 150

	var x_comp = move_direction.cross(gravity)

	if x_comp != 0:
		# all nodes in here will be mirrored when changing directions
		# these range from simple sprites to feet that require mirroring the parent node, not the sprites themselves
		var mirror_group = [get_node("Rig/Right Foot"),
				get_node("Rig/Left Foot"),
				get_node("Rig/Body/Body"),
				get_node("Rig/Head/Sprite"),
				get_node("Rig/Head/Face"),
				get_node("Rig/Right Hand/Sprite"),
				get_node("Rig/Left Hand/Sprite")]
		#could implement face rotation here
		for i in mirror_group:
			var s = i.get_scale()
			if (s.x > 0 and x_comp < 0) or (s.x < 0 and x_comp > 0) :
				s.x *= -1
			i.scale.x = s.x
		facing_direction = x_comp

func _update_wall_direction():
	var is_near_wall_left : bool = _check_is_valid_wall(left_wall_raycasts)
	var is_near_wall_right : bool = _check_is_valid_wall(right_wall_raycasts)

	if is_near_wall_left && is_near_wall_right:
		wall_direction = move_direction.rotated(gravity.angle() + PI/2).x
	else:
		wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)

func _handle_move_input(h_weight := .2):
	if !disable_movement:
		var y_comp = velocity.project(gravity)
		var x_comp = (move_direction - move_direction.project(gravity)) * move_speed
		velocity = velocity.linear_interpolate(x_comp + y_comp, h_weight)


func _handle_wall_slide_sticking():
	var rel_move_dir = move_direction_adjusted.x
	
	if gravity.project(Vector2.LEFT).length() > 0.1 :
		rel_move_dir *= -1
	
	if sign(rel_move_dir) == sign(wall_direction) :
		wall_slide_sticky_timer.start()

#statemachine code begins here
func _state_machine_ready():
	_add_state('idle')
	_add_state('run')
	_add_state('jump')
	_add_state('fall')
	_add_state('wall_slide')
	_add_state('disabled')
	_add_state('hitstun')
	anim_tree.active = true
	anim_tree['parameters/playback'].start("Airborne")
	anim_tree['parameters/playback'].start("Grounded")
	anim_tree['parameters/Grounded/playback'].start("Idle")
	_set_state(states.idle)

func _add_state(state_name):
	states[state_name] = states.size()

func _state_logic(delta : float):
	_update_player_stats()
	_update_move_direction()
	_update_wall_direction()
	_update_wall_action()
	_apply_gravity(delta)
	if state != states.wall_slide and state != states.disabled:
		if state == states.hitstun :
			_handle_move_input(.02)
		elif state == states.jump or state == states.fall :
			_handle_move_input(.1)
		else :
			 _handle_move_input()
	if state == states.disabled:
		_stop_movement()
	if state == states.wall_slide:
		_cap_gravity_wall_slide()
		_handle_wall_slide_sticking()
	_handle_jumping()
	_apply_movement()

	anim_tree['parameters/Airborne/blend_position'] = adjusted_velocity.y / 300

func _get_transition(delta : float):
	match state:
		states.idle:
			if !is_on_floor():
				if adjusted_velocity.y < 0:
					return states.jump
				elif adjusted_velocity.y >= 0:
					return states.fall
			elif abs(move_direction_adjusted.x) > 0.1:
				return states.run
		states.run:
			if !is_on_floor():
				if adjusted_velocity.y < 0:
					return states.jump
				elif adjusted_velocity.y >= 0:
					return states.fall
			elif abs(move_direction_adjusted.x) < 0.1:
				return states.idle
		states.jump:
			if is_on_floor():
				return states.idle
			elif adjusted_velocity.y >= 0:
				return states.fall
		states.fall:
			if move_direction_adjusted.y > 0.5:
				set_collision_mask_bit(DROP_THRU_BIT, false)
			elif !_is_in_platform() :
				set_collision_mask_bit(DROP_THRU_BIT, true)
			if wall_direction != 0 && wall_slide_cooldown.is_stopped() && move_direction.project(wall_action).length() > 0 :
				return states.wall_slide
			elif is_on_floor():
				parent.play_sound('Land')
				return states.idle
			elif adjusted_velocity.y < 0:
				return states.jump
		states.wall_slide:
			if is_on_floor():
				return states.idle
			elif wall_direction == 0 :
				return states.fall

	#Error in transitions if this is returned
	return null

func _enter_state(new_state, old_state):

	var state_name = null
	var _state = null
	var anim = null
	var mod = 1.0

	match new_state:
		states.idle:
			state_name = "Grounded"
			anim = "Idle"
			_state = anim_tree['parameters/Grounded/playback']
			state_label.text = 'idle'
		states.run:
			state_name = "Grounded"
			if !disable_movement:
				anim = "Run"
				_state = anim_tree['parameters/Grounded/playback']
			state_label.text = 'run'
			feet_timer.start()
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
		states.hitstun:
			mod = .5
			state_label.text = 'hitstun'

	modulate.a = mod
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
		states.run:
			feet_timer.stop()

func _set_state(new_state):
	previous_state = state
	state = new_state

	if previous_state != null:
		_exit_state(previous_state, new_state)
	if new_state != null:
		_enter_state(new_state, previous_state)

func _set_face(type='default'):
	# this function will get called every time we need a new face
	# used for punching, but can also be used for more personality during the game
	# just leave this to me - TheMikirog
	var face = $Rig/Head/Face
	if type=='taunt1-1': face.set_texture(face_textures[4][1])
	elif type=='taunt1-2': face.set_texture(face_textures[5][1])
	else:
		# for now it's just the punching, but I plan to implement more
		face.set_texture(face_textures[0][1])
	
func _voice(type):
	# play a certain voice clip, sometimes these could be randomized
	if type == 'taunt1-1':
		if randi()%2 == 0: get_node('Taunts/1/A1').play()
		else: get_node('Taunts/1/A2').play()
	elif type == 'taunt1-2':
		if randi()%2 == 0: get_node('Taunts/1/B1').play()
		else: get_node('Taunts/1/B2').play()
		pass

func _update_wall_action():
	if wall_direction > 0 : wall_action = Vector2.LEFT.rotated(gravity.angle() + PI/2)
	if wall_direction < 0 : wall_action = Vector2.RIGHT.rotated(gravity.angle() + PI/2)
	return wall_action

func _pickup_item():
	var items = $PickupRange.get_overlapping_areas()
	var item = null
	for temp in items : if temp.is_in_group("item") : item = temp.get_parent()

	if item && item.grabbable && !disable_fists:
		set_item(item)
	elif item :
		item.grab(self)
	return holding_item

func set_item(item):
	if item:
		item.sprite = item.get_node('Obj/Sprite')
		holding_item = true
		item.grab(self)
		held_item = item
		item.position = Vector2.ZERO
		right_hand.call_deferred('add_child', item)

func _stop_movement():
	velocity = velocity.project(gravity)

func _handle_jumping():
	if move_direction_adjusted.y > 0.1 && fall_through_timer.is_stopped() && [states.idle, states.run].has(state):
		fall_through_timer.start()
	elif move_direction_adjusted.y < 0.1 :
		fall_through_timer.stop()

	if [states.idle, states.run].has(state) && state != states.wall_slide:
		#JUMP
		if Input.is_action_pressed(move_jump):

			if move_direction_adjusted.y > .2 && _is_on_platform():
				set_collision_mask_bit(DROP_THRU_BIT, false)
			elif can_jump:
				jump()
	elif state == states.wall_slide:

		if Input.is_action_pressed(move_jump) && can_jump:

			_set_state(states.jump)
			wall_jump()

func _is_in_platform():
	var is_in_platform := false
	for body in fall_through_area.get_overlapping_bodies():
		if body.get_collision_layer_bit(DROP_THRU_BIT) :
			return true
	return false

func _is_on_platform():
	for body in platform_raycasts.get_children():
		if body.is_colliding() :
			return true
	return false

func _check_is_valid_wall(wall_raycasts : Node):
	for raycast in wall_raycasts.get_children():
		if raycast.is_colliding():
			var dot : float = acos(Vector2.UP.rotated(gravity.angle() - PI/2).dot(raycast.get_collision_normal()))
			if dot > PI * 0.35 && dot < PI * 0.55:
				return true
	return false

func _cap_gravity_wall_slide():
	var max_velocity : float
#	if any part the move direction is "down"
	if move_direction.project(gravity).dot(gravity) > 0.3 :
		max_velocity = 16 * Globals.CELL_SIZE
	else:
		max_velocity = 4 * Globals.CELL_SIZE
	var y_comp = velocity.project(gravity)
	if y_comp.length() > max_velocity :
		velocity -= y_comp
		velocity += y_comp.normalized() *  max_velocity


func _on_JumpCooldownTimer_timeout():
	can_jump = true

func _on_FallThroughTimer_timeout():
	set_collision_mask_bit(DROP_THRU_BIT, false)

func _on_WallSlideStickyTimer_timeout():
	if state == states.wall_slide:
		_set_state(states.fall)

func _on_TopOfHeadArea_body_entered(affected_player):
	if not affected_player.is_in_group("player") :
		return
	var affected_player_feet = affected_player.get_node('Rig/Feet/CollisionShape2D')
	if affected_player.state == affected_player.states.fall:
		affected_player._set_state(affected_player.states.jump)
		affected_player.velocity.y = -30 * Globals.CELL_SIZE
		_set_state(states.fall)
		velocity.y = 25 * Globals.CELL_SIZE

func _on_AttackTimer_timeout():
	hit_exceptions = []
	attack_area.monitoring = false

func _on_AttackArea_body_entered(body):
	if body.has_method("hit") and not hit_exceptions.has(body):
		body.hit(self, 20, (body.global_position - global_position).normalized(), Damage.PUNCHES)
		hit_exceptions.append(body)

func _on_HurtCooldownTimer_timeout():
	_set_state(states.idle)


#handle all taunt a/v fx here
func _taunt1():
	print('taunt1')
	anim_tree['parameters/playback'].start("Taunt 1")

func _taunt2():
	print('taunt2')
	parent.play_sound('Taunts/2')

func _taunt3():
	print('taunt3')
	parent.play_sound('Taunts/3')

func _taunt4():
	print('taunt4')
	parent.play_sound('Taunts/4')

func _manual_move_hand(dir := Vector2.ZERO, force := 1, hand := 'right'):
	var body_part = $Rig/Body
	var head = $Rig/Head
	var vel = Vector2.ZERO
	var hand_ref
	
	# change hands for each punch
	if hand == 'right':
		hand_ref = right_hand
	elif hand == 'head':
		hand_ref = head
	else:
		hand_ref = left_hand
	
	vel = hand_ref.get_gravity_scale() * force * dir.normalized()
	hand_ref.apply_central_impulse(vel)

func _on_WalkingFeetTimer_timeout():
	parent.play_sound('Feet')
