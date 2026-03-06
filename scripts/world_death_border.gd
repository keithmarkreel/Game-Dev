extends Area2D

@onready var timer: Timer = $Timer

# Optional: time before respawn after death
var respawn_delay: float = 1.0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Reduce all health to 0 (so health bar updates)
		body.take_damage(body.current_health)
		
		# Start a one-shot timer to reload the scene after delay
		var respawn_timer = Timer.new()
		respawn_timer.one_shot = true
		respawn_timer.wait_time = respawn_delay
		add_child(respawn_timer)
		respawn_timer.start()
		respawn_timer.timeout.connect(func():
			get_tree().reload_current_scene()
		)
