extends Node

# Time Tracking Stuff
var time_elapsed : float = 0.0
var time_stopped : bool = true

func _process(delta):
	if not time_stopped:
		time_elapsed += delta if Engine.time_scale != 0.1 else delta * 10
		
func is_time_stopped():
	return time_stopped
	
func curr_time_elapsed():
	return time_elapsed


func start_or_stop_time():
	time_stopped = not time_stopped


func reset():
	time_elapsed = 0
