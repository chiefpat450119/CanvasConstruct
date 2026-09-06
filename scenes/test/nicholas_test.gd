extends Node

@export var runtime_texture : RuntimeTexture
@export var drawing_grid : DrawingGrid

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	pass
	#if event.is_action_pressed("Render"):
		#var image : Image = drawing_system.get_image_from_drawing()
		#runtime_texture.init_from_image(image)
