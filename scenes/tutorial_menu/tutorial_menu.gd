extends Control

@export var tutorial_images: Array
@export var tutorial_text: Array
@export var display: TextureRect
@export var prev_button: TextureButton
@export var next_button: TextureButton
@export var back_button: TextureButton
@export var tutorial_label: Label

var _curr_image: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if tutorial_images.size() <= 1:
		next_button.disabled = true
	display.texture = load(tutorial_images[_curr_image])
	tutorial_label.text = tutorial_text[_curr_image]
	

func _on_prev_pressed() -> void:
	_curr_image = _curr_image - 1
	next_button.disabled = false
	if _curr_image <= 0:
		prev_button.disabled = true
	display.texture = load(tutorial_images[_curr_image])
	tutorial_label.text = tutorial_text[_curr_image]
	

func _on_next_pressed() -> void:
	_curr_image = _curr_image + 1
	prev_button.disabled = false
	if _curr_image >= tutorial_images.size() - 1:
		next_button.disabled = true
	display.texture = load(tutorial_images[_curr_image])
	tutorial_label.text = tutorial_text[_curr_image]


func _on_back_pressed() -> void:
	_curr_image = 0
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
