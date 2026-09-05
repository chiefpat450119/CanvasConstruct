extends Node2D

@export var texture: RuntimeTexture
@export var dmg: DamagableComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture.init(30, 30)
	texture._img.fill(Color.RED)
	texture._texture.update(texture._img)
	for i in range(30):
		for j in range(30):
			texture.visible_pixels.append(Vector2i(i, j))


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_text_backspace"):
		dmg.damage(0.2)
