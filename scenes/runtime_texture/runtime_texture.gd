class_name RuntimeTexture
extends Node

var _img: Image
var _texture: ImageTexture
var _width: int
var _height: int
var visible_pixels: Array[Vector2i]

@export var sprite2d: Sprite2D

func init_from_image(image: Image):
	_img = image
	_texture = ImageTexture.create_from_image(_img)
	_width = image.get_width()
	_height = image.get_height()
	sprite2d.texture = _texture

func init(w: int, h: int):
	_img = Image.create(w, h, false, Image.FORMAT_RGBAF)
	_texture = ImageTexture.create_from_image(_img)
	_width = w
	_height = h
	sprite2d.texture = _texture

func set_pixel(x: int, y: int, color: Color):
	var point := Vector2i(x, y)
	_img.set_pixelv(point, color)
	_texture.update(_img)
	_update_visible_pixels([point], color)

func set_pixels(points: Array[Vector2i], color: Color):
	for p in points:
		_img.set_pixelv(p, color)
	_texture.update(_img)
	_update_visible_pixels(points, color)

func get_pixel(x: int, y: int) -> Color:
	return _img.get_pixel(x, y)

func _update_visible_pixels(points: Array[Vector2i], color: Color) -> void:
	if color.a == 0.0:
		for point in points:
			visible_pixels.erase(point)
	else:
		for point in points:
			if not visible_pixels.has(point):
				visible_pixels.append(point)

func get_width() -> int:
	return _width

func get_height() -> int:
	return _height
