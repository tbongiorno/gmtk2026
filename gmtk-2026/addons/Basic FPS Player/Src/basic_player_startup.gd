@tool
class_name Player
extends CharacterBody3D

var BasicFPSPlayerScene : PackedScene = preload("basic_player_head.tscn")
var addedHead = false

func _enter_tree():
	
	if find_child("Head"):
		addedHead = true
	
	if Engine.is_editor_hint() && !addedHead:
		var s = BasicFPSPlayerScene.instantiate()
		add_child(s)
		s.owner = get_tree().edited_scene_root
		addedHead = true

## PLAYER MOVMENT SCRIPT ##
###########################
@export_category("Mouse Capture")
@export var CAPTURE_ON_START := true

@export_category("Movement")
@export_subgroup("Settings")
@export var SPEED := 8.0
@export var ACCEL := 50.0
@export var IN_AIR_SPEED := 3.0
@export var IN_AIR_ACCEL := 5.0
@export var JUMP_VELOCITY := 6
@export var DASH_VELOCITY := 4.5
@export var SLIDE_VELOCITY := 3
@export_subgroup("Head Bob")
@export var HEAD_BOB := true
@export var HEAD_BOB_FREQUENCY := 0.3
@export var HEAD_BOB_AMPLITUDE := 0.01
@export_subgroup("Clamp Head Rotation")
@export var CLAMP_HEAD_ROTATION := true
@export var CLAMP_HEAD_ROTATION_MIN := -90.0
@export var CLAMP_HEAD_ROTATION_MAX := 90.0

@export_category("Key Binds")
@export_subgroup("Mouse")
@export var MOUSE_ACCEL := true
@export var KEY_BIND_MOUSE_SENS := 0.005
@export var KEY_BIND_MOUSE_ACCEL := 50
@export_subgroup("Movement")
@export var KEY_BIND_UP : String = "forward"
@export var KEY_BIND_LEFT : String = "left"
@export var KEY_BIND_RIGHT : String = "right"
@export var KEY_BIND_DOWN : String = "back"
@export var KEY_BIND_JUMP : String = "jump"
@export var KEY_BIND_DASH : String = "dash"
@export var KEY_BIND_SHOOT : String = "shoot"
@export var KEY_BIND_AIM : String = "aim"

@export_category("Advanced")
@export var UPDATE_PLAYER_ON_PHYS_STEP := true	# When check player is moved and rotated in _physics_process (fixed fps)
												# Otherwise player is updated in _process (uncapped)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# To keep track of current speed and acceleration
var speed = SPEED
var accel = ACCEL

# Used when lerping rotation to reduce stuttering when moving the mouse
var rotation_target_player : float
var rotation_target_head : float

# Used when bobing head
var head_start_pos : Vector3

# Current player tick, used in head bob calculation
var tick = 0

@onready var player_hud = %player_hud
var base_jumps : int = 0
var base_dashes : int = 0
var base_shots : int = 0

var num_jumps : int = 1
var num_dashes : int = 1
var num_shots : int = 1

var is_jumping : bool = false
var is_dashing : bool = false
var is_sliding : bool = false
var can_slide : bool = true

var on_ramp : bool = false

var hit_enemy: bool = false
#var can_shoot : bool = true

var spawn_point : Vector3 = Vector3(0, 0, 0)

func _ready():
	if Engine.is_editor_hint():
		return

	# Capture mouse if set to true
	if CAPTURE_ON_START:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	head_start_pos = $Head.position

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	
	if get_floor_angle() > 0.0 and get_floor_angle() < 1.0:
		on_ramp = true
	else:
		on_ramp = false
	
	# Increment player tick, used in head bob motion
	tick += 1
	
	if UPDATE_PLAYER_ON_PHYS_STEP:
		move_player(delta)
		rotate_player(delta)
	
	if HEAD_BOB:
		# Only move head when on the floor and moving
		if velocity && is_on_floor():
			head_bob_motion()
		reset_head_bob(delta)

func _process(delta):
	if Engine.is_editor_hint():
		return
	
	$RayCast3D.rotation.x = rotation_target_head
	$RayCast3D.position = head_start_pos
	
	# Handle Shoot
	if Input.is_action_just_pressed("shoot") and num_shots != 0:

		print($RayCast3D.get_collision_point())
		var collider = $RayCast3D.get_collider()
		if collider != null:
			print(collider.get_parent().name)
			if collider.get_parent().name.left(6) == "turret":
				collider.get_parent().destroy()
				hit_enemy = true
				$crosshair.modulate = Color(255, 0, 0)
				$shoot_timer.start()
			else:
				hit_enemy = false
				$crosshair.modulate = Color(255, 255, 255)
		else:
			hit_enemy = false
			$crosshair.modulate = Color(255, 255, 255)
		num_shots -= 1
		$player_hud/shots.text = "[pulse][color=red]" + str(num_shots) + "[/color][/pulse]"
		print(num_shots)
	
	if not hit_enemy:
		SPEED = 5
	else:
		SPEED = 10
	
	
	if !UPDATE_PLAYER_ON_PHYS_STEP:
		move_player(delta)
		rotate_player(delta)

func _input(event):
	if Engine.is_editor_hint():
		return
	
	# Listen for mouse movement and check if mouse is captured
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		set_rotation_target(event.relative)

func set_rotation_target(mouse_motion : Vector2):
	# Add player target to the mouse -x input
	rotation_target_player += -mouse_motion.x * KEY_BIND_MOUSE_SENS
	# Add head target to the mouse -y input
	rotation_target_head += -mouse_motion.y * KEY_BIND_MOUSE_SENS
	# Clamp rotation
	if CLAMP_HEAD_ROTATION:
		rotation_target_head = clamp(rotation_target_head, deg_to_rad(CLAMP_HEAD_ROTATION_MIN), deg_to_rad(CLAMP_HEAD_ROTATION_MAX))
	
