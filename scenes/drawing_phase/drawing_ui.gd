class_name DrawingUI
extends Control

signal finish_requested

const DRAWING_COLUMN_CENTER_X: float = 0.25
const REFERENCE_COLUMN_CENTER_X: float = 0.75
const CONTENT_CENTER_Y: float = 0.5
const CONTENT_VERTICAL_OFFSET: float = 80.0

@export var drawing_grid: DrawingGrid
@export var reference_art: TextureRect
@export var reference_art_grid_lines : GridLines
@export var timer_label: Label
@export var finish_button: Button

var _drawing_timer: Timer
var _reference_image_size: Vector2


func _ready() -> void:
	finish_button.pressed.connect(finish_requested.emit)
	resized.connect(_layout_drawing_content)


func setup_drawing(
	reference_image: Texture2D,
	drawing_timer: Timer = null,
	initial_drawing: Image = null
) -> void:
	# Setup reference image
	var reference_width := reference_image.get_width()
	var reference_height := reference_image.get_height()
	_reference_image_size = Vector2(reference_width, reference_height)
	reference_art.texture = reference_image
	reference_art_grid_lines.init(reference_width, reference_height)
	
	# Setup drawing area
	drawing_grid.active_colour = _get_reference_colour(reference_image)
	drawing_grid.init(reference_width, reference_height)
	_layout_drawing_content()
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


func _layout_drawing_content() -> void:
	if _reference_image_size.x <= 0.0 or _reference_image_size.y <= 0.0:
		return
	if size.x <= 0.0 or size.y <= 0.0:
		return

	var drawing_size := drawing_grid.get_combined_minimum_size()
	drawing_grid.size = drawing_size
	var reference_scale := minf(
		drawing_size.x / _reference_image_size.x,
		drawing_size.y / _reference_image_size.y
	)
	var reference_size := _reference_image_size * reference_scale
	reference_art.size = reference_size

	var drawing_center := Vector2(
		size.x * DRAWING_COLUMN_CENTER_X,
		size.y * CONTENT_CENTER_Y + CONTENT_VERTICAL_OFFSET
	)
	var reference_center := Vector2(
		size.x * REFERENCE_COLUMN_CENTER_X,
		size.y * CONTENT_CENTER_Y + CONTENT_VERTICAL_OFFSET
	)

	drawing_grid.position = (drawing_center - drawing_size * 0.5).round()
	reference_art.position = (reference_center - reference_size * 0.5).round()


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
