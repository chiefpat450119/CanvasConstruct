class_name DamagableComponent
extends Node

const _NEIGHBOR_OFFSETS: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1),
]

@export var visuals: RuntimeTexture

# dmg should be a percentage (0 - 1)
# of how much percentage of total texture is destroyed
func damage(dmg: float) -> void:
	if visuals == null or visuals.visible_pixels.is_empty():
		return

	var remove_pixels := roundi(clampf(dmg, 0.0, 1.0) * visuals.get_width() * visuals.get_height())
	if remove_pixels == 0:
		return

	var edge_indices := _get_edge_indices(visuals.visible_pixels)
	var random_index: int = edge_indices.pick_random()
	var selected_pixels := _select_indices(
		visuals.visible_pixels, random_index, remove_pixels
	)
	visuals.set_pixels(selected_pixels, Color.TRANSPARENT)


func _get_edge_indices(pixels: Array[Vector2i]) -> Array[int]:
	var edge_indices: Array[int] = []
	var available: Dictionary = {}
	for pixel in pixels:
		available[pixel] = true

	for index in pixels.size():
		var pixel := pixels[index]
		for offset in _NEIGHBOR_OFFSETS:
			if not available.has(pixel + offset):
				edge_indices.append(index)
				break

	return edge_indices


func _select_indices(pixels: Array[Vector2i], start: int, amount: int) -> Array[Vector2i]:
	var selected: Array[Vector2i] = []
	if pixels.is_empty() or amount <= 0:
		return selected

	# A dictionary provides constant-time neighbor checks and prevents a pixel from
	# being selected more than once if the source array contains duplicates.
	var available: Dictionary = {}
	for pixel in pixels:
		available[pixel] = true

	var target_amount := mini(amount, available.size())
	var start_pos := pixels[clampi(start, 0, pixels.size() - 1)]
	var frontier: Array[Vector2i] = [start_pos]
	var visited: Dictionary = {}
	visited[start_pos] = true

	while selected.size() < target_amount:
		# Damage may have divided the remaining pixels into separate components. If
		# this component is exhausted, continue from the closest remaining pixel.
		if frontier.is_empty():
			var closest_pixel := Vector2i.ZERO
			var closest_distance := 0
			var found_pixel := false

			for pixel in pixels:
				if visited.has(pixel):
					continue

				var distance := start_pos.distance_squared_to(pixel)
				if not found_pixel or distance < closest_distance:
					closest_pixel = pixel
					closest_distance = distance
					found_pixel = true

			if not found_pixel:
				break

			visited[closest_pixel] = true
			frontier.append(closest_pixel)

		# Growing from a random edge pixel avoids the uniform distance rings that
		# produce a diamond-shaped chunk while keeping the damage connected.
		var random_frontier_index := randi_range(0, frontier.size() - 1)
		var current_pixel := frontier[random_frontier_index]
		frontier[random_frontier_index] = frontier.back()
		frontier.pop_back()
		selected.append(current_pixel)

		for offset in _NEIGHBOR_OFFSETS:
			var neighbor := current_pixel + offset
			if available.has(neighbor) and not visited.has(neighbor):
				visited[neighbor] = true
				frontier.append(neighbor)

	return selected
