class_name Level
extends Node3D

@onready var player_spawn = %player_spawn

@export var jumps = 0
@export var dashes = 0
@export var shots = 0

const LEVEL_1 : String = "uid://334sld36crvk"
const LEVEL_2 : String = "uid://dlb0wcd2i5s1y"
const LEVEL_3 : String = "uid://yrxtgegvio7l"
const LEVEL_4 : String = "uid://c3fjkpxtal5uu"
const LEVEL_5 : String = "uid://i2dkw5v3udq1"
const LEVEL_6 : String = "uid://d2x6e4j38fc06"

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
		if name == "testing_level":
			get_parent().get_parent().get_parent().load_level(LEVEL_1)
		elif name == "level_1":
			get_parent().get_parent().get_parent().load_level(LEVEL_2)
		elif name == "level_2":
			get_parent().get_parent().get_parent().load_level(LEVEL_3)
		elif name == "level_3":
			get_parent().get_parent().get_parent().load_level(LEVEL_4)
		elif name == "level_4":
			get_parent().get_parent().get_parent().load_level(LEVEL_5)
		elif name == "level_5":
			get_parent().get_parent().get_parent().load_level(LEVEL_6)
		else:
			print("YOU WIN!")


func _on_die_area_body_entered(body):
	if body.name == "player":
		print("Exited below")
		body.hit()
