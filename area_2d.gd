extends Area2D

# We use a Timer to give the player a moment to realize they died
@onready var timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	# Print to console so we know it worked
	print("You died!")
	
	# Slow down time for a dramatic effect (Optional)
	Engine.time_scale = 0.5
	
	# Start the timer
	timer.start()

func _on_timer_timeout() -> void:
	# Reset time speed back to normal
	Engine.time_scale = 1.0
	# Reload the current level
	get_tree().reload_current_scene()
