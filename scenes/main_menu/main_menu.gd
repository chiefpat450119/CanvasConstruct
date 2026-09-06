extends Control

func _on_start_pressed() -> void:
	# TODO: Make sure to switch to correct scene if it's not this
	get_tree().change_scene_to_file("res://scenes/drawing_phase/DrawingPhase.tscn")
