class_name PlayerPart
extends RefCounted


var reference_part: PartResource
var drawing: Image


func _init(resource: PartResource, texture: Image) -> void:
	assert(resource != null, "A player part requires a PartResource.")
	assert(texture != null, "A player part requires a Image.")
	reference_part = resource
	drawing = texture