func rotate_player(delta):
	if MOUSE_ACCEL:
		# Shperical lerp between player rotation and target
		quaternion = quaternion.slerp(Quaternion(Vector3.UP, rotation_target_player), KEY_BIND_MOUSE_ACCEL * delta)
		# Same again for head
		$Head.quaternion = $Head.quaternion.slerp(Quaternion(Vector3.RIGHT, rotation_target_head), KEY_BIND_MOUSE_ACCEL * delta)
	else:
		# If mouse accel is turned off, simply set to target
		quaternion = Quaternion(Vector3.UP, rotation_target_player)
		$Head.quaternion = Quaternion(Vector3.RIGHT, rotation_target_head)
	
func move_player(delta):
	# Check if not on floor
	if not is_on_floor() and not is_dashing:
		# Reduce speed and accel
		speed = IN_AIR_SPEED
		accel = IN_AIR_ACCEL
		# Add the gravity
		velocity.y -= gravity * delta
	elif not is_dashing:
		speed = SPEED
		accel = ACCEL
	else:
		# Set speed and accel to defualt
		speed = SPEED + 7
		accel = ACCEL * 10
	
	# Handle Jump.
	if Input.is_action_just_pressed(KEY_BIND_JUMP) and is_on_floor() and num_jumps > 0:
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		$jump_timer.start()
		num_jumps -= 1
		$player_hud/jumps.text = "[wave][color=green]" + str(num_jumps) + "[/color][/wave]"
		print(num_jumps)
		
	# Handle Dash
	if Input.is_action_just_pressed(KEY_BIND_DASH) and num_dashes > 0:
		is_dashing = true
		$dash_timer.start()
		num_dashes -= 1
		$player_hud/dashes.text = "[shake][color=blue]" + str(num_dashes) + "[/color][/shake]"
		print(num_dashes)
		
	#Handle Slide
	#if Input.is_action_pressed("slide") and is_on_floor():
		#if not is_sliding and not on_ramp:
			#$slide_timer.start(0.5 * global_transform.basis.z.dot(velocity))
		#if on_ramp:
			#can_slide = true
		#is_sliding = true
	#else:
		#is_sliding = false
		#can_slide = true

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector(KEY_BIND_LEFT, KEY_BIND_RIGHT, KEY_BIND_UP, KEY_BIND_DOWN)
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction and not is_jumping and not is_sliding: # If there's a direction with no dash / jump
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		#print(velocity)
	
	#if is_sliding:
		#$Head.position.y = -0.25
		
		#if can_slide and direction != Vector3(0, 0, 0):
			#if on_ramp:
				#speed = SPEED + 40
				#accel = 30
				#velocity.y = move_toward(velocity.y, direction.y + (speed / 2), accel * delta)
			#else:
				#speed = SPEED + 20
				#accel = 20
			#direction = direction + (transform.basis * Vector3(0, 0, -1.0)).normalized()
			#velocity.x = move_toward(velocity.x, direction.x * speed * 2, accel * delta)
			#velocity.z = move_toward(velocity.z, direction.z * speed * 2, accel * delta)
			#print(velocity)
			#if is_jumping:
			#	velocity.y = move_toward(velocity.y, direction.y * (speed * 2), accel * delta)
	#else:
		#$Head.position.y = 0
	
	if is_dashing: # If dash 
		var horizontal_direction = (transform.basis * Vector3(0, 0, -1.0)).normalized()
		velocity.x = (horizontal_direction.x * speed) + ((speed / 2) * direction.x)
		velocity.z = (horizontal_direction.z * speed) + ((speed / 2) * direction.z)
	
	if not is_dashing and not is_sliding: # If not dashing 
		velocity.x = move_toward(velocity.x, direction.x * speed, accel * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, accel * delta)

	move_and_slide()

func head_bob_motion():
	var pos = Vector3.ZERO
	pos.y += sin(tick * HEAD_BOB_FREQUENCY) * HEAD_BOB_AMPLITUDE
	pos.x += cos(tick * HEAD_BOB_FREQUENCY/2) * HEAD_BOB_AMPLITUDE 
	$Head.position += pos

func reset_head_bob(delta):
	# Lerp back to the staring position
	if $Head.position == head_start_pos:
		pass
	$Head.position = lerp($Head.position, head_start_pos, 2 * (1/HEAD_BOB_FREQUENCY) * delta)


func _on_jump_timer_timeout():
	print("Jumped")
	is_jumping = false


func _on_dash_timer_timeout():
	print("Dashed")
	is_dashing = false


func _on_slide_timer_timeout():
	print("End Slide")
	can_slide = false


func _on_shoot_timer_timeout():
	print("END SHOOT")
	$crosshair.modulate = Color(255, 255, 255)


func hit():
	print("I've Been Hit")
	get_parent().get_parent().get_parent().place_enemies_in_level()
	global_position = spawn_point
	reset_stats()

func reset_stats():
	num_jumps = base_jumps
	num_dashes = base_dashes
	num_shots = base_shots
	$player_hud/jumps.text = "[wave][color=green]" + str(num_jumps) + "[/color][/wave]"
	$player_hud/dashes.text = "[shake][color=blue]" + str(num_dashes) + "[/color][/shake]"
	$player_hud/shots.text = "[pulse][color=red]" + str(num_shots) + "[/color][/pulse]"
