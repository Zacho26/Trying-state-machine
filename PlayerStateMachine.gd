extends StateMachine

func _ready():
	_init_states()
	call_deferred("_set_state", states.idle)

func _init_states():
	_add_state("idle")
	_add_state("run")
	_add_state("jump")
	_add_state("fall")

func _input(event):
	if [states.idle, states.run].has(state):
		if event.is_action_pressed("jump"):
			if Input.is_action_pressed("down"):
				if parent._check_is_grounded($DropthroughRay):
					parent.set_collision_mask_bit(parent.DROPTHROUGH_BIT, false)
			else:
				parent.velocity.y = parent.max_jump_velocity
				parent.is_jumping = true
	if state == states.jump:
		if event.is_action_released("jump") and parent.velocity.y < parent.min_jump_velocity:
			parent.velocity.y = parent.min_jump_velocity

func _state_logic(delta):
	parent._handle_move_input()
	parent._apply_gravity(delta)
	parent._apply_movement()

func _get_transition(delta):
	match state:
		states.idle:
			if !parent.is_grounded:
				if parent.velocity.y < 0:
					return states.jump
				if parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x != 0:
				return states.run
		states.run:
			if !parent.is_grounded:
				if parent.velocity.y < 0:
					return states.jump
				if parent.velocity.y > 0:
					return states.fall
			elif parent.velocity.x == 0:
				return states.idle
		states.jump:
			if parent.is_grounded:
				return states.idle
			elif parent.velocity.y >= 0:
				return states.fall
		states.fall:
			if parent.is_grounded:
				return states.idle
			elif parent.velocity.y < 0:
				return states.jump

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.anim_player.play("idle")
		states.run:
			parent.anim_player.play("run")
		states.jump:
			parent.anim_player.play("jump")
		states.fall:
			parent.anim_player.play("jump")
	
func _exit_state(old_state, new_state):
	pass

