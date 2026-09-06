class_name GridLines
extends GridContainer

@export var cell_texture : Texture2D

## Create grid lines from given width and height
func init(width: int, height: int) -> void:
	# Clear previous grid lines
	for child: Node in get_children():
		child.free()
	
	columns = width
	
	for _index: int in range(width * height):
		var cell := TextureButton.new()
		
		# Default grid cell properties
		cell.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		cell.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell.size_flags_vertical = Control.SIZE_EXPAND_FILL
		cell.ignore_texture_size = true
		cell.texture_normal = cell_texture
		cell.modulate = Color(1.0, 1.0, 1.0, 1.0)
		
		add_child(cell)
