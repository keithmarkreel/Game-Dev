extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

var target_position: Vector2 = Vector2.zero
var prev_x: float = 0.0

func _ready():
	# Disable processing for remote players - server drives them
	set_physics_process(false)

func update_from_server(x: float, y: float):
	prev_x = position.x
	position = Vector2(x, y)
	
	# Mirror animations based on movement direction
	var diff = position.x - prev_x
	if diff > 0:
		animated_sprite.flip_h = false
		animated_sprite.play("run")
	elif diff < 0:
		animated_sprite.flip_h = true
		animated_sprite.play("run")
	else:
		animated_sprite.play("Idle")
