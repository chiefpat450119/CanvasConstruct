extends Control

const GRID_SIZE : int = 16
const CELL_SIZE : int = 16
var active_colour : Color = Color(1,0,0)
var is_painting : bool = false

@export var grid : GridContainer
@export var cell_texture : Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_generate_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Start painting
	if Input.is_action_pressed("M1"):
		is_painting = true
		
		var cell_under_mouse : TextureButton = get_cell_at_mouse_pos(get_viewport().get_mouse_position())
		# Check if there is a cell under the mouse and if cell already painted with active colour
		if cell_under_mouse and !cell_under_mouse.modulate.is_equal_approx(active_colour):
			cell_under_mouse.modulate = active_colour
	
	# Stop painting
	if Input.is_action_just_released("M1"):
		is_painting = false

## Generate grid of cells
func _generate_grid() -> void:
	grid.columns = GRID_SIZE
	
	for i in range(GRID_SIZE * GRID_SIZE):
		var cell = TextureButton.new()
		
		# Default grid cell properties
		cell.custom_minimum_size = Vector2(CELL_SIZE, CELL_SIZE)
		cell.stretch_mode = TextureButton.STRETCH_SCALE
		cell.ignore_texture_size = true
		cell.texture_normal = cell_texture
		cell.modulate = Color.WHITE
		
		grid.add_child(cell)

## Get the cell under the mouse position
func get_cell_at_mouse_pos(mouse_pos: Vector2) -> TextureButton:
	# Find the cell by position
	var grid_buttons = grid.get_children()
	for i in range(grid_buttons.size()):
		var cell = grid_buttons[i]
		var cell_pos = cell.global_position
		var cell_size = cell.custom_minimum_size
		if cell_pos.x <= mouse_pos.x and mouse_pos.x <= cell_pos.x + cell_size.x and cell_pos.y <= mouse_pos.y and mouse_pos.y <= cell_pos.y + cell_size.y:
			return cell
	return null
