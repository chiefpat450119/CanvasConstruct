class_name DrawingUI
extends Control

signal finish_requested

@export var drawing_grid: DrawingGrid
@export var reference_art: TextureRect
@export var timer_label: Label
@export var finish_button: Button

var _drawing_timer: Timer


func _ready() -> void:
	finish_button.pressed.connect(finish_requested.emit)


func setup_drawing(
	reference_image: Texture2D,
	drawing_timer: Timer = null,
	initial_drawing: Image = null
) -> void:
	var reference_width := reference_image.get_width()
	var reference_height := reference_image.get_height()
	reference_art.texture = reference_image
	drawing_grid.active_colour = _get_reference_colour(reference_image)
	drawing_grid.init(reference_width, reference_height)
	if is_instance_valid(initial_drawing):
		drawing_grid.fill_from_drawing(initial_drawing)
	_drawing_timer = drawing_timer
	if _drawing_timer != null:
		_update_timer_label()


func stop_drawing() -> Image:
	_drawing_timer = null
	timer_label.text = "Time\n0"
	return drawing_grid.get_image_from_drawing()


func get_drawing_grid() -> DrawingGrid:
	return drawing_grid


func _get_reference_colour(reference_texture: Texture2D) -> Color:
	var reference_image := reference_texture.get_image()
	for y: int in range(reference_image.get_height()):
		for x: int in range(reference_image.get_width()):
			var colour := reference_image.get_pixel(x, y)
			if colour.a > 0.0:
				return colour

	return Color.RED


func _process(_delta: float) -> void:
	if _drawing_timer != null:
		_update_timer_label()


func _update_timer_label() -> void:
	var seconds_left := ceili(maxf(_drawing_timer.time_left, 0.0))
	timer_label.text = "Time\n%d" % seconds_left
