extends Node3D

var target_position = null
var bullet_direction = null
var bullet_moving = false
const BULLET_SPEED = 15


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if bullet_moving:
		global_position += bullet_direction * BULLET_SPEED * delta


func init_bullet(target):
	target_position = target.global_position
	bullet_direction = global_position.direction_to(target_position)
	bullet_moving = true
	
	
func _on_area_3d_body_entered(body):
	if body.name == "player":
		body.hit()
	#print(body.name)
	queue_free()
