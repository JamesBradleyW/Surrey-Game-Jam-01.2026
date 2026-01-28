extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var goal_pos = $"../Player/CharacterBody2D".position
	goal_pos.x += $"../Player/CharacterBody2D".facing * 20
	position = position.lerp(goal_pos, delta * 5)
