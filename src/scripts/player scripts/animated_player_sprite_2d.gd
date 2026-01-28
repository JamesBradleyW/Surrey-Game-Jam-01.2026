extends AnimatedSprite2D

@export var respawn_delay: float = 0.5
@export var respawn_marker_path: NodePath  # (optional) drag PlayerStart Marker2D here in Inspector

var _is_dead := false
var _spawn_global_pos: Vector2
var _timer_ui: Node
@onready var _player_body: CharacterBody2D = get_parent() as CharacterBody2D

func _ready():
	# Save spawn point (Marker2D if provided, otherwise current player position)
	var marker := get_node_or_null(respawn_marker_path)
	if marker and marker is Node2D:
		_spawn_global_pos = (marker as Node2D).global_position
	else:
		_spawn_global_pos = _player_body.global_position

	play("idle")
	animation_finished.connect(_on_animation_finished)

		# Connect to TimerUI (wait 1 frame so it has added itself to the group)
	await get_tree().process_frame

	_timer_ui = get_tree().get_first_node_in_group("timer_ui")
	if _timer_ui and _timer_ui.has_signal("time_up"):
		_timer_ui.time_up.connect(_on_time_up)


func _process(_delta):
	# If dead, don't let inputs override the death animation
	if _is_dead:
		return

	# Movement animations
	if Input.is_action_pressed("right"):
		play("run")
		flip_h = false
	elif Input.is_action_pressed("left"):
		play("run")
		flip_h = true
	else:
		play("idle")

	# Action animations
	if Input.is_action_just_pressed("attack"):
		play("attack")

	if Input.is_action_just_pressed("take_damage"):
		play("hit")

func _on_time_up():
	die()

func die():
	if _is_dead:
		return

	_is_dead = true

	# Freeze player movement while dying (prevents sliding/falling)
	if _player_body:
		_player_body.velocity = Vector2.ZERO
		_player_body.set_physics_process(false)

	play("death")  # IMPORTANT: "death" animation must exist and Loop must be OFF

func _on_animation_finished():
	# Return to idle after attack/hit (only if alive)
	if animation in ["attack", "hit"] and not _is_dead:
		play("idle")

	# When death finishes, respawn
	if animation == "death":
		_respawn()

func _respawn():
	await get_tree().create_timer(respawn_delay).timeout

	# Move the CharacterBody2D back to spawn
	if _player_body:
		_player_body.global_position = _spawn_global_pos
		_player_body.velocity = Vector2.ZERO
		_player_body.set_physics_process(true)

	_is_dead = false
	play("idle")

	# Restart the timer UI (make sure TimerUI.gd has restart())
	if _timer_ui and _timer_ui.has_method("restart"):
		_timer_ui.restart()
