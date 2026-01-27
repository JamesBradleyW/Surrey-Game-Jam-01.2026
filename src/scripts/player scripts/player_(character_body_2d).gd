extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -400.0
@export var acceleration = 15.0
@export var friction = 15.0

# Get the gravity from the project settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# Add gravity every frame
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

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
