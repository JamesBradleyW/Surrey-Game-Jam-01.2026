extends AnimatedSprite2D

@export var float_height: float = 2.0     # pixels up/down
@export var float_speed: float = 2.0      # cycles per second

var time_passed: float = 0.0
var start_y: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	start_y = position.y
	play("default")

	# Connect area signals
	$Area2D.body_entered.connect(_on_area_entered)
	$Area2D.area_entered.connect(_on_area_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_passed += delta

	# Floating animation
	position.y = start_y + sin(time_passed * float_speed * PI) * float_height

func _on_body_entered(body):
	collect_powerup_check(body)

func _on_area_entered(area):
	if area.owner:
		collect_powerup_check(area.owner)

func collect_powerup_check(target):
	# Check if target can collect powerups
	if target.has_method("collect_powerup"):
		target.collect_powerup("hourglass")
		queue_free()
