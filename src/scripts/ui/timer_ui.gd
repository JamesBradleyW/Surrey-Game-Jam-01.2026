extends CanvasLayer
signal time_up

@export var start_seconds: float = 30.0
@export var low_time_threshold: float = 5.0

@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeLabel

var time_left: float = 0.0
var running := false

func _ready() -> void:
	add_to_group("timer_ui")
	reset(start_seconds)
	start()

func reset(seconds: float) -> void:
	time_left = max(seconds, 0.0)
	_update_ui()

func start() -> void:
	running = true

func pause() -> void:
	running = false
	
func restart() -> void:
	reset(start_seconds)
	start()

func add_time(seconds: float) -> void:
	time_left = max(time_left + seconds, 0.0)
	_update_ui()

func _process(delta: float) -> void:
	if not running:
		return

	time_left -= delta
	if time_left <= 0.0:
		time_left = 0.0
		running = false
		_update_ui()
		emit_signal("time_up")
		return

	_update_ui()

func _update_ui() -> void:
	time_label.text = str(int(ceil(time_left)))

	# keep your pulse
	if time_left <= low_time_threshold:
		var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() / 120.0)
		time_label.scale = Vector2.ONE * (1.0 + 0.08 * pulse)
	else:
		time_label.scale = Vector2.ONE
