extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# We check if the thing entering the portal is actually the Player
	if body is CharacterBody2D:
		print("--- SUCCESS ---")
		
		# Get the path of the current level (e.g., "res://levels/level_1.tscn")
		var current_scene_file = get_tree().current_scene.scene_file_path
		
		# to_int() finds the first number in the string (the level number)
		var next_level_number = current_scene_file.to_int() + 1
		
		# Build the string for the next level's file path
		var next_level_path = "res://levels/level_" + str(next_level_number) + ".tscn"
		
		# Check if the next level file actually exists before trying to load it
		if FileAccess.file_exists(next_level_path):
			get_tree().change_scene_to_file(next_level_path)
		else:
			print("No more levels! You've reached the end of the game.")
			# Optional: Go back to a main menu or show a win screend
