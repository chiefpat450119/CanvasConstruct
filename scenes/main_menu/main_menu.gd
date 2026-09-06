extends Control

func _on_start_pressed() -> void:
	# TODO: Make sure to switch to correct scene if it's not this
	get_tree().change_scene_to_file("res://scenes/drawing_phase/DrawingPhase.tscn")


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tutorial_menu/tutorial_menu.tscn")
