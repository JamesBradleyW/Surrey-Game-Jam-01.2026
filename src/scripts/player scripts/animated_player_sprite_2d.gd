extends AnimatedSprite2D

func _ready():
	play("idle")  # Start with idle animation#
	animation_finished.connect(_on_animation_finished)

func _process(_delta):
	# Example animation control
	if Input.is_action_pressed("right"):
		play("run")
		flip_h = false
	elif Input.is_action_pressed("left"):
		play("run")
		flip_h = true
	else:
		play("idle")
	
	if Input.is_action_just_pressed("attack"):
		play("attack")

	if Input.is_action_just_pressed("take_damage"):
		play("hit")

func _on_animation_finished():
	if animation in ["attack", "hit"]:
		play("idle")  # Return to idle after attack/hit
	# Death animation typically doesn't transition back
