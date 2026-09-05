extends Node2D

@export var texture: RuntimeTexture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture.init(100, 100)
	texture._img.fill(Color.RED)
	texture._texture.update(texture._img)
