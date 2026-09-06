class_name DrawingGrid
extends Control

const CELL_SIZE: int = 16
const PAINTED_META: StringName = &"is_painted"

@export var grid: GridContainer
@export var cell_texture: Texture2D

var active_colour: Color = Color.RED
var is_painting: bool = false
var is_erasing: bool = false

var _grid_width: int = 0
var _grid_height: int = 0


func _process(_delta: float) -> void:
	# Start painting
	if Input.is_action_pressed("M1"):
		is_painting = true
		
		var cell_under_mouse: TextureButton = _get_cell_at_mouse_pos(
			get_viewport().get_mouse_position()
		)
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
	
		var cell_under_mouse: TextureButton = _get_cell_at_mouse_pos(
			get_viewport().get_mouse_position()
		)
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
func init(width: int, height: int) -> void:
	assert(width > 0 and height > 0, "Drawing grid dimensions must be positive")

	_grid_width = width
	_grid_height = height
	for child: Node in grid.get_children():
		child.free()
	_generate_grid()


## Fills cells from the non-transparent pixels in an existing drawing.
func fill_from_drawing(drawing: Image) -> void:
	var fill_width := mini(_grid_width, drawing.get_width())
	var fill_height := mini(_grid_height, drawing.get_height())
	for y: int in range(fill_height):
		for x: int in range(fill_width):
			var colour := drawing.get_pixel(x, y)
			if colour.a <= 0.0:
				continue

			var cell := _get_cell_at_pos(x, y)
			if cell == null:
				continue

			cell.modulate = colour
			cell.set_meta(PAINTED_META, true)


## Returns an image created from the player's drawing.
func get_image_from_drawing() -> Image:
	var image := Image.create(
		_grid_width,
		_grid_height,
		false,
		Image.FORMAT_RGBAF
	)

	for x: int in range(_grid_width):
		for y: int in range(_grid_height):
			image.set_pixel(x, y, get_cell_colour(x, y))

	return image


## Generate grid of cells
func _generate_grid() -> void:
	grid.columns = _grid_width
	
	for _index: int in range(_grid_width * _grid_height):
		var cell := TextureButton.new()
		
		# Default grid cell properties
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.size_flags_vertical = Control.SIZE_EXPAND_FILL
		cell.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT
		cell.ignore_texture_size = true
		cell.texture_normal = cell_texture
		cell.modulate = Color.WHITE
		cell.set_meta(PAINTED_META, false)
		
		grid.add_child(cell)

## Get the cell at the given grid position
func _get_cell_at_pos(x: int, y: int) -> TextureButton:
	if x < 0 or x >= _grid_width or y < 0 or y >= _grid_height:
		return null

	var cell_index: int = y * _grid_width + x
	if cell_index >= grid.get_child_count():
		return null

	return grid.get_child(cell_index) as TextureButton

## Get the cell under the mouse position
func _get_cell_at_mouse_pos(mouse_pos: Vector2) -> TextureButton:
	# Find the cell by position
	for y in range(_grid_height):
		for x in range(_grid_width):
			var cell: TextureButton = _get_cell_at_pos(x, y)
			if cell and cell.get_global_rect().has_point(mouse_pos):
				return cell
	return null

## Returns colour of the cell at given x,y pos
func get_cell_colour(x: int, y: int) -> Color:
	var cell: TextureButton = _get_cell_at_pos(x, y)
	if cell and cell.get_meta(PAINTED_META, false):
		return cell.modulate

	return Color.TRANSPARENT

## Returns grid width
func get_width() -> int:
	return _grid_width

## Returns grid height
func get_height() -> int:
	return _grid_height
