class_name Level
extends Node3D

@onready var player_spawn = %player_spawn

@export var jumps = 0
@export var dashes = 0
@export var shots = 0

const LEVEL_1 : String = "uid://334sld36crvk"

var num_enemies : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	num_enemies = $enemy_spawn_points.get_child_count()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_default_player_spawn():
	return player_spawn.global_position


func _on_finish_line_body_entered(body):
	if body.name == "player" and num_enemies == 0:
		print("END LEVEL")
		get_parent().get_parent().get_parent().load_level(LEVEL_1)
