class_name DrawingSystem
extends Control

@export var drawing_grid : DrawingGrid
@export var reference_art : TextureRect

func _ready() -> void:
	init_drawing_UI()

## Returns image created from player drawing
func get_image_from_drawing() -> Image:
	var height : int = drawing_grid.get_width()
	var width : int = drawing_grid.get_height()
	var img : Image = Image.create(width, height, false, Image.FORMAT_RGBAF)

	# Iterate through all pixels of player's drawing and copy over to texture
	for x in range(drawing_grid.get_width()):
		for y in range(drawing_grid.get_height()):
			var cell_colour : Color = drawing_grid.get_cell_colour(x,y)
			img.set_pixel(x, y, cell_colour)
	
	return img

## Formats UI with drawing grid that matches reference art
func init_drawing_UI():
	drawing_grid.init(reference_art.texture.get_width(), reference_art.texture.get_height())
