extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

# Dash Variables
const DASH_SPEED = 600.0
const DASH_DURATION = 0.2
var is_dashing = false

# Death Variables
const DEATH_UPWARD_FORCE = -800  # Strong pop-up
const DEATH_GRAVITY = 900
var is_dead = false

# Health Variables
var max_health = 5
var current_health = 5
  # Path to your ProgressBar with damage bar
@onready var health_bar: ProgressBar = $UI/Healthbar
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_stream_player_2d_2: AudioStreamPlayer2D = $AudioStreamPlayer2D2
@onready var audio_stream_player_2d_3: AudioStreamPlayer2D = $AudioStreamPlayer2D3

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# Initialize health bar
	health_bar.init_health(max_health)


func _physics_process(delta: float) -> void:
	
	# -----------------
	# DEATH STATE
	# -----------------
	if is_dead:
		velocity.y += DEATH_GRAVITY * delta
		rotation += 5 * delta
		move_and_slide()
		return
	
	
	# -----------------
	# NORMAL MOVEMENT
	# -----------------
	if not is_on_floor() and not is_dashing:
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("move_shift") and not is_dashing:
		start_dash()
		audio_stream_player_2d_2.play()
		

	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_dashing:
		velocity.y = JUMP_VELOCITY
		audio_stream_player_2d.play()
	var direction := Input.get_axis("move_left", "move_right")
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if is_dashing:
		animated_sprite.play("dash")
	elif is_on_floor():
		if direction == 0:
			animated_sprite.play("Idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	if is_dashing:
		velocity.x = (-DASH_SPEED if animated_sprite.flip_h else DASH_SPEED)
	elif direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


# -----------------
# DASH FUNCTION
# -----------------
func start_dash():
	is_dashing = true
	await get_tree().create_timer(DASH_DURATION).timeout
	is_dashing = false


# -----------------
# PLAYER DEATH
# -----------------
func die():
	if is_dead:
		audio_stream_player_2d_3.play()
		return

	is_dead = true
	is_dashing = false
	velocity = Vector2(0, DEATH_UPWARD_FORCE)

	if animated_sprite.sprite_frames.has_animation("death"):
		animated_sprite.play("death")
		
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.5)


# -----------------
# TAKE DAMAGE
# -----------------
func take_damage(amount: int = 1):
	if is_dead:
		return
	
	current_health -= amount
	current_health = max(current_health, 0)

	# Update the health bar
	health_bar._set_health(current_health)

	# Check death
	if current_health <= 0:
		die()


# -----------------
# HEAL PLAYER
# -----------------
func heal(amount: int = 1):
	current_health += amount
	current_health = min(current_health, max_health)
	health_bar._set_health(current_health)
