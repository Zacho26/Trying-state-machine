extends KinematicBody2D

#necessary consts
const UP = Vector2(0, -1)
const SLOPE_STOP = 64
const DROPTHROUGH_BIT = 1

#kinematic vars
var velocity = Vector2()
var move_speed = 5 * 16
var gravity
var max_jump_velocity
var min_jump_velocity
var is_grounded
var is_jumping = false

var min_jump_height = 0.8 * Globals.unit_size
var max_jump_height = 2.25 * Globals.unit_size
var jump_duration = 0.5

#onreadies
onready var raycast_ground = $RayCast2D
onready var anim_player = $body/AnimationPlayer
onready var state_machine = $StateMachine

#called when ready to set base variables
func _ready():
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)

func _apply_gravity(delta):	
	velocity.y += gravity * delta #apply gravity

func _apply_movement():
	if is_jumping and velocity.y >= 0:
		is_jumping = false

	velocity = move_and_slide(velocity, UP, SLOPE_STOP) #apply movement, resetting every frame
	
	is_grounded = !is_jumping and get_collision_mask_bit(DROPTHROUGH_BIT) and _check_is_grounded(raycast_ground) # check for grounding


#function to get player's input
func _handle_move_input():
	#sets in motion
	var move_direction = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	var jump_direction = int(Input.is_action_pressed("jump"))
	velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())
	
	#flip char sprite
	if move_direction != 0:
		$body.scale.x = move_direction
		
#movement on ground and in air
func _get_h_weight():
	return 0.2 if is_grounded else 0.1

func _check_is_grounded(raycast):
	if raycast.is_colliding():
		return true
	else:
		return false

func _on_Area2D_body_exited(body):
	set_collision_mask_bit(DROPTHROUGH_BIT, true)
	
