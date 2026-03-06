extends Node2D

const SPEED = 60
var direction = 1

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta):

	# Change direction if hitting a wall
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
		
	elif ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	# Move enemy
	position.x += direction * SPEED * delta


func _on_body_entered(body):

	# Only kill player
	if body.is_in_group("player"):
		get_tree().reload_current_scene()
