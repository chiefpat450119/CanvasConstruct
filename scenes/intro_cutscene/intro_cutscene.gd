extends Control

@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("cutscene")
	await animation_player.animation_finished  
	GameStateManagerInstance.reset_run()
	GameStateManagerInstance.switch_to_drawing_phase() 
