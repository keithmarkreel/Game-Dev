extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

# Dash Variables
const DASH_SPEED = 600.0
const DASH_DURATION = 0.2
var is_dashing = false

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# 1. Add gravity (Disabled while dashing for a "clean" dash)
	if not is_on_floor() and not is_dashing:
		velocity += get_gravity() * delta

	# 2. Handle Dash Input
	if Input.is_action_just_pressed("move_shift") and not is_dashing:
		start_dash()

	# 3. Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_dashing:
		velocity.y = JUMP_VELOCITY

	# 4. Get input direction
	var direction := Input.get_axis("move_left", "move_right")
	
	# Flip sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# 5. Player Animations
	if is_dashing:
		animated_sprite.play("dash")
	elif is_on_floor():
		if direction == 0:
			animated_sprite.play("Idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	# 6. Handle Movement
	if is_dashing:
		# Keep moving in the direction we were facing
		velocity.x = (-DASH_SPEED if animated_sprite.flip_h else DASH_SPEED)
	elif direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# This helper function handles the dash timer
func start_dash():
	is_dashing = true
	# Create a quick timer to stop the dash
	await get_tree().create_timer(DASH_DURATION).timeout
	is_dashing = false
