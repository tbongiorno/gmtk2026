class_name MainGame
extends Node


# FUTURE (main menu): Load test level for prototype
const TEST_LEVEL : String = "uid://cx8wx8n140b6p"
const PLAYER : String = "uid://bfdvy6ycjo3p6"

var player : Player = null

var current_level: Level = null

#Game World Root Nodes
@onready var level_root = %LevelRoot
@onready var entity_root = %EntityRoot
@onready var effect_root = %EffectRoot


# UI Root Nodes
@onready var hud_layer = $HudLayer
@onready var transition_layer = $TransitionLayer
@onready var debug_layer = $DebugLayer


func _ready():
	_init_player()
	load_level(TEST_LEVEL)
	
	
func _init_player():
	var player_scene : PackedScene = ResourceLoader.load(PLAYER) as PackedScene
	if player_scene == null:
		push_error("Could not load player scene: " + PLAYER)
		return
	
	player = player_scene.instantiate() as Player
	if player == null:
		push_error("Loaded player scene does not extend player or DNE: " + PLAYER)
		return
	
	entity_root.add_child(player)


func load_level(level_scene: String) -> void:
	_deferred_load_level.call_deferred(level_scene)

func _deferred_load_level(level_scene_uid: String) -> void:
	if current_level != null:
		current_level.queue_free()
		current_level = null
	
	await get_tree().process_frame
	
	var new_level_packed : PackedScene =\
		ResourceLoader.load(level_scene_uid, "PackedScene") as PackedScene
	if new_level_packed == null:
		push_error("Could not load level as a packed scene: " + level_scene_uid)
		return
	
	current_level = new_level_packed.instantiate() as Level
	if current_level == null:
		push_error("Loaded level is not of type Level or DNE: " + level_scene_uid)
		return
	
	level_root.add_child(current_level)
	
	await get_tree().process_frame
	_place_player_at_level_spawn()

func _place_player_at_level_spawn():
	if player == null:
		push_error("Cannot place player in level because it is null")
		return
	if current_level == null:
		push_error("Cannot place player in level because level is null")
		return
	
	player.global_position = current_level.get_default_player_spawn()
	
	
	
	
