class_name Level
extends Node3D

@onready var player_spawn = %player_spawn

const LEVEL_1 : String = "uid://334sld36crvk"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_default_player_spawn():
	return player_spawn.global_position


func _on_finish_line_body_entered(body):
	if body.name == "player":
		print("END LEVEL")
		get_parent().get_parent().get_parent().load_level(LEVEL_1)
