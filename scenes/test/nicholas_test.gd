extends Node

@export var runtime_texture : RuntimeTexture
@export var drawing_grid : DrawingGrid

@export_category("SFX")
@export var test_sfx : AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play_SFX(test_sfx, -10)
	while (true):
		AudioManager.play_build_music()
		await get_tree().create_timer(13).timeout
		AudioManager.play_drawing_music()
		await get_tree().create_timer(10).timeout
		AudioManager.play_combat_music()
		await get_tree().create_timer(30).timeout


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Render"):
		get_tree().change_scene_to_file("res://scenes/test/test_player.tscn")
