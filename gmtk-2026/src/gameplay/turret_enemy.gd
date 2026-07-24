class_name Enemy
extends Node3D

@onready var player = get_parent().get_node("player")
@onready var bullet = $bullet

var target_position = null
var bullet_direction = null
var bullet_moving = false
const BULLET_SPEED = 7

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	target_position = player.global_position
	if bullet_moving:
		bullet.global_position += bullet_direction * BULLET_SPEED * delta


func _on_shoot_timer_timeout():
	bullet.get_child(1).disabled = true
	bullet.position = Vector3(0, 0, 0)
	bullet.show()
	
	bullet_direction = (global_position - target_position).normalized()
	bullet.get_child(1).disabled = false
	print("Fired")

func _on_bullet_body_entered(body):
	if body.name == "player":
		body.hit()
	else:
		bullet_moving = false
		bullet.hide()
		
