class_name DrawingGrid
extends Control

var _grid_width : int = 16
var _grid_height : int = 16
const CELL_SIZE : int = 16
const PAINTED_META : StringName = &"is_painted"
var active_colour : Color = Color(1,0,0)
var is_painting : bool = false
var is_erasing : bool = false

@export var grid : GridContainer
@export var cell_texture : Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init(10,20)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Start painting
	if Input.is_action_pressed("M1"):
		is_painting = true
		
		var cell_under_mouse : TextureButton = _get_cell_at_mouse_pos(get_viewport().get_mouse_position())
		# Check if there is a cell under the mouse and if cell already painted with active colour
		if cell_under_mouse and (
			!cell_under_mouse.get_meta(PAINTED_META, false)
			or !cell_under_mouse.modulate.is_equal_approx(active_colour)
		):
			cell_under_mouse.modulate = active_colour
			cell_under_mouse.set_meta(PAINTED_META, true)
	
	# Stop painting
	if Input.is_action_just_released("M1"):
		is_painting = false
	
	# Start erasing
	if Input.is_action_pressed("M2"):
		is_erasing = true
	
		var cell_under_mouse : TextureButton = _get_cell_at_mouse_pos(get_viewport().get_mouse_position())
		# Check if there is a cell under the mouse and if cell has already been erased
		if cell_under_mouse and (
			cell_under_mouse.get_meta(PAINTED_META, false)
		):
			cell_under_mouse.modulate = Color.WHITE
			cell_under_mouse.set_meta(PAINTED_META, false)
	
	# Stop erasing
	if Input.is_action_just_released("M2"):
		is_erasing = false

## Initialize the drawing grid with given width and height
func init(width : int, height: int):
	_grid_width = width
	_grid_height = height
	_generate_grid()

## Generate grid of cells
func _generate_grid() -> void:
	grid.columns = _grid_width
	
	for i in range(_grid_width * _grid_height):
		var cell = TextureButton.new()
		
		# Default grid cell properties
		cell.custom_minimum_size = Vector2(CELL_SIZE, CELL_SIZE)
		cell.stretch_mode = TextureButton.STRETCH_SCALE
		cell.ignore_texture_size = true
		cell.texture_normal = cell_texture
		cell.modulate = Color.WHITE
		cell.set_meta(PAINTED_META, false)
		
		grid.add_child(cell)

## Get the cell at the given grid position
func _get_cell_at_pos(x : int, y : int) -> TextureButton:
	if x < 0 or x >= _grid_width or y < 0 or y >= _grid_height:
		return null

	var cell_index : int = y * _grid_width + x
	if cell_index >= grid.get_child_count():
		return null

	return grid.get_child(cell_index) as TextureButton

## Get the cell under the mouse position
func _get_cell_at_mouse_pos(mouse_pos: Vector2) -> TextureButton:
	# Find the cell by position
	for y in range(_grid_height):
		for x in range(_grid_width):
			var cell : TextureButton = _get_cell_at_pos(x, y)
			if cell and cell.get_global_rect().has_point(mouse_pos):
				return cell
	return null

## Returns colour of the cell at given x,y pos
func get_cell_colour(x : int, y : int) -> Color:
	var cell : TextureButton = _get_cell_at_pos(x, y)
	if cell and cell.get_meta(PAINTED_META, false):
		return cell.modulate

	return Color.TRANSPARENT

## Returns grid width
func get_width() -> int:
	return _grid_width

## Returns grid height
func get_height() -> int:
	return _grid_height
