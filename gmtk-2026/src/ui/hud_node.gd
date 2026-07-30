extends Control

# Time Tracking Stuff
var time_elapsed : float = 0.0
var time_stopped : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not time_stopped:
		if Engine.time_scale == 0.1:
			time_elapsed += (delta * 10)
		else:
			time_elapsed += delta
		$stopwatch.text = str(time_elapsed).pad_decimals(2)
	
	if Input.is_action_just_pressed("pause"):
		print("Paused")
		start_or_stop_stopwatch()
		get_tree().paused = not get_tree().paused

func start_or_stop_stopwatch():
	time_stopped = not time_stopped
	$pause.visible = not $pause.visible

func reset_stopwatch():
	time_elapsed = 0.0
	
func get_time() -> float:
	time_stopped = true
	return time_elapsed
