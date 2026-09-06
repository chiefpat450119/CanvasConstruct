class_name PlayerPart
extends RefCounted


var reference_part: PartResource
var drawing: RuntimeTexture


func _init(resource: PartResource, texture: RuntimeTexture) -> void:
	assert(resource != null, "A player part requires a PartResource.")
	assert(texture != null, "A player part requires a RuntimeTexture.")
	reference_part = resource
	drawing = texture
