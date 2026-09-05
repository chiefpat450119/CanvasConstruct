class_name RuntimeTexture
extends Node

var _img: Image
var _texture: ImageTexture

# num of visible pixels
var visible_pixels: int

@export var sprite2d: Sprite2D

func init(w: int, h: int):
	_img = Image.create(w, h, false, Image.FORMAT_RGBAF)
	_texture = ImageTexture.create_from_image(_img)
	sprite2d.texture = _texture

func set_pixel(x: int, y: int, color: Color):
	_img.set_pixel(x, y, color)
	_texture.update(_img)
	visible_pixels += 1

func set_pixels(points: Array[Vector2i], color: Color):
	for p in points:
		_img.set_pixelv(p, color)
	_texture.update(_img)
	visible_pixels += points.size()

func get_pixel(x: int, y: int) -> Color:
	return _img.get_pixel(x, y)
