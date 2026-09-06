class_name DrawingUI
extends Control

@export var drawing_grid: DrawingGrid
@export var reference_art: TextureRect
@export var timer_label: Label

var _drawing_timer: Timer


func setup_drawing(reference_image: Texture2D, drawing_timer: Timer = null) -> void:
	var reference_width := reference_image.get_width()
	var reference_height := reference_image.get_height()
	reference_art.texture = reference_image
	drawing_grid.init(reference_width, reference_height)
	_drawing_timer = drawing_timer
	if _drawing_timer != null:
		_update_timer_label()


func stop_drawing() -> void:
	_drawing_timer = null
	timer_label.text = "Time\n0"


func get_drawing_grid() -> DrawingGrid:
	return drawing_grid


func _process(_delta: float) -> void:
	if _drawing_timer != null:
		_update_timer_label()


func _update_timer_label() -> void:
	var seconds_left := ceili(maxf(_drawing_timer.time_left, 0.0))
	timer_label.text = "Time\n%d" % seconds_left
