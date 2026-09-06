extends Control


func _on_main_menu_pressed() -> void:
	GameStateManagerInstance.reset_run()
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")