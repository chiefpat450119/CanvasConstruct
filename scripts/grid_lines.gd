class_name GridLines
extends Control

const LINE_WIDTH_RATIO: float = 0.12

var _grid_width: int = 0
var _grid_height: int = 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


## Configure the number of reference-image cells drawn by the overlay.
func init(width: int, height: int) -> void:
	_grid_width = width
	_grid_height = height
	queue_redraw()


func _draw() -> void:
	if _grid_width <= 0 or _grid_height <= 0 or size.x <= 0.0 or size.y <= 0.0:
		return

	var cell_size := Vector2(size.x / _grid_width, size.y / _grid_height)
	var line_width := maxf(1.0, roundf(minf(cell_size.x, cell_size.y) * LINE_WIDTH_RATIO))
	var half_line_width := line_width * 0.5

	for column: int in range(_grid_width + 1):
		var x := roundf(cell_size.x * column)
		if column == 0:
			x = half_line_width
		elif column == _grid_width:
			x = size.x - half_line_width
		draw_line(Vector2(x, 0.0), Vector2(x, size.y), Color.BLACK, line_width, false)

	for row: int in range(_grid_height + 1):
		var y := roundf(cell_size.y * row)
		if row == 0:
			y = half_line_width
		elif row == _grid_height:
			y = size.y - half_line_width
		draw_line(Vector2(0.0, y), Vector2(size.x, y), Color.BLACK, line_width, false)
