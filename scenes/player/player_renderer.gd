class_name PlayerRenderer
extends Node2D

@export var torso: RuntimeTexture
@export var head: RuntimeTexture
@export var atk: RuntimeTexture
@export var def: RuntimeTexture

@export_group("For testing: pls remove")
@export var example_t: TorsoResource
@export var example_h: HeadResource
@export var example_a: AtkResource
@export var example_d: DefResource

func init(t: Image, h: Image, a: Image, d: Image):
	torso.init_from_image(t)
	head.init_from_image(h)
	atk.init_from_image(a)
	def.init_from_image(d)

func _ready():
	if example_t == null:
		return

	init(example_t.reference_image.get_image(), example_h.reference_image.get_image(), example_a.reference_image.get_image(), example_d.reference_image.get_image())
