extends CharacterBody2D

var SPEED = 50
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D
var chase = false
@onready var anim = $AnimatedSprite2D

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if chase and player:
		anim.play("run")
		var dx = player.global_position.x - global_position.x
		velocity.x = sign(dx) * SPEED
		$AnimatedSprite2D.flip_h = dx < 0
	else:
		anim.play("idle")
		velocity.x = 0

	move_and_slide()


func _on_detection_body_entered(body):
	if body is CharacterBody2D:
		player = body
		chase = true

func _on_detection_body_exited(body):
	if body is CharacterBody2D:
		chase = false
