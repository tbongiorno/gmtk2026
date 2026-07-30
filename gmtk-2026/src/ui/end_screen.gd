extends Control

@export var score : String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_back_to_start_pressed():
	var tween = get_tree().create_tween()
	tween.tween_property($fade, "modulate", Color(0,0,0,1), 2)
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://src/ui/start_screen.tscn")
