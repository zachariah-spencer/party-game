extends StateMachine

func _ready():
	add_state('idle')
	add_state('run')
	add_state('jump')
	add_state('fall')
	add_state('wall_slide')
	call_deferred('set_state', states.idle)

func _input(event):
	if [states.idle, states.run].has(state) && state != states.wall_slide:
		#JUMP
		if event.is_action_pressed('jump'):
			if Input.is_action_pressed('down'):
				parent.set_collision_mask_bit(parent.DROP_THRU_BIT, false)
			else:
				parent.jump()
	elif state == states.wall_slide:
		if event.is_action_pressed('jump'):
			set_state(states.jump)
			parent.wall_jump()
			
	elif state == states.jump:
		#VARIABLE JUMP
		if event.is_action_released('jump') && parent.velocity.y < parent.min_jump_velocity:
			parent.velocity.y = parent.min_jump_velocity

func _state_logic(delta):
	parent._update_move_direction()
	parent._update_wall_direction()
	if state != states.wall_slide:
		parent._handle_move_input()
	parent._apply_gravity(delta)
	if state == states.wall_slide:
		parent._cap_gravity_wall_slide()
		parent._handle_wall_slide_sticking()
	parent._apply_movement()

func _get_transition(delta):
	match state:
		states.idle:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y >= 0:
					return states.fall
			elif parent.velocity.x != 0:
				return states.run
		states.run:
			if !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y >= 0:
					return states.fall
			elif parent.velocity.x == 0:
				return states.idle
		states.jump:
			if parent.wall_direction != 0  && parent.wall_slide_cooldown.is_stopped():
				return states.wall_slide
			elif parent.is_on_floor():
				return states.idle
			elif parent.velocity.y >= 0:
				return states.fall
		states.fall:
			if parent.wall_direction != 0 && parent.wall_slide_cooldown.is_stopped():
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
	
	#Error in transitions if this is returned
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			pass
			#parent.anim_player.play('idle')
		states.run:
			pass
			#parent.anim_player.play('run')
		states.jump:
			pass
			#parent.anim_player.play('jump')
		states.fall:
			pass
			#parent.anim_player.play('fall')
		states.wall_slide:
			#parent.anim_player.play('wall_slide')
			parent.body.scale.x = -parent.wall_direction
	pass

func _exit_state(old_state, new_state):
	match old_state:
		states.wall_slide:
			parent.wall_slide_cooldown.start()

func _on_WallSlideStickyTimer_timeout():
	if state == states.wall_slide:
		set_state(states.fall)
