extends StateMachine
#warning-ignore-all:unused_argument

var wall_action : String

func _ready():
	add_state('idle')
	add_state('run')
	add_state('jump')
	add_state('fall')
	add_state('wall_slide')
	add_state('attack')
	$AnimationTree.active = true
	call_deferred('set_state', states.idle)

func _update_wall_action():
	match parent.wall_direction:
		-1:
			wall_action = parent.move_left
		1:
			wall_action = parent.move_right
	return wall_action

func _input(event : InputEvent):

	if event.is_action_pressed(parent.attack_input) && parent.attack_timer.is_stopped() && state != states.wall_slide && parent.can_attack:
		set_state(states.attack)
		parent.attack()

	if [states.idle, states.run].has(state) && state != states.wall_slide:
		#JUMP
		if event.is_action_pressed(parent.move_jump):
			if Input.is_action_pressed(parent.move_down):
				parent.set_collision_mask_bit(parent.DROP_THRU_BIT, false)
			else:
				parent.jump()
	elif state == states.wall_slide:

		if event.is_action_pressed(parent.move_jump) && Input.is_action_pressed(wall_action):

			set_state(states.jump)
			parent.wall_jump()

	elif state == states.jump:
		#VARIABLE JUMP
		if event.is_action_released(parent.move_jump) && parent.velocity.y < parent.min_jump_velocity:
			parent.velocity.y = parent.min_jump_velocity

func _state_logic(delta : float):
	parent._update_player_stats()
	parent._update_move_direction()
	parent._update_wall_direction()
	_update_wall_action()
	if state != states.wall_slide:
		parent._handle_move_input()
	parent._apply_gravity(delta)
	if state == states.wall_slide:
		parent._cap_gravity_wall_slide()
		parent._handle_wall_slide_sticking()
	parent._apply_movement()
	$AnimationTree['parameters/Airborne/blend_position'] = parent.velocity.y / 300

func _get_transition(delta : float):
	match state:
		states.idle:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y >= 0:
					return states.fall
			elif abs(parent.move_direction) != 0:
				return states.run
		states.run:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y >= 0:
					return states.fall
			elif abs(parent.move_direction) == 0:
				return states.idle
		states.jump:
			if parent.wall_direction != 0  && parent.wall_slide_cooldown.is_stopped() && Input.is_action_pressed(wall_action):
				return states.wall_slide
			elif parent.is_on_floor():
				return states.idle
			elif parent.velocity.y >= 0:
				return states.fall
		states.fall:
			if parent.wall_direction != 0 && parent.wall_slide_cooldown.is_stopped() && Input.is_action_pressed(wall_action):
				return states.wall_slide
			elif parent.is_on_floor():
				return states.idle
			elif parent.velocity.y < 0:
				return states.jump
		states.wall_slide:
			if parent.is_on_floor():
				return states.idle
			elif parent.wall_direction == 0:
				return states.fall
			elif !Input.is_action_pressed(wall_action):
				return states.fall
		states.attack:
			if parent.attack_timer.is_stopped():
				return states.idle

	#Error in transitions if this is returned
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			$AnimationTree['parameters/playback'].travel('Grounded')
			$AnimationTree['parameters/Grounded/playback'].travel('Idle')
			$StateLabel.text = 'idle'
		states.run:
			$AnimationTree['parameters/playback'].travel('Grounded')
			$AnimationTree['parameters/Grounded/playback'].travel('Run')
			$StateLabel.text = 'run'
		states.jump:
			$AnimationTree['parameters/playback'].travel('Airborne')
			$StateLabel.text = 'jump'
		states.fall:
			$AnimationTree['parameters/playback'].travel('Airborne')
			$StateLabel.text = 'fall'
		states.wall_slide:
			$StateLabel.text = 'wall_slide'#flip here
			#parent.anim_player.play('wall_slide')
#			parent.body.scale.x = -parent.wall_direction
	pass

func _exit_state(old_state, new_state):
	match old_state:
		states.wall_slide:
			parent.wall_slide_cooldown.start()

func _on_WallSlideStickyTimer_timeout():
	if state == states.wall_slide:
		set_state(states.fall)
