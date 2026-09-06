extends Control


@export var start_button: Button
@export var tutorial_button: Button


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	tutorial_button.pressed.connect(_on_tutorial_pressed)


func _on_start_pressed() -> void:
	GameStateManagerInstance.reset_run()
	GameStateManagerInstance.switch_to_drawing_phase()


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tutorial_menu/tutorial_menu.tscn")
