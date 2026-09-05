class_name DrawingSystem
extends Control

@export var drawing_grid : DrawingGrid


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
