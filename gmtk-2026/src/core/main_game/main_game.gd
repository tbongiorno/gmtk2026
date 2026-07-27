class_name MainGame
extends Node


# FUTURE (main menu): Load test level for prototype
const LEVEL_1 : String = "uid://334sld36crvk"
const PLAYER : String = "uid://bfdvy6ycjo3p6"
const ENEMY : String = "uid://dahkw2wfumb0y"

var player : Player = null
var current_level: Level = null
var enemy : Enemy = null

#Game World Root Nodes
@onready var level_root = %LevelRoot
@onready var entity_root = %EntityRoot
@onready var effect_root = %EffectRoot

# UI Root Nodes
@onready var hud_layer = $HudLayer
@onready var transition_layer = $TransitionLayer
@onready var debug_layer = $DebugLayer

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_init_player()
	load_level(LEVEL_1)

func _process(delta: float) -> void:
	if Input.is_action_pressed("aim"):
		print("AIMING")
		Engine.time_scale = 0.1
	else:
		Engine.time_scale = 1.0

	
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
	print(level_scene)
	deferred_load_level.call_deferred(level_scene)

func deferred_load_level(level_scene_uid: String) -> void:
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
	place_player_at_level_spawn()
	place_enemies_in_level()

func place_player_at_level_spawn():
	if player == null:
		push_error("Cannot place player in level because it is null")
		return
	if current_level == null:
		push_error("Cannot place player in level because level is null")
		return
	
	player.global_position = current_level.get_default_player_spawn()
	player.spawn_point = player.global_position
	
	player.base_jumps = current_level.jumps
	player.base_dashes = current_level.dashes
	player.base_shots = current_level.shots
	player.reset_stats()

func place_enemies_in_level():
	var enemy_scene : PackedScene = ResourceLoader.load(ENEMY) as PackedScene
	if enemy_scene == null:
		push_error("Could not load enemy scene: " + ENEMY)
		return
	
	for entity in entity_root.get_children():
		if entity.name.left(6) == "turret":
			entity.queue_free()
	
	var enemy_spawns = current_level.get_node("enemy_spawn_points").get_children()
	
	current_level.num_enemies = 0
	for spawn in enemy_spawns:
		enemy = enemy_scene.instantiate() as Enemy
		current_level.num_enemies += 1
		if enemy == null:
			push_error("Loaded enemy scene does not extend enemy or DNE: " + ENEMY)
			return
		
		entity_root.add_child(enemy)
		enemy.name = "turret_enemy"
		enemy.global_position = spawn.global_position


func initialize_end():
	var final_time = hud_layer.get_node("HudRoot/hud_node").get_time()
	
	level_root.remove_child(current_level)
	entity_root.remove_child(player)
	hud_layer.get_node("HudRoot/hud_node").hide()
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	var end_screen = hud_layer.get_node("HudRoot/end_screen")
	end_screen.show()
	end_screen.get_node("score").text = "Your Score is
" + str("%.2f" % final_time)
	
	
	#
	##Save Score
	#hud.start_or_stop_stopwatch()
	#var sw_result: Dictionary = await SilentWolf.Scores.save_score("example", hud.time_elapsed).sw_save_score_complete
	#print("Score persisted successfully: " + str(sw_result.score_id))
	#
	##List of Scores
	#var sw_results: Dictionary = await SilentWolf.Scores.get_scores(20).sw_get_scores_complete
	#print("Scores: " + str(sw_results.scores))
