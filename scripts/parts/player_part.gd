class_name PlayerPart
extends RefCounted


var reference_part: PartResource
var drawing: Image


func _init(resource: PartResource, texture: Image) -> void:
	assert(resource != null, "A player part requires a PartResource.")
	assert(texture != null, "A player part requires a Image.")
	reference_part = resource
	drawing = texture


func get_similarity() -> float:
	if (
		not is_instance_valid(drawing)
		or reference_part == null
		or reference_part.reference_image == null
	):
		return 0.0

	return clampf(
		TextureCompare.compare(drawing, reference_part.reference_image),
		0.0,
		1.0
	)


func get_stat_multiplier() -> float:
	var similarity := get_similarity()
	if reference_part is HeadResource:
		return 2.0 - similarity
	return similarity
