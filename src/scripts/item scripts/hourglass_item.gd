extends AnimatedSprite2D

@export var float_height: float = 2.0     # pixels up/down
@export var float_speed: float = 2.0      # cycles per second

var time_passed: float = 0.0
var start_y: float = 0.0


func _ready() -> void:
	start_y = position.y
	play("default")

	# Connect signals (Godot 4 style)
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	time_passed += delta
	position.y = start_y + sin(time_passed * float_speed * PI) * float_height


func _on_body_entered(body: Node) -> void:
	print("BODY ENTERED:", body, body.name)
	collect_powerup_check(body)


func _on_area_entered(area: Area2D) -> void:
	if area.owner != null:
		collect_powerup_check(area.owner)


func collect_powerup_check(target: Node) -> void:
	# Player pickup
	if target is CharacterBody2D:
		queue_free()
