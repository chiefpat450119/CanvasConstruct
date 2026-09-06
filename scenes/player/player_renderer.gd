class_name PlayerRenderer
extends Node2D

@export var torso: RuntimeTexture
@export var head: RuntimeTexture
@export var atk: RuntimeTexture
@export var def: RuntimeTexture

func init(t: Image, h: Image, a: Image, d: Image):
	torso.init_from_image(t)
	head.init_from_image(h)
	atk.init_from_image(a)
	def.init_from_image(d)
