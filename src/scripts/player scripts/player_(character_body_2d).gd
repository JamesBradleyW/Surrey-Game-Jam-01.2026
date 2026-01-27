extends CharacterBody2D

@export_subgroup("Timers")
@export var jump_buffer_timer: Timer
@export var coyote_timer: Timer

@export var speed = 300.0
@export var jump_velocity = -400.0
@export var acceleration = 15.0
@export var friction = 15.0

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_going_up = false
var is_jumping = false 
var on_floor_last_frame = false

@onready var animated_sprite = $AnimatedSprite2D

func has_just_landed(body: CharacterBody2D):
	return body.is_on_floor() and is_jumping and not on_floor_last_frame

func has_just_stepped_off_ledge(body: CharacterBody2D):
	return not body.is_on_floor() and on_floor_last_frame and not is_jumping
	
func is_allowed_to_jump(body, jump_input):
	return jump_input and (body.is_on_floor() or not coyote_timer.is_stopped())
	
func run_jump(body: CharacterBody2D):
	body.velocity.y = jump_velocity
	is_jumping = true
	jump_buffer_timer.stop()
	coyote_timer.stop()
	
func handle_jump(body: CharacterBody2D, jump_input: bool):
	if has_just_landed(body):
		is_jumping = false
	
	if is_allowed_to_jump(body, jump_input):
		run_jump(body)
		
	handle_jump_buffer(body, jump_input)
	handle_coyote_time(body)
	
	is_going_up = body.velocity.y < 0 and not body.is_on_floor()
	on_floor_last_frame = body.is_on_floor()
	
func handle_jump_buffer(body: CharacterBody2D, jump_input: bool):
	if jump_input and not body.is_on_floor():
		jump_buffer_timer.start()
	
	if body.is_on_floor() and not jump_buffer_timer.is_stopped():
		run_jump(body)
		
func handle_coyote_time(body: CharacterBody2D):
	if has_just_stepped_off_ledge(body):
		coyote_timer.start()
		
	if not coyote_timer.is_stopped() and not is_jumping:
		body.velocity.y = 0

func _physics_process(delta):
	# Add gravity every frame
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump
	handle_jump(self, Input.is_action_just_pressed("jump"))

	# Get input direction
	var direction = Input.get_axis("left", "right")

# Apply movement
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration)

		# Flip sprite based on direction
		animated_sprite.flip_h = direction < 0

		# Play run animation
		if is_on_floor():
			animated_sprite.play("run")
	else:
		# Apply friction when no input
		velocity.x = move_toward(velocity.x, 0, friction)

		# Play idle animation
		if is_on_floor():
			animated_sprite.play("idle")

	# Play jump/fall animation
	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")  # Add jump animation if you have it
		else:
			animated_sprite.play("fall")  # Add fall animation if you have it

	# Move the character
	move_and_slide()
