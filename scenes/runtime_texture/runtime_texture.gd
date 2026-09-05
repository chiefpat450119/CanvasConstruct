class_name RuntimeTexture
extends Node

var img: Image
var texture: ImageTexture

@export var sprite2d: Sprite2D

func init(w: int, h: int):
	img = Image.create(w, h, false, Image.FORMAT_RGBAF)
	texture = ImageTexture.create_from_image(img)
	sprite2d.texture = texture

func set_pixel(x: int, y: int, color: Color):
	img.set_pixel(x, y, color)
	texture.update(img)

func set_pixels(points: Array[Vector2i], color: Color):
	for p in points:
		img.set_pixelv(p, color)

func get_pixel(x: int, y: int) -> Color:
	return img.get_pixel(x, y)
