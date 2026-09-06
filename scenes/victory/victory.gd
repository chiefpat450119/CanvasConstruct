extends Control

@export_group("SFX")
@export var win_sfx: AudioStream

func _ready() -> void:
	AudioManager.play_SFX(win_sfx, -10)

func _on_main_menu_pressed() -> void:
	GameStateManagerInstance.reset_run()
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
