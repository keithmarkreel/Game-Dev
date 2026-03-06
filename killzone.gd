extends Area2D

@onready var timer: Timer = $Timer

# How much damage the Killzone does per hit
var damage_amount: int = 1

# How long to wait before respawning when player dies
var respawn_delay: float = 1.0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Apply damage
		body.take_damage(damage_amount)
		
		# Optional: slow motion effect when player is hit
		Engine.time_scale = 0.5
		timer.start()  # timer will restore time
		Engine.time_scale = 1
		# If the player died, start respawn timer
		if body.is_dead:
			# Start a one-shot timer for respawn
			var respawn_timer = Timer.new()
			respawn_timer.one_shot = true
			respawn_timer.wait_time = respawn_delay
			add_child(respawn_timer)
			respawn_timer.start()
			respawn_timer.timeout.connect(func():
				Engine.time_scale = 1
				get_tree().reload_current_scene()
			)
