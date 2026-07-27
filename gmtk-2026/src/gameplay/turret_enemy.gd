class_name Enemy
extends Node3D

@onready var player = get_parent().get_node("player")
@onready var bullets = $bullets
var bullet = load("res://src/gameplay/bullet.tscn")

var target_position = null
var bullet_direction = null
var bullet_moving = false
const BULLET_SPEED = 7

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_shoot_timer_timeout():
	var new_bullet = bullet.instantiate()
	bullets.add_child(new_bullet)
	new_bullet.init_bullet(player)


func destroy():
	##REMOVE BULLETS LATER
	get_parent().get_parent().get_child(0).get_child(0).num_enemies -= 1
	queue_free()
