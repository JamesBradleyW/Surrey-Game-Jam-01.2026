extends CharacterBody2D

@export_subgroup("Timers")
@export var jump_buffer_timer: Timer
@export var coyote_timer: Timer

@export var speed = 300.0
@export var jump_velocity = -400.0
@export var max_air_jumps = 1
var air_jumps_remaining = 0
var can_double_jump = false  # Powerup status
@export var acceleration = 15.0
@export var friction = 15.0

# Gravity
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# State
var facing = 1
var is_going_up = false
var is_jumping = false
var on_floor_last_frame = false

# Double jump
var can_double_jump := false
var has_double_jumped := false

@onready var animated_sprite = $AnimatedSprite2D


func timer_active(t: Timer) -> bool:
	return t != null and not t.is_stopped()


func has_just_landed(body: CharacterBody2D) -> bool:
	return body.is_on_floor() and is_jumping and not on_floor_last_frame


func has_just_stepped_off_ledge(body: CharacterBody2D) -> bool:
	return not body.is_on_floor() and on_floor_last_frame and not is_jumping


func is_allowed_to_jump(body: CharacterBody2D, jump_input: bool) -> bool:
	if not jump_input:
		return false

	# Ground or coyote jump
	if body.is_on_floor() or timer_active(coyote_timer):
		return true

	# Double jump
	if can_double_jump and not has_double_jumped:
		has_double_jumped = true
		return true

	return false


func run_jump(body: CharacterBody2D) -> void:
	body.velocity.y = jump_velocity
	is_jumping = true
	if jump_buffer_timer: jump_buffer_timer.stop()
	if coyote_timer: coyote_timer.stop()


func handle_jump(body: CharacterBody2D, jump_input: bool) -> void:
	if has_just_landed(body):
		is_jumping = false
		has_double_jumped = false

	if is_allowed_to_jump(body, jump_input):
		run_jump(body)
	elif can_double_jump and air_jumps_remaining > 0:
		run_jump(body)
		air_jumps_remaining -= 1
		
	handle_jump_buffer(body, jump_input)
	handle_coyote_time(body)

	is_going_up = body.velocity.y < 0 and not body.is_on_floor()
	on_floor_last_frame = body.is_on_floor()


func handle_jump_buffer(body: CharacterBody2D, jump_input: bool):
	if jump_input and not body.is_on_floor() and jump_buffer_timer:
		jump_buffer_timer.start()

	if body.is_on_floor() and jump_buffer_timer and timer_active(jump_buffer_timer):
		run_jump(body)


func handle_coyote_time(body: CharacterBody2D):
	if has_just_stepped_off_ledge(body) and coyote_timer:
		coyote_timer.start()

	if coyote_timer and timer_active(coyote_timer) and not is_jumping:
		body.velocity.y = 0

func enable_double_jump():
	can_double_jump = true
	max_air_jumps = 1

func disable_doube_jump():
	can_double_jump = false
	max_air_jumps = 0
func _physics_process(delta):
	# Add gravity every frame
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
			air_jumps_remaining = max_air_jumps
	# Handle jump
	handle_jump(self, Input.is_action_just_pressed("jump"))

	# Horizontal input
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		facing = direction

	# Movement
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration)
		animated_sprite.flip_h = direction < 0

		if is_on_floor():
			animated_sprite.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, friction)

		if is_on_floor():
			animated_sprite.play("idle")

	# Air animations
	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")

	move_and_slide()


func enable_double_jump() -> void:
	can_double_jump = true
	print("Double jump unlocked!")
