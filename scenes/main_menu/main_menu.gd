extends Control


@export var start: BaseButton
@export var tutorial: BaseButton


func _ready():
	AudioManager.play_build_music()
	start.pressed.connect(_on_start_pressed)
	tutorial.pressed.connect(_on_tutorial_pressed)


func _on_start_pressed() -> void:
	GameStateManagerInstance.switch_to_cutscene()


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tutorial_menu/tutorial_menu.tscn")
